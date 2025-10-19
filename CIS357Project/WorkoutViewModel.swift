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

    // Streak & Achievements
    @Published var recentAchievement: String? = nil
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0

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

    // MARK: - Timer controls
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

    // MARK: - Workout management
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
        
        // Update streak
        updateStreak(for: completed.date!)

        // Check milestones
        checkAchievements()

        return completed
    }

    func deleteWorkout(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        recalcStreak()
    }

    func clearHistory() {
        history.removeAll()
        currentStreak = 0
        longestStreak = 0
    }

    // MARK: - Streak Calculation
    private func updateStreak(for date: Date) {
        let calendar = Calendar.current
        guard let lastWorkout = history.dropLast().last?.date else {
            currentStreak = 1
            longestStreak = max(longestStreak, currentStreak)
            return
        }

        if calendar.isDateInYesterday(lastWorkout) && calendar.isDateInToday(date) {
            currentStreak += 1
        } else if calendar.isDateInToday(lastWorkout) {
            // same day, no change
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
    }

    private func recalcStreak() {
        currentStreak = 0
        longestStreak = 0
        let sortedHistory = history.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
        for workout in sortedHistory {
            if let date = workout.date {
                updateStreak(for: date)
            }
        }
    }

    // MARK: - Achievements
    private func checkAchievements() {
        recentAchievement = nil

        if history.count == 1 {
            recentAchievement = "First Workout Completed!"
        } else if history.count == 5 {
            recentAchievement = "5 Workouts Completed!"
        } else if history.count == 10 {
            recentAchievement = "10 Workouts Completed!"
        } else if currentStreak == 7 {
            recentAchievement = "7-Day Streak!"
        }
    }
}
