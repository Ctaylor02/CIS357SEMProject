import SwiftUI

struct AddWorkoutSheet: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var theme: ThemeManager

    @Binding var newWorkoutName: String
    @Binding var showAddWorkout: Bool

    @State private var workoutIcon: String = "🔥"
    @State private var difficulty: Double = 1

    private let icons = ["🔥", "🏋️‍♂️", "🚴‍♂️", "🏃‍♂️", "🏊‍♂️", "🧘", "🥊", "🚶"]

    var body: some View {
        ZStack {
            dimBackground
            sheetCard
        }
    }
}

extension AddWorkoutSheet {

    private var dimBackground: some View {
        Color.black.opacity(0.25)
            .ignoresSafeArea()
            .onTapGesture { dismissSheet() }
    }

    private var sheetCard: some View {
        VStack(spacing: 22) {
            topBar
            title
            iconPicker
            nameField
            difficultySlider
            saveButton
            Spacer(minLength: 10)
        }
        .padding(.bottom, 20)
        .padding(.top, 10)
        .frame(maxWidth: 370)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
        )
        .shadow(radius: 20)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button(action: dismissSheet) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }

    private var title: some View {
        Text("Add New Workout")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.purple)
    }

    private var iconPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(icons, id: \.self) { icon in
                    Text(icon)
                        .font(.system(size: workoutIcon == icon ? 40 : 32))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(workoutIcon == icon
                                      ? theme.accentColor.opacity(0.25)
                                      : Color.white.opacity(0.12))
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                workoutIcon = icon
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Text Field
    private var nameField: some View {
        TextField("Workout Name", text: $newWorkoutName)
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.15)))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.25))
            )
            .foregroundColor(.primary)
            .padding(.horizontal)
            .autocorrectionDisabled()
    }

    // MARK: - Difficulty Slider
    private var difficultySlider: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Difficulty")
                .font(.headline)
                .foregroundColor(.secondary)

            Slider(value: $difficulty, in: 1...5, step: 1)
                .tint(theme.accentColor)

            HStack {
                ForEach(1...5, id: \.self) { lvl in
                    Circle()
                        .fill(lvl <= Int(difficulty) ? theme.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveWorkout) {
            Text("Save Workout")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(newWorkoutName.isEmpty
                            ? Color.gray.opacity(0.3)
                            : theme.accentColor)
                .cornerRadius(14)
                .foregroundColor(.white)
        }
        .disabled(newWorkoutName.isEmpty)
        .padding(.horizontal)
    }
}

extension AddWorkoutSheet {

    // MARK: - Functions

    private func saveWorkout() {
        guard !newWorkoutName.isEmpty else { return }

        let workout = Workout(name: "\(workoutIcon) \(newWorkoutName)")
        viewModel.workouts.append(workout)
        viewModel.selectedWorkout = workout

        newWorkoutName = ""
        showAddWorkout = false
    }

    private func dismissSheet() {
        newWorkoutName = ""
        showAddWorkout = false
    }
}
