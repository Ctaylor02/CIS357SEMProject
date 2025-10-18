//
//  HistoryView.swift
//  CIS357Project
//
//  Updated by Caleb Taylor on 10/18/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack {
            Text("Workout History")
                .font(.largeTitle)
                .padding(.bottom)

            if viewModel.history.isEmpty {
                Text("No workouts completed yet.")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
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
                .padding(.bottom, 8)

                // MARK: - Workout List
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
            }

            Spacer()
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    // MARK: - Helper Functions
    func deleteWorkout(at offsets: IndexSet) {
        let count = viewModel.history.count
        let reversedOffsets = IndexSet(offsets.map { count - 1 - $0 })
        viewModel.deleteWorkout(at: reversedOffsets)
    }

    func formatDate(_ date: Date?) -> String {
        guard let date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
