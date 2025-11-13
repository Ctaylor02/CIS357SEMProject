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

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModePreference")
    }
}
