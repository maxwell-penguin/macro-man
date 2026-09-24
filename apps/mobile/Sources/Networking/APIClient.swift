import Foundation

struct HealthResponse: Codable {
    let status: String
}

enum APIError: LocalizedError {
    case server(Int, String)

    var errorDescription: String? {
        if case let .server(code, message) = self {
            return "Server error \(code): \(message)"
        }
        return nil
    }
}

enum APIClient {
    static let baseURL = URL(string: "http://localhost:8000")!
    // ponytail: single-user app until auth exists (see CLAUDE.md Auth: "not yet decided")
    static let currentUserId = 1

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    static func health() async throws -> HealthResponse {
        try await get("health")
    }

    static func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        let data = try await run(path, method: "GET", query: query, httpBody: nil)
        return try decoder.decode(T.self, from: data)
    }

    static func post<B: Encodable, T: Decodable>(_ path: String, body: B, query: [String: String] = [:]) async throws -> T {
        let data = try await run(path, method: "POST", query: query, httpBody: try encoder.encode(body))
        return try decoder.decode(T.self, from: data)
    }

    static func put<B: Encodable, T: Decodable>(_ path: String, body: B, query: [String: String] = [:]) async throws -> T {
        let data = try await run(path, method: "PUT", query: query, httpBody: try encoder.encode(body))
        return try decoder.decode(T.self, from: data)
    }

    static func delete(_ path: String) async throws {
        _ = try await run(path, method: "DELETE", query: [:], httpBody: nil)
    }

    private static func run(_ path: String, method: String, query: [String: String], httpBody: Data?) async throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        if let httpBody {
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw APIError.server(statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return data
    }
}
