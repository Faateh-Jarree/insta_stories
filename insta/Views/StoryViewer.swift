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
    private let progressUpdateInterval: TimeInterval = 0.05
    
    enum TransitionDirection {
        case none, left, right
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                Group {
                    if let currentStory = getCurrentStory() {
                        StoryContentView(
                            story: currentStory,
                            viewModel: viewModel,
                            progressValue: progressValue,
                            totalStories: currentUserStories.count,
                            currentIndex: currentStoryIndex,
                            onLike: {
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
                        .id(currentStory.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: transitionDirection == .left ? .trailing : .leading),
                            removal: .move(edge: transitionDirection == .left ? .leading : .trailing)
                        ))
                        .animation(.easeInOut(duration: 0.3), value: currentStory.id)
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
    }
    
    private func setupStories() {
        if let author = story.author {
            currentUserStories = viewModel.stories.filter { $0.author?.id == author.id }
            currentStoryIndex = currentUserStories.firstIndex(of: story) ?? 0
            
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
    }
    
    private func restartAutoAdvance() {
        stopAutoAdvance()
        startAutoAdvance()
    }
    
    private func nextStory() {
        if currentStoryIndex < currentUserStories.count - 1 {
            transitionDirection = .left
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStoryIndex += 1
                progressValue = 0.0
            }
        } else {
            nextUser()
        }
    }
    
    private func previousStory() {
        if currentStoryIndex > 0 {
            transitionDirection = .right
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStoryIndex -= 1
                progressValue = 0.0
            }
        } else {
            previousUser()
        }
    }
    
    private func nextUser() {
        var nextUserIndex = currentUserIndex + 1
        while nextUserIndex < viewModel.stories.count {
            let nextStory = viewModel.stories[nextUserIndex]
            if let nextAuthor = nextStory.author {
                let userStories = viewModel.stories.filter { $0.author?.id == nextAuthor.id }
                if !userStories.isEmpty {
                    currentUserStories = userStories
                    currentStoryIndex = 0
                    currentUserIndex = nextUserIndex
                    progressValue = 0.0
                    restartAutoAdvance()
                    return
                }
            }
            nextUserIndex += 1
        }
        
        shouldDismiss = true
    }
    
    private func previousUser() {
        var prevUserIndex = currentUserIndex - 1
        while prevUserIndex >= 0 {
            let prevStory = viewModel.stories[prevUserIndex]
            if let prevAuthor = prevStory.author {
                let userStories = viewModel.stories.filter { $0.author?.id == prevAuthor.id }
                if !userStories.isEmpty {
                    currentUserStories = userStories
                    currentStoryIndex = userStories.count - 1
                    currentUserIndex = prevUserIndex
                    progressValue = 0.0
                    restartAutoAdvance()
                    return
                }
            }
            prevUserIndex -= 1
        }
        
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
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onPrevious()
                        }

                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onNext()
                        }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .allowsHitTesting(true)

                VStack(spacing: 0) {
                    storyHeader
                        .zIndex(20)
                    
                    storyImage
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(15)
                    
                    storyControls
                        .zIndex(25)
                }
                .zIndex(50)
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
            
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "message")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Reply").font(.caption).foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {}) {
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

#Preview {
    StoryViewer(
        story: Story(),
        viewModel: StoriesViewModel(context: PersistenceController.preview.container.viewContext)
    )
}
