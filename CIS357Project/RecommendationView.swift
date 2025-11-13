//
//  RecommendationView.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/13/25.
//

import SwiftUI

struct RecommendationView: View {
    @StateObject private var viewModel = RecommendationViewModel()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orange.opacity(0.25), Color.pink.opacity(0.2)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            if let recommendation = viewModel.todayRecommendation {
                VStack(spacing: 30) {
                    Text("Today's Recommendation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.linearGradient(colors: [.purple, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))

                    // Workout Card
                    VStack(spacing: 15) {
                        Text("💪 Workout: \(recommendation.workout.name)")
                            .font(.headline)
                        if let reps = recommendation.workout.reps {
                            Text("Sets: \(recommendation.workout.sets), Reps: \(reps)")
                        }
                        if let duration = recommendation.workout.durationMinutes {
                            Text("Duration: \(duration) min")
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.2)))
                    .shadow(radius: 5)

                    // Meal Card
                    VStack(spacing: 15) {
                        Text("🥗 Meal: \(recommendation.meal.name)")
                            .font(.headline)
                        Text("\(recommendation.meal.calories) Calories")
                        Text(recommendation.meal.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.2)))
                    .shadow(radius: 5)

                    Spacer()
                }
                .padding()
            } else {
                Text("Loading recommendation...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Daily Recommendation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RecommendationView()
    }
}
