//
//  TrackWorkoutView.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 10/18/25.
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

            Text(formatTime(viewModel.elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding()

            HStack(spacing: 20) {
                Button(action: {
                    if viewModel.isPaused {
                        viewModel.resumeTimer()
                    } else {
                        viewModel.pauseTimer()
                    }
                }) {
                    Text(viewModel.isPaused ? "Resume" : "Pause")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    // Pass a copy of the current workout with the elapsed time
                    var workoutCopy = workout
                    workoutCopy.duration = viewModel.elapsedTime
                    // Do NOT append to history here
                    navigator.navigate(to: .summary(workoutCopy))
                }) {
                    Text("Finish")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .onAppear { viewModel.startTimer() }
        .onDisappear { viewModel.stopTimer() }
        .padding()
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
