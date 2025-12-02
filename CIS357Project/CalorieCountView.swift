import SwiftUI
import Foundation

enum caloriePeriod: CaseIterable {
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
        case .daily: return "Today"
        case .weekly: return "Last 7 Days"
        case .monthly: return "Last 30 Days"
        }
    }
}


struct CalorieCountView: View {
    @EnvironmentObject var navigator: MyNavigator
    @EnvironmentObject var healthKit: HealthkitIntegration
    @ObservedObject var viewModel: WorkoutViewModel
    
    @State private var selectedPeriod: caloriePeriod = .daily
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 30) {
                header
                
                periodPicker
                
                progressSection
                
                calorieInfoCard
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear { healthKit.dailyCaloriesUpdate() }
        .navigationTitle("Calorie Count")
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension CalorieCountView {
    private var calorieValue: Int {
        switch selectedPeriod {
        case .daily: return healthKit.dailyCalories > 0 ? healthKit.dailyCalories: Int(Double(healthKit.dailySteps) * 0.04)
        case .weekly: return healthKit.weeklyCalories > 0 ? healthKit.weeklyCalories: Int(Double(healthKit.weeklySteps) * 0.04)
        case .monthly: return healthKit.monthlyCalories > 0 ? healthKit.monthlyCalories: Int(Double(healthKit.monthlySteps) * 0.04)
        }
    }
    

    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.20)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var header: some View {
        Text("Calorie Count")
            .font(.system(size: 36, weight: .heavy, design: .rounded))
            .foregroundStyle(.linearGradient(colors: [.pink, .purple],
                                             startPoint: .top,
                                             endPoint: .bottom))
            .shadow(radius: 5)
    }
    
    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(caloriePeriod.allCases, id: \.self) { period in
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
    
    private var progressSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 16)
                
                Circle()
                    .trim(from: 0, to: min(CGFloat(calorieValue) / 10000, 1.0))
                    .stroke(
                        AngularGradient(colors: [.green, .yellow, .orange, .red],
                                        center: .center),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: calorieValue)
                
                VStack {
                    Text("\(calorieValue)")
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
    
    private var calorieInfoCard: some View {
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
            return calorieValue < 5000 ? "Try taking a short walk today!" : "Awesome! You're above your daily average."
        case .weekly:
            return "Tracking consistent weekly activity helps build great habits."
        case .monthly:
            return "Monthly progress shows how strong your routine is becoming."
        }
    }
//    Text("(Calories only calculated from AppleWatch)")
}

//#Preview {
//    CalorieCountView(viewModel: WorkoutViewModel())
//        .environmentObject(MyNavigator())
//        .environmentObject(HealthkitIntegration())
//}
