//
//  CIS357ProjectApp.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/12/25.
//

import SwiftUI

@main
struct CIS357ProjectApp: App {
    @StateObject private var viewModel = WorkoutViewModel()
    @StateObject private var navigator = MyNavigator()
    @StateObject private var healthKit = HealthkitIntegration()

    //Global Theme Manager
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(navigator)
                .environmentObject(healthKit)
                .environmentObject(theme)   // ← give entire app access to theme
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)  // ← APPLY THEME GLOBALLY
        }
    }
}
