import SwiftUI

struct RecommendationView: View {
    @StateObject private var viewModel = RecommendationViewModel()

    var body: some View {
        ZStack {
            if let rec = viewModel.todayRecommendation {
                background(rec.themeColor)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        header(rec)

                        workoutCard(rec)
                        mealCard(rec)
                        whySection(rec)

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal)
                }
            } else {
                ProgressView("Loading recommendation...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension RecommendationView {

    //  Background
    private func background(_ color: Color) -> some View {
        LinearGradient(
            colors: [
                color.opacity(0.45),
                Color.black.opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // Header
    private func header(_ rec: DailyRecommendation) -> some View {
        VStack(spacing: 8) {
            Text("\(rec.emoji) \(rec.day)")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Text("Today's Recommendation")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }

    // Workout Card
    private func workoutCard(_ rec: DailyRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)

                Text("Workout")
                    .font(.title3.bold())
            }

            Text(rec.workout.name)
                .font(.headline)
                .foregroundColor(.primary)

            if let reps = rec.workout.reps {
                Text("Sets: \(rec.workout.sets) • Reps: \(reps)")
                    .foregroundColor(.secondary)
            }

            if let duration = rec.workout.durationMinutes {
                Text("Duration: \(duration) minutes")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 5)
    }

    //  Meal Card
    private func mealCard(_ rec: DailyRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 28))
                    .foregroundColor(.green)

                Text("Meal")
                    .font(.title3.bold())
            }

            Text(rec.meal.name)
                .font(.headline)

            Text("\(rec.meal.calories) Calories")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(rec.meal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 5)
    }

    //  Why Section
    private func whySection(_ rec: DailyRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)

                Text("Why This Recommendation?")
                    .font(.title3.bold())
            }

            Text("Based on your weekly routine, today's workout and meal help maintain balance and support healthy recovery.")
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

#Preview {
    NavigationStack { RecommendationView() }
}
