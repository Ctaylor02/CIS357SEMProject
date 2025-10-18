//
//  TrackWorkout.swift
//  CIS357Project
//
//  Created by Aiden Mack on 10/18/25.
//
import SwiftUI

struct TrackWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    let workout: Workout

    var body: some View {
        Text("Track Workout")
    }
}
