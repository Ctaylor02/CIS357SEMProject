//
//  TrackWorkoutView.swift
//  CIS357Project
//
//  Created by Aiden Mack on 10/18/25.
//  Updated by Caleb Taylor on 10/18/25.
//

import SwiftUI

struct TrackWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout

    var body: some View {
        VStack(spacing: 24) {
            Text("Tracking \(workout.name)")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top)

            // Live timer display
            Text(formatTime(viewModel.elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding()

            Button(action: {
                let completedWorkout = viewModel.completeWorkout()
                navigator.navigate(to: .summary(completedWorkout))
            }) {
                Text("Finish Workout")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .padding()
    }

    // Helper for formatting time
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
