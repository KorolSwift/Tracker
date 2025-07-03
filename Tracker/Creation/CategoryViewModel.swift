//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Ди Di on 30/06/25.
//

import Foundation


final class TrackerCategoryViewModel {
    private let store: TrackerCategoryStore
    
    var categories: [TrackerCategory] = [] {
        didSet {
            onUpdate?(categories)
        }
    }
    
    var onUpdate: (([TrackerCategory]) -> Void)?
    
    init(store: TrackerCategoryStore) {
        self.store = store
        self.store.delegate = self
        fetchCategories()
    }
    
    func fetchCategories() {
        categories = store.fetchedCategories
    }
    
    func addCategory(_ name: String) {
        do {
            try store.addCategory(name: name, trackers: [])
        } catch {
            print("Ошибка добавления категории: \(error)")
        }
    }
    
    func deleteCategory(_ name: String) {
        store.deleteCategory(name)
        fetchCategories()
    }
}

extension TrackerCategoryViewModel: StoreDelegateProtocol {
    func didUpdate() {}
    
    func didUpdateRecords(_ records: [TrackerRecord]) {}
    
    func didUpdateCategories(_ categories: [TrackerCategory]) {
        self.categories = categories
        onUpdate?(categories)
    }
}

