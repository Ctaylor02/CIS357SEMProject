import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator
    @State private var showAddWorkout = false
    @State private var newWorkoutName = ""
    @State private var showAchievementBanner = false
    @State private var showSettings = false // Settings sheet

    // Daily Quote
    private var dailyQuote: String {
        let quotes = [
            "Push yourself, because no one else will.",
            "The only bad workout is the one that didn’t happen.",
            "Sweat is just fat crying.",
            "Don’t limit your challenges. Challenge your limits.",
            "Strive for progress, not perfection.",
            "Your body can stand almost anything. It’s your mind you have to convince.",
            "Small steps every day add up to big results."
        ]
        let weekday = Calendar.current.component(.weekday, from: Date())
        return quotes[(weekday - 1) % quotes.count]
    }

    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigator.navPath) {
            ZStack {
                // Background Gradient
                LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                // Floating Icons
                FloatingIconsView()

                VStack(spacing: 25) {
                    //  - Header with Settings Button
                    HStack {
                        Text("Workout Tracker")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.linearGradient(colors: [.pink, .purple],
                                                             startPoint: .top,
                                                             endPoint: .bottom))
                            .shadow(radius: 5)

                        Spacer()

                        Button {
                            withAnimation(.easeInOut) {
                                showSettings.toggle()
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.purple)
                                .padding(8)
                                .background(.white.opacity(0.3))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)

                    // Daily Quote
                    Text("💡 \(dailyQuote)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    //  Streak Info
                    VStack(spacing: 5) {
                        Text("🔥 Current Streak: \(viewModel.currentStreak) day(s)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("🏆 Longest Streak: \(viewModel.longestStreak) day(s)")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }

                    // Workout Picker
                    Picker("Workout", selection: $viewModel.selectedWorkout) {
                        ForEach(viewModel.workouts) { workout in
                            Text(workout.name).tag(workout)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(.white.opacity(0.3))
                    .cornerRadius(12)
                    .shadow(radius: 3)

                    // Buttons
                    VStack(spacing: 12) {
                        Button("Start") {
                            viewModel.startWorkout()
                            navigator.navigate(to: .workout(viewModel.selectedWorkout))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .frame(maxWidth: .infinity)

                        Button("History") {
                            navigator.navigate(to: .History)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .frame(maxWidth: .infinity)

                        Button {
                            navigator.navigate(to: .stepCount)
                        } label: {
                            Text("Step Count")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button("Daily Recommendation") {
                            navigator.navigate(to: .recommendation)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .frame(maxWidth: .infinity)

                        Button("Add Custom Workout") {
                            showAddWorkout.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .onReceive(viewModel.$recentAchievement) { achievement in
                    if achievement != nil {
                        showAchievementBanner = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showAchievementBanner = false
                        }
                    }
                }

                //  Achievement Banner
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
            //  Add Workout Sheet
            .sheet(isPresented: $showAddWorkout) {
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
            // Settings Sheet
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            // MARK: - Navigation Destinations
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .History:
                    HistoryView(viewModel: viewModel)
                case .workout(let workout):
                    TrackWorkoutView(viewModel: viewModel, workout: workout)
                case .summary(let workout):
                    WorkoutSummaryView(viewModel: viewModel, workout: workout)
                case .stepCount:
                    StepCountView(viewModel: viewModel)
                case .recommendation:
                    RecommendationView()
                }
            }
        }
    }
}

// Floating Icons
struct FloatingIconsView: View {
    @State private var positions: [CGSize] = Array(repeating: .zero, count: 10)

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<positions.count, id: \.self) { i in
                Image(systemName: ["heart.fill", "star.fill", "flame.fill", "bolt.fill"].randomElement()!)
                    .foregroundColor([.pink, .yellow, .orange, .purple].randomElement())
                    .opacity(0.4)
                    .position(x: CGFloat.random(in: 0...geo.size.width),
                              y: CGFloat.random(in: 0...geo.size.height))
                    .scaleEffect(CGFloat.random(in: 0.5...1.2))
                    .animation(Animation.easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)), value: positions[i])
            }
        }
    }
}

#Preview {
    ContentView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
}
