//
//  CardStore.swift
//  Tracker
//
//  Created by Ди Di on 16/06/25.
//

import CoreData
import UIKit


final class CardStore {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addCard(_ card: Card) {
        let check: NSFetchRequest<CardCoreData> = CardCoreData.fetchRequest()
        check.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
        if let existing = try? context.fetch(check), !existing.isEmpty {
            return
        }
        let entity = CardCoreData(context: context)
        entity.id = card.id
        entity.emoji = card.emoji
        entity.descriptionText = card.description
        entity.colorIndex = Int32(card.colorIndex)
        entity.selectedDays = card.selectedDays as NSArray
        entity.originalSectionTitle = card.originalSectionTitle
        entity.isPinned = card.isPinned
        try? context.save()
    }
    
    func fetchCards() -> [Card] {
        let request: NSFetchRequest<CardCoreData> = CardCoreData.fetchRequest()
        do {
            let result = try context.fetch(request)
            return result.compactMap { entity in
                guard
                    let id = entity.id,
                    let emoji = entity.emoji,
                    let description = entity.descriptionText,
                    let selectedDays = entity.selectedDays as? [String],
                    let sectionTitle = entity.originalSectionTitle
                else {
                    return nil
                }
                let isPinned = entity.isPinned
                
                return Card(
                    id: id,
                    emoji: emoji,
                    description: description,
                    colorIndex: Int(entity.colorIndex),
                    selectedDays: selectedDays,
                    originalSectionTitle: sectionTitle,
                    isPinned: isPinned
                )
            }
        } catch {
            print("Ошибка загрузки карточек: \(error)")
            return []
        }
    }
    
    func save(_ card: Card) {
        let request: NSFetchRequest<CardCoreData> = CardCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
        do {
            if let existing = try context.fetch(request).first {
                existing.emoji = card.emoji
                existing.descriptionText = card.description
                existing.colorIndex = Int32(card.colorIndex)
                existing.selectedDays = card.selectedDays as NSObject
                existing.originalSectionTitle = card.originalSectionTitle
                existing.isPinned = card.isPinned
            } else {
                let entity = CardCoreData(context: context)
                entity.id = card.id
                entity.emoji = card.emoji
                entity.descriptionText = card.description
                entity.colorIndex = Int32(card.colorIndex)
                entity.selectedDays = card.selectedDays as NSObject
                entity.originalSectionTitle = card.originalSectionTitle
                entity.isPinned = card.isPinned
            }
            try context.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    
    func delete(_ card: Card) {
        let request: NSFetchRequest<CardCoreData> = CardCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
        do {
            let objects = try context.fetch(request)
            for obj in objects {
                context.delete(obj)
            }
            try context.save()
        } catch {
            print("Ошибка удаления карточки: \(error)")
        }
    }
    
    func update(_ card: Card) {
        let request: NSFetchRequest<CardCoreData> = CardCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.emoji = card.emoji
                entity.descriptionText = card.description
                entity.colorIndex = Int32(card.colorIndex)
                entity.selectedDays = card.selectedDays as NSArray
                entity.originalSectionTitle = card.originalSectionTitle
                entity.isPinned = card.isPinned
                
                try context.save()
            }
        } catch {
            print("Ошибка обновления карточки: \(error)")
        }
    }
}
