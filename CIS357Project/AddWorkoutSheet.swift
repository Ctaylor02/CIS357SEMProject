//
//  AddWorkoutSheet.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/13/25.
//

import SwiftUI

// allows for coustom workouts
struct AddWorkoutSheet: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Binding var newWorkoutName: String
    @Binding var showAddWorkout: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Workout")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Workout Name", text: $newWorkoutName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Save") {
                guard !newWorkoutName.isEmpty else { return }
                let workout = Workout(name: newWorkoutName)
                viewModel.workouts.append(workout)
                viewModel.selectedWorkout = workout
                newWorkoutName = ""
                showAddWorkout = false
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button("Cancel") {
                showAddWorkout = false
                newWorkoutName = ""
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
