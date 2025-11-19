//
//  ABTesting.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - A-B Testing Infrastructure and Tests
final class ABTesting: XCTestCase {
    
    // MARK: - A-B Testing Infrastructure
    
    enum Variant: String, CaseIterable {
        case control = "control"
        case variantA = "variant_a"
        case variantB = "variant_b"
    }
    
    struct ABTestConfig {
        let testName: String
        let variants: [Variant]
        let allocation: [Variant: Double] // Percentage allocation
        
        static let defaultAllocation: [Variant: Double] = [
            .control: 0.33,
            .variantA: 0.33,
            .variantB: 0.34
        ]
    }
    
    class ABTestManager {
        static let shared = ABTestManager()
        private var userVariants: [String: Variant] = [:]
        
        private init() {}
        
        func assignVariant(for testName: String, userId: String, config: ABTestConfig) -> Variant {
            let key = "\(testName)_\(userId)"
            
            if let existing = userVariants[key] {
                return existing // Consistent assignment
            }
            
            // Assign based on allocation
            let random = Double.random(in: 0...1)
            var cumulative = 0.0
            var assigned: Variant = .control
            
            for variant in config.variants {
                let allocation = config.allocation[variant] ?? 0.0
                cumulative += allocation
                if random <= cumulative {
                    assigned = variant
                    break
                }
            }
            
            userVariants[key] = assigned
            return assigned
        }
        
        func getVariant(for testName: String, userId: String) -> Variant? {
            let key = "\(testName)_\(userId)"
            return userVariants[key]
        }
        
        func reset() {
            userVariants.removeAll()
        }
    }
    
    // MARK: - A-B Test Configurations
    
    func testDietPlanAlgorithmVariant() {
        // A-B Test: Different diet plan algorithms
        let config = ABTestConfig(
            testName: "diet_algorithm",
            variants: [.control, .variantA, .variantB],
            allocation: ABTestConfig.defaultAllocation
        )
        
        let userId = "test_user_1"
        let variant = ABTestManager.shared.assignVariant(for: config.testName, userId: userId, config: config)
        
        XCTAssertTrue([.control, .variantA, .variantB].contains(variant), "Variant should be assigned")
        
        // Test consistency
        let variant2 = ABTestManager.shared.assignVariant(for: config.testName, userId: userId, config: config)
        XCTAssertEqual(variant, variant2, "Same user should get same variant")
    }
    
    func testUIButtonLayoutVariant() {
        // A-B Test: Different UI button layouts
        let config = ABTestConfig(
            testName: "button_layout",
            variants: [.control, .variantA],
            allocation: [.control: 0.5, .variantA: 0.5]
        )
        
        let userId1 = "user_1"
        let userId2 = "user_2"
        
        let variant1 = ABTestManager.shared.assignVariant(for: config.testName, userId: userId1, config: config)
        let variant2 = ABTestManager.shared.assignVariant(for: config.testName, userId: userId2, config: config)
        
        // Both should get valid variants
        XCTAssertTrue([.control, .variantA].contains(variant1))
        XCTAssertTrue([.control, .variantA].contains(variant2))
    }
    
    func testRecommendationStyleVariant() {
        // A-B Test: Different recommendation presentation styles
        let config = ABTestConfig(
            testName: "recommendation_style",
            variants: [.control, .variantA, .variantB],
            allocation: ABTestConfig.defaultAllocation
        )
        
        let healthData = createTestHealthData()
        let analyzer = MedicalAnalyzer()
        var collection = MedicalTestCollection()
        
        var bloodTest = BloodTestReport(date: Date())
        bloodTest.glucose = 150.0
        bloodTest.hemoglobin = 14.5
        bloodTest.totalCholesterol = 250.0
        collection.bloodTests.append(bloodTest)
        
        let report = analyzer.analyze(collection: collection, gender: .male)
        
        // Simulate A-B test: different recommendation styles
        let userId = "test_user"
        let variant = ABTestManager.shared.assignVariant(for: config.testName, userId: userId, config: config)
        
        switch variant {
        case .control:
            // Standard recommendations
            XCTAssertFalse(report.recommendations.isEmpty, "Control should have recommendations")
        case .variantA:
            // Detailed recommendations
            XCTAssertFalse(report.recommendations.isEmpty, "Variant A should have recommendations")
        case .variantB:
            // Simplified recommendations
            XCTAssertFalse(report.recommendations.isEmpty, "Variant B should have recommendations")
        }
    }
    
