import Foundation
import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator
    @EnvironmentObject private var profileManager: UserProfileManager
    @EnvironmentObject private var healthKit: HealthkitIntegration


    @State private var showAddWorkout = false
    @State private var newWorkoutName = ""
    @State private var showAchievementBanner = false
    @State private var showSettings = false

    //  Daily Quote
    private var dailyQuote: String {
        let quotes = [
            "Push yourself, because no one else will.",
            "The only bad workout is the one that didn’t happen.",
            "Strive for progress, not perfection.",
            "Challenge your limits.",
            "Small steps every day add up to big results.",
            "Your body can handle it—your mind needs convincing.",
            "Consistency beats intensity."
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
                // Background
                LinearGradient(colors: [Color.blue.opacity(0.3),
                                        Color.purple.opacity(0.2)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()

                FloatingIconsView()

                VStack(spacing: 25) {

                    todaysStatsCard
                        .padding(.top, 20)

                    //  Header + Settings Button
                    HStack {
                        Text("Workout Tracker")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.linearGradient(colors: [.pink, .purple],
                                                             startPoint: .top,
                                                             endPoint: .bottom))
                            .shadow(radius: 5)

                        Spacer()

                        Button {
                            withAnimation { showSettings.toggle() }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.purple)
                                .padding(8)
                                .background(.white.opacity(0.35))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)

                    //  Quote
                    Text("💡 \(dailyQuote)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 5)

                    //  Streak Info
                    VStack(spacing: 5) {
                        Text("🔥 Current Streak: \(viewModel.currentStreak) day(s)")
                            .font(.headline)
                            .foregroundColor(.orange)

                        Text("🏆 Longest Streak: \(viewModel.longestStreak) day(s)")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }

                    //  Workout Picker
                    Picker("Workout", selection: $viewModel.selectedWorkout) {
                        ForEach(viewModel.workouts) { workout in
                            Text(workout.name).tag(workout)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(.white.opacity(0.25))
                    .cornerRadius(12)
                    .shadow(radius: 3)

                    //  Buttons
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
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .frame(maxWidth: .infinity)

                        Button("Step Count") {
                            navigator.navigate(to: .stepCount)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.yellow)
                        .frame(maxWidth: .infinity)
                        
                        Button("Calorie Count") {
                            navigator.navigate(to: .calorieCount)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .frame(maxWidth: .infinity)
                        
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

                    Button("Profile") {
                        navigator.navigate(to: .profile)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    .frame(maxWidth: .infinity)
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
                }
            }

            // Add Workout Sheet
            .sheet(isPresented: $showAddWorkout) {
                VStack(spacing: 20) {
                    Text("Add New Workout")
                        .font(.title2).bold()

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
                        newWorkoutName = ""
                        showAddWorkout = false
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }

            // Settings Sheet
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }

            // Navigation Destinations
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

                case .profile:
                    ProfileView()
                    
                case .calorieCount:
                    CalorieCountView(viewModel: viewModel)
                }
            }
            .onAppear {
                healthKit.refreshSteps()
                healthKit.refreshCalories()
            }
        }
    }
}

extension ContentView {
    // Today's Stats Card
    private var todaysStatsCard: some View {
        let steps = healthKit.dailySteps
        let healthKitCalories = healthKit.dailyCalories
        let calories = healthKitCalories > 0 ? healthKitCalories : Int(Double(steps) * 0.04)

        let todaysWorkouts = viewModel.history.filter {
            Calendar.current.isDateInToday($0.date ?? Date())
        }

        let totalDuration = todaysWorkouts.reduce(0) { $0 + $1.duration }
        let minutes = Int(totalDuration) / 60

        return VStack(alignment: .leading, spacing: 8) {
            Text("📊 Today's Stats")
                .font(.title3)
                .bold()
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text("🚶 Steps: \(steps)")
                Text("🔥 Calories: \(calories) cal")
                Text("⏱ Workout Time: \(minutes) min")
                Text("🏋️ Workouts Completed: \(todaysWorkouts.count)")
            }
            .font(.headline)
            .foregroundColor(.white)

        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [.purple, .pink],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .opacity(0.85)
        )
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}
