//
//  AppDelegate.swift
//  Tracker
//
//  Created by Ди Di on 22/05/25.
//

import UIKit
import CoreData


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure(error.localizedDescription)
            }
        })
        return container
    }()
    
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
}