    func testPlanGenerationSpeedVariant() {
        // A-B Test: Different optimization algorithms for speed
        let config = ABTestConfig(
            testName: "plan_generation_speed",
            variants: [.control, .variantA],
            allocation: [.control: 0.5, .variantA: 0.5]
        )
        
        let healthData = createTestHealthData()
        let solver = DietSolver()
        
        let userId = "test_user"
        let variant = ABTestManager.shared.assignVariant(for: config.testName, userId: userId, config: config)
        
        // Measure performance for each variant
        let startTime = Date()
        let plan = solver.solve(healthData: healthData, season: .spring)
        let duration = Date().timeIntervalSince(startTime)
        
        XCTAssertNotNil(plan, "Plan should be generated")
        
        // Log performance metrics (in real implementation, this would be tracked)
        switch variant {
        case .control:
            print("Control variant: \(duration)s")
        case .variantA:
            print("Variant A: \(duration)s")
        case .variantB:
            print("Variant B: \(duration)s")
        }
    }
    
    func testUserEngagementVariant() {
        // A-B Test: Different features to increase engagement
        let config = ABTestConfig(
            testName: "user_engagement",
            variants: [.control, .variantA, .variantB],
            allocation: ABTestConfig.defaultAllocation
        )
        
        let viewModel = DietSolverViewModel()
        let healthData = createTestHealthData()
        
        let userId = "test_user"
        let variant = ABTestManager.shared.assignVariant(for: config.testName, userId: userId, config: config)
        
        viewModel.setHealthData(healthData)
        
        // Simulate different engagement features based on variant
        switch variant {
        case .control:
            // Standard features
            viewModel.solveDiet()
        case .variantA:
            // Enhanced notifications
            viewModel.solveDiet()
            // In real implementation, would enable enhanced notifications
        case .variantB:
            // Gamification features
            viewModel.solveDiet()
            // In real implementation, would enable badges/gamification
        }
        
        let expectation = XCTestExpectation(description: "Plan generated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(viewModel.dietPlan, "Plan should be generated for all variants")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAllocationDistribution() {
        // Test that allocation works correctly across many users
        let config = ABTestConfig(
            testName: "allocation_test",
            variants: [.control, .variantA, .variantB],
            allocation: ABTestConfig.defaultAllocation
        )
        
        var variantCounts: [Variant: Int] = [.control: 0, .variantA: 0, .variantB: 0]
        let totalUsers = 1000
        
        for i in 0..<totalUsers {
            let userId = "user_\(i)"
            let variant = ABTestManager.shared.assignVariant(for: config.testName, userId: userId, config: config)
            variantCounts[variant, default: 0] += 1
        }
        
        // Check that distribution is approximately correct (within 10% tolerance)
        let controlRatio = Double(variantCounts[.control]!) / Double(totalUsers)
        let variantARatio = Double(variantCounts[.variantA]!) / Double(totalUsers)
        let variantBRatio = Double(variantCounts[.variantB]!) / Double(totalUsers)
        
        XCTAssertEqual(controlRatio, 0.33, accuracy: 0.1, "Control allocation should be ~33%")
        XCTAssertEqual(variantARatio, 0.33, accuracy: 0.1, "Variant A allocation should be ~33%")
        XCTAssertEqual(variantBRatio, 0.34, accuracy: 0.1, "Variant B allocation should be ~34%")
    }
    
    override func tearDown() {
        ABTestManager.shared.reset()
        super.tearDown()
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
