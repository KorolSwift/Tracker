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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
                name: categoryEntity.name ?? "",
                trackers: []
            )
        }
        delegate?.didUpdateCategories(categories)
    }
    
    var fetchedCategories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.map {
            TrackerCategory(name: $0.name ?? "", trackers: [])
        }
    }
    
    func addCategory(name: String, trackers: [CardCoreData]) throws {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "name == %@", name)
        if let existing = try? context.fetch(req), !existing.isEmpty {
            return
        }
        let category = TrackerCategoryCoreData(context: context)
        category.name = name
        category.trackers = NSSet(array: trackers)
        try context.save()
    }
    
    func deleteCategory(_ name: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        if let results = try? context.fetch(fetchRequest) {
            for category in results {
                context.delete(category)
            }
            try? context.save()
        }
    }
}
