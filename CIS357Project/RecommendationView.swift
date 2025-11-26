import SwiftUI

struct RecommendationView: View {
    @StateObject private var viewModel = RecommendationViewModel()

    var body: some View {
        ZStack {
            backgroundGradient
            
            if let rec = viewModel.todayRecommendation {
                ScrollView {
                    VStack(spacing: 30) {
                        
                        titleHeader
                        
                        workoutCard(rec)
                        mealCard(rec)
                        
                        Spacer()
                    }
                    .padding()
                }
            } else {
                ProgressView("Loading recommendation...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Daily Recommendation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension RecommendationView {
    
    private var backgroundGradient: some View {
        LinearGradient(colors: [.orange.opacity(0.25), .pink.opacity(0.22)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
    
    private var titleHeader: some View {
        Text("Today's Recommendation")
            .font(.system(size: 34, weight: .heavy, design: .rounded))
            .foregroundStyle(
                .linearGradient(colors: [.purple, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
            )
            .padding(.top, 10)
    }
    
    //  Workout Card
    private func workoutCard(_ rec: DailyRecommendation) -> some View {
        VStack(spacing: 12) {
            Text("💪 Workout: \(rec.workout.name)")
                .font(.headline)
            
            if let reps = rec.workout.reps {
                Text("Sets: \(rec.workout.sets) • Reps: \(reps)")
            }
            if let duration = rec.workout.durationMinutes {
                Text("Duration: \(duration) minutes")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.20)))
        .shadow(radius: 5)
    }
    
    //  Meal Card
    private func mealCard(_ rec: DailyRecommendation) -> some View {
        VStack(spacing: 12) {
            Text("🥗 Meal: \(rec.meal.name)")
                .font(.headline)
            
            Text("\(rec.meal.calories) Calories")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(rec.meal.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.20)))
        .shadow(radius: 5)
    }
}

#Preview {
    NavigationStack {
        RecommendationView()
    }
}
