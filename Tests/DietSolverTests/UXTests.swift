//
//  UXTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - UX Tests for User Experience Validation
final class UXTests: XCTestCase {
    
    var viewModel: DietSolverViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DietSolverViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Performance Tests
    
    func testDietPlanGenerationPerformance() {
        // UX: Diet plan generation should complete in reasonable time
        let healthData = createTestHealthData()
        viewModel.setHealthData(healthData)
        
        measure {
            viewModel.solveDiet()
            // Wait for completion
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .now() + 10.0)
        }
    }
    
    func testExercisePlanGenerationPerformance() {
        // UX: Exercise plan generation should be fast
        let healthData = createTestHealthData()
        
        measure {
            viewModel.setHealthData(healthData)
            // Exercise plan is generated synchronously in setHealthData
        }
    }
    
    func testMedicalAnalysisPerformance() {
        // UX: Medical analysis should complete quickly
        let analyzer = MedicalAnalyzer()
        var collection = MedicalTestCollection()
        
        var bloodTest = BloodTestReport(date: Date())
        bloodTest.glucose = 95.0
        bloodTest.hemoglobin = 14.5
        bloodTest.totalCholesterol = 180.0
        collection.bloodTests.append(bloodTest)
        
        measure {
            _ = analyzer.analyze(collection: collection, gender: .male)
        }
    }
    
    // MARK: - Usability Tests
    
    func testDefaultValuesForNewUsers() {
        // UX: New users should have sensible defaults
        let newUserData = HealthData(
            age: 30,
            gender: .male,
            weight: 70.0,
            height: 170.0,
            activityLevel: .moderate
        )
        
        viewModel.setHealthData(newUserData)
        
        // System should work with minimal data
        XCTAssertNotNil(viewModel.exercisePlan, "Exercise plan should be generated with minimal data")
        
        let expectation = XCTestExpectation(description: "Diet plan generated")
        viewModel.solveDiet()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.viewModel.dietPlan, "Diet plan should be generated with minimal data")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testErrorRecovery() {
        // UX: System should recover gracefully from errors
        let invalidData = HealthData(
            age: 0,
            gender: .male,
            weight: 0.0,
            height: 0.0,
            activityLevel: .moderate
        )
        
        viewModel.setHealthData(invalidData)
        
        // System should not crash, should handle gracefully
        XCTAssertNotNil(viewModel.healthData, "System should accept data without crashing")
    }
    
    func testDataPersistence() {
        // UX: User data should persist across operations
        let healthData = createTestHealthData()
        viewModel.setHealthData(healthData)
        
        // Perform multiple operations
        viewModel.solveDiet()
        viewModel.generateLongTermPlan(duration: .threeMonths, urgency: .medium)
        
        let expectation = XCTestExpectation(description: "Operations complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Health data should still be there
            XCTAssertNotNil(self.viewModel.healthData, "Health data should persist")
            XCTAssertEqual(self.viewModel.healthData?.age, healthData.age, "Health data should not change")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Accessibility Tests
    
    func testDataAccessibility() {
        // UX: All data should be accessible when needed
        let healthData = createTestHealthData()
        viewModel.setHealthData(healthData)
        
        // Verify all expected data is accessible
        XCTAssertNotNil(viewModel.healthData, "Health data should be accessible")
        XCTAssertNotNil(viewModel.exercisePlan, "Exercise plan should be accessible")
        
        let expectation = XCTestExpectation(description: "Diet plan accessible")
        viewModel.solveDiet()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.viewModel.dietPlan, "Diet plan should be accessible")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Consistency Tests
    
    func testConsistentResults() {
        // UX: Same inputs should produce consistent results
        let healthData = createTestHealthData()
        
        viewModel.setHealthData(healthData)
        viewModel.solveDiet()
        
        let expectation1 = XCTestExpectation(description: "First plan")
        var firstPlan: DailyDietPlan?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            firstPlan = self.viewModel.dietPlan
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 5.0)
        
        // Generate again with same data
        viewModel.solveDiet()
        
        let expectation2 = XCTestExpectation(description: "Second plan")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let secondPlan = self.viewModel.dietPlan
            XCTAssertNotNil(secondPlan, "Second plan should be generated")
            // Plans may differ due to randomization, but structure should be consistent
            XCTAssertEqual(secondPlan!.meals.count, firstPlan!.meals.count, 
                          "Plans should have same number of meals")
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 5.0)
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
