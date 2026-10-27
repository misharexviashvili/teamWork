import SwiftUI

struct PostDetailView: View {
    var postID: Int = 1

    var body: some View {
        Text("Post Detail")
            .navigationTitle("Post")
    }
}

#Preview {
    NavigationStack {
        PostDetailView()
    }
}
