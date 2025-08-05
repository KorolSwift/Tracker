//
//  StatisticsModel.swift
//  Tracker
//
//  Created by Ди Di on 05/08/25.
//

import Foundation


struct StatisticsModel {
    static func compute(records: [TrackerRecord]) -> [(title: String, value: Int)] {
        guard !records.isEmpty else { return [] }
        let calendar = Calendar.current
        var dailyCounts = [Date:Int]()
        for rec in records {
            let day = calendar.startOfDay(for: rec.date)
            dailyCounts[day, default: 0] += 1
        }
        let total = records.count
        return [
            (NSLocalizedString("completed_trackers", comment: ""), total)
        ]
    }
}
