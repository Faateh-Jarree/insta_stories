import SwiftUI

struct ReelsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Reels View")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Text("This tab will contain reels functionality")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Reels")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ReelsView()
}
