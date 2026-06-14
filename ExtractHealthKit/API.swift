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
let HealthKitExportTimeout: NSTimeInterval = 30
let HealthKitExportMaxPayloadBytes = 64 * 1024
let HealthKitExportManager: Alamofire.Manager = {
    let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
    let manager = Alamofire.Manager(configuration: configuration)
    manager.delegate.taskWillPerformHTTPRedirection = { _, _, _, _ in
        return nil
    }
    return manager
}()

func exportEndpointURL() -> NSURL? {
    let endpoint = NSBundle.mainBundle().objectForInfoDictionaryKey(HealthKitExportEndpointKey) as? String
    let trimmedEndpoint = endpoint?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

    if let configuredEndpoint = trimmedEndpoint {
        if !configuredEndpoint.isEmpty {
            let url = NSURL(string: configuredEndpoint)
            if url?.scheme == "https" &&
                url?.user == nil &&
                url?.password == nil &&
                url?.query == nil &&
                url?.fragment == nil {
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
        request.HTTPShouldHandleCookies = false
        request.timeoutInterval = HealthKitExportTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        if !NSJSONSerialization.isValidJSONObject(payload) {
            return false
        }
        var error: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: &error)
        if error != nil || body == nil {
            return false
        }
        if let encodedBody = body {
            if encodedBody.length > HealthKitExportMaxPayloadBytes {
                return false
            }
            request.HTTPBody = encodedBody
        }
        HealthKitExportManager.request(request)
        return true
    }

    return false
}
