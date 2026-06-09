//
//  API.swift
//  ExtractHealthKit
//
//  Created by Gareth on 5/17/15.
//  Copyright (c) 2015 GarethPaul. All rights reserved.
//

import Foundation
import Alamofire

let HealthKitExportEndpointKey = "HealthKitExportEndpoint"

func exportEndpointURL() -> NSURL? {
    let endpoint = NSBundle.mainBundle().objectForInfoDictionaryKey(HealthKitExportEndpointKey) as? String
    let trimmedEndpoint = endpoint?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

    if let configuredEndpoint = trimmedEndpoint {
        if !configuredEndpoint.isEmpty {
            let url = NSURL(string: configuredEndpoint)
            if url?.scheme == "https" && url?.user == nil && url?.password == nil {
                if let host = url?.host {
                    if !host.isEmpty {
                        return url
                    }
                }
            }
        }
    }

    return nil
}

func postRequest(payload: AnyObject) -> Bool {

    if let url = exportEndpointURL() {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var error: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: &error)
        if error != nil || body == nil {
            return false
        }
        request.HTTPBody = body
        Alamofire.request(request)
        return true
    }

    return false
}
