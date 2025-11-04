//
//  StepCountView.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/18/25.
//

import SwiftUI

struct Activities {
    let id: Int
    let title: String
    let subtitles: String
    let image: String
    let amount: String
}


struct StepCountView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator
    @State private var selectedPeriod: StepPeriod = .daily
    @EnvironmentObject var healthKit: HealthkitIntegration

    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // MARK: - Header
                Text("Step Count")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        .linearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(radius: 5)
                    .padding(.top, 20)

                // MARK: - Segmented Button Bar
                HStack(spacing: 0) {
                    ForEach(StepPeriod.allCases, id: \.self) { period in
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedPeriod = period
                            }
                        } label: {
                            Text(period.title)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            selectedPeriod == period
                                            ? Color.purple.opacity(0.3)
                                            : Color.white.opacity(0.1)
                                        )
                                )
                                .foregroundColor(selectedPeriod == period ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                        .shadow(radius: 3)
                )
                .padding(.horizontal)

                // MARK: - Step Count Display
                VStack(spacing: 20) {
                    // Break into a local variable to avoid compiler overload
                    let stepCount = selectedPeriod.displaySteps(from: healthKit)

                    Text(stepCount)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.2))
                        )
                        .shadow(radius: 8)

                    Text(selectedPeriod.subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationTitle("Step Count")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Step Period Enum
enum StepPeriod: CaseIterable {
    case daily, weekly, monthly

    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }

    var subtitle: String {
        switch self {
        case .daily: return "Steps Today"
        case .weekly: return "Steps This Week"
        case .monthly: return "Steps This Month"
        }
    }

    func displaySteps(from healthKit: HealthkitIntegration) -> String {
        switch self {
        case .daily: return "\(healthKit.dailySteps)"
        case .weekly: return "\(healthKit.weeklySteps)"
        case .monthly: return "\(healthKit.monthlySteps)"
        }
    }
}

// MARK: - Preview
#Preview {
    StepCountView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
}
