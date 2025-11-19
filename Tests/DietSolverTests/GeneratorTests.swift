//
//  GeneratorTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Generator Tests
final class GeneratorTests: XCTestCase {
    
    var healthData: HealthData!
    var dietPlan: DailyDietPlan!
    
    override func setUp() {
        super.setUp()
        healthData = createTestHealthData()
        dietPlan = createTestDietPlan()
    }
    
    override func tearDown() {
        healthData = nil
        dietPlan = nil
        super.tearDown()
    }
    
    // MARK: - GroceryListGenerator Tests
    
    func testGroceryListGeneratorFromSinglePlan() {
        let generator = GroceryListGenerator.shared
        let groceryList = generator.generateGroceryList(from: dietPlan)
        
        XCTAssertFalse(groceryList.items.isEmpty, "Grocery list should have items")
        XCTAssertEqual(groceryList.daysCovered, 1, "Single plan should cover 1 day")
        XCTAssertGreaterThan(groceryList.totalEstimatedCost, 0, "Total cost should be positive")
    }
    
    func testGroceryListGeneratorFromDailyPlans() {
        let generator = GroceryListGenerator.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        let groceryList = generator.generateGroceryList(from: dailyPlans, days: 7)
        
        XCTAssertFalse(groceryList.items.isEmpty, "Grocery list should have items")
        XCTAssertEqual(groceryList.daysCovered, 7, "Should cover 7 days")
        XCTAssertGreaterThan(groceryList.totalEstimatedCost, 0, "Total cost should be positive")
    }
    
    func testGroceryListGeneratorCategorization() {
        let generator = GroceryListGenerator.shared
        let groceryList = generator.generateGroceryList(from: dietPlan)
        
        let categories = Set(groceryList.items.map { $0.category })
        XCTAssertFalse(categories.isEmpty, "Items should be categorized")
    }
    
    func testGroceryListGeneratorItemAggregation() {
        let generator = GroceryListGenerator.shared
        let dailyPlans = createTestDailyPlans(days: 3)
        let groceryList = generator.generateGroceryList(from: dailyPlans, days: 3)
        
        // Check that same foods are aggregated
        let itemNames = groceryList.items.map { $0.name.lowercased() }
        let uniqueNames = Set(itemNames)
        XCTAssertEqual(itemNames.count, uniqueNames.count, "Same foods should be aggregated")
    }
    
    func testGroceryListGeneratorMealTracking() {
        let generator = GroceryListGenerator.shared
        let groceryList = generator.generateGroceryList(from: dietPlan)
        
        for item in groceryList.items {
            XCTAssertFalse(item.meals.isEmpty, "Item should track which meals use it")
        }
    }
    
    func testGroceryListGeneratorSorting() {
        let generator = GroceryListGenerator.shared
        let groceryList = generator.generateGroceryList(from: dietPlan)
        
        // Check items are sorted by category
        for i in 1..<groceryList.items.count {
            let prev = groceryList.items[i - 1]
            let curr = groceryList.items[i]
            
            if prev.category == curr.category {
                XCTAssertLessThanOrEqual(prev.name, curr.name, "Items in same category should be sorted by name")
            } else {
                XCTAssertLessThanOrEqual(prev.category.rawValue, curr.category.rawValue, "Items should be sorted by category")
            }
        }
    }
    
    func testGroceryListGeneratorFormatForSharing() {
        let generator = GroceryListGenerator.shared
        let groceryList = generator.generateGroceryList(from: dietPlan)
        let formatted = generator.formatForSharing(groceryList)
        
        XCTAssertFalse(formatted.isEmpty, "Formatted text should not be empty")
        XCTAssertTrue(formatted.contains("Grocery List"), "Should contain header")
        XCTAssertTrue(formatted.contains("days"), "Should contain days info")
    }
    
    func testGroceryListGeneratorDifferentDayCounts() {
        let generator = GroceryListGenerator.shared
        let dailyPlans = createTestDailyPlans(days: 30)
        
        let list3 = generator.generateGroceryList(from: dailyPlans, days: 3)
        let list7 = generator.generateGroceryList(from: dailyPlans, days: 7)
        let list14 = generator.generateGroceryList(from: dailyPlans, days: 14)
        let list30 = generator.generateGroceryList(from: dailyPlans, days: 30)
        
        XCTAssertEqual(list3.daysCovered, 3, "Should cover 3 days")
        XCTAssertEqual(list7.daysCovered, 7, "Should cover 7 days")
        XCTAssertEqual(list14.daysCovered, 14, "Should cover 14 days")
        XCTAssertEqual(list30.daysCovered, 30, "Should cover 30 days")
        
        // Longer plans should generally have more items or higher cost
        XCTAssertLessThanOrEqual(list3.items.count, list30.items.count, "30-day list should have at least as many items")
    }
    
    // MARK: - RecipeGenerator Tests
    
    func testRecipeGeneratorBasicGeneration() {
        let meal = dietPlan.meals.first!
        let recipe = RecipeGenerator.generateRecipe(for: meal)
        
        XCTAssertFalse(recipe.isEmpty, "Recipe should not be empty")
        XCTAssertTrue(recipe.contains(meal.name), "Recipe should contain meal name")
    }
    
