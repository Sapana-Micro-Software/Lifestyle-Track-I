//
//  HearingIntegrationTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Unit Tests
final class HearingIntegrationUnitTests: XCTestCase {
    
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
    
    // MARK: - Unit Tests
    
    func testHearingDataModelCreation() {
        // Test hearing prescription creation
        let prescription = HearingPrescription(
            date: Date(),
            rightEar: HearingPrescription.EarPrescription(),
            leftEar: HearingPrescription.EarPrescription()
        )
        XCTAssertNotNil(prescription)
        XCTAssertEqual(prescription.rightEar.hearingLossType, nil)
    }
    
    func testDailyAudioHearingTestCreation() {
        let test = DailyAudioHearingTest(
            date: Date(),
            testType: .quick,
            device: .iphone
        )
        XCTAssertNotNil(test)
        XCTAssertEqual(test.testType, .quick)
        XCTAssertEqual(test.device, .iphone)
    }
    
    func testMusicHearingSessionCreation() {
        let session = MusicHearingSession(
            date: Date(),
            duration: 30.0,
            musicType: .classical,
            volumeLevel: .moderate
        )
        XCTAssertNotNil(session)
        XCTAssertEqual(session.duration, 30.0)
        XCTAssertEqual(session.musicType, .classical)
    }
    
    func testHealthDataWithHearingData() {
        healthData.dailyAudioHearingTests.append(
            DailyAudioHearingTest(date: Date(), testType: .quick)
        )
        healthData.musicHearingSessions.append(
            MusicHearingSession(date: Date(), duration: 30.0)
        )
        
        XCTAssertEqual(healthData.dailyAudioHearingTests.count, 1)
        XCTAssertEqual(healthData.musicHearingSessions.count, 1)
    }
    
    func testExercisePlannerIncludesHearingActivities() {
        let goals = ExerciseGoals()
        let plan = exercisePlanner.generateWeeklyPlan(for: healthData, goals: goals)
        
        // Check that plan includes hearing-related activities
        let hasHearingActivity = plan.weeklyPlan.contains { dayPlan in
            dayPlan.activities.contains { activity in
                activity.activity.name.contains("Music") ||
                activity.activity.name.contains("Hearing") ||
                activity.activity.name.contains("Binaural") ||
                activity.activity.name.contains("Nature Sounds")
            }
        }
        XCTAssertTrue(hasHearingActivity, "Weekly plan should include hearing-related activities")
    }
    
    func testExercisePlannerRecommendsHearingExercisesWhenNoTests() {
        // Health data with no hearing tests
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasHearingRecommendation = recommendations.contains { activity in
            activity.name.contains("Hearing") || activity.name.contains("Music")
        }
        XCTAssertTrue(hasHearingRecommendation, "Should recommend hearing exercises when no tests exist")
    }
    
    func testExercisePlannerRecommendsHearingExercisesForHearingLoss() {
        // Create test with hearing loss
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 1000,
                threshold: 30.0, // Mild hearing loss
                ear: .right
            )
        ]
        healthData.dailyAudioHearingTests.append(test)
        
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasHearingExercise = recommendations.contains { activity in
            activity.name == "Hearing Exercise"
        }
        XCTAssertTrue(hasHearingExercise, "Should recommend hearing exercises for hearing loss")
    }
    
    func testExercisePlannerRecommendsTinnitusTherapy() {
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.tinnitusPresence = true
        test.rightEar.tinnitusSeverity = .moderate
        healthData.dailyAudioHearingTests.append(test)
        
        let recommendations = exercisePlanner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTinnitusTherapy = recommendations.contains { activity in
            activity.name == "Nature Sounds Therapy" || activity.name == "Binaural Beats Session"
        }
        XCTAssertTrue(hasTinnitusTherapy, "Should recommend tinnitus therapy for tinnitus")
    }
    
    func testExercisePlannerFocusAreasIncludeHearing() {
        let goals = ExerciseGoals()
        let plan = exercisePlanner.generateWeeklyPlan(for: healthData, goals: goals)
        
        let hasHearingFocus = plan.focusAreas.contains { area in
            area.contains("Hearing") || area.contains("Music")
        }
        XCTAssertTrue(hasHearingFocus, "Focus areas should include hearing-related items")
    }
    
    func testExerciseDatabaseContainsHearingActivities() {
        let database = ExerciseDatabase.shared
        let hearingActivities = database.activities.filter { activity in
            activity.name.contains("Music") ||
            activity.name.contains("Hearing") ||
            activity.name.contains("Binaural") ||
            activity.name.contains("Nature Sounds") ||
            activity.name.contains("Audio Book")
        }
        XCTAssertGreaterThan(hearingActivities.count, 0, "Exercise database should contain hearing activities")
    }
}

