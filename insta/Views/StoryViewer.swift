import SwiftUI
import CoreData

struct StoryViewer: View {
    let story: Story
    @ObservedObject var viewModel: StoriesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var currentStoryIndex = 0
    @State private var currentUserStories: [Story] = []
    @State private var showingUserProfile = false
    @State private var progressValue: Double = 0.0
    @State private var autoAdvanceTimer: Timer?
    @State private var dragOffset = CGSize.zero
    @State private var transitionDirection: TransitionDirection = .none
    @State private var shouldDismiss = false
    @State private var currentUserIndex = 0
    
    private let storyDuration: TimeInterval = 5.0
    private let progressUpdateInterval: TimeInterval = 0.05 // More frequent updates for smoother animation
    
    enum TransitionDirection {
        case none, left, right
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                // Story Content with Cube Transition - Should be interactive
                Group {
                    if let currentStory = getCurrentStory() {
                        StoryContentView(
                            story: currentStory,
                            viewModel: viewModel,
                            progressValue: progressValue,
                            totalStories: currentUserStories.count,
                            currentIndex: currentStoryIndex,
                            onLike: {
                                print("StoryViewer onLike called for story: \(currentStory.id?.uuidString ?? "unknown")")
                                viewModel.toggleStoryLike(currentStory)
                            },
                            onUserTap: {
                                showingUserProfile = true
                            },
                            onNext: {
                                nextStory()
                            },
                            onPrevious: {
                                previousStory()
                            },
                            onDismiss: {
                                shouldDismiss = true
                            }
                        )
                        .id(currentStory.id) // Important: uniquely identify the current story
                        .transition(.asymmetric(
                            insertion: .move(edge: transitionDirection == .left ? .trailing : .leading),
                            removal: .move(edge: transitionDirection == .left ? .leading : .trailing)
                        ))
                        .animation(.easeInOut(duration: 0.3), value: currentStory.id) // Animate on story change
                    }
                }
            }
        }
        .onAppear {
            setupStories()
            startAutoAdvance()
        }
        .onDisappear {
            stopAutoAdvance()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                startAutoAdvance()
            } else {
                stopAutoAdvance()
            }
        }
        .sheet(isPresented: $showingUserProfile) {
            if let user = getCurrentStory()?.author {
                UserProfileView(user: user)
            }
        }
        .onChange(of: shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .onChange(of: viewModel.stories) { _, newValue in
            print("Stories updated in StoryViewer, count: \(newValue.count)")
        }
    }
    
    private func setupStories() {
        // Get all stories from the same user
        if let author = story.author {
            currentUserStories = viewModel.stories.filter { $0.author?.id == author.id }
            currentStoryIndex = currentUserStories.firstIndex(of: story) ?? 0
            
            // Find the current user's index in the overall stories array
            if let currentStory = getCurrentStory(),
               let index = viewModel.stories.firstIndex(of: currentStory) {
                currentUserIndex = index
            }
        }
    }
    
    private func getCurrentStory() -> Story? {
        guard currentUserStories.count > 0 else { return nil }
        return currentUserStories[currentStoryIndex]
    }
    
    private func startAutoAdvance() {
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: progressUpdateInterval, repeats: true) { _ in
            withAnimation(.linear(duration: progressUpdateInterval)) {
                progressValue = min(progressValue + progressUpdateInterval / storyDuration, 1.0)
            }
            
            if progressValue >= 1.0 {
                nextStory()
            }
        }
    }
    
    private func stopAutoAdvance() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
        print("Auto-advance timer stopped")
    }
    
    private func restartAutoAdvance() {
        stopAutoAdvance()
        startAutoAdvance()
        print("Auto-advance timer restarted")
    }
    
    private func nextStory() {
        print("nextStory called - current index: \(currentStoryIndex), total stories: \(currentUserStories.count)")
        if currentStoryIndex < currentUserStories.count - 1 {
            // Next story of same user
            print("Moving to next story of same user")
            transitionDirection = .left
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStoryIndex += 1
                progressValue = 0.0
            }
        } else {
            // Move to next user
            print("Moving to next user")
            nextUser()
        }
    }
    
    private func previousStory() {
        print("previousStory called - current index: \(currentStoryIndex), total stories: \(currentUserStories.count)")
        if currentStoryIndex > 0 {
            // Previous story of same user
            print("Moving to previous story of same user")
            transitionDirection = .right
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStoryIndex -= 1
                progressValue = 0.0
            }
        } else {
            // Move to previous user
            print("Moving to previous user")
            previousUser()
        }
    }
    
    private func nextUser() {
        print("nextUser called - current user index: \(currentUserIndex), total stories in ViewModel: \(viewModel.stories.count)")
        // Find the next user with stories
        var nextUserIndex = currentUserIndex + 1
        while nextUserIndex < viewModel.stories.count {
            let nextStory = viewModel.stories[nextUserIndex]
            if let nextAuthor = nextStory.author {
                // Check if this user has stories
                let userStories = viewModel.stories.filter { $0.author?.id == nextAuthor.id }
                if !userStories.isEmpty {
                    // Found next user with stories, update current state
                    print("Found next user with stories: \(nextAuthor.fullName ?? "unknown")")
                    currentUserStories = userStories
                    currentStoryIndex = 0
                    currentUserIndex = nextUserIndex
                    progressValue = 0.0
                    restartAutoAdvance() // Restart timer for new user
                    return
                }
            }
            nextUserIndex += 1
        }
        
        // No more users with stories, dismiss
        print("No more users with stories, dismissing")
        shouldDismiss = true
    }
    
    private func previousUser() {
        print("previousUser called - current user index: \(currentUserIndex), total stories in ViewModel: \(viewModel.stories.count)")
        // Find the previous user with stories
        var prevUserIndex = currentUserIndex - 1
        while prevUserIndex >= 0 {
            let prevStory = viewModel.stories[prevUserIndex]
            if let prevAuthor = prevStory.author {
                // Check if this user has stories
                let userStories = viewModel.stories.filter { $0.author?.id == prevAuthor.id }
                if !userStories.isEmpty {
                    // Found previous user with stories, update current state
                    print("Found previous user with stories: \(prevAuthor.fullName ?? "unknown")")
                    currentUserStories = userStories
                    currentStoryIndex = userStories.count - 1
                    currentUserIndex = prevUserIndex
                    progressValue = 0.0
                    restartAutoAdvance() // Restart timer for new user
                    return
                }
            }
            prevUserIndex -= 1
        }
        
        // No more users with stories, dismiss
        print("No more previous users with stories, dismissing")
        shouldDismiss = true
    }
    

}

