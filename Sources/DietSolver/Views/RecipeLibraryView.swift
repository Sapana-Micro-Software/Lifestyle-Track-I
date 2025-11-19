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
                ModernCard(shadow: AppDesign.Shadow.small, gradient: false) {
                    HStack(spacing: AppDesign.Spacing.sm) {
                        IconBadge(icon: "magnifyingglass", color: AppDesign.Colors.primary, size: 20)
                        TextField("Search recipes...", text: $searchText)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppDesign.Spacing.sm) {
                        // Meal Type Filter
                        ModernCard(shadow: AppDesign.Shadow.small, gradient: false) {
                            Picker("Meal Type", selection: $selectedMealType) {
                                Text("All").tag(Meal.MealType?.none)
                                ForEach(Meal.MealType.allCases, id: \.self) { type in
                                    Text(type.rawValue.capitalized).tag(Meal.MealType?.some(type))
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        
                        // Rating Filter
                        ModernCard(shadow: AppDesign.Shadow.small, gradient: false) {
                            Toggle("Min Rating", isOn: $showRatingFilter)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        
                        if showRatingFilter {
                            ModernCard(shadow: AppDesign.Shadow.small, gradient: false) {
                                HStack(spacing: AppDesign.Spacing.sm) {
                                    Text("\(String(format: "%.1f", minRating))")
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textPrimary)
                                        .frame(width: 30)
                                    Slider(value: $minRating, in: 0...5, step: 0.5)
                                        .tint(AppDesign.Colors.accent)
                                }
                                .frame(width: 180)
                            }
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
                EmptyStateView(
                    icon: "book.closed",
                    title: "No recipes found",
                    message: searchText.isEmpty ? "Save recipes from your meal plans to build your library" : "Try adjusting your search or filters"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: AppDesign.Spacing.md) {
                        ForEach(Array(filteredRecipes.enumerated()), id: \.element.id) { index, recipe in
                            RecipeCard(recipe: recipe, libraryManager: libraryManager)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                                .animation(
                                    AppDesign.Animation.spring.delay(Double(index) * 0.05),
                                    value: filteredRecipes.count
                                )
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
        .background(AppDesign.Colors.background.ignoresSafeArea())
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
    @State private var isHovered = false
    
    var body: some View {
        ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                HStack(alignment: .top) {
                    IconBadge(
                        icon: mealTypeIcon(recipe.mealType),
                        color: AppDesign.Colors.primary,
                        size: 40,
                        gradient: true
                    )
                    
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                        Text(recipe.mealName)
                            .font(AppDesign.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        
                        HStack(spacing: AppDesign.Spacing.sm) {
                            Label(recipe.mealType.rawValue.capitalized, systemImage: mealTypeIcon(recipe.mealType))
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            
                            if recipe.timesMade > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                    Text("\(recipe.timesMade)x")
                                }
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.success)
                                .padding(.horizontal, AppDesign.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(AppDesign.Colors.success.opacity(0.1))
                                .cornerRadius(AppDesign.Radius.small)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Rating
                    if let rating = recipe.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppDesign.Colors.accent)
                                .font(.system(size: 14))
                            Text(String(format: "%.1f", rating))
                                .font(AppDesign.Typography.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        .padding(.horizontal, AppDesign.Spacing.sm)
                        .padding(.vertical, AppDesign.Spacing.xs)
                        .background(AppDesign.Colors.accent.opacity(0.1))
                        .cornerRadius(AppDesign.Radius.small)
                    }
                }
                
                // Items Preview
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 10))
                        .foregroundColor(AppDesign.Colors.primary)
                    Text("\(recipe.items.count) ingredients")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                
                // Actions
                HStack(spacing: AppDesign.Spacing.sm) {
                    GradientButton(
                        title: "View Recipe",
                        icon: "eye.fill",
                        action: { showDetails.toggle() },
                        style: .secondary
                    )
                    
                    Button(action: {
                        withAnimation(AppDesign.Animation.spring) {
                            libraryManager.markRecipeAsMade(recipe.id)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text("Made")
                        }
                        .font(AppDesign.Typography.subheadline)
                        .foregroundColor(AppDesign.Colors.success)
                        .padding(.horizontal, AppDesign.Spacing.md)
                        .padding(.vertical, AppDesign.Spacing.sm)
                        .background(AppDesign.Colors.success.opacity(0.1))
                        .cornerRadius(AppDesign.Radius.small)
                    }
                    
                    Button(action: {
                        withAnimation(AppDesign.Animation.spring) {
                            libraryManager.deleteRecipe(recipe.id)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppDesign.Colors.error)
                            .padding(AppDesign.Spacing.sm)
                            .background(AppDesign.Colors.error.opacity(0.1))
                            .clipShape(Circle())
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

// MARK: - Helper Function
private func mealTypeIcon(_ type: Meal.MealType) -> String {
    switch type {
    case .breakfast: return "sunrise.fill"
    case .lunch: return "sun.max.fill"
    case .dinner: return "moon.fill"
    case .snack: return "leaf.fill"
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
            ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
                HStack {
                    IconBadge(icon: mealTypeIcon(recipe.mealType), color: AppDesign.Colors.primary, size: 32, gradient: true)
                    Text("Recipe Details")
                        .font(AppDesign.Typography.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    Spacer()
                    GradientButton(
                        title: "Done",
                        icon: nil,
                        action: { dismiss() },
                        style: .secondary
                    )
                    .frame(width: 80)
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            .padding(.top, AppDesign.Spacing.sm)
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.lg) {
                    // Header
                    ModernCard(shadow: AppDesign.Shadow.small, gradient: true) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            Text(recipe.mealName)
                                .font(AppDesign.Typography.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            
                            HStack(spacing: AppDesign.Spacing.sm) {
                                IconBadge(icon: mealTypeIcon(recipe.mealType), color: AppDesign.Colors.primary, size: 24)
                                Text(recipe.mealType.rawValue.capitalized)
                                    .font(AppDesign.Typography.body)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Ingredients
                    ModernCard(shadow: AppDesign.Shadow.small, gradient: true) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                IconBadge(icon: "list.bullet", color: AppDesign.Colors.primary, size: 24)
                                Text("Ingredients")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                            }
                            
                            ForEach(recipe.items) { item in
                                HStack(spacing: AppDesign.Spacing.sm) {
                                    Circle()
                                        .fill(AppDesign.Gradients.primary)
                                        .frame(width: 10, height: 10)
                                    Text(item.foodName)
                                        .font(AppDesign.Typography.body)
                                        .foregroundColor(AppDesign.Colors.textPrimary)
                                    Spacer()
                                    Text("\(String(format: "%.1f", item.amount)) \(item.unit)")
                                        .font(AppDesign.Typography.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppDesign.Colors.primary)
                                }
                                .padding(.vertical, AppDesign.Spacing.xs)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Recipe Instructions
                    ModernCard(shadow: AppDesign.Shadow.small, gradient: true) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                IconBadge(icon: "book.fill", color: AppDesign.Colors.accent, size: 24)
                                Text("Instructions")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                            }
                            
                            Text(recipe.recipeText)
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Rating
                    ModernCard(shadow: AppDesign.Shadow.small, gradient: true) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                IconBadge(icon: "star.fill", color: AppDesign.Colors.accent, size: 24)
                                Text("Rate this recipe")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                            }
                            
                            HStack(spacing: AppDesign.Spacing.sm) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: { 
                                        withAnimation(AppDesign.Animation.spring) {
                                            rating = Double(star)
                                            libraryManager.rateRecipe(recipe.id, rating: rating)
                                        }
                                    }) {
                                        Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                            .font(.system(size: 28, weight: .medium))
                                            .foregroundColor(star <= Int(rating) ? AppDesign.Colors.accent : AppDesign.Colors.textSecondary)
                                            #if os(iOS)
                                            .symbolEffect(.bounce, value: rating)
                                            #endif
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.vertical, AppDesign.Spacing.md)
            }
        }
        .onAppear {
            rating = recipe.rating ?? 0.0
        }
    }
}
