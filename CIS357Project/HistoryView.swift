//
//  HistoryView.swift
//  CIS357Project
//
//  Updated by Caleb Taylor on 10/18/25.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Workout History")
                    .font(.largeTitle)
                    .padding(.top)

                // MARK: - Stats Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Workouts: \(viewModel.history.count)")
                    Text("Total Time: \(formatTime(viewModel.history.reduce(0) { $0 + $1.duration }))")
                    Text("Average Duration: \(formatTime(viewModel.history.isEmpty ? 0 : viewModel.history.reduce(0) { $0 + $1.duration } / Double(viewModel.history.count)))")
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                // MARK: - Weekly Progress Chart
                if !viewModel.history.isEmpty {
                    Text("Weekly Progress")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    Chart(weeklyData) { day in
                        BarMark(
                            x: .value("Day", formatDate(day.date, format: "E")),
                            y: .value("Duration (min)", day.totalDuration / 60)
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                }

                // MARK: - Workout Type Breakdown Chart
                if !viewModel.history.isEmpty {
                    Text("Time by Workout Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    Chart(workoutTypeData) { item in
                        BarMark(
                            x: .value("Workout", item.type),
                            y: .value("Duration (min)", item.totalDuration / 60)
                        )
                        .foregroundStyle(.green.gradient)
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                }

                // MARK: - Workout List
                if viewModel.history.isEmpty {
                    Text("No workouts completed yet.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.history.reversed()) { workout in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name)
                                    .font(.headline)
                                Text("Date: \(formatDate(workout.date))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Duration: \(formatTime(workout.duration))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if let note = workout.note, !note.isEmpty {
                                    Text("Note: \(note)")
                                        .font(.subheadline)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(viewModel.history.count * 80))
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Delete Workout
    func deleteWorkout(at offsets: IndexSet) {
        let count = viewModel.history.count
        let reversedOffsets = IndexSet(offsets.map { count - 1 - $0 })
        viewModel.deleteWorkout(at: reversedOffsets)
    }

    // MARK: - Helpers
    func formatDate(_ date: Date?, format: String = "MMM d") -> String {
        guard let date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Weekly Progress Data
    var weeklyData: [DailyWorkout] {
        let calendar = Calendar.current
        let today = Date()
        var data: [DailyWorkout] = []

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let workoutsOnDay = viewModel.history.filter {
                guard let date = $0.date else { return false }
                return calendar.isDate(date, inSameDayAs: day)
            }
            let totalDuration = workoutsOnDay.reduce(0) { $0 + $1.duration }
            data.append(DailyWorkout(date: day, totalDuration: totalDuration))
        }
        return data.reversed()
    }

    // MARK: - Workout Type Data
    var workoutTypeData: [WorkoutTypeAggregate] {
        let types = viewModel.workouts.map { $0.name }
        return types.map { typeName in
            let totalDuration = viewModel.history
                .filter { $0.name == typeName }
                .reduce(0) { $0 + $1.duration }
            return WorkoutTypeAggregate(type: typeName, totalDuration: totalDuration)
        }
    }
}

// MARK: - Supporting Structs
struct DailyWorkout: Identifiable {
    let id = UUID()
    let date: Date
    let totalDuration: TimeInterval
}

struct WorkoutTypeAggregate: Identifiable {
    let id = UUID()
    let type: String
    let totalDuration: TimeInterval
}

#Preview {
    HistoryView(viewModel: WorkoutViewModel())
}
