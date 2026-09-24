import SwiftUI

struct DashboardView: View {
    @State private var apiStatus = "checking..."

    var body: some View {
        VStack {
            Text("Dashboard")
            Text("API: \(apiStatus)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .task {
            do {
                apiStatus = try await APIClient.health().status
            } catch {
                apiStatus = "unreachable"
            }
        }
    }
}
