import SwiftUI

@MainActor
struct PostDetailView: View {
    let postID: Int
    var showsAuthorButton = true

    @State private var post: Post?
    @State private var comments: [Comment] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var authorID: Int?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("პოსტი იტვირთება…")
            } else if let errorMessage {
                ContentUnavailableView {
                    Label("ჩატვირთვა ვერ მოხერხდა", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("ხელახლა ცდა", action: reload)
                        .buttonStyle(.borderedProminent)
                }
            } else if let post {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(post.title.capitalized)
                                .font(.title3.bold())
                            Text(post.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)

                        if showsAuthorButton {
                            Button("ავტორის პროფილი", systemImage: "person.circle") {
                                authorID = post.userId
                            }
                        }
                    }

                    Section("კომენტარები (\(comments.count))") {
                        ForEach(comments) { comment in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.name)
                                    .font(.subheadline.bold())
                                Text(comment.email)
                                    .font(.caption)
                                    .foregroundStyle(.tint)
                                Text(comment.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .refreshable { await load() }
            }
        }
        .navigationTitle("პოსტი")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $authorID) { id in
            UserProfileView(userID: id)
        }
        .task(id: postID) { await load() }
    }

    private func reload() {
        Task { await load() }
    }

    private func load() async {
        isLoading = post == nil
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let fetchedPost = APIClient.shared.fetchPost(id: postID)
            async let fetchedComments = APIClient.shared.fetchComments(postID: postID)
            (post, comments) = try await (fetchedPost, fetchedComments)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(postID: 1)
    }
}
