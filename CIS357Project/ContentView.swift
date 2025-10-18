//
//  ContentView.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/12/25.
//

import SwiftUI

struct ContentView: View {
    // Accept the view model from the app and promote it to a StateObject for stability.
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator

    // Custom initializer to wrap the injected instance.
    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigator.navPath) {
            VStack(spacing: 24) {
                Text("Workout Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Picker("Workout", selection: $viewModel.selectedWorkout) {
                    ForEach(viewModel.workouts) { workout in
                        Text(workout.name).tag(workout)
                    }
                }
                .pickerStyle(.menu)

                Button("Start") {
                    viewModel.startWorkout()
                    // Example navigation to the selected workout detail.
                    navigator.navigate(to: .workout(viewModel.selectedWorkout))
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)

                Button {
                    navigator.navigate(to: .History)
                } label: {
                    Text("History")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .History:
                    HistoryView(viewModel: viewModel)
                case .workout(let workout):
                    TrackWorkoutView(viewModel: viewModel, workout: workout)
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
}
