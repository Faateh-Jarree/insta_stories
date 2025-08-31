import SwiftUI
import CoreData

struct StoriesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: StoriesViewModel
    @State private var selectedStory: Story?
    @State private var showingStoryViewer = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StoriesViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Stories List
                storiesList
            }
            .navigationBarHidden(true)
            .onAppear {
                if viewModel.stories.isEmpty {
                    viewModel.generateSampleStories()
                }
            }
        }
        .sheet(isPresented: $showingStoryViewer) {
            if let story = selectedStory {
                StoryViewer(story: story, viewModel: viewModel)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Stories")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                viewModel.refreshStories()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
    }
    
    private var storiesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.stories, id: \.objectID) { story in
                    StoryRowView(story: story, viewModel: viewModel) {
                        selectedStory = story
                        showingStoryViewer = true
                        viewModel.markStoryAsViewed(story)
                    }
                }
                
                // Load more indicator
                if viewModel.hasMoreStories {
                    loadMoreButton
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .refreshable {
            viewModel.refreshStories()
        }
    }
    
    private var loadMoreButton: some View {
        Button(action: {
            viewModel.loadMoreStories()
        }) {
            HStack {
                Text("Load More Stories")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Image(systemName: "arrow.down")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
    }
}

struct StoryRowView: View {
    let story: Story
    let viewModel: StoriesViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Profile Image with Story Ring
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: story.isViewed ? [Color.gray] : [Color.purple, Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 60, height: 60)
                    
                    AsyncImage(url: URL(string: story.author?.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray4))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                }
                
                // Story Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(story.author?.fullName ?? "Unknown")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(timeAgoString(from: story.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(story.content ?? "Story content")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Like Button
                Button(action: {
                    viewModel.toggleStoryLike(story)
                }) {
                    Image(systemName: story.isLiked ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(story.isLiked ? .red : .primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgoString(from date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    StoriesListView(context: PersistenceController.preview.container.viewContext)
}
