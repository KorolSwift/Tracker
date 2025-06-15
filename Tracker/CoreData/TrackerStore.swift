//
//  TrackerStore.swift
//  Tracker
//
//  Created by Ди Di on 14/06/25.
//

import CoreData


final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
