//
//  UserProfileManager.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/24/25.
//

// UserProfileManager.swift
import SwiftUI
import Combine

@MainActor
class UserProfileManager: ObservableObject {

    @Published var profile: UserProfile

    init() {
        self.profile = UserProfile()
        load()
    }

    func profileImage() -> UIImage? {
        guard let data = profile.photoData else { return nil }
        return UIImage(data: data)
    }

    func updateProfileImage(_ image: UIImage) {
        profile.photoData = image.jpegData(compressionQuality: 0.8)
        save()
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let loadedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = loadedProfile
        }
    }
}
