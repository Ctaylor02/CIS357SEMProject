import SwiftUI
import Foundation

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
}


struct StepCountView: View {
    @EnvironmentObject var navigator: MyNavigator
    @EnvironmentObject var healthKit: HealthkitIntegration
    @ObservedObject var viewModel: WorkoutViewModel
    
    @State private var selectedPeriod: StepPeriod = .daily
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 30) {
                header
                
                periodPicker
                
                progressSection
                
                stepInfoCard
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear { healthKit.dailyStepsUpdate() }
        .navigationTitle("Step Count")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension StepCountView {
    
    // MARK: - Computed Step Value
    private var stepValue: Int {
        switch selectedPeriod {
        case .daily: return healthKit.dailySteps
        case .weekly: return healthKit.weeklySteps
        case .monthly: return healthKit.monthlySteps
        }
    }
    
    // MARK: - Background
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.20)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var header: some View {
        Text("Step Count")
            .font(.system(size: 36, weight: .heavy, design: .rounded))
            .foregroundStyle(.linearGradient(colors: [.pink, .purple],
                                             startPoint: .top,
                                             endPoint: .bottom))
            .shadow(radius: 5)
    }
    
    // MARK: - Segmented Picker
    private var periodPicker: some View {
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
                                .fill(selectedPeriod == period ?
                                      Color.purple.opacity(0.35) :
                                      Color.white.opacity(0.12))
                        )
                        .foregroundColor(selectedPeriod == period ? .white : .primary)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.15)))
    }
    
    // MARK: - Progress Ring + Step Number
    private var progressSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 16)
                
                Circle()
                    .trim(from: 0, to: min(CGFloat(stepValue) / 10000, 1.0))
                    .stroke(
                        AngularGradient(colors: [.green, .yellow, .orange, .red],
                                        center: .center),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: stepValue)
                
                VStack {
                    Text("\(stepValue)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text(selectedPeriod.subtitle)
                        .foregroundColor(.secondary)
                        .font(.headline)
                }
            }
            .frame(width: 220, height: 220)
        }
    }
    
    // MARK: - Step Info Card
    private var stepInfoCard: some View {
        VStack(spacing: 10) {
            Text("You're doing great!")
                .font(.title3.bold())
            
            Text(messageForPeriod())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.20)))
        .shadow(radius: 4)
    }
    
    private func messageForPeriod() -> String {
        switch selectedPeriod {
        case .daily:
            return stepValue < 5000 ? "Try taking a short walk today!" : "Awesome! You're above your daily average."
        case .weekly:
            return "Tracking consistent weekly activity helps build great habits."
        case .monthly:
            return "Monthly progress shows how strong your routine is becoming."
        }
    }
}

#Preview {
    StepCountView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
        .environmentObject(HealthkitIntegration())
}
