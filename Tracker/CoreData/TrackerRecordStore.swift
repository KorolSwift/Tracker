//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ди Di on 14/06/25.
//

import Foundation
import CoreData


final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: StoreDelegateProtocol?
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let controller = NSFetchedResultsController<TrackerRecordCoreData>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let fetchedResultsController = controller as? NSFetchedResultsController<TrackerRecordCoreData>,
            let entities = fetchedResultsController.fetchedObjects
        else {
            delegate?.didUpdateRecords([])
            return
        }
        let records = entities.compactMap { entity -> TrackerRecord? in
            guard let id = entity.trackerId,
                  let date = entity.date
            else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
        delegate?.didUpdateRecords(records)
    }
    
    func add(_ record: TrackerRecord) {
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerId = record.trackerId
        entity.date = record.date
        try? context.save()
    }
    
    func delete(_ record: TrackerRecord) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as NSDate
        )
        if let object = try? context.fetch(request).first {
            context.delete(object)
            try? context.save()
        }
    }
    
    func fetchAllRecords() -> [TrackerRecord] {
        guard let entities = fetchedResultsController.fetchedObjects else { return [] }
        return entities.compactMap { entity in
            guard let id = entity.trackerId,
                  let date = entity.date
            else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
    }
}
