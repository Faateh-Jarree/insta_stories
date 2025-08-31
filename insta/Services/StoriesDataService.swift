import Foundation
import CoreData

class StoriesDataService: ObservableObject {
    static let shared = StoriesDataService()
    
    private init() {}
    
    struct UsersResponse: Codable {
        let pages: [Page]
    }
    
    struct Page: Codable {
        let users: [UserData]
    }
    
    struct UserData: Codable {
        let id: Int
        let name: String
        let profile_picture_url: String
    }
    
    private let storyContents = [
        "Just had the most amazing coffee! ☕️",
        "Beautiful sunset tonight 🌅",
        "Weekend vibes are here! 🎉",
        "Working on something exciting 💻",
        "Perfect weather for a walk 🚶‍♂️",
        "New book arrived today 📚",
        "Cooking up a storm in the kitchen 👨‍🍳",
        "Music session with friends 🎵",
        "Exploring the city today 🏙️",
        "Game night with family 🎮",
        "Morning workout complete 💪",
        "Art project in progress 🎨",
        "Pet cuddles are the best 🐕",
        "Garden looking beautiful today 🌸",
        "Movie night with popcorn 🍿",
        "Road trip adventures 🚗",
        "Beach day was perfect 🏖️",
        "New recipe success! 👨‍🍳",
        "Photography session 📸",
        "Yoga session complete 🧘‍♀️"
    ]
    
    private let storyImages = [
        "https://picsum.photos/400/600?random=1",
        "https://picsum.photos/400/600?random=2",
        "https://picsum.photos/400/600?random=3",
        "https://picsum.photos/400/600?random=4",
        "https://picsum.photos/400/600?random=5",
        "https://picsum.photos/400/600?random=6",
        "https://picsum.photos/400/600?random=7",
        "https://picsum.photos/400/600?random=8",
        "https://picsum.photos/400/600?random=9",
        "https://picsum.photos/400/600?random=10",
        "https://picsum.photos/400/600?random=11",
        "https://picsum.photos/400/600?random=12",
        "https://picsum.photos/400/600?random=13",
        "https://picsum.photos/400/600?random=14",
        "https://picsum.photos/400/600?random=15",
        "https://picsum.photos/400/600?random=16",
        "https://picsum.photos/400/600?random=17",
        "https://picsum.photos/400/600?random=18",
        "https://picsum.photos/400/600?random=19",
        "https://picsum.photos/400/600?random=20"
    ]
    
    func loadUsersFromJSON() -> [UserData] {
        guard let url = Bundle.main.url(forResource: "users", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(UsersResponse.self, from: data) else {
            return []
        }
        
        return response.pages.flatMap { $0.users }
    }
    
    func generateStoriesForUser(_ user: User, context: NSManagedObjectContext) {
        let storyCount = Int.random(in: 5...8)
        
        for i in 0..<storyCount {
            let story = Story(context: context)
            story.id = UUID()
            story.content = storyContents.randomElement() ?? "Amazing day! ✨"
            story.mediaURL = storyImages.randomElement() ?? "https://picsum.photos/400/600?random=\(Int.random(in: 1...100))"
            story.mediaType = "image"
            story.timestamp = Date().addingTimeInterval(-Double(i * 1800))
            story.duration = Double.random(in: 3.0...8.0)
            story.author = user
            story.isViewed = false
            story.isLiked = false
        }
    }
    
    func generateAllStories(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Story.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to clear existing stories: \(error)")
        }
        
        let userData = loadUsersFromJSON()
        
        for userData in userData {
            let user = User(context: context)
            user.id = UUID()
            user.username = userData.name.lowercased().replacingOccurrences(of: " ", with: "_")
            user.fullName = userData.name
            user.profileImageURL = userData.profile_picture_url
            user.bio = "Living life to the fullest ✨"
            user.followers = Int32.random(in: 100...10000)
            user.following = Int32.random(in: 50...500)
            user.posts = 0
            
            generateStoriesForUser(user, context: context)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save stories: \(error)")
        }
    }
    
    func loadMoreStories(context: NSManagedObjectContext, currentCount: Int, pageSize: Int = 20) -> [Story] {
        let request: NSFetchRequest<Story> = Story.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Story.timestamp, ascending: false)]
        request.fetchLimit = pageSize
        request.fetchOffset = currentCount
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to load more stories: \(error)")
            return []
        }
    }
}
