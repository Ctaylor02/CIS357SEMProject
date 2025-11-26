//
//  DailyRecommendation.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/13/25.
//

import SwiftUI

struct DailyRecommendation {
    let day: String
    let emoji: String
    let themeColor: Color
    
    let workout: WorkoutSuggestion
    let meal: MealSuggestion
}

// MARK: - Workout Suggestion
struct WorkoutSuggestion {
    let name: String
    let sets: Int
    let reps: Int?
    let durationMinutes: Int?
}

//  Meal Suggestion
struct MealSuggestion {
    let name: String
    let calories: Int
    let description: String
}
