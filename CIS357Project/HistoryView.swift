import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var workoutToDelete: Workout?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Workout History")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                    .padding(.top)

                // MARK: - Stats Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Total Workouts: \(viewModel.history.count)")
                    Text("Total Time: \(formatTime(viewModel.history.reduce(0) { $0 + $1.duration }))")
                    Text("Average Duration: \(formatTime(viewModel.history.isEmpty ? 0 : viewModel.history.reduce(0) { $0 + $1.duration } / Double(viewModel.history.count)))")
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.2)))
                .shadow(radius: 3)
                .padding(.horizontal)

                // MARK: - Weekly Progress Chart
                if !viewModel.history.isEmpty {
                    Text("Weekly Progress")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    Chart(weeklyData) { day in
                        BarMark(
                            x: .value("Day", formatDate(day.date, format: "E")),
                            y: .value("Duration (min)", day.totalDuration / 60)
                        )
                        .foregroundStyle(.purple.gradient)
                    }
                    .frame(height: 150)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.15)))
                    .padding(.horizontal)
                }

                // MARK: - Workout Type Breakdown Chart
                if !viewModel.history.isEmpty {
                    Text("Time by Workout Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    Chart(workoutTypeData) { item in
                        BarMark(
                            x: .value("Workout", item.type),
                            y: .value("Duration (min)", item.totalDuration / 60)
                        )
                        .foregroundStyle(.green.gradient)
                    }
                    .frame(height: 150)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.15)))
                    .padding(.horizontal)
                }

                // MARK: - Workout List (LazyVStack with Delete)
                if viewModel.history.isEmpty {
                    Text("No workouts completed yet.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.history.enumerated()).reversed(), id: \.element.id) { index, workout in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.name).font(.headline)
                                        Text("Date: \(formatDate(workout.date))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Duration: \(formatTime(workout.duration))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        if let note = workout.note, !note.isEmpty {
                                            Text("Note: \(note)")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        workoutToDelete = workout
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(8)
                                            .background(Circle().fill(Color.white.opacity(0.3)))
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.2)))
                                .shadow(radius: 3)
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer(minLength: 30)
            }
        }
        .background(
            LinearGradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Workout"),
                message: Text("Are you sure you want to delete this workout?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let workout = workoutToDelete,
                       let index = viewModel.history.firstIndex(of: workout) {
                        withAnimation { viewModel.history.remove(at: index) }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Helpers
    func formatDate(_ date: Date?, format: String = "MMM d") -> String {
        guard let date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var weeklyData: [DailyWorkout] {
        let calendar = Calendar.current
        let today = Date()
        var data: [DailyWorkout] = []

        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let workoutsOnDay = viewModel.history.filter {
                guard let date = $0.date else { return false }
                return calendar.isDate(date, inSameDayAs: day)
            }
            let totalDuration = workoutsOnDay.reduce(0) { $0 + $1.duration }
            data.append(DailyWorkout(date: day, totalDuration: totalDuration))
        }
        return data.reversed()
    }

    var workoutTypeData: [WorkoutTypeAggregate] {
        let types = viewModel.workouts.map { $0.name }
        return types.map { typeName in
            let totalDuration = viewModel.history
                .filter { $0.name == typeName }
                .reduce(0) { $0 + $1.duration }
            return WorkoutTypeAggregate(type: typeName, totalDuration: totalDuration)
        }
    }
}

struct DailyWorkout: Identifiable {
    let id = UUID()
    let date: Date
    let totalDuration: TimeInterval
}

struct WorkoutTypeAggregate: Identifiable {
    let id = UUID()
    let type: String
    let totalDuration: TimeInterval
}

#Preview {
    HistoryView(viewModel: WorkoutViewModel())
}