struct StoryContentView: View {
    let story: Story
    @ObservedObject var viewModel: StoriesViewModel
    let progressValue: Double
    let totalStories: Int
    let currentIndex: Int
    let onLike: () -> Void
    let onUserTap: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var localLikeState: Bool = false
    
    private var updatedStory: Story? {
        viewModel.stories.first { $0.id == story.id }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Tap Navigation Zones in Background (left/right thirds)
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("Tapped left area")
                            onPrevious()
                        }

                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("Tapped right area")
                            onNext()
                        }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .allowsHitTesting(true)

                // Main Story UI Content
                VStack(spacing: 0) {
                    storyHeader
                        .zIndex(20)
                    
                    storyImage
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(15)
                    
                    storyControls
                        .zIndex(25) // Ensure buttons are above tap zones
                }
                .zIndex(50) // All UI elements above tap zone
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -30 {
                            onNext()
                        } else if value.translation.width > 30 {
                            onPrevious()
                        } else if value.translation.height > 100 {
                            onDismiss()
                        }
                    }
            )
        }
        .onAppear {
            localLikeState = story.isLiked
        }
        .onChange(of: viewModel.stories) { _, newValue in
            if let updated = newValue.first(where: { $0.id == story.id }) {
                localLikeState = updated.isLiked
            }
        }
    }
    
    private var storyHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(0..<totalStories, id: \.self) { index in
                    ProgressView(value: getProgressForStory(index))
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            HStack {
                Button(action: onUserTap) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: story.author?.profileImageURL ?? "")) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle().fill(Color(.systemGray4))
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(story.author?.fullName ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(timeAgoString(from: story.timestamp))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var storyImage: some View {
        AsyncImage(url: URL(string: story.mediaURL ?? "")) { image in
            image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
            VStack {
                ProgressView().scaleEffect(1.5).tint(.white)
                Text("Loading story...").foregroundColor(.white).padding(.top)
            }
        }
        .onAppear {
            if let url = URL(string: story.mediaURL ?? "") {
                URLSession.shared.dataTask(with: url).resume()
            }
        }
        .allowsHitTesting(false)
        .zIndex(15)
    }
    
    private var storyControls: some View {
        HStack(spacing: 20) {
            Button(action: {
                onLike()
                localLikeState.toggle()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: localLikeState ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundColor(localLikeState ? .red : .white)
                        .scaleEffect(localLikeState ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: localLikeState)
                    
                    Text(localLikeState ? "Liked" : "Like")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                // Reply action
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "message")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Reply").font(.caption).foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                // Share action
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "paperplane")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Share").font(.caption).foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .zIndex(20)
    }
    
    private func getProgressForStory(_ index: Int) -> Double {
        if index < currentIndex {
            return 1.0
        } else if index == currentIndex {
            return min(max(progressValue, 0.0), 1.0)
        } else {
            return 0.0
        }
    }
    
    private func timeAgoString(from date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

struct UserProfileView: View {
    let user: User?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = user {
                    // Profile Image
                    AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray4))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    // User Info
                    VStack(spacing: 8) {
                        Text(user.fullName ?? "Unknown")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("@\(user.username ?? "unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let bio = user.bio {
                            Text(bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(user.posts)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Posts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(user.followers)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(user.following)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TapNavigationOverlay: View {
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: geometry.size.width / 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Left side tapped")
                        onPrevious()
                    }
                
                Color.clear
                    .frame(width: geometry.size.width / 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Right side tapped")
                        onNext()
                    }
            }
            .frame(height: geometry.size.height)
        }
        .allowsHitTesting(true)
    }
}


#Preview {
    StoryViewer(
        story: Story(),
        viewModel: StoriesViewModel(context: PersistenceController.preview.container.viewContext)
    )
}
