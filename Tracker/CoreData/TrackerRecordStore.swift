//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ди Di on 14/06/25.
//

import CoreData
import UIKit


final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: StoreDelegateProtocol?
    private let context: NSManagedObjectContext
    static let shared = TrackerRecordStore(
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
            print("Ошибка при performFetch() в TrackerRecordStore: \(error.localizedDescription)")
        }
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при performFetch() в init TrackerRecordStore: \(error.localizedDescription)")
        }
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
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении TrackerRecord: \(error.localizedDescription)")
        }
    }
    
    func delete(_ record: TrackerRecord) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as NSDate
        )
        do {
            if let object = try context.fetch(request).first {
                context.delete(object)
                try context.save()
            }
        } catch {
            print("Ошибка при удалении TrackerRecord: \(error.localizedDescription)")
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
    
    func getAllRecords() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0.toTrackerRecord() }
        } catch {
            print("Ошибка получения записей: \(error.localizedDescription)")
            return []
        }
    }
}

