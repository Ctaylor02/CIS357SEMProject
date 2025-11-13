//
//  SettingsView.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/13/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var theme: ThemeManager  // ← GLOBAL THEME MANAGER

    @AppStorage("dailyGoal") private var dailyGoal: Int = 10000
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true

    @State private var showResetAlert = false
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Animated Gradient Background
            LinearGradient(
                colors: [Color.purple.opacity(0.25), Color.blue.opacity(0.25), Color.cyan.opacity(0.25)],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)
            .onAppear { animateGradient = true }

            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.linearGradient(colors: [.purple, .blue],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing))
                        .padding(.top, 20)

                    // Appearance
                    settingsCard(title: "Appearance") {
                        Toggle(isOn: $theme.isDarkMode) { // ← Use global theme
                            Label("Dark Mode", systemImage: theme.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(theme.isDarkMode ? .yellow : .orange)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    }

                    // Daily Goal
                    settingsCard(title: "Daily Goal") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Set your daily step/workout goal:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack {
                                Text("\(dailyGoal.formatted()) steps")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            Slider(value: Binding(
                                get: { Double(dailyGoal) },
                                set: { dailyGoal = Int($0) }
                            ), in: 1000...20000, step: 500)
                                .tint(.purple)
                        }
                    }

                    //  Haptics
                    settingsCard(title: "Feedback") {
                        Toggle(isOn: $hapticsEnabled) {
                            Label("Enable Haptic Feedback", systemImage: "waveform.path")
                                .foregroundColor(.purple)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    }

                    //  Reset Button
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.red.opacity(0.2)))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.red, lineWidth: 1.5))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .alert("Reset All Data?", isPresented: $showResetAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Reset", role: .destructive) {
                            viewModel.clearHistory()
                            viewModel.saveHistory()
                            viewModel.resetStreakData()
                        }
                    } message: {
                        Text("This will permanently delete all workouts, streaks, and achievements.")
                    }

                    Spacer(minLength: 50)
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(theme.isDarkMode ? .dark : .light) // ← Applies theme globally
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    //  Card Style Builder
    @ViewBuilder
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.15)))
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

#Preview {
    SettingsView(viewModel: WorkoutViewModel())
        .environmentObject(ThemeManager())
}
