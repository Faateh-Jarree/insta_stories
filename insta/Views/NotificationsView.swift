import SwiftUI

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Notifications View")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Text("This tab will contain notifications functionality")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    NotificationsView()
}
