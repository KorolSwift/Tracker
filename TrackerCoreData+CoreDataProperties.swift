//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Ди Di on 01/08/25.
//

import Foundation
import CoreData


extension TrackerCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
    
    @NSManaged public var colour: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: String?
    @NSManaged public var selectedDays: NSObject?
    @NSManaged public var originalSectionTitle: String?
    @NSManaged public var isPinned: Bool
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var records: NSSet?
    
}

extension TrackerCoreData {
    
    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordCoreData)
    
    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordCoreData)
    
    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)
    
    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)
}
