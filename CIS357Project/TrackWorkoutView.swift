import SwiftUI

struct TrackWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.orange.opacity(0.2), Color.red.opacity(0.1)],
                           center: .center, startRadius: 100, endRadius: 500)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Tracking \(workout.name)")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(.purple)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: min(CGFloat(viewModel.elapsedTime / max(workout.duration, 1)), 1.0))
                        .stroke(AngularGradient(gradient: Gradient(colors: [.purple, .orange]), center: .center),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: viewModel.elapsedTime)

                    Text(formatTime(viewModel.elapsedTime))
                        .font(.system(size: 72, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
                .frame(width: 250, height: 250)
                .padding()

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
                        workoutCopy.date = Date() // Set the date for summary/history
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
    TrackWorkoutView(viewModel: WorkoutViewModel(), workout: Workout(name: "Running", duration: 1800))
        .environmentObject(MyNavigator())
}
