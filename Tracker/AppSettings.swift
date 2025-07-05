//
//  AppSettings.swift
//  Tracker
//
//  Created by Ди Di on 04/07/25.
//

import Foundation


final class AppSettings {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    static var hasSeenOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
}
