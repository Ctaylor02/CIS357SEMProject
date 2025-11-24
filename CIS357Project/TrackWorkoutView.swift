import SwiftUI

struct TrackWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout

    // Sample motivational messages
    private var motivationalMessage: String {
        let messages = [
            "Keep pushing! 💪",
            "You're stronger than yesterday!",
            "Almost there, stay focused!",
            "One step at a time!",
            "Feel the burn! Love the results!"
        ]
        return messages.randomElement()!
    }

    var body: some View {
        ZStack {
            // Background
            RadialGradient(colors: [Color.orange.opacity(0.2), Color.red.opacity(0.1)],
                           center: .center, startRadius: 100, endRadius: 600)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Workout Title
                Text("Tracking \(workout.name)")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.linearGradient(colors: [.purple, .orange], startPoint: .top, endPoint: .bottom))
                    .shadow(radius: 5)

                // Circular Timer / Progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)

                    Circle()
                        .trim(from: 0, to: min(CGFloat(viewModel.elapsedTime / max(workout.duration, 1)), 1.0))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .orange, .red]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: viewModel.elapsedTime)

                    VStack {
                        Text(formatTime(viewModel.elapsedTime))
                            .font(.system(size: 64, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)

                        Text("Elapsed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 300, height: 300)
                .padding()

                // Stats Panel
                VStack(spacing: 10) {
                    HStack {
                        Text("Remaining: \(formatTime(max(workout.duration - viewModel.elapsedTime, 0)))")
                        Spacer()
                        Text("Calories: \(calculateCalories()) cal")
                    }
                    .font(.headline)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Motivational Message
                Text(motivationalMessage)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)

                // Buttons
                HStack(spacing: 20) {
                    Button(viewModel.isPaused ? "Resume" : "Pause") {
                        viewModel.isPaused ? viewModel.resumeTimer() : viewModel.pauseTimer()
                        Haptics.feedback(style: .medium)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.isPaused ? .green : .yellow)
                    .frame(maxWidth: .infinity)
                    .font(.headline)

                    Button("Finish") {
                        var workoutCopy = workout
                        workoutCopy.duration = viewModel.elapsedTime
                        workoutCopy.date = Date()
                        Haptics.feedback(style: .heavy)
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

    // Helper functions
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func calculateCalories() -> Int {
        //
        let met = 8.0 // average for hard exercise
        let weightKg = 70.0
        return Int((met * 3.5 * weightKg / 200.0) * viewModel.elapsedTime / 60)
    }
}

// Simple Haptic feedback helper
struct Haptics {
    static func feedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

#Preview {
    TrackWorkoutView(viewModel: WorkoutViewModel(), workout: Workout(name: "Running", duration: 1800))
        .environmentObject(MyNavigator())
}
