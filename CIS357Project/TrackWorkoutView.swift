import SwiftUI

struct TrackWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.orange.opacity(0.2), Color.red.opacity(0.1)], center: .center, startRadius: 100, endRadius: 500)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Tracking \(workout.name)")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(.purple)

                Text(formatTime(viewModel.elapsedTime))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.2)))
                    .shadow(radius: 8)

                HStack(spacing: 20) {
                    Button(viewModel.isPaused ? "Resume" : "Pause") {
                        viewModel.isPaused ? viewModel.resumeTimer() : viewModel.pauseTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.isPaused ? .green : .yellow)
                    .frame(maxWidth: .infinity)
                    .font(.headline)

                    Button("Finish") {
                        var workoutCopy = workout
                        workoutCopy.duration = viewModel.elapsedTime
                        workoutCopy.date = Date()           // <-- Fix: add the date here
                        navigator.navigate(to: .summary(workoutCopy))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear { viewModel.startTimer() }
        .onDisappear { viewModel.stopTimer() }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TrackWorkoutView(viewModel: WorkoutViewModel(), workout: Workout(name: "Running"))
        .environmentObject(MyNavigator())
}
