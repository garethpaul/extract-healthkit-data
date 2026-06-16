import Foundation

private var failureCount = 0

private func expect(_ actual: [(String, String)], _ expected: [(String, String)], _ message: String) {
    if actual.count != expected.count {
        failureCount += 1
        print("FAIL: \(message): expected \(expected.count) rows, got \(actual.count)")
        return
    }

    for index in 0..<actual.count {
        if actual[index].0 != expected[index].0 || actual[index].1 != expected[index].1 {
            failureCount += 1
            print("FAIL: \(message): row \(index) differed")
            return
        }
    }
}

private func syntheticRows(_ count: Int) -> [(String, String)] {
    var rows = [(String, String)]()
    for index in 0..<count {
        rows.append((String(format: "day-%02d", index), String(index)))
    }
    return rows
}

expect(healthKitExportRows([]), [], "empty input")
expect(healthKitExportRows(syntheticRows(3)), syntheticRows(3), "short input")
expect(healthKitExportRows(syntheticRows(30)), syntheticRows(30), "exact lookback window")
expect(healthKitExportRows(syntheticRows(31)), Array(syntheticRows(31)[1...30]), "newest 30 rows")
expect(healthKitExportRows([("  day  ", "  12  ")]), [("day", "12")], "field trimming")
expect(healthKitExportRows([("", "1"), ("day", ""), ("valid", "2")]), [("valid", "2")], "invalid field filtering")

var noBackfill = syntheticRows(31)
noBackfill[30] = ("day-30", "   ")
expect(healthKitExportRows(noBackfill), Array(syntheticRows(30)[1...29]), "invalid newest row does not backfill old data")

if failureCount > 0 {
    exit(1)
}

print("HealthKitExportPolicy behavioral tests passed")
