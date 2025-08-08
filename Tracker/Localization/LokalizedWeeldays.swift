//
//  LokalizedWeeldays.swift
//  Tracker
//
//  Created by Ди Di on 08/08/25.
//

import CoreData


enum Localized {
    enum Weekday {
        static let monday = NSLocalizedString("monday", comment: "")
        static let tuesday = NSLocalizedString("tuesday", comment: "")
        static let wednesday = NSLocalizedString("wednesday", comment: "")
        static let thursday = NSLocalizedString("thursday", comment: "")
        static let friday = NSLocalizedString("friday", comment: "")
        static let saturday = NSLocalizedString("saturday", comment: "")
        static let sunday = NSLocalizedString("sunday", comment: "")

        static let mondayShort = NSLocalizedString("monday_short", comment: "")
        static let tuesdayShort = NSLocalizedString("tuesday_short", comment: "")
        static let wednesdayShort = NSLocalizedString("wednesday_short", comment: "")
        static let thursdayShort = NSLocalizedString("thursday_short", comment: "")
        static let fridayShort = NSLocalizedString("friday_short", comment: "")
        static let saturdayShort = NSLocalizedString("saturday_short", comment: "")
        static let sundayShort = NSLocalizedString("sunday_short", comment: "")

        static func shortName(for full: String) -> String {
            switch full {
            case monday: return mondayShort
            case tuesday: return tuesdayShort
            case wednesday: return wednesdayShort
            case thursday: return thursdayShort
            case friday: return fridayShort
            case saturday: return saturdayShort
            case sunday: return sundayShort
            default: return full
            }
        }
    }
}
