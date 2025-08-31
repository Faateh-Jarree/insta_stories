import Foundation
import CoreData

class SampleDataService {
    static let shared = SampleDataService()
    
    private init() {}
    
    func generateSampleData(context: NSManagedObjectContext) {
        let user1 = User(context: context)
        user1.id = UUID()
        user1.username = "john_doe"
        user1.fullName = "John Doe"
        user1.profileImageURL = "https://picsum.photos/200/200?random=1"
        user1.bio = "Photography enthusiast 📸"
        user1.followers = 0
        user1.following = 0
        user1.posts = 0
        
        let user2 = User(context: context)
        user2.id = UUID()
        user2.username = "jane_smith"
        user2.fullName = "Jane Smith"
        user2.profileImageURL = "https://picsum.photos/200/200?random=2"
        user2.bio = "Travel lover ✈️"
        user2.followers = 0
        user2.following = 0
        user2.posts = 0
        
        let user3 = User(context: context)
        user3.id = UUID()
        user3.username = "mike_wilson"
        user3.fullName = "Mike Wilson"
        user3.profileImageURL = "https://picsum.photos/200/200?random=3"
        user3.bio = "Food blogger 🍕"
        user3.followers = 0
        user3.following = 0
        user3.posts = 0
        
        let post1 = Post(context: context)
        post1.id = UUID()
        post1.caption = "Beautiful sunset at the beach today! 🌅 #sunset #beach #photography"
        post1.imageURL = "https://picsum.photos/400/400?random=10"
        post1.likes = 0
        post1.comments = 0
        post1.timestamp = Date()
        post1.author = user1
        post1.isLiked = false
        
        let post2 = Post(context: context)
        post2.id = UUID()
        post2.caption = "Exploring the mountains this weekend 🏔️ #adventure #nature #hiking"
        post2.imageURL = "https://picsum.photos/400/400?random=11"
        post2.likes = 0
        post2.comments = 0
        post2.timestamp = Date()
        post2.author = user2
        post2.isLiked = false
        
        let post3 = Post(context: context)
        post3.id = UUID()
        post3.caption = "Delicious homemade pizza! 🍕 #food #cooking #homemade"
        post3.imageURL = "https://picsum.photos/400/400?random=12"
        post3.likes = 0
        post3.comments = 0
        post3.timestamp = Date()
        post3.author = user3
        post3.isLiked = false
        
        let post4 = Post(context: context)
        post4.id = UUID()
        post4.caption = "City lights at night ✨ #city #night #photography"
        post4.imageURL = "https://picsum.photos/400/400?random=13"
        post4.likes = 0
        post4.comments = 0
        post4.timestamp = Date()
        post4.author = user1
        post4.isLiked = false
        
        let story1 = Story(context: context)
        story1.id = UUID()
        story1.mediaURL = "https://picsum.photos/300/400?random=20"
        story1.mediaType = "image"
        story1.timestamp = Date()
        story1.duration = 5.0
        story1.author = user1
        story1.isViewed = false
        
        let story2 = Story(context: context)
        story2.id = UUID()
        story2.mediaURL = "https://picsum.photos/300/400?random=21"
        story2.mediaType = "image"
        story2.timestamp = Date()
        story2.duration = 5.0
        story2.author = user2
        story2.isViewed = false
        
        let story3 = Story(context: context)
        story3.id = UUID()
        story3.mediaURL = "https://picsum.photos/300/400?random=22"
        story3.mediaType = "image"
        story3.timestamp = Date()
        story3.duration = 5.0
        story3.author = user3
        story3.isViewed = false
        
        user1.posts = 2
        user2.posts = 1
        user3.posts = 1
        
        do {
            try context.save()
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
}