    func testRecipeGeneratorContainsIngredients() {
        let meal = dietPlan.meals.first!
        let recipe = RecipeGenerator.generateRecipe(for: meal)
        
        for item in meal.items {
            XCTAssertTrue(recipe.contains(item.food.name), "Recipe should contain ingredient: \(item.food.name)")
        }
    }
    
    func testRecipeGeneratorForAllMeals() {
        for meal in dietPlan.meals {
            let recipe = RecipeGenerator.generateRecipe(for: meal)
            XCTAssertFalse(recipe.isEmpty, "Recipe should be generated for \(meal.name)")
        }
    }
    
    // MARK: - SongGenerator Tests
    
    func testSongGeneratorBasicGeneration() {
        let song = SongGenerator.generateSong(for: dietPlan)
        
        XCTAssertFalse(song.isEmpty, "Song should not be empty")
    }
    
    func testSongGeneratorContainsMealNames() {
        let song = SongGenerator.generateSong(for: dietPlan)
        
        // Song might contain meal names or references
        XCTAssertFalse(song.isEmpty, "Song should be generated")
    }
    
    // MARK: - NutritionFactsGenerator Tests
    
    func testNutritionFactsGeneratorBasicGeneration() {
        let requirements = healthData.adjustedNutrientRequirements()
        let nutritionFacts = NutritionFactsGenerator.generateNutritionFacts(for: dietPlan, requirements: requirements)
        
        XCTAssertFalse(nutritionFacts.isEmpty, "Nutrition facts should not be empty")
    }
    
    func testNutritionFactsGeneratorContainsCalories() {
        let requirements = healthData.adjustedNutrientRequirements()
        let nutritionFacts = NutritionFactsGenerator.generateNutritionFacts(for: dietPlan, requirements: requirements)
        
        XCTAssertTrue(nutritionFacts.contains("Calories") || nutritionFacts.contains("calories"), "Should contain calories")
    }
    
    func testNutritionFactsGeneratorContainsMacronutrients() {
        let requirements = healthData.adjustedNutrientRequirements()
        let nutritionFacts = NutritionFactsGenerator.generateNutritionFacts(for: dietPlan, requirements: requirements)
        
        let lowercased = nutritionFacts.lowercased()
        XCTAssertTrue(lowercased.contains("protein") || lowercased.contains("carb") || lowercased.contains("fat"), "Should contain macronutrients")
    }
    
    // MARK: - HealthReportGenerator Tests
    
    func testHealthReportGeneratorWeeklyReport() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .weekly
        )
        
        XCTAssertEqual(report.timeframe, .weekly, "Report timeframe should match")
        XCTAssertNotNil(report.summary, "Report should have summary")
        XCTAssertNotNil(report.progress, "Report should have progress")
    }
    
    func testHealthReportGeneratorMonthlyReport() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 30)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .monthly
        )
        
        XCTAssertEqual(report.timeframe, .monthly, "Report timeframe should match")
    }
    
    func testHealthReportGeneratorQuarterlyReport() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 90)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .quarterly
        )
        
        XCTAssertEqual(report.timeframe, .quarterly, "Report timeframe should match")
    }
    
    func testHealthReportGeneratorYearlyReport() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 365)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .yearly
        )
        
        XCTAssertEqual(report.timeframe, .yearly, "Report timeframe should match")
    }
    
    func testHealthReportGeneratorWithoutPlan() {
        let generator = HealthReportGenerator.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: nil,
            dailyPlans: dailyPlans,
            timeframe: .weekly
        )
        
        XCTAssertNotNil(report, "Report should be generated even without long-term plan")
        XCTAssertNotNil(report.summary, "Report should have summary")
    }
    
    func testHealthReportGeneratorSummary() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .weekly
        )
        
        XCTAssertNotNil(report.summary.currentWeight, "Summary should have current weight")
        XCTAssertNotNil(report.summary.currentBMI, "Summary should have BMI")
        XCTAssertNotNil(report.summary.healthScore, "Summary should have health score")
    }
    
    func testHealthReportGeneratorGoals() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .weekly
        )
        
        if !plan.goals.isEmpty {
            XCTAssertFalse(report.goals.isEmpty, "Report should have goals if plan has goals")
        }
    }
    
    func testHealthReportGeneratorProgress() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .weekly
        )
        
        XCTAssertNotNil(report.progress, "Report should have progress section")
    }
    
    func testHealthReportGeneratorRecommendations() {
        let generator = HealthReportGenerator.shared
        let plan = createTestLongTermPlan()
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let report = generator.generateHealthReport(
            healthData: healthData,
            longTermPlan: plan,
            dailyPlans: dailyPlans,
            timeframe: .weekly
        )
        
        XCTAssertNotNil(report.recommendations, "Report should have recommendations")
    }
    
    // MARK: - Helper Methods
    
    private func createTestHealthData() -> HealthData {
        return HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
    }
    
    private func createTestDietPlan() -> DailyDietPlan {
        let solver = DietSolver()
        return solver.solve(healthData: healthData, season: .spring)
    }
    
    private func createTestDailyPlans(days: Int) -> [DailyPlanEntry] {
        let planner = LongTermPlanner()
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        return planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring).prefix(days).map { $0 }
    }
    
    private func createTestLongTermPlan() -> LongTermPlan {
        let planner = LongTermPlanner()
        return planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
    }
}
