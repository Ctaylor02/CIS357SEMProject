import SwiftUI
import Combine

class RecommendationViewModel: ObservableObject {
    @Published var todayRecommendation: DailyRecommendation?

    init() {
        generateRecommendation()
    }

    @MainActor
    func generateRecommendation() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Sunday = 1 ... Saturday = 7

        switch weekday {
        case 1:
            todayRecommendation = DailyRecommendation(
                day: "Sunday",
                workout: WorkoutSuggestion(name: "Rest / Light Stretching", sets: 1, reps: nil, durationMinutes: 20),
                meal: MealSuggestion(name: "Grilled Salmon Salad", calories: 400, description: "Salmon with mixed greens and olive oil dressing")
            )
        case 2:
            todayRecommendation = DailyRecommendation(
                day: "Monday",
                workout: WorkoutSuggestion(name: "Running", sets: 1, reps: nil, durationMinutes: 30),
                meal: MealSuggestion(name: "Oatmeal & Berries", calories: 350, description: "Oats with mixed berries and almonds")
            )
        case 3:
            todayRecommendation = DailyRecommendation(
                day: "Tuesday",
                workout: WorkoutSuggestion(name: "Weight Lifting", sets: 4, reps: 10, durationMinutes: nil),
                meal: MealSuggestion(name: "Grilled Chicken & Quinoa", calories: 500, description: "High-protein balanced meal")
            )
        case 4:
            todayRecommendation = DailyRecommendation(
                day: "Wednesday",
                workout: WorkoutSuggestion(name: "Swimming", sets: 1, reps: nil, durationMinutes: 40),
                meal: MealSuggestion(name: "Veggie Stir Fry", calories: 400, description: "Tofu, broccoli, and carrots with light soy sauce")
            )
        case 5:
            todayRecommendation = DailyRecommendation(
                day: "Thursday",
                workout: WorkoutSuggestion(name: "HIIT", sets: 5, reps: 12, durationMinutes: nil),
                meal: MealSuggestion(name: "Turkey Wrap", calories: 450, description: "Whole grain wrap with lean turkey and veggies")
            )
        case 6:
            todayRecommendation = DailyRecommendation(
                day: "Friday",
                workout: WorkoutSuggestion(name: "Cycling", sets: 1, reps: nil, durationMinutes: 45),
                meal: MealSuggestion(name: "Smoothie Bowl", calories: 350, description: "Banana, spinach, and protein powder topped with granola")
            )
        case 7:
            todayRecommendation = DailyRecommendation(
                day: "Saturday",
                workout: WorkoutSuggestion(name: "Yoga / Flexibility", sets: 1, reps: nil, durationMinutes: 30),
                meal: MealSuggestion(name: "Avocado Toast & Eggs", calories: 400, description: "Whole grain toast with avocado and poached eggs")
            )
        default:
            todayRecommendation = nil
        }
    }
}
