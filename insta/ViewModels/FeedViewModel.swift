import Foundation
import CoreData
import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadPosts() {
        guard context.persistentStoreCoordinator != nil else {
            errorMessage = "Core Data context not ready"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Post.timestamp, ascending: false)]
        
        do {
            posts = try context.fetch(request)
            isLoading = false
        } catch {
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func likePost(_ post: Post) {
        guard context.persistentStoreCoordinator != nil else {
            errorMessage = "Core Data context not ready"
            return
        }
        
        post.isLiked.toggle()
        post.likes += post.isLiked ? 1 : -1
        
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to update like: \(error.localizedDescription)"
        }
    }
    
    func refreshPosts() {
        loadPosts()
    }
}
