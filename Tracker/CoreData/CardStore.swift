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
        let entity = CardCoreData(context: context)
        entity.id = card.id
        entity.emoji = card.emoji
        entity.descriptionText = card.description
        entity.colorIndex = Int32(card.colorIndex)
        entity.selectedDays = card.selectedDays as NSObject
        entity.originalSectionTitle = card.originalSectionTitle
        entity.isPinned = card.isPinned
        
        if let category = card.category {
            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", category.name)
            
            if let existingCategory = try? context.fetch(request).first {
                entity.category = existingCategory
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.name = category.name
                entity.category = newCategory
            }
        }
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }
    
    func fetchCards() -> [Card] {
        let request: NSFetchRequest<CardCoreData> = CardCoreData.fetchRequest()
        do {
            let result = try context.fetch(request)
            return result.compactMap { entity in
                guard
                    let id = entity.id,
                    let emoji = entity.emoji,
                    let description = entity.descriptionText
                else {
                    return nil
                }
                let selectedDays = entity.selectedDays as? [String] ?? []
                let originalSectionTitle = entity.originalSectionTitle ?? ""
                let isPinned = entity.isPinned
                
                let category: TrackerCategory? = {
                    if let categoryEntity = entity.category,
                       let name = categoryEntity.name {
                        return TrackerCategory(name: name, trackers: [])
                    }
                    return nil
                }()
                
                return Card(
                    id: id,
                    emoji: emoji,
                    description: description,
                    colorIndex: Int(entity.colorIndex),
                    selectedDays: selectedDays,
                    originalSectionTitle: originalSectionTitle,
                    isPinned: isPinned,
                    category: category
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
                
                if let category = card.category {
                    let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                    categoryRequest.predicate = NSPredicate(format: "name == %@", category.name)
                    
                    let categories = try context.fetch(categoryRequest)
                    if let categoryEntity = categories.first {
                        existing.category = categoryEntity
                    }
                }
            } else {
                addCard(card)
                return
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
                
                if let category = card.category {
                    let fetchCategory: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                    fetchCategory.predicate = NSPredicate(format: "name == %@", category.name)
                    
                    let categories = try context.fetch(fetchCategory)
                    if let found = categories.first {
                        entity.category = found
                    }
                }
                try context.save()
            }
        } catch {
            print("Ошибка обновления карточки: \(error)")
        }
    }
}
