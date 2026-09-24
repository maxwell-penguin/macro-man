import Foundation

struct UserProfile: Codable {
    var id: Int? = nil
    var email: String? = nil
    var weightKg: Double?
    var heightCm: Double?
    var age: Int?
    var sex: String?
    var activityLevel: String?
    var goal: String?
    var targetRate: Double?

    enum CodingKeys: String, CodingKey {
        case id, email, age, sex, goal
        case weightKg = "weight_kg"
        case heightCm = "height_cm"
        case activityLevel = "activity_level"
        case targetRate = "target_rate"
    }
}

struct TDEEResponse: Codable {
    var bmr: Double
    var tdee: Double
}

struct Meal: Codable, Identifiable {
    var id: Int
    var userId: Int
    var loggedAt: String
    var source: String
    var name: String
    var qty: Double?
    var calories: Double?
    var proteinG: Double?
    var carbsG: Double?
    var fatG: Double?

    enum CodingKeys: String, CodingKey {
        case id, source, name, qty, calories
        case userId = "user_id"
        case loggedAt = "logged_at"
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
    }
}

struct MealInput: Codable {
    var name: String
    var qty: Double?
    var calories: Double?
    var proteinG: Double?
    var carbsG: Double?
    var fatG: Double?

    enum CodingKeys: String, CodingKey {
        case name, qty, calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
    }
}

struct Exercise: Codable, Identifiable {
    var id: Int
    var userId: Int
    var loggedAt: String
    var type: String
    var durationMin: Double?
    var caloriesBurned: Double?
    var source: String

    enum CodingKeys: String, CodingKey {
        case id, type, source
        case userId = "user_id"
        case loggedAt = "logged_at"
        case durationMin = "duration_min"
        case caloriesBurned = "calories_burned"
    }
}

struct ExerciseInput: Codable {
    var type: String
    var durationMin: Double?
    var caloriesBurned: Double?

    enum CodingKeys: String, CodingKey {
        case type
        case durationMin = "duration_min"
        case caloriesBurned = "calories_burned"
    }
}

struct DailySummary: Codable {
    var date: String
    var caloriesIn: Double
    var caloriesBurned: Double
    var tdee: Double
    var net: Double
    var status: String

    enum CodingKeys: String, CodingKey {
        case date, tdee, net, status
        case caloriesIn = "calories_in"
        case caloriesBurned = "calories_burned"
    }
}
