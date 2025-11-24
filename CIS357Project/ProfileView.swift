import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: UIImage?

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {

                    // Profile Image
                    VStack {
                        if let image = profileManager.profileImage() {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                .padding(.bottom, 8)
                        } else {
                            Circle()
                                .fill(.white.opacity(0.3))
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

                    // Text Fields
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

                    // Fitness Level Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fitness Level")
                            .font(.headline)
                            .foregroundColor(.white)

                        Picker("Fitness Level",
                               selection: $profileManager.profile.fitnessLevel) {
                            ForEach(FitnessLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .padding()

                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // rofile Field Builder
    private func profileField(title: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)

            TextField(title, text: value)
                .padding()
                .background(.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
    }
}
