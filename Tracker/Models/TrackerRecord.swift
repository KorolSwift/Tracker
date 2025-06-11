//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Ди Di on 26/05/25.
//

import UIKit


struct TrackerRecord: Hashable, Codable {
    let trackerId: UUID
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
    }
    
    static func ==(lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.trackerId == rhs.trackerId && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}

extension Date {
    func stripTimeComponent() -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: comps) ?? self
    }
}
