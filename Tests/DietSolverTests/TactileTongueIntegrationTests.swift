//
//  TactileTongueIntegrationTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Unit Tests
final class TactileTongueIntegrationUnitTests: XCTestCase {
    
    var healthData: HealthData!
    var exercisePlanner: ExercisePlanner!
    
    override func setUp() {
        super.setUp()
        healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        exercisePlanner = ExercisePlanner()
    }
    
    override func tearDown() {
        healthData = nil
        exercisePlanner = nil
        super.tearDown()
    }
    
    // MARK: - Tactile Tests
    
    func testTactileDataModelCreation() {
        let prescription = TactilePrescription(
            date: Date(),
            bodyRegions: [],
            sensitivityLevels: TactilePrescription.SensitivityLevels(
                overall: .normal,
                fineTouch: .normal,
                pressure: .normal,
                temperature: .normal,
                vibration: .normal
            )
        )
        XCTAssertNotNil(prescription)
        XCTAssertEqual(prescription.sensitivityLevels.overall, .normal)
    }
    
    func testDailyTactileTestCreation() {
        let test = DailyTactileTest(
            date: Date(),
            testType: .quick,
            bodyRegion: .fingertips,
            device: .manual
        )
        XCTAssertNotNil(test)
        XCTAssertEqual(test.testType, .quick)
        XCTAssertEqual(test.bodyRegion, .fingertips)
    }
    
    func testTactileVitalitySessionCreation() {
        let session = TactileVitalitySession(
            date: Date(),
            duration: 30.0,
            activityType: .massage,
            intensity: .moderate
        )
        XCTAssertNotNil(session)
        XCTAssertEqual(session.duration, 30.0)
        XCTAssertEqual(session.activityType, .massage)
    }
    
    // MARK: - Tongue Tests
    
    func testTongueDataModelCreation() {
        let prescription = TonguePrescription(
            date: Date(),
            baselineAppearance: TonguePrescription.TongueAppearance(
                color: .pink,
                coating: .none,
                coatingThickness: .none,
                moisture: .normal,
                texture: .smooth,
                size: .normal,
                cracks: .none,
                spots: .none
            )
        )
        XCTAssertNotNil(prescription)
        XCTAssertEqual(prescription.baselineAppearance.color, .pink)
    }
    
    func testDailyTongueTestCreation() {
        let test = DailyTongueTest(
            date: Date(),
            testType: .quick,
            device: .mirror
        )
        XCTAssertNotNil(test)
        XCTAssertEqual(test.testType, .quick)
        XCTAssertEqual(test.device, .mirror)
    }
    
    func testTongueVitalitySessionCreation() {
        let session = TongueVitalitySession(
            date: Date(),
            duration: 15.0,
            activityType: .tongueExercises,
            intensity: .moderate
        )
        XCTAssertNotNil(session)
        XCTAssertEqual(session.duration, 15.0)
        XCTAssertEqual(session.activityType, .tongueExercises)
    }
    
    // MARK: - Integration Tests
    
    func testHealthDataWithTactileAndTongueData() {
        healthData.dailyTactileTests.append(
            DailyTactileTest(date: Date(), testType: .quick)
        )
        healthData.tactileVitalitySessions.append(
            TactileVitalitySession(date: Date(), duration: 30.0)
        )
        healthData.dailyTongueTests.append(
            DailyTongueTest(date: Date(), testType: .quick)
        )
        healthData.tongueVitalitySessions.append(
            TongueVitalitySession(date: Date(), duration: 15.0)
        )
        
        XCTAssertEqual(healthData.dailyTactileTests.count, 1)
        XCTAssertEqual(healthData.tactileVitalitySessions.count, 1)
        XCTAssertEqual(healthData.dailyTongueTests.count, 1)
        XCTAssertEqual(healthData.tongueVitalitySessions.count, 1)
    }
    
    func testExercisePlannerIncludesTactileAndTongueActivities() {
        let goals = ExerciseGoals()
        let plan = exercisePlanner.generateWeeklyPlan(for: healthData, goals: goals)
        
        let hasTactileActivity = plan.weeklyPlan.contains { dayPlan in
            dayPlan.activities.contains { activity in
                activity.activity.name.contains("Tactile") ||
                activity.activity.name.contains("Massage") ||
                activity.activity.name.contains("Texture") ||
                activity.activity.name.contains("Temperature") ||
                activity.activity.name.contains("Reflexology")
            }
        }
        XCTAssertTrue(hasTactileActivity, "Weekly plan should include tactile-related activities")
        
        let hasTongueActivity = plan.weeklyPlan.contains { dayPlan in
            dayPlan.activities.contains { activity in
                activity.activity.name.contains("Tongue") ||
                activity.activity.name.contains("Taste") ||
                activity.activity.name.contains("Speech")
            }
        }
        XCTAssertTrue(hasTongueActivity, "Weekly plan should include tongue-related activities")
    }
    
