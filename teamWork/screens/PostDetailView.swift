import SwiftUI

struct PostDetailView: View {
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
