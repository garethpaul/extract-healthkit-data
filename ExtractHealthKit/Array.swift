//
//  Array.swift
//  ExtractHealthKit
//
//  Created by Gareth on 5/17/15.
//  Copyright (c) 2015 GarethPaul. All rights reserved.
//

import Foundation

func sortArray(tableData) {
    tableData = outData.reverse()
    dispatch_async(dispatch_get_main_queue(), {
        self.tableView.reloadData()
        return
    })
}