// MARK: - Regression Tests
final class HearingIntegrationRegressionTests: XCTestCase {
    
    func testHearingDataPersistence() {
        // Test that hearing data can be encoded and decoded
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        let test = DailyAudioHearingTest(date: Date(), testType: .comprehensive)
        healthData.dailyAudioHearingTests.append(test)
        
        let session = MusicHearingSession(date: Date(), duration: 45.0)
        healthData.musicHearingSessions.append(session)
        
        // Encode
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(healthData) else {
            XCTFail("Failed to encode health data")
            return
        }
        
        // Decode
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(HealthData.self, from: encoded) else {
            XCTFail("Failed to decode health data")
            return
        }
        
        XCTAssertEqual(decoded.dailyAudioHearingTests.count, 1)
        XCTAssertEqual(decoded.musicHearingSessions.count, 1)
    }
    
    func testExercisePlannerConsistency() {
        // Test that planner generates consistent results
        let healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        let goals = ExerciseGoals()
        let planner = ExercisePlanner()
        
        let plan1 = planner.generateWeeklyPlan(for: healthData, goals: goals)
        let plan2 = planner.generateWeeklyPlan(for: healthData, goals: goals)
        
        // Plans should have same structure (same number of days, activities per day)
        XCTAssertEqual(plan1.weeklyPlan.count, plan2.weeklyPlan.count)
        for (day1, day2) in zip(plan1.weeklyPlan, plan2.weeklyPlan) {
            XCTAssertEqual(day1.activities.count, day2.activities.count)
        }
    }
    
    func testHearingRecommendationsStability() {
        // Test that recommendations don't change unexpectedly
        let healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        let planner = ExercisePlanner()
        
        let rec1 = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        let rec2 = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        // Should recommend same activities for same input
        let names1 = Set(rec1.map { $0.name })
        let names2 = Set(rec2.map { $0.name })
        XCTAssertEqual(names1, names2)
    }
}

// MARK: - Black Box Tests
final class HearingIntegrationBlackBoxTests: XCTestCase {
    
    func testSystemBehaviorWithNoHearingData() {
        // Test system behavior when no hearing data is provided
        let healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        let planner = ExercisePlanner()
        let goals = ExerciseGoals()
        
        let plan = planner.generateWeeklyPlan(for: healthData, goals: goals)
        
        // System should still function and include hearing activities
        XCTAssertFalse(plan.weeklyPlan.isEmpty)
        XCTAssertTrue(plan.focusAreas.contains { $0.contains("Hearing") || $0.contains("Music") })
    }
    
    func testSystemBehaviorWithExtensiveHearingData() {
        // Test system with many hearing tests and sessions
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        // Add 30 days of hearing tests
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            healthData.dailyAudioHearingTests.append(
                DailyAudioHearingTest(date: date, testType: .quick)
            )
        }
        
        // Add 20 music sessions
        for i in 0..<20 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            healthData.musicHearingSessions.append(
                MusicHearingSession(date: date, duration: Double.random(in: 20...60))
            )
        }
        
        let planner = ExercisePlanner()
        let goals = ExerciseGoals()
        let plan = planner.generateWeeklyPlan(for: healthData, goals: goals)
        
        // System should handle extensive data gracefully
        XCTAssertFalse(plan.weeklyPlan.isEmpty)
        XCTAssertFalse(plan.focusAreas.isEmpty)
    }
    
    func testSystemBehaviorWithInvalidHearingData() {
        // Test system with edge cases
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        // Add test with extreme values
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 20000, // Very high frequency
                threshold: 100.0, // Very high threshold (severe loss)
                ear: .right
            )
        ]
        healthData.dailyAudioHearingTests.append(test)
        
        let planner = ExercisePlanner()
        let recommendations = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        // System should handle extreme values without crashing
        XCTAssertFalse(recommendations.isEmpty)
    }
}

