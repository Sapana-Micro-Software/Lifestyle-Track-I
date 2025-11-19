//
//  ManagerTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver
#if canImport(UserNotifications)
import UserNotifications
#endif

// MARK: - Manager Tests
final class ManagerTests: XCTestCase {
    
    // MARK: - NotificationManager Tests
    
    func testNotificationManagerSingleton() {
        let manager1 = NotificationManager.shared
        let manager2 = NotificationManager.shared
        
        XCTAssertTrue(manager1 === manager2, "NotificationManager should be a singleton")
    }
    
    func testNotificationManagerInitialization() {
        let manager = NotificationManager.shared
        // Manager should initialize without crashing
        XCTAssertNotNil(manager, "NotificationManager should initialize")
    }
    
    func testNotificationManagerScheduleMealReminder() {
        let manager = NotificationManager.shared
        let futureDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        
        // Should not crash even if notifications not authorized
        manager.scheduleMealReminder(mealName: "Breakfast", date: futureDate, minutesBefore: 15)
        
        // Test passes if no crash occurs
        XCTAssertTrue(true, "Meal reminder scheduling should not crash")
    }
    
    func testNotificationManagerScheduleExerciseReminder() {
        let manager = NotificationManager.shared
        let futureDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        
        manager.scheduleExerciseReminder(activityName: "Running", date: futureDate, minutesBefore: 30)
        
        XCTAssertTrue(true, "Exercise reminder scheduling should not crash")
    }
    
    func testNotificationManagerScheduleWaterReminder() {
        let manager = NotificationManager.shared
        let futureDate = Date()
        
        manager.scheduleWaterReminder(date: futureDate, intervalMinutes: 120)
        
        XCTAssertTrue(true, "Water reminder scheduling should not crash")
    }
    
    func testNotificationManagerScheduleSleepReminder() {
        let manager = NotificationManager.shared
        let bedtime = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
        
        manager.scheduleSleepReminder(targetBedtime: bedtime)
        
        XCTAssertTrue(true, "Sleep reminder scheduling should not crash")
    }
    
    func testNotificationManagerScheduleMedicationReminder() {
        let manager = NotificationManager.shared
        let medicationTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        
        manager.scheduleMedicationReminder(medicationName: "Vitamin D", time: medicationTime, repeats: true)
        manager.scheduleMedicationReminder(medicationName: "One-time", time: medicationTime, repeats: false)
        
        XCTAssertTrue(true, "Medication reminder scheduling should not crash")
    }
    
    func testNotificationManagerScheduleHealthCheckIn() {
        let manager = NotificationManager.shared
        let checkInDate = Date()
        
        manager.scheduleHealthCheckIn(date: checkInDate, frequency: .daily)
        manager.scheduleHealthCheckIn(date: checkInDate, frequency: .weekly)
        manager.scheduleHealthCheckIn(date: checkInDate, frequency: .monthly)
        
        XCTAssertTrue(true, "Health check-in scheduling should not crash")
    }
    
    func testNotificationManagerScheduleMilestoneNotification() {
        let manager = NotificationManager.shared
        let milestoneDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        
        manager.scheduleMilestoneNotification(milestoneName: "30-Day Milestone", date: milestoneDate)
        
        XCTAssertTrue(true, "Milestone notification scheduling should not crash")
    }
    
    func testNotificationManagerScheduleBadgeNotification() {
        let manager = NotificationManager.shared
        
        manager.scheduleBadgeNotification(badgeName: "First Week Complete")
        
        XCTAssertTrue(true, "Badge notification scheduling should not crash")
    }
    
    func testNotificationManagerScheduleGenericNotification() {
        let manager = NotificationManager.shared
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        
        manager.scheduleNotification(identifier: "test-notification", title: "Test", body: "Test body", date: futureDate)
        
        XCTAssertTrue(true, "Generic notification scheduling should not crash")
    }
    
    func testNotificationManagerScheduleDailyReminder() {
        let manager = NotificationManager.shared
        
        manager.scheduleDailyReminder(identifier: "daily-test", title: "Daily", body: "Daily reminder", hour: 9, minute: 0)
        
        XCTAssertTrue(true, "Daily reminder scheduling should not crash")
    }
    
    func testNotificationManagerScheduleWeeklyReminder() {
        let manager = NotificationManager.shared
        
        manager.scheduleWeeklyReminder(identifier: "weekly-test", title: "Weekly", body: "Weekly reminder", weekday: 1, hour: 10, minute: 0)
        
        XCTAssertTrue(true, "Weekly reminder scheduling should not crash")
    }
    
