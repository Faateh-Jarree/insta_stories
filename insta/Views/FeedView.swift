import SwiftUI
import CoreData

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var feedViewModel: FeedViewModel
    
    init() {
        self._feedViewModel = StateObject(wrappedValue: FeedViewModel(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    StoriesSection(context: viewContext)
                    
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
            feedViewModel.context = viewContext
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
