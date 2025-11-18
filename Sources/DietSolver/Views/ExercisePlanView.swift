import SwiftUI

struct ExercisePlanView: View {
    let plan: ExercisePlan
    let healthData: HealthData
    
    var body: some View {
        ModernExercisePlanView(plan: plan, healthData: healthData)
    }
}

struct LegacyExercisePlanView: View {
    let plan: ExercisePlan
    let healthData: HealthData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Focus Areas
                if !plan.focusAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Focus Areas")
                            .font(.headline)
                        ForEach(plan.focusAreas, id: \.self) { area in
                            HStack {
                                Image(systemName: "target")
                                Text(area)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(10)
                }
                
                // Weekly Plan
                Text("Weekly Exercise Plan")
                    .font(.title2)
                    .bold()
                
                ForEach(plan.weeklyPlan) { dayPlan in
                    DayPlanView(dayPlan: dayPlan, healthData: healthData)
                }
                
                // Goals Summary
                GoalsSummaryView(goals: plan.goals)
            }
            .padding()
        }
        .navigationTitle("Exercise Plan")
    }
}

struct DayPlanView: View {
    let dayPlan: ExercisePlan.DayPlan
    let healthData: HealthData
    
    private var dayName: String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayPlan.dayOfWeek]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dayName)
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(dayPlan.activities) { activity in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.activity.name)
                            .font(.subheadline)
                            .bold()
                        Text("\(String(format: "%.0f", activity.duration)) min • \(activity.timeOfDay.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(activity.activity.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor(activity.activity.category))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.vertical, 4)
            }
            
            // Calculate estimated calories
            let totalCalories = dayPlan.activities.reduce(0.0) { sum, activity in
                let planner = ExercisePlanner()
                return sum + planner.calculateCaloriesBurned(
                    activity: activity.activity,
                    duration: activity.duration,
                    weight: healthData.weight
                )
            }
            
            if totalCalories > 0 {
                Text("Estimated Calories: \(String(format: "%.0f", totalCalories)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .cornerRadius(10)
    }
    
    private func categoryColor(_ category: ExerciseCategory) -> Color {
        switch category {
        case .cardio: return .red
        case .strength: return .blue
        case .flexibility: return .green
        case .mindBody: return .purple
        case .breathing: return .orange
        case .dance: return .pink
        case .martialArts: return .brown
        case .functional: return .gray
        }
    }
}

struct GoalsSummaryView: View {
    let goals: ExerciseGoals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Exercise Goals")
                .font(.headline)
            
            GoalRow(label: "Weekly Cardio", value: "\(String(format: "%.0f", goals.weeklyCardioMinutes)) min")
            GoalRow(label: "Strength Sessions", value: "\(goals.weeklyStrengthSessions)/week")
            GoalRow(label: "Flexibility", value: "\(String(format: "%.0f", goals.weeklyFlexibilityMinutes)) min/week")
            GoalRow(label: "Mind-Body", value: "\(String(format: "%.0f", goals.weeklyMindBodyMinutes)) min/week")
            GoalRow(label: "Daily Steps", value: "\(goals.dailySteps)")
            GoalRow(label: "Daily Stairs", value: "\(goals.dailyStairs) flights")
            GoalRow(label: "Breathing Practice", value: "\(String(format: "%.0f", goals.weeklyBreathingPractice)) min/week")
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .cornerRadius(10)
    }
}

struct GoalRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
