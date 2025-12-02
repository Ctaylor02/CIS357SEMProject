//
//  ThemeManager.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/13/25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkModePreference")
        }
    }

    // Primary accent color used throughout the app
    @Published var accentColor: Color

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModePreference")
        // Choose a default accent color; can be made dynamic later if desired
        self.accentColor = .purple
    }
}
