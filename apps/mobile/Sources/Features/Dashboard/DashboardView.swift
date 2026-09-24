import SwiftUI

struct DashboardView: View {
    @State private var summary: DailySummary?
    @State private var errorMessage: String?

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let summary {
                    VStack(spacing: 12) {
                        statRow("Calories in", summary.caloriesIn)
                        statRow("Calories burned", summary.caloriesBurned)
                        statRow("TDEE", summary.tdee)
                        Divider()
                        statRow("Net", summary.net)
                        Text(summary.status.capitalized)
                            .font(.title2.bold())
                            .foregroundStyle(statusColor(summary.status))
                    }
                    .padding()
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Dashboard")
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func statRow(_ label: String, _ value: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value)) kcal")
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "deficit": return .green
        case "surplus": return .orange
        default: return .secondary
        }
    }

    private func load() async {
        do {
            summary = try await APIClient.get(
                "daily-summary/\(todayString)",
                query: ["user_id": String(APIClient.currentUserId)]
            )
            errorMessage = nil
        } catch {
            summary = nil
            errorMessage = "Complete your profile on the Profile tab to see your dashboard."
        }
    }
}
