import SwiftUI

//  Step Period Enum
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
        
        
        let steps = computeSteps()
        
        return ZStack {
            backgroundGradient
            
            VStack(spacing: 40) {
                
                header
                
                periodPicker
                
                stepDisplay(steps: steps)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear { healthKit.dailyStepsUpdate() }
        .navigationTitle("Step Count")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension StepCountView {
    
    // Compute Step Count
    private func computeSteps() -> Int {
        switch selectedPeriod {
        case .daily: return healthKit.dailySteps
        case .weekly: return healthKit.weeklySteps
        case .monthly: return healthKit.monthlySteps
        }
    }
    
    //  Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.25),
                     Color.purple.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // Header
    private var header: some View {
        Text("Step Count")
            .font(.system(size: 36, weight: .heavy, design: .rounded))
            .foregroundStyle(
                .linearGradient(colors: [.pink, .purple],
                                startPoint: .top,
                                endPoint: .bottom)
            )
            .shadow(radius: 5)
            .padding(.top, 20)
    }
    
    // Segmented Picker
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
                                .fill(
                                    selectedPeriod == period
                                    ? Color.purple.opacity(0.35)
                                    : Color.white.opacity(0.12)
                                )
                        )
                        .foregroundColor(selectedPeriod == period ? .white : .primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
    
    //  Step Display
    private func stepDisplay(steps: Int) -> some View {
        VStack(spacing: 20) {
            
            Text("\(steps)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.22))
                )
                .shadow(radius: 8)
            
            Text(selectedPeriod.subtitle)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StepCountView(viewModel: WorkoutViewModel())
        .environmentObject(MyNavigator())
        .environmentObject(HealthkitIntegration())
}
