import Foundation

let HealthKitExportLookbackDays = 30

let healthKitValidExportField: (String) -> String? = { value in
#if EXECUTABLE_POLICY_TESTS
    let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
#else
    let trimmedValue = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
#endif
    if trimmedValue.isEmpty {
        return nil
    }
    return trimmedValue
}

let healthKitExportRows: ([(String, String)]) -> [(String, String)] = { rows in
#if EXECUTABLE_POLICY_TESTS
    let newestFirst = Array(rows.reversed())
#else
    let newestFirst = rows.reverse()
#endif
    var selected = [(String, String)]()
    var inspectedRows = 0

    for row in newestFirst {
        if inspectedRows >= HealthKitExportLookbackDays {
            break
        }
        inspectedRows += 1
        if let date = healthKitValidExportField(row.0) {
            if let value = healthKitValidExportField(row.1) {
                selected.append((date, value))
            }
        }
    }

#if EXECUTABLE_POLICY_TESTS
    return Array(selected.reversed())
#else
    return selected.reverse()
#endif
}
