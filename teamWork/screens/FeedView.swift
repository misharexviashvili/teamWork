import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Post") {
                PostDetailView()
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
}
