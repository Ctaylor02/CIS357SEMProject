import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    @State private var workoutToDelete: Workout?
    @State private var showDeleteAlert = false
    
    @State private var sortType: SortType = .dateNewest
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Title
                Text("Workout History")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                    .padding(.top)
                
                
                // M Sort Controls
                sortControls
                
                
                //  Stats
                statsSection
                
                
                //  Weekly Progress Chart
                if !viewModel.history.isEmpty {
                    Text("Weekly Progress")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Chart(weeklyData) { day in
                        BarMark(
                            x: .value("Day", formatDate(day.date, format: "E")),
                            y: .value("Min", day.totalDuration / 60)
                        )
                        .foregroundStyle(.purple.gradient)
                    }
                    .frame(height: 150)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.15)))
                    .padding(.horizontal)
                }
                
                
                //  Workout Type Chart
                if !viewModel.history.isEmpty {
                    Text("Time by Workout Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Chart(workoutTypeData) { item in
                        BarMark(
                            x: .value("Workout", item.type),
                            y: .value("Min", item.totalDuration / 60)
                        )
                        .foregroundStyle(.green.gradient)
                    }
                    .frame(height: 150)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.15)))
                    .padding(.horizontal)
                }
                
                
                //  Workout List
                if sortedHistory.isEmpty {
                    Text("No workouts completed yet.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedHistory) { workout in
                            workoutRow(workout)
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
}

extension HistoryView {
    
    // Sort Controls
    private var sortControls: some View {
        Picker("Sort", selection: $sortType) {
            Text("Date").tag(SortType.dateNewest)
            Text("Duration").tag(SortType.durationHigh)
            Text("Workout").tag(SortType.workoutAZ)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    
    // Stats Section
    private var statsSection: some View {
        let totalDuration = viewModel.history.reduce(0) { $0 + $1.duration }
        let avgDuration = viewModel.history.isEmpty ? 0 : totalDuration / Double(viewModel.history.count)
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("Total Workouts: \(viewModel.history.count)")
            Text("Total Time: \(formatTime(totalDuration))")
            Text("Average Duration: \(formatTime(avgDuration))")
        }
        .font(.subheadline)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.2)))
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    
    // Workout Row
    private func workoutRow(_ workout: Workout) -> some View {
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
    
    
    // Sorting Logic
    private var sortedHistory: [Workout] {
        switch sortType {
        case .dateNewest:
            return viewModel.history.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        case .durationHigh:
            return viewModel.history.sorted { $0.duration > $1.duration }
        case .workoutAZ:
            return viewModel.history.sorted { $0.name < $1.name }
        }
    }
    
    
    //  Helpers
    func formatDate(_ date: Date?, format: String = "MMM d") -> String {
        guard let date else { return "N/A" }
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: date)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    
    //  Weekly Data
    var weeklyData: [DailyWorkout] {
        let calendar = Calendar.current
        let today = Date()
        var data: [DailyWorkout] = []
        
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: -i, to: today)!
            let workouts = viewModel.history.filter {
                guard let d = $0.date else { return false }
                return calendar.isDate(d, inSameDayAs: day)
            }
            let total = workouts.reduce(0) { $0 + $1.duration }
            data.append(DailyWorkout(date: day, totalDuration: total))
        }
        
        return data.reversed()
    }
    
    
    //  Workout Type Chart Data
    var workoutTypeData: [WorkoutTypeAggregate] {
        let types = Set(viewModel.workouts.map { $0.name })
        return types.map { type in
            let total = viewModel.history
                .filter { $0.name == type }
                .reduce(0) { $0 + $1.duration }
            return WorkoutTypeAggregate(type: type, totalDuration: total)
        }
    }
}


//  Sort Enum
enum SortType {
    case dateNewest, durationHigh, workoutAZ
}


// Models for chart data
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

