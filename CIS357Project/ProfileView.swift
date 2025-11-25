import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedImage: PhotosPickerItem?
    @State private var showSavedBanner = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {

                    profileImageSection
                    infoFieldsSection
                    bioSection
                    fitnessGoalsSection
                    bmiCard
                    achievementsSection

                    Spacer().frame(height: 100)
                }
                .padding(.top, 25)
            }

            saveButton

            if showSavedBanner {
                savedBanner
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ProfileView {

    // MARK: PROFILE IMAGE
    private var profileImageSection: some View {
        VStack {
            if let img = profileManager.profileImage() {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            } else {
                Circle()
                    .fill(.white.opacity(0.25))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }

            PhotosPicker(selection: $selectedImage, matching: .images) {
                Text("Change Photo")
                    .foregroundColor(.blue)
                    .font(.headline)
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileManager.updateProfileImage(uiImage)
                    }
                }
            }
        }
    }

    // MARK: INFO FIELDS
    private var infoFieldsSection: some View {
        VStack(spacing: 15) {
            profileField(title: "Name", value: $profileManager.profile.name)
            profileField(title: "Age", value: Binding(
                get: { "\(profileManager.profile.age)" },
                set: { profileManager.profile.age = Int($0) ?? profileManager.profile.age }
            ))
            profileField(title: "Height (cm)", value: Binding(
                get: { "\(Int(profileManager.profile.height))" },
                set: { profileManager.profile.height = Double($0) ?? profileManager.profile.height }
            ))
            profileField(title: "Weight (lb)", value: Binding(
                get: { "\(Int(profileManager.profile.weight))" },
                set: { profileManager.profile.weight = Double($0) ?? profileManager.profile.weight }
            ))
        }
        .padding()
        .background(.white.opacity(0.15))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    // MARK: BIO (always white)
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bio")
                .font(.headline)
                .foregroundColor(.white)

            TextEditor(text: $profileManager.profile.bio)
                .frame(height: 100)
                .padding(8)
                .background(Color.white)        // 👍 stays white in dark mode
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .foregroundColor(.black)        // 👍 readable text
        }
        .padding()
        .background(.white.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: FITNESS GOALS
    private var fitnessGoalsSection: some View {
        VStack(alignment: .leading, spacing: 15) {

            Text("Goals")
                .font(.headline)
                .foregroundColor(.white)

            Picker("Primary Fitness Goal",
                   selection: $profileManager.profile.fitnessGoal) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    Text(goal.rawValue).tag(goal)
                }
            }
            .padding()
            .background(.white.opacity(0.2))
            .cornerRadius(12)

            Stepper("Daily Step Goal: \(profileManager.profile.dailyStepGoal)",
                    value: $profileManager.profile.dailyStepGoal,
                    in: 1000...30000,
                    step: 500)
                .foregroundColor(.white)

            Stepper("Weekly Workout Goal: \(profileManager.profile.weeklyWorkoutGoal)",
                    value: $profileManager.profile.weeklyWorkoutGoal,
                    in: 1...14)
                .foregroundColor(.white)

        }
        .padding()
        .background(.white.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: BMI CARD
    private var bmiCard: some View {
        let bmi = profileManager.profile.bmi
        let category = profileManager.profile.bmiCategory
        let range = profileManager.profile.idealWeightRange

        return VStack(alignment: .leading, spacing: 8) {

            Text("📏 BMI & Body Metrics")
                .font(.headline)
                .foregroundColor(.white)

            Text("BMI: \(String(format: "%.1f", bmi)) — \(category)")
                .foregroundColor(.white)

            Text("Ideal Weight: \(Int(range.min)) – \(Int(range.max)) lbs")
                .foregroundColor(.white)

        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [.pink, .purple],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .opacity(0.85)
        )
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding(.horizontal)
    }

    // MARK: ACHIEVEMENTS
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.white)

            if profileManager.profile.achievements.isEmpty {
                Text("No achievements yet.")
                    .foregroundColor(.white.opacity(0.7))
            } else {
                ForEach(profileManager.profile.achievements, id: \.self) { achievement in
                    HStack {
                        Text(achievement.rawValue)
                            .font(.subheadline)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(.white.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: FIELD BUILDER
    private func profileField(title: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)

            TextField(title, text: value)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .foregroundColor(.black)
                .shadow(radius: 2)
        }
    }

    // MARK: SAVE BUTTON
    private var saveButton: some View {
        VStack {
            Spacer()

            Button {
                profileManager.save()
                withAnimation { showSavedBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showSavedBanner = false }
                }
            } label: {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: SAVED BANNER
    private var savedBanner: some View {
        VStack {
            Spacer()

            Text("✔ Saved!")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
