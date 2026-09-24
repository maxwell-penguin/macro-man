ACTIVITY_MULTIPLIERS = {
    "sedentary": 1.2,
    "light": 1.375,
    "moderate": 1.55,
    "active": 1.725,
    "very_active": 1.9,
}


def bmr(weight_kg: float, height_cm: float, age: int, sex: str) -> float:
    base = 10 * weight_kg + 6.25 * height_cm - 5 * age
    return base + 5 if sex == "male" else base - 161


def tdee(weight_kg: float, height_cm: float, age: int, sex: str, activity_level: str) -> float:
    multiplier = ACTIVITY_MULTIPLIERS[activity_level]
    return bmr(weight_kg, height_cm, age, sex) * multiplier


def net_calories(calories_in: float, tdee_value: float, calories_burned: float) -> float:
    return calories_in - (tdee_value + calories_burned)
