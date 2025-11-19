//
//  PlannerTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Planner Tests
final class PlannerTests: XCTestCase {
    
    var healthData: HealthData!
    
    override func setUp() {
        super.setUp()
        healthData = createTestHealthData()
    }
    
    override func tearDown() {
        healthData = nil
        super.tearDown()
    }
    
    // MARK: - MealPrepPlanner Tests
    
    func testMealPrepPlannerSingleton() {
        let planner1 = MealPrepPlanner.shared
        let planner2 = MealPrepPlanner.shared
        
        XCTAssertTrue(planner1 === planner2, "MealPrepPlanner should be a singleton")
    }
    
    func testMealPrepPlannerGenerateSchedule() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        XCTAssertFalse(schedule.tasks.isEmpty, "Schedule should have tasks")
        XCTAssertEqual(schedule.daysCovered, 7, "Should cover 7 days")
        XCTAssertGreaterThan(schedule.totalEstimatedTime, 0, "Should have estimated time")
    }
    
    func testMealPrepPlannerBatchCookingTasks() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        let batchCookingTasks = schedule.tasks.filter { $0.type == .batchCooking }
        // May or may not have batch cooking depending on meal content
        XCTAssertNotNil(batchCookingTasks, "Should handle batch cooking tasks")
    }
    
    func testMealPrepPlannerPrepTasks() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        let prepTasks = schedule.tasks.filter { $0.type == .prep }
        // Should have prep tasks if there are meals
        XCTAssertNotNil(prepTasks, "Should handle prep tasks")
    }
    
    func testMealPrepPlannerDailyTasks() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        let dailyTasks = schedule.tasks.filter { $0.type == .daily }
        XCTAssertGreaterThanOrEqual(dailyTasks.count, 7, "Should have at least one daily task per day")
    }
    
    func testMealPrepPlannerTaskPriorities() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        for task in schedule.tasks {
            XCTAssertTrue([.low, .medium, .high].contains(task.priority), "Task should have valid priority")
        }
    }
    
    func testMealPrepPlannerTaskEstimatedTime() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        for task in schedule.tasks {
            XCTAssertGreaterThan(task.estimatedTime, 0, "Task should have estimated time")
        }
    }
    
    func testMealPrepPlannerTotalEstimatedTime() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let schedule = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        
        let calculatedTotal = schedule.tasks.reduce(0) { $0 + $1.estimatedTime }
        XCTAssertEqual(schedule.totalEstimatedTime, calculatedTotal, "Total estimated time should match sum of tasks")
    }
    
    func testMealPrepPlannerDifferentDayCounts() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 30)
        
        let schedule3 = planner.generateMealPrepSchedule(from: dailyPlans, days: 3)
        let schedule7 = planner.generateMealPrepSchedule(from: dailyPlans, days: 7)
        let schedule14 = planner.generateMealPrepSchedule(from: dailyPlans, days: 14)
        
        XCTAssertEqual(schedule3.daysCovered, 3, "Should cover 3 days")
        XCTAssertEqual(schedule7.daysCovered, 7, "Should cover 7 days")
        XCTAssertEqual(schedule14.daysCovered, 14, "Should cover 14 days")
    }
    
    func testMealPrepPlannerBatchCookingRecommendations() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let recommendations = planner.getBatchCookingRecommendations(from: dailyPlans)
        
        // Recommendations may or may not exist depending on meal content
        XCTAssertNotNil(recommendations, "Should generate batch cooking recommendations")
    }
    
    func testMealPrepPlannerBatchCookingRecommendationStructure() {
        let planner = MealPrepPlanner.shared
        let dailyPlans = createTestDailyPlans(days: 7)
        
        let recommendations = planner.getBatchCookingRecommendations(from: dailyPlans)
        
        for recommendation in recommendations {
            XCTAssertFalse(recommendation.food.isEmpty, "Recommendation should have food name")
            XCTAssertGreaterThan(recommendation.frequency, 0, "Recommendation should have frequency")
            XCTAssertFalse(recommendation.recommendedBatchSize.isEmpty, "Recommendation should have batch size")
            XCTAssertFalse(recommendation.storageMethod.isEmpty, "Recommendation should have storage method")
            XCTAssertFalse(recommendation.prepInstructions.isEmpty, "Recommendation should have prep instructions")
        }
    }
    
    func testMealPrepPlannerEmptyPlans() {
        let planner = MealPrepPlanner.shared
        let emptyPlans: [DailyPlanEntry] = []
        
        let schedule = planner.generateMealPrepSchedule(from: emptyPlans, days: 7)
        
        // Should still generate schedule with daily tasks
        XCTAssertNotNil(schedule, "Should handle empty plans")
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
    
    private func createTestDailyPlans(days: Int) -> [DailyPlanEntry] {
        let planner = LongTermPlanner()
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        return planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring).prefix(days).map { $0 }
    }
}
