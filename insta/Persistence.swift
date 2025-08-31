//
//  Persistence.swift
//  insta
//
//  Created by Faateh Jarree on 31.08.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Generate sample data for preview
        SampleDataService.shared.generateSampleData(context: viewContext)
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "insta")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Generate sample data if this is the first launch (after stores are loaded)
        generateSampleDataIfNeeded()
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private func generateSampleDataIfNeeded() {
        DispatchQueue.main.async {
            let context = self.container.viewContext
            let userRequest: NSFetchRequest<User> = User.fetchRequest()
            if let userCount = try? context.count(for: userRequest), userCount == 0 {
                StoriesDataService.shared.generateAllStories(context: context)
            }
        }
    }
}
