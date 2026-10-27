import SwiftUI

struct UserProfileView: View {
    let userID: Int

    var body: some View {
        Text("ავტორი \(userID)")
            .navigationTitle("ავტორი")
    }
}

#Preview {
    NavigationStack {
        UserProfileView(userID: 1)
    }
}
