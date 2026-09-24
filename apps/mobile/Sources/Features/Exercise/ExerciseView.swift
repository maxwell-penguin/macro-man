import SwiftUI

struct ExerciseView: View {
    @State private var exercises: [Exercise] = []
    @State private var type = ""
    @State private var durationMin = ""
    @State private var caloriesBurned = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Log exercise") {
                    TextField("Type (e.g. Running)", text: $type)
                    TextField("Duration (min)", text: $durationMin).keyboardType(.decimalPad)
                    TextField("Calories burned", text: $caloriesBurned).keyboardType(.decimalPad)
                    Button("Add exercise") { Task { await addExercise() } }
                        .disabled(type.isEmpty)
                }

                Section("Today") {
                    if exercises.isEmpty {
                        Text("No exercise logged yet").foregroundStyle(.secondary)
                    }
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading) {
                            Text(exercise.type).font(.headline)
                            Text("\(Int(exercise.durationMin ?? 0)) min · \(Int(exercise.caloriesBurned ?? 0)) kcal burned")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteExercises)
                }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Exercise")
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        do {
            exercises = try await APIClient.get("exercises", query: ["user_id": String(APIClient.currentUserId)])
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load exercises"
        }
    }

    private func addExercise() async {
        let body = ExerciseInput(type: type, durationMin: Double(durationMin), caloriesBurned: Double(caloriesBurned))
        do {
            let _: Exercise = try await APIClient.post("exercises", body: body, query: ["user_id": String(APIClient.currentUserId)])
            type = ""; durationMin = ""; caloriesBurned = ""
            await load()
        } catch {
            errorMessage = "Failed to add exercise"
        }
    }

    private func deleteExercises(at offsets: IndexSet) {
        Task {
            for index in offsets {
                try? await APIClient.delete("exercises/\(exercises[index].id)")
            }
            await load()
        }
    }
}
