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
}
