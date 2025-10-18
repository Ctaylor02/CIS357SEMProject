//
//  StatsView.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/18/25.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack {
            Text("Workout Stats")
                .font(.largeTitle)
                .padding(.bottom)
            Text("Your stats will appear here for \(viewModel.selectedWorkout.name).")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StatsView(viewModel: WorkoutViewModel())
}
