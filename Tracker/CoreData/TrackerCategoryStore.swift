//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Ди Di on 14/06/25.
//

import CoreData


final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: StoreDelegateProtocol?
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController<TrackerCategoryCoreData>(
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
        guard let objects = fetchedResultsController.fetchedObjects else {
            delegate?.didUpdateCategories([])
            return
        }
        let categories = objects.map { categoryEntity in
            TrackerCategory(
                title: categoryEntity.title ?? "",
                trackers: []
            )
        }
        delegate?.didUpdateCategories(categories)
    }
}