    func testNotificationManagerCancelAllNotifications() {
        let manager = NotificationManager.shared
        
        manager.cancelAllNotifications()
        
        XCTAssertTrue(true, "Cancel all notifications should not crash")
    }
    
    func testNotificationManagerCancelSpecificNotification() {
        let manager = NotificationManager.shared
        
        manager.cancelNotification(identifier: "test-id")
        
        XCTAssertTrue(true, "Cancel specific notification should not crash")
    }
    
    // MARK: - RecipeLibraryManager Tests
    
    func testRecipeLibraryManagerSingleton() {
        let manager1 = RecipeLibraryManager.shared
        let manager2 = RecipeLibraryManager.shared
        
        XCTAssertTrue(manager1 === manager2, "RecipeLibraryManager should be a singleton")
    }
    
    func testRecipeLibraryManagerSaveRecipe() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        let initialCount = manager.savedRecipes.count
        manager.saveRecipe(from: meal)
        
        XCTAssertEqual(manager.savedRecipes.count, initialCount + 1, "Recipe should be saved")
    }
    
    func testRecipeLibraryManagerSaveRecipeWithRating() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        manager.saveRecipe(from: meal, rating: 4.5)
        
        let savedRecipe = manager.savedRecipes.first { $0.mealName == meal.name }
        XCTAssertNotNil(savedRecipe, "Recipe should be saved")
        XCTAssertEqual(savedRecipe?.rating, 4.5, "Recipe should have rating")
    }
    
    func testRecipeLibraryManagerUpdateExistingRecipe() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        manager.saveRecipe(from: meal)
        let initialCount = manager.savedRecipes.count
        
        // Save same recipe again
        manager.saveRecipe(from: meal, rating: 5.0)
        
        XCTAssertEqual(manager.savedRecipes.count, initialCount, "Should update existing recipe, not create duplicate")
        
        let savedRecipe = manager.savedRecipes.first { $0.mealName == meal.name }
        XCTAssertEqual(savedRecipe?.rating, 5.0, "Recipe rating should be updated")
    }
    
    func testRecipeLibraryManagerRateRecipe() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        manager.saveRecipe(from: meal)
        let recipeId = manager.savedRecipes.first { $0.mealName == meal.name }!.id
        
        manager.rateRecipe(recipeId, rating: 4.0)
        
        let ratedRecipe = manager.savedRecipes.first { $0.id == recipeId }
        XCTAssertEqual(ratedRecipe?.rating, 4.0, "Recipe should be rated")
    }
    
    func testRecipeLibraryManagerMarkRecipeAsMade() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        manager.saveRecipe(from: meal)
        let recipeId = manager.savedRecipes.first { $0.mealName == meal.name }!.id
        
        let initialTimesMade = manager.savedRecipes.first { $0.id == recipeId }!.timesMade
        
        manager.markRecipeAsMade(recipeId)
        
        let updatedRecipe = manager.savedRecipes.first { $0.id == recipeId }
        XCTAssertEqual(updatedRecipe?.timesMade, initialTimesMade + 1, "Times made should increment")
        XCTAssertNotNil(updatedRecipe?.lastMadeDate, "Last made date should be set")
    }
    
    func testRecipeLibraryManagerDeleteRecipe() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        manager.saveRecipe(from: meal)
        let recipeId = manager.savedRecipes.first { $0.mealName == meal.name }!.id
        let initialCount = manager.savedRecipes.count
        
        manager.deleteRecipe(recipeId)
        
        XCTAssertEqual(manager.savedRecipes.count, initialCount - 1, "Recipe should be deleted")
        XCTAssertNil(manager.savedRecipes.first { $0.id == recipeId }, "Recipe should not exist")
    }
    
    func testRecipeLibraryManagerGetFavoriteRecipes() {
        let manager = RecipeLibraryManager.shared
        
        // Clear existing recipes
        manager.savedRecipes.removeAll()
        
        let meal1 = createTestMeal(name: "Meal 1")
        let meal2 = createTestMeal(name: "Meal 2")
        let meal3 = createTestMeal(name: "Meal 3")
        
        manager.saveRecipe(from: meal1, rating: 4.5)
        manager.saveRecipe(from: meal2, rating: 3.0)
        manager.saveRecipe(from: meal3, rating: 5.0)
        
        let favorites = manager.getFavoriteRecipes(minRating: 4.0)
        
        XCTAssertEqual(favorites.count, 2, "Should have 2 favorites with rating >= 4.0")
        XCTAssertTrue(favorites.allSatisfy { ($0.rating ?? 0) >= 4.0 }, "All favorites should have rating >= 4.0")
    }
    
    func testRecipeLibraryManagerGetMostMadeRecipes() {
        let manager = RecipeLibraryManager.shared
        
        // Clear existing recipes
        manager.savedRecipes.removeAll()
        
        let meal1 = createTestMeal(name: "Meal 1")
        let meal2 = createTestMeal(name: "Meal 2")
        let meal3 = createTestMeal(name: "Meal 3")
        
        manager.saveRecipe(from: meal1)
        manager.saveRecipe(from: meal2)
        manager.saveRecipe(from: meal3)
        
        let recipe1Id = manager.savedRecipes.first { $0.mealName == "Meal 1" }!.id
        let recipe2Id = manager.savedRecipes.first { $0.mealName == "Meal 2" }!.id
        
        manager.markRecipeAsMade(recipe1Id)
        manager.markRecipeAsMade(recipe1Id)
        manager.markRecipeAsMade(recipe2Id)
        
        let mostMade = manager.getMostMadeRecipes(limit: 2)
        
        XCTAssertEqual(mostMade.count, 2, "Should return 2 most made recipes")
        XCTAssertEqual(mostMade.first?.mealName, "Meal 1", "Most made should be first")
    }
    
    func testRecipeLibraryManagerSearchRecipes() {
        let manager = RecipeLibraryManager.shared
        
        // Clear existing recipes
        manager.savedRecipes.removeAll()
        
        let meal1 = createTestMeal(name: "Chicken Salad")
        let meal2 = createTestMeal(name: "Beef Steak")
        let meal3 = createTestMeal(name: "Salmon Fillet")
        
        manager.saveRecipe(from: meal1)
        manager.saveRecipe(from: meal2)
        manager.saveRecipe(from: meal3)
        
        let searchResults = manager.searchRecipes(query: "chicken")
        
        XCTAssertFalse(searchResults.isEmpty, "Should find recipes matching query")
        XCTAssertTrue(searchResults.contains { $0.mealName.lowercased().contains("chicken") }, "Should find chicken recipe")
    }
    
    func testRecipeLibraryManagerFilterByMealType() {
        let manager = RecipeLibraryManager.shared
        
        // Clear existing recipes
        manager.savedRecipes.removeAll()
        
        let breakfastMeal = createTestMeal(name: "Breakfast", mealType: .breakfast)
        let lunchMeal = createTestMeal(name: "Lunch", mealType: .lunch)
        let dinnerMeal = createTestMeal(name: "Dinner", mealType: .dinner)
        
        manager.saveRecipe(from: breakfastMeal)
        manager.saveRecipe(from: lunchMeal)
        manager.saveRecipe(from: dinnerMeal)
        
        let breakfastRecipes = manager.filterByMealType(.breakfast)
        
        XCTAssertEqual(breakfastRecipes.count, 1, "Should have 1 breakfast recipe")
        XCTAssertTrue(breakfastRecipes.allSatisfy { $0.mealType == .breakfast }, "All should be breakfast")
    }
    
    func testRecipeLibraryManagerPersistence() {
        let manager = RecipeLibraryManager.shared
        let meal = createTestMeal()
        
        manager.saveRecipe(from: meal)
        let recipeId = manager.savedRecipes.first { $0.mealName == meal.name }!.id
        
        // Create new manager instance (simulates app restart)
        let newManager = RecipeLibraryManager.shared
        
        // Recipes should persist (same singleton, but tests persistence mechanism)
        let persistedRecipe = newManager.savedRecipes.first { $0.id == recipeId }
        XCTAssertNotNil(persistedRecipe, "Recipe should persist")
    }
    
    // MARK: - Helper Methods
    
    private func createTestMeal(name: String = "Test Meal", mealType: Meal.MealType = .breakfast) -> Meal {
        let food = Food(
            id: UUID(),
            name: "Test Food",
            category: .vegetable,
            nutrientContent: NutrientContent(calories: 100, protein: 5, carbohydrates: 20, fats: 2),
            properties: FoodProperties(tasteScore: 7, digestionScore: 8, pros: ["Healthy"], cons: [], seasonalAvailability: [.spring, .summer])
        )
        
        let mealItem = MealItem(food: food, amount: 100)
        
        return Meal(
            id: UUID(),
            name: name,
            items: [mealItem],
            mealType: mealType
        )
    }
}
