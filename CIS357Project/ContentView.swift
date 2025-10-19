import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator

    init(viewModel: WorkoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigator.navPath) {
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("Workout Tracker")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(.linearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom))
                        .shadow(radius: 5)

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
                }
                .padding()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .History:
                    HistoryView(viewModel: viewModel)
                case .workout(let workout):
                    TrackWorkoutView(viewModel: viewModel, workout: workout)
                case .summary(let workout):
                    WorkoutSummaryView(viewModel: viewModel, workout: workout)
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
}
