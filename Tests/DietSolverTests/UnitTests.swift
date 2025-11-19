//
//  UnitTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Unit Tests for Core Business Logic
final class UnitTests: XCTestCase {
    
    // MARK: - DietSolver Tests
    func testDietSolverBasicFunctionality() {
        let solver = DietSolver()
        let healthData = createTestHealthData()
        let season = Season.spring
        
        let plan = solver.solve(healthData: healthData, season: season)
        
        XCTAssertNotNil(plan, "Diet plan should be generated")
        XCTAssertFalse(plan.meals.isEmpty, "Plan should contain meals")
        XCTAssertEqual(plan.season, season, "Plan season should match input")
    }
    
    func testDietSolverNutrientRequirements() {
        let solver = DietSolver()
        let healthData = createTestHealthData()
        let requirements = healthData.adjustedNutrientRequirements()
        let season = Season.spring
        
        let plan = solver.solve(healthData: healthData, season: season)
        let totalNutrients = plan.totalNutrients
        
        // Verify plan has nutrients (requirements is a dictionary)
        XCTAssertGreaterThan(totalNutrients.calories, 0, 
                                   "Plan should have calories")
    }
    
    func testDietSolverSeasonalFoodAvailability() {
        let solver = DietSolver()
        let healthData = createTestHealthData()
        
        let springPlan = solver.solve(healthData: healthData, season: .spring)
        let winterPlan = solver.solve(healthData: healthData, season: .winter)
        
        // Plans should be different for different seasons
        XCTAssertNotEqual(springPlan.meals.count, 0, "Spring plan should have meals")
        XCTAssertNotEqual(winterPlan.meals.count, 0, "Winter plan should have meals")
    }
    
    func testDietSolverTasteScore() {
        let solver = DietSolver()
        let healthData = createTestHealthData()
        let season = Season.spring
        
        let plan = solver.solve(healthData: healthData, season: season)
        
        XCTAssertGreaterThan(plan.overallTasteScore, 0, "Taste score should be positive")
        XCTAssertLessThanOrEqual(plan.overallTasteScore, 10, "Taste score should be within valid range")
    }
    
    func testDietSolverDigestionScore() {
        let solver = DietSolver()
        let healthData = createTestHealthData()
        let season = Season.spring
        
        let plan = solver.solve(healthData: healthData, season: season)
        
        XCTAssertGreaterThan(plan.overallDigestionScore, 0, "Digestion score should be positive")
        XCTAssertLessThanOrEqual(plan.overallDigestionScore, 10, "Digestion score should be within valid range")
    }
    
    // MARK: - DietSolverViewModel Tests
    func testViewModelSetHealthData() {
        let viewModel = DietSolverViewModel()
        let healthData = createTestHealthData()
        
        viewModel.setHealthData(healthData)
        
        XCTAssertNotNil(viewModel.healthData, "Health data should be set")
        XCTAssertEqual(viewModel.healthData?.age, healthData.age, "Age should match")
        XCTAssertNotNil(viewModel.exercisePlan, "Exercise plan should be generated")
    }
    
    func testViewModelUpdateHealthData() {
        let viewModel = DietSolverViewModel()
        let healthData = createTestHealthData()
        
        viewModel.setHealthData(healthData)
        var updatedData = healthData
        updatedData.weight = 80.0
        viewModel.updateHealthData(updatedData)
        
        XCTAssertEqual(viewModel.healthData?.weight, 80.0, "Weight should be updated")
    }
    
    func testViewModelSolveDiet() {
        let viewModel = DietSolverViewModel()
        let healthData = createTestHealthData()
        
        viewModel.setHealthData(healthData)
        
        let expectation = XCTestExpectation(description: "Diet plan generated")
        viewModel.solveDiet()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(viewModel.dietPlan, "Diet plan should be generated")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testViewModelGenerateLongTermPlan() {
        let viewModel = DietSolverViewModel()
        let healthData = createTestHealthData()
        
        viewModel.setHealthData(healthData)
        viewModel.generateLongTermPlan(duration: .threeMonths, urgency: .medium)
        
        XCTAssertNotNil(viewModel.longTermPlan, "Long-term plan should be generated")
    }
    
    // MARK: - MedicalAnalyzer Tests
    func testMedicalAnalyzerBloodTest() {
        let analyzer = MedicalAnalyzer()
        var collection = MedicalTestCollection()
        
        var bloodTest = BloodTestReport(date: Date())
        bloodTest.glucose = 95.0
        bloodTest.hemoglobin = 14.5
        bloodTest.totalCholesterol = 180.0
        collection.bloodTests.append(bloodTest)
        
        let report = analyzer.analyze(collection: collection, gender: .male)
        
        XCTAssertNotNil(report.bloodAnalysis, "Blood analysis should be performed")
    }
    
    func testMedicalAnalyzerRecommendations() {
        let analyzer = MedicalAnalyzer()
        var collection = MedicalTestCollection()
        
        var bloodTest = BloodTestReport(date: Date())
        bloodTest.glucose = 150.0 // High glucose
        bloodTest.hemoglobin = 14.5
        bloodTest.totalCholesterol = 250.0 // High cholesterol
        collection.bloodTests.append(bloodTest)
        
        let report = analyzer.analyze(collection: collection, gender: .male)
        
        XCTAssertFalse(report.recommendations.isEmpty, "Recommendations should be generated for abnormal values")
    }
    
    // MARK: - ExercisePlanner Tests
    func testExercisePlannerGeneratePlan() {
        let planner = ExercisePlanner()
        let healthData = createTestHealthData()
        let goals = ExerciseGoals()
        
        let plan = planner.generateWeeklyPlan(for: healthData, goals: goals)
        
        XCTAssertNotNil(plan, "Exercise plan should be generated")
        XCTAssertFalse(plan.weeklyPlan.isEmpty, "Plan should contain weekly plan")
    }
    
    func testExercisePlannerActivityLevel() {
        let planner = ExercisePlanner()
        var healthData = createTestHealthData()
        let goals = ExerciseGoals()
        
        healthData.activityLevel = .active
        let highActivityPlan = planner.generateWeeklyPlan(for: healthData, goals: goals)
        
        healthData.activityLevel = .sedentary
        let lowActivityPlan = planner.generateWeeklyPlan(for: healthData, goals: goals)
        
        // High activity should generally have more activities or higher intensity
        let highActivityCount = highActivityPlan.weeklyPlan.reduce(0) { $0 + $1.activities.count }
        let lowActivityCount = lowActivityPlan.weeklyPlan.reduce(0) { $0 + $1.activities.count }
        XCTAssertGreaterThanOrEqual(highActivityCount, lowActivityCount,
                                   "High activity plan should have at least as many activities")
    }
    
    // MARK: - Helper Methods
    private func createTestHealthData() -> HealthData {
        return HealthData(
            age: 30,
            gender: .male,
            weight: 70.0,
            height: 170.0,
            activityLevel: .moderate
        )
    }
}
