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
                List(viewModel.history.reversed()) { workout in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline)
                        Text("Date: \(formatDate(workout.date))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Duration: \(formatTime(workout.duration))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }

            Spacer()
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    // Helper functions
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

#Preview {
    HistoryView(viewModel: WorkoutViewModel())
}
