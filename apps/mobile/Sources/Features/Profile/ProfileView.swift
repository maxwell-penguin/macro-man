import SwiftUI

struct ProfileView: View {
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var age = ""
    @State private var sex = "male"
    @State private var activityLevel = "moderate"
    @State private var goal = "maintain"
    @State private var targetRate = ""
    @State private var tdeeResult: TDEEResponse?
    @State private var errorMessage: String?
    @State private var isSaving = false

    private let sexes = ["male", "female"]
    private let activityLevels = ["sedentary", "light", "moderate", "active", "very_active"]
    private let goals = ["cut", "maintain", "bulk"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Weight (kg)", text: $weightKg).keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $heightCm).keyboardType(.decimalPad)
                    TextField("Age", text: $age).keyboardType(.numberPad)
                    Picker("Sex", selection: $sex) {
                        ForEach(sexes, id: \.self) { Text($0.capitalized) }
                    }
                    Picker("Activity level", selection: $activityLevel) {
                        ForEach(activityLevels, id: \.self) { Text($0.replacingOccurrences(of: "_", with: " ").capitalized) }
                    }
                    Picker("Goal", selection: $goal) {
                        ForEach(goals, id: \.self) { Text($0.capitalized) }
                    }
                    TextField("Target rate (kg/week)", text: $targetRate).keyboardType(.decimalPad)
                }

                if let tdeeResult {
                    Section("TDEE") {
                        LabeledContent("BMR", value: "\(Int(tdeeResult.bmr)) kcal")
                        LabeledContent("TDEE", value: "\(Int(tdeeResult.tdee)) kcal")
                    }
                }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                Section {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Profile")
            .task { await load() }
        }
    }

    private func load() async {
        guard let profile: UserProfile = try? await APIClient.get("users/\(APIClient.currentUserId)") else { return }
        weightKg = profile.weightKg.map { String($0) } ?? ""
        heightCm = profile.heightCm.map { String($0) } ?? ""
        age = profile.age.map { String($0) } ?? ""
        sex = profile.sex ?? sex
        activityLevel = profile.activityLevel ?? activityLevel
        goal = profile.goal ?? goal
        targetRate = profile.targetRate.map { String($0) } ?? ""
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        let body = UserProfile(
            weightKg: Double(weightKg),
            heightCm: Double(heightCm),
            age: Int(age),
            sex: sex,
            activityLevel: activityLevel,
            goal: goal,
            targetRate: Double(targetRate)
        )
        do {
            let _: UserProfile = try await APIClient.put("users/\(APIClient.currentUserId)", body: body)
            tdeeResult = try await APIClient.get("users/\(APIClient.currentUserId)/tdee")
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
}
