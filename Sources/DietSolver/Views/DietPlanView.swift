import SwiftUI

struct DietPlanView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MealsView(plan: viewModel.dietPlan!)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
                .tag(0)
            
            RecipesView(plan: viewModel.dietPlan!)
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
                .tag(1)
            
            NutritionFactsView(plan: viewModel.dietPlan!, healthData: viewModel.healthData!)
                .tabItem {
                    Label("Nutrition", systemImage: "chart.bar")
                }
                .tag(2)
            
            SongView(plan: viewModel.dietPlan!)
                .tabItem {
                    Label("Song", systemImage: "music.note")
                }
                .tag(3)
            
            if let exercisePlan = viewModel.exercisePlan, let healthData = viewModel.healthData {
                ExercisePlanView(plan: exercisePlan, healthData: healthData)
                    .tabItem {
                        Label("Exercise", systemImage: "figure.run")
                    }
                    .tag(4)
            }
            
            if let healthData = viewModel.healthData {
                ExerciseLogView(healthData: Binding(
                    get: { healthData },
                    set: { viewModel.updateHealthData($0) }
                ))
                .tabItem {
                    Label("Log Exercise", systemImage: "plus.circle")
                }
                .tag(5)
            }
        }
        .navigationTitle("Your Diet Plan")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("New Plan") {
                    viewModel.reset()
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button("New Plan") {
                    viewModel.reset()
                }
            }
            #endif
        }
    }
}

struct MealsView: View {
    let plan: DailyDietPlan
    
    var body: some View {
        ModernMealsView(plan: plan)
    }
}

struct RecipesView: View {
    let plan: DailyDietPlan
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(plan.meals) { meal in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(meal.name)
                            .font(.title2)
                            .bold()
                        
                        Text(RecipeGenerator.generateRecipe(for: meal))
                            .font(.body)
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct NutritionFactsView: View {
    let plan: DailyDietPlan
    let healthData: HealthData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(NutritionFactsGenerator.generateNutritionFacts(
                    for: plan,
                    requirements: healthData.adjustedNutrientRequirements()
                ))
                .font(.body)
            }
            .padding()
        }
    }
}

struct SongView: View {
    let plan: DailyDietPlan
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(SongGenerator.generateSong(for: plan))
                    .font(.body)
            }
            .padding()
        }
    }
}
