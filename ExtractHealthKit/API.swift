//
//  API.swift
//  ExtractHealthKit
//
//  Created by Gareth on 5/17/15.
//  Copyright (c) 2015 GarethPaul. All rights reserved.
//

import Foundation
import Alamofire

func postRequest(payload: AnyObject){
    
    // Send HTTP request to URL
    let url = NSURL(string: "https://requestlabs.appspot.com/api/steps")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    var error: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: &error)
    Alamofire.request(request)

}