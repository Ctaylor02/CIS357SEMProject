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
    @EnvironmentObject var healthKit: HealthkitIntegration
    @Published var workouts: [Workout]
    @Published var selectedWorkout: Workout
    
    // Automatically save whenever history changes
    @Published var history: [Workout] = [] {
        didSet {
            saveHistory()
            updateProgressStats()
        }
    }

    @Published var weeklySteps: Int = 56000
    @Published var monthlySteps: Int = 224000
    @Published var dailySteps: Int = 0


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

    // Persistence Keys
    private let historyKey = "savedWorkoutHistory"
    private let streakKey = "savedStreakData"

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init() {
        let defaultWorkouts = [
            Workout(name: "Running"),
            Workout(name: "Cycling"),
            Workout(name: "Weights"),
            Workout(name: "Swimming")
        ]
        self.workouts = defaultWorkouts
        self.selectedWorkout = defaultWorkouts.first!

        // Load saved data
        loadHistory()
        loadStreakData()

        // Recalculate streaks and charts
        recalcStreak()
        updateProgressStats()

        // Auto-save when app goes to background
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.saveHistory()
                self?.saveStreakData()
            }
            .store(in: &cancellables)
    }

    //  Timer controls
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

    // Workout Management
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
        updateStreak(for: completed.date ?? Date())
        checkAchievements()
        saveHistory()
        saveStreakData()
        return completed
    }

    func deleteWorkout(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        recalcStreak()
        saveHistory()
        saveStreakData()
    }

    func clearHistory() {
        history.removeAll()
        currentStreak = 0
        longestStreak = 0
        saveHistory()
        saveStreakData()
    }

    // Streak Calculation
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

    //  Achievements
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

    // Persistence
    func saveHistory() {
        do {
            let encoded = try JSONEncoder().encode(history)
            UserDefaults.standard.set(encoded, forKey: historyKey)
        } catch {
            print(" Failed to save workout history: \(error)")
        }
    }

    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        do {
            history = try JSONDecoder().decode([Workout].self, from: data)
        } catch {
            print(" Failed to load workout history: \(error)")
            history = []
        }
    }

    func saveStreakData() {
        let streakData = ["current": currentStreak, "longest": longestStreak]
        UserDefaults.standard.set(streakData, forKey: streakKey)
    }

    func loadStreakData() {
        guard let streakData = UserDefaults.standard.dictionary(forKey: streakKey) as? [String: Int] else { return }
        currentStreak = streakData["current"] ?? 0
        longestStreak = streakData["longest"] ?? 0
    }

    func resetStreakData() {
        currentStreak = 0
        longestStreak = 0
        recentAchievement = nil
        UserDefaults.standard.removeObject(forKey: streakKey)
    }

    // Dynamic Progress Stats
    private func updateProgressStats() {
        //  total workout count in the past week/month
        let calendar = Calendar.current
        let now = Date()
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let oneMonthAgo = calendar.date(byAdding: .day, value: -30, to: now)!

        let weeklyWorkouts = history.filter { $0.date ?? now >= oneWeekAgo }
        let monthlyWorkouts = history.filter { $0.date ?? now >= oneMonthAgo }

        weeklySteps = weeklyWorkouts.count * 8000 //
        monthlySteps = monthlyWorkouts.count * 8000
    }
}
