import SwiftUI

struct DiaryView: View {
    @State private var meals: [Meal] = []
    @State private var name = ""
    @State private var qty = ""
    @State private var calories = ""
    @State private var proteinG = ""
    @State private var carbsG = ""
    @State private var fatG = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Log a meal") {
                    TextField("Name", text: $name)
                    TextField("Qty", text: $qty).keyboardType(.decimalPad)
                    TextField("Calories", text: $calories).keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $proteinG).keyboardType(.decimalPad)
                    TextField("Carbs (g)", text: $carbsG).keyboardType(.decimalPad)
                    TextField("Fat (g)", text: $fatG).keyboardType(.decimalPad)
                    Button("Add meal") { Task { await addMeal() } }
                        .disabled(name.isEmpty)
                }

                Section("Today") {
                    if meals.isEmpty {
                        Text("No meals logged yet").foregroundStyle(.secondary)
                    }
                    ForEach(meals) { meal in
                        VStack(alignment: .leading) {
                            Text(meal.name).font(.headline)
                            Text("\(Int(meal.calories ?? 0)) kcal · P\(Int(meal.proteinG ?? 0)) C\(Int(meal.carbsG ?? 0)) F\(Int(meal.fatG ?? 0))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteMeals)
                }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Diary")
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        do {
            meals = try await APIClient.get("meals", query: ["user_id": String(APIClient.currentUserId)])
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load meals"
        }
    }

    private func addMeal() async {
        let body = MealInput(
            name: name,
            qty: Double(qty),
            calories: Double(calories),
            proteinG: Double(proteinG),
            carbsG: Double(carbsG),
            fatG: Double(fatG)
        )
        do {
            let _: Meal = try await APIClient.post("meals", body: body, query: ["user_id": String(APIClient.currentUserId)])
            name = ""; qty = ""; calories = ""; proteinG = ""; carbsG = ""; fatG = ""
            await load()
        } catch {
            errorMessage = "Failed to add meal"
        }
    }

    private func deleteMeals(at offsets: IndexSet) {
        Task {
            for index in offsets {
                try? await APIClient.delete("meals/\(meals[index].id)")
            }
            await load()
        }
    }
}