    func testExercisePlannerRecommendsTactileExercisesWhenNoTests() {
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTactileRecommendation = recommendations.contains { activity in
            activity.name.contains("Tactile") || activity.name.contains("Massage")
        }
        XCTAssertTrue(hasTactileRecommendation, "Should recommend tactile exercises when no tests exist")
    }
    
    func testExercisePlannerRecommendsTongueExercisesWhenNoTests() {
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTongueRecommendation = recommendations.contains { activity in
            activity.name.contains("Tongue") || activity.name.contains("Taste")
        }
        XCTAssertTrue(hasTongueRecommendation, "Should recommend tongue exercises when no tests exist")
    }
    
    func testExercisePlannerRecommendsTactileExercisesForNumbness() {
        var test = DailyTactileTest(date: Date(), bodyRegion: .fingertips)
        test.results.numbness = .moderate
        healthData.dailyTactileTests.append(test)
        
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTactileExercise = recommendations.contains { activity in
            activity.name == "Tactile Stimulation" || activity.name == "Texture Exploration"
        }
        XCTAssertTrue(hasTactileExercise, "Should recommend tactile exercises for numbness")
    }
    
    func testExercisePlannerRecommendsTongueExercisesForTasteIssues() {
        var test = DailyTongueTest(date: Date(), testType: .taste)
        test.tasteTest = DailyTongueTest.TasteTest(
            sweet: 0.3,
            sour: 0.3,
            salty: 0.3,
            bitter: 0.3,
            umami: 0.3,
            overallScore: 0.3
        )
        healthData.dailyTongueTests.append(test)
        
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTasteTraining = recommendations.contains { activity in
            activity.name == "Taste Training"
        }
        XCTAssertTrue(hasTasteTraining, "Should recommend taste training for reduced taste sensitivity")
    }
    
    func testExercisePlannerFocusAreasIncludeTactileAndTongue() {
        let goals = ExerciseGoals()
        let plan = exercisePlanner.generateWeeklyPlan(for: healthData, goals: goals)
        
        let hasTactileFocus = plan.focusAreas.contains { area in
            area.contains("Tactile")
        }
        XCTAssertTrue(hasTactileFocus, "Focus areas should include tactile-related items")
        
        let hasTongueFocus = plan.focusAreas.contains { area in
            area.contains("Tongue")
        }
        XCTAssertTrue(hasTongueFocus, "Focus areas should include tongue-related items")
    }
    
    func testExerciseDatabaseContainsTactileAndTongueActivities() {
        let database = ExerciseDatabase.shared
        let tactileActivities = database.activities.filter { activity in
            activity.name.contains("Tactile") ||
            activity.name.contains("Massage") ||
            activity.name.contains("Texture") ||
            activity.name.contains("Temperature") ||
            activity.name.contains("Reflexology")
        }
        XCTAssertGreaterThan(tactileActivities.count, 0, "Exercise database should contain tactile activities")
        
        let tongueActivities = database.activities.filter { activity in
            activity.name.contains("Tongue") ||
            activity.name.contains("Taste") ||
            activity.name.contains("Speech") ||
            activity.name.contains("Oil Pulling")
        }
        XCTAssertGreaterThan(tongueActivities.count, 0, "Exercise database should contain tongue activities")
    }
}

// MARK: - Analyzer Tests
final class TactileTongueAnalyzerTests: XCTestCase {
    
    func testTactileAnalyzer() {
        let analyzer = TactileAnalyzer()
        let tests: [DailyTactileTest] = []
        let sessions: [TactileVitalitySession] = []
        
        let report = analyzer.analyze(tests: tests, sessions: sessions)
        XCTAssertNotNil(report)
        XCTAssertEqual(report.testHistory.count, 0)
    }
    
    func testTongueAnalyzer() {
        let analyzer = TongueAnalyzer()
        let tests: [DailyTongueTest] = []
        let sessions: [TongueVitalitySession] = []
        
        let report = analyzer.analyze(tests: tests, sessions: sessions)
        XCTAssertNotNil(report)
        XCTAssertEqual(report.testHistory.count, 0)
    }
    
    func testTactileAnalyzerWithData() {
        let analyzer = TactileAnalyzer()
        var test = DailyTactileTest(date: Date(), testType: .comprehensive)
        test.results.pressureSensitivity = 0.8
        test.results.vibrationSensitivity = 0.7
        
        let report = analyzer.analyze(tests: [test], sessions: [])
        XCTAssertNotNil(report)
        XCTAssertEqual(report.testHistory.count, 1)
        XCTAssertNotNil(report.summary.averageSensitivity)
    }
    
    func testTongueAnalyzerWithData() {
        let analyzer = TongueAnalyzer()
        var test = DailyTongueTest(date: Date(), testType: .comprehensive)
        test.tasteTest = DailyTongueTest.TasteTest(
            sweet: 0.8,
            sour: 0.7,
            salty: 0.8,
            bitter: 0.6,
            umami: 0.7,
            overallScore: 0.72
        )
        
        let report = analyzer.analyze(tests: [test], sessions: [])
        XCTAssertNotNil(report)
        XCTAssertEqual(report.testHistory.count, 1)
        XCTAssertNotNil(report.summary.averageTasteScore)
    }
}
