//
//  RecipeLibraryManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Recipe Library Manager
class RecipeLibraryManager: ObservableObject {
    static let shared = RecipeLibraryManager()
    
    @Published var savedRecipes: [SavedRecipe] = []
    
    private let userDefaultsKey = "savedRecipes"
    
    private init() {
        loadRecipes()
    }
    
    // MARK: - Save Recipe
    func saveRecipe(from meal: Meal, rating: Double? = nil) {
        let recipeItems = meal.items.map { item in
            SavedRecipe.SavedRecipeItem(
                foodName: item.food.name,
                amount: item.amount,
                unit: "g"
            )
        }
        
        let recipe = SavedRecipe(
            id: UUID(),
            mealName: meal.name,
            mealType: meal.mealType,
            items: recipeItems,
            recipeText: RecipeGenerator.generateRecipe(for: meal),
            savedDate: Date(),
            rating: rating,
            timesMade: 0
        )
        
        // Check if recipe already exists
        if let existingIndex = savedRecipes.firstIndex(where: { $0.mealName == meal.name && $0.items.count == meal.items.count }) {
            savedRecipes[existingIndex] = recipe
        } else {
            savedRecipes.append(recipe)
        }
        
        saveRecipes()
    }
    
    // MARK: - Rate Recipe
    func rateRecipe(_ recipeId: UUID, rating: Double) {
        guard let index = savedRecipes.firstIndex(where: { $0.id == recipeId }) else { return }
        savedRecipes[index].rating = rating
        saveRecipes()
    }
    
    // MARK: - Mark Recipe as Made
    func markRecipeAsMade(_ recipeId: UUID) {
        guard let index = savedRecipes.firstIndex(where: { $0.id == recipeId }) else { return }
        savedRecipes[index].timesMade += 1
        savedRecipes[index].lastMadeDate = Date()
        saveRecipes()
    }
    
    // MARK: - Delete Recipe
    func deleteRecipe(_ recipeId: UUID) {
        savedRecipes.removeAll { $0.id == recipeId }
        saveRecipes()
    }
    
    // MARK: - Get Favorite Recipes
    func getFavoriteRecipes(minRating: Double = 4.0) -> [SavedRecipe] {
        return savedRecipes.filter { ($0.rating ?? 0) >= minRating }
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
    }
    
    // MARK: - Get Most Made Recipes
    func getMostMadeRecipes(limit: Int = 10) -> [SavedRecipe] {
        return savedRecipes.sorted { $0.timesMade > $1.timesMade }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Search Recipes
    func searchRecipes(query: String) -> [SavedRecipe] {
        let lowercasedQuery = query.lowercased()
        return savedRecipes.filter { recipe in
            recipe.mealName.lowercased().contains(lowercasedQuery) ||
            recipe.items.contains { $0.foodName.lowercased().contains(lowercasedQuery) }
        }
    }
    
    // MARK: - Filter by Meal Type
    func filterByMealType(_ mealType: Meal.MealType) -> [SavedRecipe] {
        return savedRecipes.filter { $0.mealType == mealType }
    }
    
    // MARK: - Persistence
    private func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(savedRecipes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([SavedRecipe].self, from: data) {
            savedRecipes = decoded
        }
    }
}

// MARK: - Saved Recipe
struct SavedRecipe: Codable, Identifiable {
    let id: UUID
    var mealName: String
    var mealType: Meal.MealType
    var items: [SavedRecipeItem]
    var recipeText: String
    var savedDate: Date
    var rating: Double? // 0-5 stars
    var timesMade: Int
    var lastMadeDate: Date?
    
    struct SavedRecipeItem: Codable, Identifiable {
        let id: UUID
        var foodName: String
        var amount: Double
        var unit: String
        
        init(id: UUID = UUID(), foodName: String, amount: Double, unit: String) {
            self.id = id
            self.foodName = foodName
            self.amount = amount
            self.unit = unit
        }
    }
    
    init(id: UUID = UUID(), mealName: String, mealType: Meal.MealType, items: [SavedRecipeItem], recipeText: String, savedDate: Date, rating: Double? = nil, timesMade: Int = 0, lastMadeDate: Date? = nil) {
        self.id = id
        self.mealName = mealName
        self.mealType = mealType
        self.items = items
        self.recipeText = recipeText
        self.savedDate = savedDate
        self.rating = rating
        self.timesMade = timesMade
        self.lastMadeDate = lastMadeDate
    }
}
