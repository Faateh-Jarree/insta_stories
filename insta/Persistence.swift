import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
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
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
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
