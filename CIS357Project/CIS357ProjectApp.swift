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
    @StateObject private var Healthkit = HealthkitIntegration()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(navigator)
                .environmentObject(Healthkit)
        }
    }
}
