//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Ди Di on 30/06/25.
//


final class CategoryListViewModel {
    private let store: TrackerCategoryStore
    var onCategoriesUpdated: (() -> Void)?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    init(store: TrackerCategoryStore) {
        self.store = store
        self.store.delegate = self
        fetchCategories()
    }
    
    func fetchCategories() {}
    
    func numberOfRows() -> Int {
        return categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    func didSelectCategory(at index: Int) {
        print("Selected category: \(categories[index].name)")
    }
}

extension CategoryListViewModel: StoreDelegateProtocol {
    func didUpdate() {}
    
    func didUpdateRecords(_ records: [TrackerRecord]) {}
    
    func didUpdateCategories(_ categories: [TrackerCategory]) {
        self.categories = categories
    }
}
