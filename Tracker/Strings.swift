//
//  Strings.swift
//  Tracker
//
//  Created by Ди Di on 10/06/25.
//

import Foundation


enum Constants {
    enum Schedule {
        static let scheduleTitle = NSLocalizedString("schedule", comment: "")
    }
    enum Category {
        static let categoryTitle = NSLocalizedString("category", comment: "")
    }
    
    enum CardCreation {
        static var errorLabel = NSLocalizedString("character_limit", comment: "")
        static var titleLabel = NSLocalizedString("new_habit_title", comment: "")
        static var descriptionTextView = NSLocalizedString("enter_tracker_name_ph", comment: "")
        static var categoryButtonTitle = NSLocalizedString("category", comment: "")
        static var scheduleButtonTitle = NSLocalizedString("schedule", comment: "")
        static var saveButtonTitle = NSLocalizedString("create_button", comment: "")
        static var cancelButtonTitle = NSLocalizedString("cancel_button", comment: "")
        static var didTapClearTitle = NSLocalizedString("enter_tracker_name_ph", comment: "")
        static var trackerCreationTitle = NSLocalizedString("creation_tracker_title", comment: "")
        static var irregularEventButtonTitle = NSLocalizedString("irregular_event_button", comment: "")
        static var habitButtonTitle = NSLocalizedString("habit_button", comment: "")
        static var addCategoryButtonTitle = NSLocalizedString("add_category_button", comment: "")
    }
}
