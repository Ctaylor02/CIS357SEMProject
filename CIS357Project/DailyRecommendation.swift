//
//  DailyRecommendation.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/13/25.
//

import Foundation

struct DailyRecommendation {
    let day: String
    let workout: WorkoutSuggestion
    let meal: MealSuggestion
}

struct WorkoutSuggestion {
    let name: String
    let sets: Int
    let reps: Int?
    let durationMinutes: Int?
}

struct MealSuggestion {
    let name: String
    let calories: Int
    let description: String
}
