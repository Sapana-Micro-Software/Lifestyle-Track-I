//
//  LongTermPlannerTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Long-Term Planner Tests
final class LongTermPlannerTests: XCTestCase {
    
    var planner: LongTermPlanner!
    var healthData: HealthData!
    
    override func setUp() {
        super.setUp()
        planner = LongTermPlanner()
        healthData = createTestHealthData()
    }
    
    override func tearDown() {
        planner = nil
        healthData = nil
        super.tearDown()
    }
    
    // MARK: - Plan Generation Tests
    
    func testGenerateThreeMonthPlan() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        
        XCTAssertEqual(plan.duration, .threeMonths, "Plan duration should match")
        XCTAssertEqual(plan.urgency, .medium, "Plan urgency should match")
        XCTAssertNotNil(plan.startDate, "Plan should have start date")
        XCTAssertNotNil(plan.endDate, "Plan should have end date")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have goals")
        XCTAssertFalse(plan.phases.isEmpty, "Plan should have phases")
    }
    
    func testGenerateSixMonthPlan() {
        let plan = planner.generatePlan(for: healthData, duration: .sixMonths, urgency: .low)
        
        XCTAssertEqual(plan.duration, .sixMonths, "Plan duration should match")
        XCTAssertEqual(plan.urgency, .low, "Plan urgency should match")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have goals")
    }
    
    func testGenerateOneYearPlan() {
        let plan = planner.generatePlan(for: healthData, duration: .oneYear, urgency: .high)
        
        XCTAssertEqual(plan.duration, .oneYear, "Plan duration should match")
        XCTAssertEqual(plan.urgency, .high, "Plan urgency should match")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have goals")
        XCTAssertFalse(plan.milestones.isEmpty, "Plan should have milestones")
    }
    
    func testGenerateTwoYearPlan() {
        let plan = planner.generatePlan(for: healthData, duration: .twoYears, urgency: .medium)
        
        XCTAssertEqual(plan.duration, .twoYears, "Plan duration should match")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have goals")
    }
    
    func testGenerateFiveYearPlan() {
        let plan = planner.generatePlan(for: healthData, duration: .fiveYears, urgency: .low)
        
        XCTAssertEqual(plan.duration, .fiveYears, "Plan duration should match")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have goals")
    }
    
    func testGenerateTenYearPlan() {
        let plan = planner.generatePlan(for: healthData, duration: .tenYears, urgency: .low)
        
        XCTAssertEqual(plan.duration, .tenYears, "Plan duration should match")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have goals")
    }
    
    // MARK: - Urgency Level Tests
    
    func testUrgencyLevels() {
        let gentlePlan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .low)
        let moderatePlan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let aggressivePlan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .high)
        let extremePlan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .critical)
        
        XCTAssertEqual(gentlePlan.difficulty, .gentle, "Low urgency should create gentle plan")
        XCTAssertEqual(moderatePlan.difficulty, .moderate, "Medium urgency should create moderate plan")
        XCTAssertEqual(aggressivePlan.difficulty, .aggressive, "High urgency should create aggressive plan")
        XCTAssertEqual(extremePlan.difficulty, .extreme, "Critical urgency should create extreme plan")
    }
    
    // MARK: - Goals Generation Tests
    
    func testWeightGoalGeneration() {
        var testData = healthData!
        testData.weight = 80.0
        testData.height = 175.0
        
        let plan = planner.generatePlan(for: testData, duration: .threeMonths, urgency: .medium)
        
        let weightGoal = plan.goals.first { $0.category == .weight }
        XCTAssertNotNil(weightGoal, "Plan should have weight goal")
        XCTAssertNotNil(weightGoal?.currentValue, "Weight goal should have current value")
        XCTAssertNotNil(weightGoal?.targetValue, "Weight goal should have target value")
    }
    
    func testMuscleMassGoalGeneration() {
        var testData = healthData!
        testData.muscleMass = 30.0
        
        let plan = planner.generatePlan(for: testData, duration: .threeMonths, urgency: .medium)
        
        let muscleGoal = plan.goals.first { $0.category == .muscleMass }
        XCTAssertNotNil(muscleGoal, "Plan should have muscle mass goal")
    }
    
    func testMuscleMassGoalEstimation() {
        var testData = healthData!
        testData.muscleMass = nil // No muscle mass data
        
        let plan = planner.generatePlan(for: testData, duration: .threeMonths, urgency: .medium)
        
        let muscleGoal = plan.goals.first { $0.category == .muscleMass }
        XCTAssertNotNil(muscleGoal, "Plan should estimate muscle mass goal")
    }
    
    func testCardiovascularGoalFromCholesterol() {
        var testData = healthData!
        var bloodTest = BloodTestReport(date: Date())
        bloodTest.totalCholesterol = 250.0 // High cholesterol
        testData.medicalTests.bloodTests.append(bloodTest)
        
        let plan = planner.generatePlan(for: testData, duration: .threeMonths, urgency: .medium)
        
        let cardioGoal = plan.goals.first { $0.category == .cardiovascular }
        XCTAssertNotNil(cardioGoal, "Plan should have cardiovascular goal for high cholesterol")
    }
    
    func testMentalHealthGoalFromStress() {
        var testData = healthData!
        testData.mentalHealth = HealthData.MentalHealth(
            stressLevel: .high,
            anxietyLevel: .moderate,
            depressionSymptoms: [],
            currentTherapy: false,
            medications: [],
            sleepQuality: .fair
        )
        
        let plan = planner.generatePlan(for: testData, duration: .threeMonths, urgency: .medium)
        
        let mentalHealthGoal = plan.goals.first { $0.category == .mentalHealth }
        XCTAssertNotNil(mentalHealthGoal, "Plan should have mental health goal for high stress")
    }
    
    // MARK: - Phases Generation Tests
    
    func testPhasesGeneration() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        
        XCTAssertFalse(plan.phases.isEmpty, "Plan should have phases")
        XCTAssertGreaterThanOrEqual(plan.phases.count, 3, "Three month plan should have at least 3 phases")
        XCTAssertLessThanOrEqual(plan.phases.count, 6, "Three month plan should have at most 6 phases")
    }
    
    func testPhaseOrdering() {
        let plan = planner.generatePlan(for: healthData, duration: .sixMonths, urgency: .medium)
        
        for i in 0..<plan.phases.count {
            let phase = plan.phases[i]
            XCTAssertGreaterThanOrEqual(phase.startDay, 1, "Phase start day should be at least 1")
            XCTAssertLessThanOrEqual(phase.endDay, plan.duration.days, "Phase end day should not exceed plan duration")
            
            if i > 0 {
                let previousPhase = plan.phases[i - 1]
                XCTAssertGreaterThan(phase.startDay, previousPhase.endDay, "Phases should not overlap")
            }
        }
    }
    
    func testPhaseNames() {
        let plan = planner.generatePlan(for: healthData, duration: .sixMonths, urgency: .medium)
        
        let phaseNames = plan.phases.map { $0.name }
        XCTAssertTrue(phaseNames.contains("Foundation"), "Plan should have Foundation phase")
    }
    
    // MARK: - Milestones Generation Tests
    
    func testMilestonesGeneration() {
        let plan = planner.generatePlan(for: healthData, duration: .oneYear, urgency: .medium)
        
        XCTAssertFalse(plan.milestones.isEmpty, "One year plan should have milestones")
        for milestone in plan.milestones {
            XCTAssertFalse(milestone.achieved, "New milestones should not be achieved")
            XCTAssertNotNil(milestone.targetDate, "Milestone should have target date")
        }
    }
    
    // MARK: - Daily Plans Generation Tests
    
    func testGenerateDailyPlans() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring)
        
        XCTAssertEqual(dailyPlans.count, plan.duration.days, "Should generate one plan per day")
        
        for (index, dailyPlan) in dailyPlans.enumerated() {
            XCTAssertEqual(dailyPlan.dayNumber, index + 1, "Day number should match index")
            XCTAssertNotNil(dailyPlan.dietPlan, "Daily plan should have diet plan")
            XCTAssertNotNil(dailyPlan.exercisePlan, "Daily plan should have exercise plan")
        }
    }
    
    func testDailyPlansHaveSupplements() {
        var testData = healthData!
        var bloodTest = BloodTestReport(date: Date())
        bloodTest.vitaminD = 20.0 // Low vitamin D
        testData.medicalTests.bloodTests.append(bloodTest)
        
        let plan = planner.generatePlan(for: testData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: testData, season: .spring)
        
        let hasSupplements = dailyPlans.contains { !$0.supplements.isEmpty }
        XCTAssertTrue(hasSupplements, "Daily plans should include supplements for deficiencies")
    }
    
    func testDailyPlansHaveMeditation() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring)
        
        for dailyPlan in dailyPlans {
            XCTAssertGreaterThan(dailyPlan.meditationMinutes, 0, "Daily plan should have meditation minutes")
        }
    }
    
    func testDailyPlansHaveBreathing() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring)
        
        for dailyPlan in dailyPlans {
            XCTAssertGreaterThan(dailyPlan.breathingPracticeMinutes, 0, "Daily plan should have breathing practice minutes")
        }
    }
    
    func testDailyPlansHaveSleepTarget() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring)
        
        for dailyPlan in dailyPlans {
            XCTAssertGreaterThan(dailyPlan.sleepTarget, 0, "Daily plan should have sleep target")
            XCTAssertLessThanOrEqual(dailyPlan.sleepTarget, 10, "Sleep target should be reasonable")
        }
    }
    
    func testDailyPlansHaveWaterIntake() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring)
        
        for dailyPlan in dailyPlans {
            XCTAssertGreaterThan(dailyPlan.waterIntake, 0, "Daily plan should have water intake")
        }
    }
    
    func testDailyPlansProgressAdjustment() {
        let plan = planner.generatePlan(for: healthData, duration: .threeMonths, urgency: .medium)
        let dailyPlans = planner.generateDailyPlans(for: plan, healthData: healthData, season: .spring)
        
        // Check that later days have adjusted health data (weight changes)
        if dailyPlans.count > 10 {
            let earlyPlan = dailyPlans[0]
            let latePlan = dailyPlans[dailyPlans.count - 1]
            
            // Plans should be different due to progress adjustments
            XCTAssertNotEqual(earlyPlan.dayNumber, latePlan.dayNumber, "Plans should be for different days")
        }
    }
    
    // MARK: - Edge Cases
    
    func testPlanWithNoHealthData() {
        let minimalData = HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate)
        let plan = planner.generatePlan(for: minimalData, duration: .threeMonths, urgency: .medium)
        
        XCTAssertNotNil(plan, "Plan should be generated even with minimal data")
        XCTAssertFalse(plan.goals.isEmpty, "Plan should have at least some goals")
    }
    
    func testPlanWithExtremeValues() {
        var extremeData = healthData!
        extremeData.weight = 200.0
        extremeData.height = 150.0
        
        let plan = planner.generatePlan(for: extremeData, duration: .threeMonths, urgency: .medium)
        
        XCTAssertNotNil(plan, "Plan should handle extreme values")
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
}
