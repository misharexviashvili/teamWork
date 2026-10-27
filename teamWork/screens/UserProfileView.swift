import SwiftUI

@MainActor
struct UserProfileView: View {
    let userID: Int

    @State private var user: User?
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("პროფილი იტვირთება…")
            } else if let errorMessage {
                ContentUnavailableView {
                    Label("ჩატვირთვა ვერ მოხერხდა", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("ხელახლა ცდა", action: reload)
                        .buttonStyle(.borderedProminent)
                }
            } else if let user {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.title3.bold())
                            Text("@\(user.username)")
                                .foregroundStyle(.secondary)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(.tint)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("პოსტები (\(posts.count))") {
                        ForEach(posts) { post in
                            NavigationLink {
                                PostDetailView(postID: post.id, showsAuthorButton: false)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.title.capitalized)
                                        .font(.headline)
                                    Text(post.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
                .refreshable { await load() }
            }
        }
        .navigationTitle("ავტორი")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: userID) { await load() }
    }

    private func reload() {
        Task { await load() }
    }

    private func load() async {
        isLoading = user == nil
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let fetchedUser = APIClient.shared.fetchUser(id: userID)
            async let fetchedPosts = APIClient.shared.fetchPosts(userID: userID)
            (user, posts) = try await (fetchedUser, fetchedPosts)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileView(userID: 1)
    }
}
