//
//  WorkoutViewModel.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/18/25.
//

import Foundation
import Combine

// Simple Workout model
struct Workout: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

// ViewModel for Workout screen
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout]
    @Published var selectedWorkout: Workout

    init() {
        let Workouts = [
            Workout(name: "Running"),
            Workout(name: "Cycling"),
            Workout(name: "Weights"),
            Workout(name: "Swimming")
        ]
        self.workouts = Workouts
        self.selectedWorkout = Workouts.first!
    }

    func startWorkout() {
        // Add your start workout logic here (logging, tracking, etc.)
        print("Started \(selectedWorkout.name)")
    }
}
