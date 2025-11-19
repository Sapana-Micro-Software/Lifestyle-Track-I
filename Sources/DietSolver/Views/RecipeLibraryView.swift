//
//  RecipeLibraryView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Recipe Library View
struct RecipeLibraryView: View {
    @StateObject private var libraryManager = RecipeLibraryManager.shared
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var searchText: String = ""
    @State private var selectedMealType: Meal.MealType? = nil
    @State private var showRatingFilter = false
    @State private var minRating: Double = 0.0
    
    var filteredRecipes: [SavedRecipe] {
        var recipes = libraryManager.savedRecipes
        
        // Search filter
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.mealName.lowercased().contains(searchText.lowercased()) ||
                recipe.items.contains { $0.foodName.lowercased().contains(searchText.lowercased()) }
            }
        }
        
        // Meal type filter
        if let mealType = selectedMealType {
            recipes = recipes.filter { $0.mealType == mealType }
        }
        
        // Rating filter
        if showRatingFilter && minRating > 0 {
            recipes = recipes.filter { ($0.rating ?? 0) >= minRating }
        }
        
        return recipes.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filters
            VStack(spacing: AppDesign.Spacing.md) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    TextField("Search recipes...", text: $searchText)
                        .foregroundColor(.black)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(AppDesign.Colors.surface)
                .cornerRadius(12)
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppDesign.Spacing.sm) {
                        // Meal Type Filter
                        Picker("Meal Type", selection: $selectedMealType) {
                            Text("All").tag(Meal.MealType?.none)
                            ForEach(Meal.MealType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(Meal.MealType?.some(type))
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, AppDesign.Spacing.md)
                        .padding(.vertical, AppDesign.Spacing.xs)
                        .background(AppDesign.Colors.surface)
                        .cornerRadius(8)
                        
                        // Rating Filter
                        Toggle("Min Rating", isOn: $showRatingFilter)
                            .padding(.horizontal, AppDesign.Spacing.md)
                            .padding(.vertical, AppDesign.Spacing.xs)
                            .background(AppDesign.Colors.surface)
                            .cornerRadius(8)
                        
                        if showRatingFilter {
                            Slider(value: $minRating, in: 0...5, step: 0.5)
                                .frame(width: 150)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.vertical, AppDesign.Spacing.md)
            .background(AppDesign.Colors.background)
            
            // Recipe List
            if filteredRecipes.isEmpty {
                Spacer()
                VStack(spacing: AppDesign.Spacing.md) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    Text("No recipes found")
                        .font(AppDesign.Typography.headline)
                    Text(searchText.isEmpty ? "Save recipes from your meal plans to build your library" : "Try adjusting your search or filters")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: AppDesign.Spacing.md) {
                        ForEach(filteredRecipes) { recipe in
                            RecipeCard(recipe: recipe, libraryManager: libraryManager)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.bottom, AppDesign.Spacing.xl)
                }
            }
        }
        .navigationTitle("Recipe Library")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveCurrentMeal) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(viewModel.dietPlan == nil && viewModel.dailyPlans.isEmpty)
            }
            #endif
        }
    }
    
    private func saveCurrentMeal() {
        // Try to save from current diet plan
        if let dietPlan = viewModel.dietPlan {
            for meal in dietPlan.meals {
                libraryManager.saveRecipe(from: meal)
            }
        } else if !viewModel.dailyPlans.isEmpty {
            // Save recipes from daily plans
            for plan in viewModel.dailyPlans {
                if let dietPlan = plan.dietPlan {
                    for meal in dietPlan.meals {
                        libraryManager.saveRecipe(from: meal)
                    }
                }
            }
        }
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let recipe: SavedRecipe
    @ObservedObject var libraryManager: RecipeLibraryManager
    @State private var showDetails = false
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                        Text(recipe.mealName)
                            .font(AppDesign.Typography.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: AppDesign.Spacing.sm) {
                            Label(recipe.mealType.rawValue.capitalized, systemImage: mealTypeIcon(recipe.mealType))
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            
                            if recipe.timesMade > 0 {
                                Label("\(recipe.timesMade)x", systemImage: "checkmark.circle.fill")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.success)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Rating
                    if let rating = recipe.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppDesign.Colors.accent)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", rating))
                                .font(AppDesign.Typography.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // Items Preview
                Text("\(recipe.items.count) ingredients")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                
                // Actions
                HStack {
                    Button(action: { showDetails.toggle() }) {
                        Label("View Recipe", systemImage: "eye.fill")
                            .font(AppDesign.Typography.subheadline)
                    }
                    
                    Spacer()
                    
                    Button(action: { libraryManager.markRecipeAsMade(recipe.id) }) {
                        Label("Made", systemImage: "checkmark")
                            .font(AppDesign.Typography.subheadline)
                    }
                    
                    Button(action: { libraryManager.deleteRecipe(recipe.id) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, AppDesign.Spacing.xs)
            }
            .padding(AppDesign.Spacing.md)
        }
        .sheet(isPresented: $showDetails) {
            RecipeDetailView(recipe: recipe, libraryManager: libraryManager)
        }
    }
    
    private func mealTypeIcon(_ type: Meal.MealType) -> String {
        switch type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: SavedRecipe
    @ObservedObject var libraryManager: RecipeLibraryManager
    @Environment(\.dismiss) var dismiss
    @State private var rating: Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Recipe Details")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.primary)
                .padding(.trailing, AppDesign.Spacing.md)
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text(recipe.mealName)
                            .font(AppDesign.Typography.title)
                            .fontWeight(.bold)
                        
                        Text(recipe.mealType.rawValue.capitalized)
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Ingredients")
                            .font(AppDesign.Typography.headline)
                        
                        ForEach(recipe.items) { item in
                            HStack {
                                Circle()
                                    .fill(AppDesign.Colors.primary.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                Text(item.foodName)
                                Spacer()
                                Text("\(String(format: "%.1f", item.amount)) \(item.unit)")
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            .font(AppDesign.Typography.body)
                        }
                    }
                    
                    // Recipe Instructions
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Instructions")
                            .font(AppDesign.Typography.headline)
                        
                        Text(recipe.recipeText)
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                    }
                    
                    // Rating
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Rate this recipe")
                            .font(AppDesign.Typography.headline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: { 
                                    rating = Double(star)
                                    libraryManager.rateRecipe(recipe.id, rating: rating)
                                }) {
                                    Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                        .foregroundColor(star <= Int(rating) ? AppDesign.Colors.accent : AppDesign.Colors.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(AppDesign.Spacing.md)
            }
        }
        .onAppear {
            rating = recipe.rating ?? 0.0
        }
    }
}
