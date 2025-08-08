//
//  TrackerStore.swift
//  Tracker
//
//  Created by Ди Di on 14/06/25.
//

import CoreData
import UIKit


final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: StoreDelegateProtocol?
    private let context: NSManagedObjectContext
    static let shared = TrackerStore(
            context: (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
                ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        )
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
        do {
            try controller.performFetch()
        } catch {
            print("Ошибка performFetch() в TrackerStore: \(error.localizedDescription)")
        }
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
    
    func getAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0.toTracker() }
        } catch {
            print("Ошибка получения трекеров: \(error.localizedDescription)")
            return []
        }
    }
}

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = self.id,
              let name = self.name,
              let emoji = self.emoji,
              let colour = self.colour,
              let schedule = self.schedule else {
            return nil
        }
        
        return Tracker(
            id: id,
            name: name,
            colour: colour,
            emoji: emoji,
            schedule: schedule
        )
    }
}
