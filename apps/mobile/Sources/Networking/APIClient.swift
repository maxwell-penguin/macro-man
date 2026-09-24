import Foundation

struct HealthResponse: Codable {
    let status: String
}

enum APIClient {
    static let baseURL = URL(string: "http://localhost:8000")!

    static func health() async throws -> HealthResponse {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("health"))
        return try JSONDecoder().decode(HealthResponse.self, from: data)
    }
}
