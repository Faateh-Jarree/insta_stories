import SwiftUI
import CoreData

struct PostCard: View {
    let post: Post
    let onLike: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Post Header
            PostHeader(post: post)
            
            // Post Image
            PostImage(imageURL: post.imageURL ?? "")
            
            // Post Actions
            PostActions(post: post, onLike: onLike)
            
            // Post Info
            PostInfo(post: post)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct PostHeader: View {
    let post: Post
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: post.author?.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray4))
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(post.author?.username ?? "Unknown User")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(post.author?.fullName ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct PostImage: View {
    let imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                )
        }
        .frame(height: 400)
        .clipped()
    }
}

struct PostActions: View {
    let post: Post
    let onLike: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onLike) {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(post.isLiked ? .red : .primary)
            }
            
            Button(action: {}) {
                Image(systemName: "bubble.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Button(action: {}) {
                Image(systemName: "paperplane")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bookmark")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct PostInfo: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(post.likes) likes")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(alignment: .top, spacing: 4) {
                Text(post.author?.username ?? "Unknown User")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(post.caption ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            if post.comments > 0 {
                Text("View all \(post.comments) comments")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let timestamp = post.timestamp {
                Text(timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

#Preview {
    // This preview won't work until Core Data entities are generated
    Text("PostCard Preview")
}
