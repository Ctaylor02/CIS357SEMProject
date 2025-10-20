import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator
    @State private var showAddWorkout = false
    @State private var newWorkoutName = ""
    @State private var showAchievementBanner = false

    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigator.navPath) {
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    // MARK: - Title
                    Text("Workout Tracker")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(.linearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom))
                        .shadow(radius: 5)

                    // MARK: - Streak Info
                    VStack(spacing: 5) {
                        Text("🔥 Current Streak: \(viewModel.currentStreak) day(s)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("🏆 Longest Streak: \(viewModel.longestStreak) day(s)")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }

                    // MARK: - Picker
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

                    // MARK: - Buttons
                    Button("Start") {
                        viewModel.startWorkout()
                        navigator.navigate(to: .workout(viewModel.selectedWorkout))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                    Button("History") {
                        navigator.navigate(to: .History)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    Button {
                        navigator.navigate(to: .stepCount)
                            } label: {
                                Text("Step Count")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 8)

                    Button("Add Custom Workout") {
                        showAddWorkout.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .frame(maxWidth: .infinity)
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

                // MARK: - Achievement Banner
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
            // MARK: - Sheet for Adding Custom Workout
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
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
}
