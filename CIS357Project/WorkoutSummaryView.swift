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

    var body: some View {
        VStack(spacing: 24) {
            Text("Workout Summary")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                Text("Workout: \(workout.name)")
                Text("Date: \(formatDate(workout.date))")
                Text("Duration: \(formatTime(workout.duration))")
            }
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(12)

            Button("Save & Return") {
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
