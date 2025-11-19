//
//  RegressionTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Regression Tests for Critical User Flows
final class RegressionTests: XCTestCase {
    
    var viewModel: DietSolverViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DietSolverViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Complete User Flow Tests
    
    func testCompleteHealthDataToDietPlanFlow() {
        // Test the complete flow from health data input to diet plan generation
        let healthData = createCompleteHealthData()
        
        viewModel.setHealthData(healthData)
        XCTAssertNotNil(viewModel.healthData, "Health data should be set")
        
        let expectation = XCTestExpectation(description: "Diet plan generated")
        viewModel.solveDiet()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.viewModel.dietPlan, "Diet plan should be generated")
            XCTAssertFalse(self.viewModel.dietPlan!.meals.isEmpty, "Plan should have meals")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testHealthDataUpdateDoesNotBreakExistingPlan() {
        // Regression: Updating health data should not break existing diet plan
        let initialData = createCompleteHealthData()
        viewModel.setHealthData(initialData)
        
        let expectation1 = XCTestExpectation(description: "Initial plan generated")
        viewModel.solveDiet()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let initialPlan = self.viewModel.dietPlan
            XCTAssertNotNil(initialPlan, "Initial plan should exist")
            
            // Update health data
            var updatedData = initialData
            updatedData.weight = 75.0
            self.viewModel.updateHealthData(updatedData)
            
            // Plan should still exist (though may be different)
            XCTAssertNotNil(self.viewModel.healthData, "Health data should be updated")
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testMultipleDietPlanGenerations() {
        // Regression: Multiple plan generations should not cause crashes
        let healthData = createCompleteHealthData()
        viewModel.setHealthData(healthData)
        
        for i in 0..<5 {
            let expectation = XCTestExpectation(description: "Plan \(i) generated")
            viewModel.solveDiet()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                XCTAssertNotNil(self.viewModel.dietPlan, "Plan \(i) should be generated")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testExercisePlanGenerationAfterHealthDataUpdate() {
        // Regression: Exercise plan should regenerate after health data update
        let healthData = createCompleteHealthData()
        viewModel.setHealthData(healthData)
        
        let initialPlan = viewModel.exercisePlan
        XCTAssertNotNil(initialPlan, "Initial exercise plan should exist")
        
        var updatedData = healthData
        updatedData.activityLevel = .active
        viewModel.updateHealthData(updatedData)
        
        let updatedPlan = viewModel.exercisePlan
        XCTAssertNotNil(updatedPlan, "Updated exercise plan should exist")
    }
    
    func testLongTermPlanGenerationWithDifferentDurations() {
        // Regression: Long-term plans should work for all durations
        let healthData = createCompleteHealthData()
        viewModel.setHealthData(healthData)
        
        let durations: [PlanDuration] = [.threeMonths, .sixMonths, .oneYear, .twoYears, .fiveYears, .tenYears]
        
        for duration in durations {
            viewModel.generateLongTermPlan(duration: duration, urgency: .medium)
            XCTAssertNotNil(viewModel.longTermPlan, "Plan for \(duration) should be generated")
        }
    }
    
    func testMedicalAnalysisWithEmptyCollection() {
        // Regression: Empty medical test collection should not crash
        let analyzer = MedicalAnalyzer()
        let emptyCollection = MedicalTestCollection()
        
        let report = analyzer.analyze(collection: emptyCollection, gender: .male)
        
        XCTAssertNotNil(report, "Report should be generated even with empty collection")
    }
    
    func testDietSolverWithExtremeHealthData() {
        // Regression: Extreme health data values should not cause crashes
        let extremeData = HealthData(
            age: 100,
            gender: .male,
            weight: 200.0,
            height: 150.0,
            activityLevel: .active
        )
        
        let solver = DietSolver()
        let plan = solver.solve(healthData: extremeData, season: .spring)
        
        XCTAssertNotNil(plan, "Plan should be generated even with extreme values")
        XCTAssertFalse(plan.meals.isEmpty, "Plan should have meals")
    }
    
    func testUnitSystemConversion() {
        // Regression: Unit system conversion should not lose data
        let viewModel = DietSolverViewModel()
        viewModel.unitSystem = .imperial
        
        let healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 154.0, // lbs
            height: 66.0, // inches
            activityLevel: .moderate
        )
        
        viewModel.setHealthData(healthData)
        XCTAssertNotNil(viewModel.healthData, "Health data should be set")
        
        // Convert to metric
        viewModel.unitSystem = .metric
        XCTAssertNotNil(viewModel.healthData, "Health data should persist after unit conversion")
    }
    
    // MARK: - Helper Methods
    private func createCompleteHealthData() -> HealthData {
        var healthData = HealthData(
            age: 35,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        healthData.glucose = 95.0
        healthData.hemoglobin = 14.5
        healthData.cholesterol = 180.0
        healthData.bloodPressure = HealthData.BloodPressure(systolic: 120, diastolic: 80)
        
        return healthData
    }
}
