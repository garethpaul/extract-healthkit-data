//
//  ViewController.swift
//  ExtractHealthKit
//
//  Created by Gareth on 5/17/15.
//  Copyright (c) 2015 GarethPaul. All rights reserved.
//

import UIKit
import HealthKit

func exportPayload(steps: [Steps]) -> [AnyObject] {
    var rows = [(String, String)]()
    for item in steps {
        rows.append((item.date, item.value))
    }

    var json = [AnyObject]()
    for row in healthKitExportRows(rows) {
        json.append(["date": row.0, "value": row.1])
    }
    return json
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!

    var tableData:[Steps] = []
    var outData:[Steps] = []
    var exportInFlight = false
    var logoView: UIImageView!
    
    let basicCellIdentifier = "BasicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        var nib = UINib(nibName: "BasicCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: basicCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        readHealthKitData()
    }
    
    func setupNav() {
        // SetupNav
        logoView = UIImageView(frame: CGRectMake(0, 0, 40, 40))
        logoView.image = UIImage(named: "logo")?.imageWithRenderingMode(.AlwaysTemplate)
        logoView.tintColor = toColor("D0021B")
        logoView.frame.origin.x = (self.view.frame.size.width - logoView.frame.size.width) / 2
        logoView.frame.origin.y = 20
        // Add the logo view to the navigation controller.
        self.navigationController?.view.addSubview(logoView)
        
        // Bring the logo view to the front.
        self.navigationController?.view.bringSubviewToFront(logoView)
        
        // Customize the navigation bar.
        self.navigationController?.navigationBar.barTintColor = toColor("EDEDED")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    func publishHealthKitData(data: [Steps]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.outData = data
            self.tableData = data.reverse()
            self.tableView.reloadData()
            return
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as! BasicCell
        let row = indexPath.row
        let rowData:Steps = tableData[row]
        cell.dateText?.text = rowData.date
        cell.valueText?.text = rowData.value
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Row was selected
    }
    
    func readHealthKitData(){
        
        // this step ensure the device has the Health app. iPad doesn't have it
        let healthStore: HKHealthStore? = {
            if HKHealthStore.isHealthDataAvailable(){
                return HKHealthStore()
            }
            else{
                println("No HKHealthStore available")
                return nil
            }
            }()
        
        //HKQuantityType - basically a standardized method represent an amount of a specific unit
        //the sample code below can be used to get any of the HKQuantiyType
        let stepCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Request only the data this sample reads.
        let dataToRead = NSSet(object: stepCount)
        
        healthStore?.requestAuthorizationToShareTypes(nil, readTypes: dataToRead as Set<NSObject>, completion: { (success, error) -> Void in
            
            if success {
                println("Successfully request authorization from user")
                
                if let store = healthStore {
                    self.readDataFromHealthStore(store)
                }
            }
            else{
                println("HealthKit authorization was not granted.")
            }
        })
        
    }
    
    func readDataFromHealthStore(theHealthStore: HKHealthStore){
        
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let calendar = NSCalendar.currentCalendar()
        let interval = NSDateComponents()
        interval.day = 7
        
        // Set the anchor date to Monday at 3:00 a.m.
        let anchorComponents =
        calendar.components(.CalendarUnitDay | .CalendarUnitMonth |
            .CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
        let offset = (7 + anchorComponents.weekday - 2) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 3
        let anchorDate = calendar.dateFromComponents(anchorComponents)
        let intervalComponents = NSDateComponents()
        intervalComponents.day = 1
        let endDate = NSDate()
        let startDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: -HealthKitExportLookbackDays, toDate: endDate, options: nil)
        let samplePredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .StrictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount, quantitySamplePredicate: samplePredicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: intervalComponents)
        
        query.initialResultsHandler = {
            query, results, error in

            if error != nil {
                // Perform proper error handling here
                println("HealthKit statistics query failed.")
                return
            }
            
            var queryData:[Steps] = []
            results.enumerateStatisticsFromDate(startDate, toDate: endDate) {
                statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let d = NSDate()
                    let s = dateFormatter.stringFromDate(date)
                    let value = Int(round(quantity.doubleValueForUnit(HKUnit.countUnit())))
                    let val = "\(value)"
                    queryData.append(Steps(date: s, value: val))
                }
                
            }

            self.publishHealthKitData(queryData)
            
        }

        theHealthStore.executeQuery(query)
    }
    
    @IBAction func exportData(sender: AnyObject) {

        if exportInFlight {
            println("HealthKit export is already in progress.")
            return
        }
        
        var exportAlert = UIAlertController(title: "Export Data", message: "Step-count data from the last 30 days will be exported to the configured HTTPS endpoint.", preferredStyle: UIAlertControllerStyle.Alert)
        
        exportAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            // Ok

            if self.outData.isEmpty {
                println("No HealthKit step data available to export.")
                return
            }

            let json = exportPayload(self.outData)
            if json.isEmpty {
                println("No valid HealthKit step data available to export.")
                return
            }

            // Construct HTTP Request
            self.exportInFlight = true
            if !postRequest(json, completion: { succeeded in
                self.exportInFlight = false
                if succeeded {
                    println("HealthKit export completed.")
                }
                else {
                    println("HealthKit export failed.")
                }
            }) {
                self.exportInFlight = false
                println("HealthKit export request was not queued.")
            }
            
        }))
        
        exportAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            // Cancel
        }))
        
        // Export Alert
        presentViewController(exportAlert, animated: true, completion: nil)
        
    }
    
}
