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
        
        //to read the data, you can just use a query
        let sortDescriptor = [NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)]
        let queryStepsCount = HKSampleQuery(sampleType: stepsCount, predicate: nil, limit: 500, sortDescriptors: sortDescriptor) { (query, results, error) -> Void in
            
            if let results = results as? [HKQuantitySample]{
                
                self.steps = results
                for result in results {
                    println(result.startDate)
                }
                
            }
        }
        //REMEMBER TO EXECUTE!!
        theHealthStore.executeQuery(queryStepsCount)
    }
    
    
}
