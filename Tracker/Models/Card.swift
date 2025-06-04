//
//  Card.swift
//  Tracker
//
//  Created by Ди Di on 03/06/25.
//

import UIKit


struct Card: Codable {
    let id: UUID
    let emoji: String
    let description: String
    let colorName: String
    let selectedDays: [String]
    var originalSectionTitle: String
    var isPinned: Bool
    var color: UIColor {
        return UIColor(named: colorName) ?? .purple
    }
    
    init(id: UUID = .init(), emoji: String, description: String, colorName: String, selectedDays: [String], originalSectionTitle: String, isPinned: Bool = false) {
        self.id = id
        self.emoji = emoji
        self.description = description
        self.colorName = colorName
        self.selectedDays = selectedDays
        self.originalSectionTitle = originalSectionTitle
        self.isPinned = isPinned
    }
}
