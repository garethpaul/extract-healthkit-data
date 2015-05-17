//
//  ViewController.swift
//  ExtractHealthKit
//
//  Created by Gareth on 5/17/15.
//  Copyright (c) 2015 GarethPaul. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    var steps = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        askingForPermission()
    }
    
    func askingForPermission(){
        
        // this step ensure the device has the Health app. iPad doesn't have it
        let healthStore: HKHealthStore? = {
            if HKHealthStore.isHealthDataAvailable(){
                println("booyeah! we have HKHealthStore")
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
        
        //we can read and write the data that is made available to us by the users
        //however choose wisely what data we want from the user, requesting too many might be intimidating
        let dataToWrite = NSSet(object: stepCount)
        let dataToRead = NSSet(object: stepCount)
        
        healthStore?.requestAuthorizationToShareTypes(dataToWrite as Set<NSObject>, readTypes: dataToRead as Set<NSObject>, completion: { (success, error) -> Void in
            
            if success {
                println("Successfully request authorization from user")
                
                self.readDataFromHealthStore(healthStore!)
            }
            else{
                println("Unsuccessful. \(error.description)")
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
        //to read the data, you can just use a query
        let sortDescriptor = [NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)]
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: intervalComponents)
        
        
        query.initialResultsHandler = {
            query, results, error in

            if error != nil {
                // Perform proper error handling here
                println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
                abort()
            }
            
            let endDate = NSDate()
            let startDate = calendar.dateByAddingUnit(NSCalendarUnit.MonthCalendarUnit, value: -1, toDate: endDate, options: nil)
            
            
            results.enumerateStatisticsFromDate(startDate, toDate: endDate) {
                statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let d = NSDate()
                    let s = dateFormatter.stringFromDate(date)

                    let value = quantity.doubleValueForUnit(HKUnit.countUnit())
                    println(s)
                    println(value)
                }
            }
            
        }
        

        
        
        //query.in
                //REMEMBER TO EXECUTE!!
        theHealthStore.executeQuery(query)
    }
    
    
}
