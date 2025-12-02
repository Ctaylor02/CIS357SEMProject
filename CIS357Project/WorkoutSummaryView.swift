import SwiftUI

struct WorkoutSummaryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var navigator: MyNavigator
    let workout: Workout
    @State private var noteText: String = ""
    @State private var showAchievementBanner = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // Use existing FloatingIconsView
            FloatingIconsView()

            VStack(spacing: 25) {
                // Header
                Text("Workout Summary")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.linearGradient(colors: [.purple, .orange], startPoint: .top, endPoint: .bottom))
                    .shadow(radius: 5)

                // Stats Cards
                VStack(spacing: 15) {
                    statCard(title: "Workout", value: workout.name, icon: "figure.walk")
                    statCard(title: "Date", value: formatDate(workout.date), icon: "calendar")
                    statCard(title: "Duration", value: formatTime(workout.duration), icon: "timer")
                    statCard(title: "Calories", value: "\(calculateCalories()) cal", icon: "flame.fill")
                }
                .padding(.horizontal)

                // Notes Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Notes:")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextEditor(text: $noteText)
                        .frame(height: 140)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.2)))
                        .shadow(radius: 4)

                    HStack {
                        Button("💪 Felt Strong") { noteText += "💪 Felt Strong. " }
                        Button("😴 Need Rest") { noteText += "😴 Need Rest. " }
                        Button("🔥 Pushed Hard") { noteText += "🔥 Pushed Hard. " }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.15)))
                .shadow(radius: 6)
                .padding(.horizontal)

                Spacer()

                // Save Button
                Button(action: {
                    _ = viewModel.completeWorkout(note: noteText)
                    navigator.navigateBackToRoot()
                    if viewModel.recentAchievement != nil {
                        showAchievementBanner = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { showAchievementBanner = false }
                    }
                    Haptics.feedback(style: .medium) // Use Haptics
                }) {
                    Text("Save & Return")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.purple, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }
            .padding(.top, 40)
            .padding(.bottom, 20)

            // Achievement Banner
            if showAchievementBanner, let achievement = viewModel.recentAchievement {
                VStack {
                    Spacer()
                    Text("🏅 \(achievement)")
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showAchievementBanner)
            }
        }
    }

    // Helpers
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

    func calculateCalories() -> Int {
        let met = 8.0 //
        let weightKg = 70.0
        return Int((met * 3.5 * weightKg / 200.0) * workout.duration / 60)
    }

    //  Stat Card
    func statCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.2)))
        .shadow(radius: 4)
    }
}

//#Preview {
//    WorkoutSummaryView(viewModel: WorkoutViewModel(),
//                       workout: Workout(name: "Running", date: Date(), duration: 1800))
//        .environmentObject(MyNavigator())
//}
