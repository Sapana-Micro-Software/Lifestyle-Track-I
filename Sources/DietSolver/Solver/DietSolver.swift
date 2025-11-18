import Foundation

// MARK: - Meal Item
struct MealItem: Codable, Identifiable {
    let id: UUID
    let food: Food
    var amount: Double // in grams
    
    init(food: Food, amount: Double) {
        self.id = UUID()
        self.food = food
        self.amount = amount
    }
    
    var nutrientContent: NutrientContent {
        food.nutrientContent.scaled(by: amount)
    }
}

// MARK: - Meal
struct Meal: Codable, Identifiable {
    let id: UUID
    let name: String
    var items: [MealItem]
    let mealType: MealType
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast, lunch, dinner, snack
    }
    
    var totalNutrients: NutrientContent {
        items.reduce(NutrientContent()) { $0 + $1.nutrientContent }
    }
    
    var tasteScore: Double {
        guard !items.isEmpty else { return 0 }
        let weightedScore = items.reduce(0.0) { sum, item in
            sum + item.food.properties.tasteScore * (item.amount / 100.0)
        }
        let totalAmount = items.reduce(0.0) { $0 + $1.amount }
        return weightedScore / (totalAmount / 100.0)
    }
    
    var digestionScore: Double {
        guard !items.isEmpty else { return 0 }
        let weightedScore = items.reduce(0.0) { sum, item in
            sum + item.food.properties.digestionScore * (item.amount / 100.0)
        }
        let totalAmount = items.reduce(0.0) { $0 + $1.amount }
        return weightedScore / (totalAmount / 100.0)
    }
}

// MARK: - Daily Diet Plan
struct DailyDietPlan: Codable {
    var meals: [Meal]
    let season: Season
    let healthData: HealthData
    
    var totalNutrients: NutrientContent {
        meals.reduce(NutrientContent()) { $0 + $1.totalNutrients }
    }
    
    var overallTasteScore: Double {
        guard !meals.isEmpty else { return 0 }
        return meals.reduce(0.0) { $0 + $1.tasteScore } / Double(meals.count)
    }
    
    var overallDigestionScore: Double {
        guard !meals.isEmpty else { return 0 }
        return meals.reduce(0.0) { $0 + $1.digestionScore } / Double(meals.count)
    }
}

// MARK: - Diet Solver
class DietSolver {
    private let foodDatabase = FoodDatabase.shared
    
    // Simple gradient descent-like optimization
    func solve(healthData: HealthData, season: Season) -> DailyDietPlan {
        let requirements = healthData.adjustedNutrientRequirements()
        let availableFoods = foodDatabase.foodsForSeason(season)
        
        // Initialize with random amounts
        var solution: [Food: Double] = [:]
        for food in availableFoods {
            solution[food] = Double.random(in: 0...500) // grams
        }
        
        // Optimize using iterative improvement
        var bestScore = Double.infinity
        var bestSolution = solution
        let iterations = 1000
        
        for _ in 0..<iterations {
            // Calculate current nutrient totals
            let currentNutrients = calculateNutrients(from: solution)
            
            // Calculate score (lower is better)
            let score = calculateScore(
                nutrients: currentNutrients,
                requirements: requirements,
                solution: solution,
                season: season
            )
            
            if score < bestScore {
                bestScore = score
                bestSolution = solution
            }
            
            // Adjust solution
            solution = adjustSolution(
                current: solution,
                nutrients: currentNutrients,
                requirements: requirements,
                availableFoods: availableFoods
            )
        }
        
        // Convert solution to meals
        let meals = createMeals(from: bestSolution, season: season)
        
        return DailyDietPlan(meals: meals, season: season, healthData: healthData)
    }
    
    private func calculateNutrients(from solution: [Food: Double]) -> NutrientContent {
        var total = NutrientContent()
        for (food, amount) in solution {
            total = total + food.nutrientContent.scaled(by: amount)
        }
        return total
    }
    
