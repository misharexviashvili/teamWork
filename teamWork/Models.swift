import Foundation

struct Post: Decodable, Identifiable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct Comment: Decodable, Identifiable, Hashable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}

struct User: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

protocol APIClientProtocol {
    func fetchPosts() async throws -> [Post]
    func fetchPost(id: Int) async throws -> Post
    func fetchComments(postID: Int) async throws -> [Comment]
    func fetchUser(id: Int) async throws -> User
    func fetchPosts(userID: Int) async throws -> [Post]
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "სერვერის პასუხი ვერ დამუშავდა."
        case .httpStatus(let code): return "სერვერის შეცდომა (HTTP \(code))."
        }
    }
}

struct APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    func fetchPosts() async throws -> [Post] {
        try await request(path: "posts")
    }

    func fetchPost(id: Int) async throws -> Post {
        try await request(path: "posts/\(id)")
    }

    func fetchComments(postID: Int) async throws -> [Comment] {
        try await request(path: "comments", query: [URLQueryItem(name: "postId", value: String(postID))])
    }

    func fetchUser(id: Int) async throws -> User {
        try await request(path: "users/\(id)")
    }

    func fetchPosts(userID: Int) async throws -> [Post] {
        try await request(path: "posts", query: [URLQueryItem(name: "userId", value: String(userID))])
    }

    private func request<T: Decodable>(path: String, query: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw APIError.invalidResponse }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(response.statusCode) else { throw APIError.httpStatus(response.statusCode) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
