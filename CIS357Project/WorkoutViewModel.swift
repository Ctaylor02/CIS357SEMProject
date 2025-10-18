//
//  WorkoutViewModel.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/18/25.
//  Updated by Caleb Taylor on 10/18/25.
//

import Foundation
import Combine

// MARK: - Workout Model
struct Workout: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var date: Date? = nil
    var duration: TimeInterval = 0
    var isCompleted: Bool = false
}

// MARK: - Workout ViewModel
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout]
    @Published var selectedWorkout: Workout
    @Published var history: [Workout] = []

    // Timer properties
    @Published var elapsedTime: TimeInterval = 0
    private var timer: AnyCancellable? = nil
    private var startDate: Date? = nil

    init() {
        let defaultWorkouts = [
            Workout(name: "Running"),
            Workout(name: "Cycling"),
            Workout(name: "Weights"),
            Workout(name: "Swimming")
        ]
        self.workouts = defaultWorkouts
        self.selectedWorkout = defaultWorkouts.first!
    }

    // MARK: - Timer Controls
    func startTimer() {
        startDate = Date()
        elapsedTime = 0
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let start = self.startDate else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }

    // MARK: - Workout Management
    func startWorkout() {
        print("Started \(selectedWorkout.name)")
        startTimer()
    }

    func completeWorkout() -> Workout {
        stopTimer()
        var completed = selectedWorkout
        completed.isCompleted = true
        completed.date = Date()
        completed.duration = elapsedTime
        history.append(completed)
        return completed
    }

    func clearHistory() {
        history.removeAll()
    }
}
