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
    var json = [AnyObject]()
    for item in steps {
        json.append(["date": item.date, "value": item.value])
    }
    return json
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!

    var tableData:[Steps] = []
    var outData:[Steps] = []
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
    
    func sortArray() {
        tableData = outData.reverse()
        dispatch_async(dispatch_get_main_queue(), {
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
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: intervalComponents)
        
        query.initialResultsHandler = {
            query, results, error in

            if error != nil {
                // Perform proper error handling here
                println("HealthKit statistics query failed.")
                return
            }
            
            let endDate = NSDate()
            let startDate = calendar.dateByAddingUnit(.CalendarUnitMonth, value: -1, toDate: endDate, options: nil)
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
                    self.outData.append(Steps(date: s, value: val))
                }
                
                self.sortArray()
            }
            
        }

        theHealthStore.executeQuery(query)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        
        var exportAlert = UIAlertController(title: "Export Data", message: "Step-count data from the last 30 days will be exported to the configured HTTPS endpoint.", preferredStyle: UIAlertControllerStyle.Alert)
        
        exportAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            // Ok

            if self.outData.isEmpty {
                println("No HealthKit step data available to export.")
                return
            }

            let json = exportPayload(self.outData)

            // Construct HTTP Request
            if !postRequest(json) {
                println("HealthKit export endpoint is not configured.")
            }
            
        }))
        
        exportAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            // Cancel
        }))
        
        // Export Alert
        presentViewController(exportAlert, animated: true, completion: nil)
        
    }
    
}
