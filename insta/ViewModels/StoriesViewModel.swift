import Foundation
import CoreData
import SwiftUI

@MainActor
class StoriesViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreStories = true
    
    private let pageSize = 20
    private var currentPage = 0
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadStories() {
        guard context.persistentStoreCoordinator != nil else {
            errorMessage = "Core Data context not ready"
            return
        }
        
        isLoading = true
        errorMessage = nil
        currentPage = 0
        
        // Load initial stories
        let initialStories = StoriesDataService.shared.loadMoreStories(
            context: context,
            currentCount: 0,
            pageSize: pageSize
        )
        
        stories = initialStories
        hasMoreStories = initialStories.count == pageSize
        isLoading = false
    }
    
    func loadMoreStories() {
        guard !isLoading && hasMoreStories else { return }
        
        isLoading = true
        currentPage += 1
        
        let moreStories = StoriesDataService.shared.loadMoreStories(
            context: context,
            currentCount: stories.count,
            pageSize: pageSize
        )
        
        stories.append(contentsOf: moreStories)
        hasMoreStories = moreStories.count == pageSize
        isLoading = false
    }
    
    func markStoryAsViewed(_ story: Story) {
        guard context.persistentStoreCoordinator != nil else {
            errorMessage = "Core Data context not ready"
            return
        }
        
        story.isViewed = true
        
        do {
            try context.save()
            // Force UI update by triggering objectWillChange
            objectWillChange.send()
        } catch {
            errorMessage = "Failed to mark story as viewed: \(error.localizedDescription)"
        }
    }
    
    func toggleStoryLike(_ story: Story) {
        guard context.persistentStoreCoordinator != nil else {
            errorMessage = "Core Data context not ready"
            return
        }
        
        print("Toggling like for story: \(story.id?.uuidString ?? "unknown")")
        print("Current like state: \(story.isLiked)")
        
        // Toggle the like state
        story.isLiked.toggle()
        
        print("New like state: \(story.isLiked)")
        
        do {
            try context.save()
            print("Context saved successfully")
            
            // Force UI update by triggering objectWillChange
            objectWillChange.send()
            
            // Also update the stories array to trigger UI refresh
            if let index = stories.firstIndex(of: story) {
                stories[index] = story
                print("Updated story in array at index: \(index)")
            }
            
            // Force a UI refresh
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
        } catch {
            errorMessage = "Failed to toggle story like: \(error.localizedDescription)"
            print("Failed to save context: \(error)")
            // Revert the change if save failed
            story.isLiked.toggle()
        }
    }
    
    func refreshStories() {
        loadStories()
    }
    
    func generateSampleStories() {
        StoriesDataService.shared.generateAllStories(context: context)
        loadStories()
    }
    
    // Helper method to get stories for a specific user
    func getStoriesForUser(_ user: User) -> [Story] {
        return stories.filter { $0.author?.id == user.id }
    }
    
    // Helper method to get next story in sequence
    func getNextStory(after currentStory: Story) -> Story? {
        guard let currentIndex = stories.firstIndex(of: currentStory) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < stories.count ? stories[nextIndex] : nil
    }
    
    // Helper method to get previous story in sequence
    func getPreviousStory(before currentStory: Story) -> Story? {
        guard let currentIndex = stories.firstIndex(of: currentStory) else { return nil }
        let prevIndex = currentIndex - 1
        return prevIndex >= 0 ? stories[prevIndex] : nil
    }
}
