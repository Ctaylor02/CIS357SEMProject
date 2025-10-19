//
//  WorkoutViewModel.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 10/18/25.
//

import Foundation
import Combine
import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout]
    @Published var selectedWorkout: Workout
    @Published var history: [Workout] = []



    // Timer
    @Published var elapsedTime: TimeInterval = 0
    @Published var isPaused: Bool = false
    private var timer: AnyCancellable? = nil
    private var startDate: Date? = nil
    private var pausedTime: TimeInterval = 0

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

    // Timer controls
    func startTimer() {
        startDate = Date()
        elapsedTime = 0
        pausedTime = 0
        isPaused = false
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused, let start = self.startDate else { return }
                self.elapsedTime = self.pausedTime + Date().timeIntervalSince(start)
            }
    }

    func pauseTimer() {
        guard !isPaused else { return }
        pausedTime = elapsedTime
        isPaused = true
    }

    func resumeTimer() {
        guard isPaused else { return }
        startDate = Date()
        isPaused = false
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        pausedTime = 0
        isPaused = false
    }

    // Workout management
    func startWorkout() {
        startTimer()
        print("Started \(selectedWorkout.name)")
    }

    func completeWorkout(note: String? = nil) -> Workout {
        stopTimer()
        let completed = Workout(
                    name: selectedWorkout.name,
                    date: Date(),
                    duration: elapsedTime,
                    isCompleted: true,
                    note: note
                )
        history.append(completed)
        return completed
    }

    func deleteWorkout(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
    }

    func clearHistory() {
        history.removeAll()
    }
}
