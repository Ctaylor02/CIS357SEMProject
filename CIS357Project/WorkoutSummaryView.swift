//
//  WorkoutSummaryView.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 10/18/25.
//

import SwiftUI

struct WorkoutSummaryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout
    @State private var noteText: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Workout Summary")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                Text("Workout: \(workout.name)")
                Text("Date: \(formatDate(workout.date))")
                Text("Duration: \(formatTime(workout.duration))")

                Text("Notes:")
                    .font(.headline)
                TextEditor(text: $noteText)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4))
                    )
            }
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(12)

            Button("Save & Return") {
                // Append to history here, only once, including notes
                _ = viewModel.completeWorkout(note: noteText)
                navigator.navigateBackToRoot()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
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