    private func calculateScore(
        nutrients: NutrientContent,
        requirements: [String: NutrientRequirement],
        solution: [Food: Double],
        season: Season
    ) -> Double {
        var score = 0.0
        
        // Nutrient deficiency/excess penalties
        score += abs(nutrients.calories - (requirements["calories"]?.dailyValue ?? 0)) * 0.1
        score += abs(nutrients.protein - (requirements["protein"]?.dailyValue ?? 0)) * 10
        score += abs(nutrients.carbohydrates - (requirements["carbs"]?.dailyValue ?? 0)) * 2
        score += abs(nutrients.fats - (requirements["fats"]?.dailyValue ?? 0)) * 5
        score += abs(nutrients.fiber - (requirements["fiber"]?.dailyValue ?? 0)) * 5
        
        // Vitamins
        score += max(0, (requirements["vitamin_a"]?.dailyValue ?? 0) - nutrients.vitaminA) * 2
        score += max(0, (requirements["vitamin_c"]?.dailyValue ?? 0) - nutrients.vitaminC) * 2
        score += max(0, (requirements["vitamin_d"]?.dailyValue ?? 0) - nutrients.vitaminD) * 5
        score += max(0, (requirements["vitamin_e"]?.dailyValue ?? 0) - nutrients.vitaminE) * 2
        score += max(0, (requirements["vitamin_k"]?.dailyValue ?? 0) - nutrients.vitaminK) * 2
        score += max(0, (requirements["thiamin"]?.dailyValue ?? 0) - nutrients.thiamin) * 10
        score += max(0, (requirements["riboflavin"]?.dailyValue ?? 0) - nutrients.riboflavin) * 10
        score += max(0, (requirements["niacin"]?.dailyValue ?? 0) - nutrients.niacin) * 5
        score += max(0, (requirements["vitamin_b6"]?.dailyValue ?? 0) - nutrients.vitaminB6) * 10
        score += max(0, (requirements["folate"]?.dailyValue ?? 0) - nutrients.folate) * 2
        score += max(0, (requirements["vitamin_b12"]?.dailyValue ?? 0) - nutrients.vitaminB12) * 10
        
        // Minerals
        score += max(0, (requirements["calcium"]?.dailyValue ?? 0) - nutrients.calcium) * 0.5
        score += max(0, (requirements["iron"]?.dailyValue ?? 0) - nutrients.iron) * 10
        score += max(0, (requirements["magnesium"]?.dailyValue ?? 0) - nutrients.magnesium) * 2
        score += max(0, (requirements["phosphorus"]?.dailyValue ?? 0) - nutrients.phosphorus) * 1
        score += max(0, (requirements["potassium"]?.dailyValue ?? 0) - nutrients.potassium) * 0.1
        score += max(0, (requirements["zinc"]?.dailyValue ?? 0) - nutrients.zinc) * 10
        score += max(0, (requirements["copper"]?.dailyValue ?? 0) - nutrients.copper) * 20
        score += max(0, (requirements["manganese"]?.dailyValue ?? 0) - nutrients.manganese) * 10
        score += max(0, (requirements["selenium"]?.dailyValue ?? 0) - nutrients.selenium) * 5
        
        // Taste and digestion (lower is better, so we subtract)
        let avgTaste = solution.reduce(0.0) { sum, item in
            sum + item.key.properties.tasteScore * (item.value / 100.0)
        } / max(1.0, solution.values.reduce(0, +) / 100.0)
        score -= avgTaste * 2 // Reward good taste
        
        let avgDigestion = solution.reduce(0.0) { sum, item in
            sum + item.key.properties.digestionScore * (item.value / 100.0)
        } / max(1.0, solution.values.reduce(0, +) / 100.0)
        score -= avgDigestion * 2 // Reward good digestion
        
        // Penalize too much of any single food
        for amount in solution.values {
            if amount > 500 {
                score += (amount - 500) * 0.1
            }
        }
        
        return score
    }
    
    private func adjustSolution(
        current: [Food: Double],
        nutrients: NutrientContent,
        requirements: [String: NutrientRequirement],
        availableFoods: [Food]
    ) -> [Food: Double] {
        var adjusted = current
        
        // Randomly adjust some foods
        for food in availableFoods.prefix(10) {
            let adjustment = Double.random(in: -50...50)
            adjusted[food] = max(0, (adjusted[food] ?? 0) + adjustment)
        }
        
        return adjusted
    }
    
    private func createMeals(from solution: [Food: Double], season: Season) -> [Meal] {
        var meals: [Meal] = []
        let foodItems = solution.filter { $0.value > 10 } // Only include meaningful amounts
            .sorted { $0.value > $1.value }
        
        // Distribute foods across meals
        var usedFoods: Set<Food> = []
        
        // Breakfast (lighter, easier to digest)
        let breakfastFoods = foodItems.filter { food, _ in
            !usedFoods.contains(food) &&
            food.properties.digestionScore > 7.0 &&
            (food.category == .fruit || food.category == .grain || food.category == .dairy)
        }.prefix(5)
        var breakfastItems: [MealItem] = []
        for (food, amount) in breakfastFoods {
            breakfastItems.append(MealItem(food: food, amount: amount * 0.3))
            usedFoods.insert(food)
        }
        if !breakfastItems.isEmpty {
            meals.append(Meal(id: UUID(), name: "Breakfast", items: breakfastItems, mealType: .breakfast))
        }
        
        // Lunch (balanced)
        let lunchFoods = foodItems.filter { food, _ in !usedFoods.contains(food) }.prefix(8)
        var lunchItems: [MealItem] = []
        for (food, amount) in lunchFoods {
            lunchItems.append(MealItem(food: food, amount: amount * 0.35))
            usedFoods.insert(food)
        }
        if !lunchItems.isEmpty {
            meals.append(Meal(id: UUID(), name: "Lunch", items: lunchItems, mealType: .lunch))
        }
        
        // Dinner (can be heavier)
        let dinnerFoods = foodItems.filter { food, _ in !usedFoods.contains(food) }.prefix(8)
        var dinnerItems: [MealItem] = []
        for (food, amount) in dinnerFoods {
            dinnerItems.append(MealItem(food: food, amount: amount * 0.35))
        }
        if !dinnerItems.isEmpty {
            meals.append(Meal(id: UUID(), name: "Dinner", items: dinnerItems, mealType: .dinner))
        }
        
        return meals
    }
}
