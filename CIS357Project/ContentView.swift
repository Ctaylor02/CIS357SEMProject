import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator
    @State private var showAddWorkout = false
    @State private var newWorkoutName = ""

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

                    Button("Add Custom Workout") {
                        showAddWorkout.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding()
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
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
}
