//
//  HistoryView.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/18/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack {
            Text("Workout History")
                .font(.largeTitle)
                .padding(.bottom)
            Text("Your workout history for \(viewModel.selectedWorkout.name) will appear here.")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HistoryView(viewModel: WorkoutViewModel())
}
