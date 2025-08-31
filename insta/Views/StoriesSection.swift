import SwiftUI
import CoreData

struct StoriesSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: StoriesViewModel
    @State private var selectedStory: Story?
    @State private var showingStoryViewer = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StoriesViewModel(context: context))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Stories Header
            HStack {
                Text("Stories")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshStories()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Horizontal Stories Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    // Add Story Button
                    AddStoryButton()
                    
                    // Story Circles with pagination
                    ForEach(Array(viewModel.stories.enumerated()), id: \.element.objectID) { index, story in
                        StoryCircle(story: story, viewModel: viewModel) {
                            selectedStory = story
                            showingStoryViewer = true
                            viewModel.markStoryAsViewed(story)
                        }
                        .onAppear {
                            // Load more stories when approaching the end
                            if index >= viewModel.stories.count - 5 {
                                viewModel.loadMoreStories()
                            }
                        }
                    }
                    
                    // Loading indicator at the end
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            if viewModel.stories.isEmpty {
                viewModel.generateSampleStories()
            }
        }
        .sheet(isPresented: $showingStoryViewer) {
            if let story = selectedStory {
                StoryViewer(story: story, viewModel: viewModel)
            }
        }
    }
}

struct AddStoryButton: View {
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Text("Add")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

struct StoryCircle: View {
    let story: Story
    let viewModel: StoriesViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Story Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: story.isViewed ? [Color.gray] : [Color.purple, Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 64, height: 64)
                    
                    // Profile Image
                    AsyncImage(url: URL(string: story.author?.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray4))
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    
                    // Like indicator
                    if story.isLiked {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .frame(width: 64, height: 64)
                    }
                }
                
                Text(story.author?.username ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    StoriesSection(context: PersistenceController.preview.container.viewContext)
}
