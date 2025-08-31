import SwiftUI
import CoreData

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var feedViewModel: FeedViewModel
    
    init() {
        // Initialize with empty context, will be updated in onAppear
        self._feedViewModel = StateObject(wrappedValue: FeedViewModel(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Stories Section
                    StoriesSection(context: viewContext)
                    
                    // Posts Section
                    if feedViewModel.posts.isEmpty && !feedViewModel.isLoading {
                        EmptyPostsView()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(feedViewModel.posts, id: \.objectID) { post in
                                PostCard(post: post, onLike: {
                                    feedViewModel.likePost(post)
                                })
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("For you")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus.square")
                            .font(.title2)
                    }
                }
            }
        }
        .onAppear {
            // Update context when view appears
            feedViewModel.context = viewContext
            
            // Small delay to ensure Core Data is fully initialized
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Load data with new context
                feedViewModel.loadPosts()
            }
        }
    }
    
    private func refreshData() async {
        feedViewModel.refreshPosts()
    }
}

struct EmptyPostsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Posts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Follow some accounts to see posts in your feed")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 32)
    }
}

#Preview {
    FeedView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
