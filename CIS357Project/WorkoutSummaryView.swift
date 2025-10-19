import SwiftUI

struct WorkoutSummaryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout
    @State private var noteText: String = ""

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Workout Summary")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)

                VStack(alignment: .leading, spacing: 15) {
                    Text("Workout: \(workout.name)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Date: \(formatDate(workout.date))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Duration: \(formatTime(workout.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Notes:")
                        .font(.headline)

                    TextEditor(text: $noteText)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.2)))
                        .shadow(radius: 4)
                        .frame(height: 120)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.15)))
                .shadow(radius: 6)
                .padding(.horizontal)

                Button("Save & Return") {
                    // Append to history with notes
                    _ = viewModel.completeWorkout(note: noteText)
                    navigator.navigateBackToRoot()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .frame(maxWidth: .infinity)
                .font(.headline)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Helpers
    func formatDate(_ date: Date?) -> String {
        guard let date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    WorkoutSummaryView(viewModel: WorkoutViewModel(),
                       workout: Workout(name: "Running", date: Date(), duration: 1800))
        .environmentObject(MyNavigator())
}
