// UserProfile.swift
import Foundation

struct UserProfile: Codable {
    // MARK: - Basic Info
    var name: String = ""
    var age: Int = 18
    var height: Double = 170   // cm
    var weight: Double = 150   // lbs
    var fitnessLevel: FitnessLevel = .beginner
    var photoData: Data? = nil
    
    // New Additions
    var bio: String = ""
    
    // Goals
    var dailyStepGoal: Int = 8000
    var weeklyWorkoutGoal: Int = 4
    var fitnessGoal: FitnessGoal = .generalHealth
    
    // Achievements
    var achievements: [Achievement] = []
}


enum FitnessLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

//  New Enums

enum FitnessGoal: String, Codable, CaseIterable {
    case loseWeight = "Lose Weight"
    case buildMuscle = "Build Muscle"
    case improveEndurance = "Improve Endurance"
    case generalHealth = "General Health"
}

enum Achievement: String, Codable, CaseIterable, Hashable {
    case fiveDayStreak = "🔥 5-Day Streak"
    case tenWorkouts = "🏋️ 10 Workouts"
    case firstCustomWorkout = "⭐ First Custom Workout"
    case tenThousandSteps = "🚶 10,000 Steps in a Day"
}

//  Computed Metrics
extension UserProfile {
    
    // BMI formula: lbs → kg, cm → m
    var bmi: Double {
        let weightKg = weight * 0.453592
        let heightM = height / 100
        guard heightM > 0 else { return 0 }
        return weightKg / (heightM * heightM)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    var idealWeightRange: (min: Double, max: Double) {
        // BMI range (18.5–24.9)
        let heightM = height / 100
        let min = 18.5 * (heightM * heightM)
        let max = 24.9 * (heightM * heightM)
        return (min / 0.453592, max / 0.453592) // return in lbs
    }
}
