import SwiftUI
import Charts

//Workout Details Screen

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Header
                Text(workout.name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
                    .padding(.top)

                // Details Card
                VStack(spacing: 16) {
                    detailRow(icon: "calendar", title: "Date", value: formatDate(workout.date))
                    detailRow(icon: "clock", title: "Duration", value: formatTime(workout.duration))

                    if let note = workout.note, !note.isEmpty {
                        detailRow(icon: "pencil", title: "Note", value: note)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .background(
            LinearGradient(colors: [.purple.opacity(0.1), .blue.opacity(0.15)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "N/A" }
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
}


// Main History View

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    @State private var workoutToDelete: Workout?
    @State private var showDeleteAlert = false
    @State private var sortType: SortType = .dateNewest
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                header
                searchBar
                sortControls
                statsSection

                if !viewModel.history.isEmpty {
                    streakHeatmap
                    weeklyChart
                    workoutTypeChart
                    workoutListSection
                } else {
                    emptyMessage
                }

                Spacer(minLength: 40)
            }
        }
        .background(backgroundGradient)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Workout"),
                message: Text("Are you sure you want to delete this workout?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let workout = workoutToDelete,
                       let idx = viewModel.history.firstIndex(of: workout) {
                        withAnimation { viewModel.history.remove(at: idx) }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

extension HistoryView {

    // Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.20), Color.purple.opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // Header
    

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.system(size: 38))
                .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 3) {
                Text("Workout History")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("Your long-term fitness progression")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search workouts...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .padding(.horizontal)
    }

    // Sort Controls

    private var sortControls: some View {
        HStack {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.purple)

            Picker("Sort", selection: $sortType) {
                Text("Date").tag(SortType.dateNewest)
                Text("Duration").tag(SortType.durationHigh)
                Text("A → Z").tag(SortType.workoutAZ)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }

    // Stats Section

    private var statsSection: some View {
        let totalDuration = viewModel.history.reduce(0) { $0 + $1.duration }
        let avgDuration = viewModel.history.isEmpty ? 0 : totalDuration / Double(viewModel.history.count)

        return HStack(spacing: 16) {
            statCard(icon: "figure.walk", title: "Workouts", value: "\(viewModel.history.count)")
            statCard(icon: "clock", title: "Total Time", value: formatTime(totalDuration))
            statCard(icon: "gauge", title: "Average", value: formatTime(avgDuration))
        }
        .padding(.horizontal)
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.purple)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 3)
    }

    // Calendar Heatmap (Streaks)

    private var streakHeatmap: some View {

        let days = generateMonthlyHeatmap()

        return VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Activity Heatmap")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(day.color)
                        .frame(height: 22)
                        .overlay(
                            Text(day.label)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        )
                }
            }
            .padding(.horizontal)
        }
    }

    private func generateMonthlyHeatmap() -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = Date()
        let monthRange = calendar.range(of: .day, in: .month, for: today)!

        return monthRange.map { day -> HeatmapDay in
            let date = calendar.date(bySetting: .day, value: day, of: today)!

            let matched = viewModel.history.contains {
                guard let d = $0.date else { return false }
                return calendar.isDate(d, inSameDayAs: date)
            }

            return HeatmapDay(
                id: UUID(),
                label: "\(day)",
                color: matched ? .purple.opacity(0.6) : .gray.opacity(0.20)
            )
        }
    }

    struct HeatmapDay: Identifiable {
        let id: UUID
        let label: String
        let color: Color
    }

    // Weekly Chart
    

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Progress")
                .font(.headline)
                .padding(.horizontal)

            Chart(weeklyData) { day in
                BarMark(
                    x: .value("Day", formatDate(day.date, format: "E")),
                    y: .value("Minutes", day.totalDuration / 60)
                )
                .foregroundStyle(.purple.gradient)
            }
            .frame(height: 150)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }

    // Workout Type Chart

    private var workoutTypeChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Minutes by Workout Type")
                .font(.headline)
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
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }

    // Filtered Workouts

    private var filteredWorkouts: [Workout] {
        if searchText.isEmpty { return sortedHistory }

        return sortedHistory.filter { workout in
            let dateMatch = formatDate(workout.date).localizedCaseInsensitiveContains(searchText)
            let nameMatch = workout.name.localizedCaseInsensitiveContains(searchText)
            let noteMatch = workout.note?.localizedCaseInsensitiveContains(searchText) ?? false
            return dateMatch || nameMatch || noteMatch
        }
    }

    
    // Workout List (List + Navigation + Swipe)

    private var workoutListSection: some View {
        VStack {
            List {
                ForEach(filteredWorkouts) { workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout)
                    } label: {
                        workoutRowListStyle(workout)
                    }
                    .listRowBackground(Color.clear)
                    .swipeActions {
                        Button(role: .destructive) {
                            workoutToDelete = workout
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .frame(height: 450)
            .scrollContentBackground(.hidden)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    // List Row Style

    private func workoutRowListStyle(_ workout: Workout) -> some View {
        HStack(spacing: 12) {

            // Category icon
            Text(iconForWorkout(workout.name))
                .font(.system(size: 30))

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)

                Text("Date: \(formatDate(workout.date))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Duration: \(formatTime(workout.duration))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let note = workout.note, !note.isEmpty {
                    Text("“\(note)”")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func iconForWorkout(_ name: String) -> String {
        let lower = name.lowercased()

        if lower.contains("run") { return "🏃‍♂️" }
        if lower.contains("cycle") { return "🚴‍♂️" }
        if lower.contains("lift") || lower.contains("weight") { return "🏋️‍♂️" }
        if lower.contains("swim") { return "🏊‍♂️" }
        if lower.contains("yoga") { return "🧘" }
        if lower.contains("walk") { return "🚶" }
        return "🔥"
    }

    // Empty Message

    private var emptyMessage: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No workouts recorded yet.")
                .foregroundColor(.secondary)
                .font(.headline)
        }
        .padding(.top, 50)
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

    // Helper Functions

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

    // Weekly chart data
    var weeklyData: [DailyWorkout] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let total = viewModel.history.filter {
                calendar.isDate($0.date ?? .distantPast, inSameDayAs: day)
            }
            .reduce(0) { $0 + $1.duration }
            return DailyWorkout(id: UUID(), date: day, totalDuration: total)
        }
        .reversed()
    }

    // Workout type chart data
    var workoutTypeData: [WorkoutTypeAggregate] {
        let types = Set(viewModel.history.map { $0.name })
        return types.map { type in
            let total = viewModel.history.filter { $0.name == type }
                .reduce(0) { $0 + $1.duration }
            return WorkoutTypeAggregate(id: UUID(), type: type, totalDuration: total)
        }
    }

    // Models

    enum SortType {
        case dateNewest
        case durationHigh
        case workoutAZ
    }

    struct DailyWorkout: Identifiable {
        let id: UUID
        let date: Date
        let totalDuration: TimeInterval
    }

    struct WorkoutTypeAggregate: Identifiable {
        let id: UUID
        let type: String
        let totalDuration: TimeInterval
    }
}
