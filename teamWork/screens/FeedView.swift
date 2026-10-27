import SwiftUI

@MainActor
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("პოსტები იტვირთება…")
                } else if let errorMessage {
                    ContentUnavailableView {
                        Label("ჩატვირთვა ვერ მოხერხდა", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("ხელახლა ცდა", action: reload)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(posts) { post in
                        NavigationLink {
                            PostDetailView(postID: post.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(post.title.capitalized)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(post.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                            .padding(.vertical, 5)
                            .contentShape(Rectangle())
                        }
                        .accessibilityHint("გახსნის პოსტის დეტალებს")
                    }
                    .refreshable { await loadPosts() }
                }
            }
            .navigationTitle("პოსტები")
            .task { await loadPosts() }
        }
    }

    private func reload() {
        Task { await loadPosts() }
    }

    private func loadPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            posts = try await APIClient.shared.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    FeedView()
}
