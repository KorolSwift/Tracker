//
//  Card.swift
//  Tracker
//
//  Created by Ди Di on 03/06/25.
//

import UIKit


struct Card {
    let id: UUID
    let emoji: String
    let description: String
    let colorIndex: Int
    let selectedDays: [String]
    var originalSectionTitle: String
    var isPinned: Bool
    let category: TrackerCategory?
    var color: UIColor {
        return CardCreationViewController.colors[colorIndex]
    }
    
    init(id: UUID = .init(),
         emoji: String,
         description: String,
         colorIndex: Int,
         selectedDays: [String],
         originalSectionTitle: String,
         isPinned: Bool = false,
         category: TrackerCategory? = nil) {
        self.id = id
        self.emoji = emoji
        self.description = description
        self.colorIndex = colorIndex
        self.selectedDays = selectedDays
        self.originalSectionTitle = originalSectionTitle
        self.isPinned = isPinned
        self.category = category
    }
}