// MARK: - UX Tests
final class HearingIntegrationUXTests: XCTestCase {
    
    func testHearingActivitiesAreAccessible() {
        // Test that hearing activities are easy to find and use
        let database = ExerciseDatabase.shared
        let hearingActivities = database.activities.filter { activity in
            activity.name.contains("Music") ||
            activity.name.contains("Hearing") ||
            activity.name.contains("Binaural") ||
            activity.name.contains("Nature Sounds")
        }
        
        // All hearing activities should have clear names and benefits
        for activity in hearingActivities {
            XCTAssertFalse(activity.name.isEmpty)
            XCTAssertFalse(activity.benefits.isEmpty)
            XCTAssertTrue(activity.benefits.contains { $0.contains("Hearing") || $0.contains("health") })
        }
    }
    
    func testHearingRecommendationsAreRelevant() {
        // Test that recommendations match user's hearing status
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        // User with tinnitus
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.tinnitusPresence = true
        healthData.dailyAudioHearingTests.append(test)
        
        let planner = ExercisePlanner()
        let recommendations = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        // Should recommend tinnitus-specific activities
        let hasTinnitusActivity = recommendations.contains { activity in
            activity.name == "Nature Sounds Therapy" || activity.name == "Binaural Beats Session"
        }
        XCTAssertTrue(hasTinnitusActivity, "Should recommend relevant activities for tinnitus")
    }
    
    func testHearingDataCollectionIsSimple() {
        // Test that creating hearing data is straightforward
        let test = DailyAudioHearingTest(
            date: Date(),
            testType: .quick,
            device: .iphone
        )
        
        // Should be able to create with minimal required parameters
        XCTAssertNotNil(test)
        XCTAssertNotNil(test.id)
        XCTAssertNotNil(test.date)
    }
}

// MARK: - A-B Testing Framework
final class HearingIntegrationABTests: XCTestCase {
    
    func testHearingActivityVariants() {
        // Test different variants of hearing activities
        let database = ExerciseDatabase.shared
        
        let musicListening = database.activities.first { $0.name == "Music Listening Session" }
        let activeMusic = database.activities.first { $0.name == "Active Music Listening" }
        
        XCTAssertNotNil(musicListening)
        XCTAssertNotNil(activeMusic)
        
        // Variants should have different characteristics
        if let music = musicListening, let active = activeMusic {
            // Active listening might have different intensity or benefits
            XCTAssertNotEqual(music.id, active.id)
        }
    }
    
    func testRecommendationAlgorithmVariants() {
        // Test different recommendation strategies
        var healthData1 = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        var healthData2 = healthData1
        
        // Variant A: No hearing data
        // Variant B: With hearing data
        healthData2.dailyAudioHearingTests.append(
            DailyAudioHearingTest(date: Date(), testType: .quick)
        )
        
        let planner = ExercisePlanner()
        let recA = planner.recommendExercises(for: healthData1, dayOfWeek: 0)
        let recB = planner.recommendExercises(for: healthData2, dayOfWeek: 0)
        
        // Both should return valid recommendations
        XCTAssertFalse(recA.isEmpty)
        XCTAssertFalse(recB.isEmpty)
        
        // Variant B might have more hearing-specific recommendations
        let hearingRecsA = recA.filter { $0.name.contains("Hearing") || $0.name.contains("Music") }
        let hearingRecsB = recB.filter { $0.name.contains("Hearing") || $0.name.contains("Music") }
        
        // Both variants should include hearing activities
        XCTAssertGreaterThan(hearingRecsA.count, 0)
        XCTAssertGreaterThan(hearingRecsB.count, 0)
    }
}
