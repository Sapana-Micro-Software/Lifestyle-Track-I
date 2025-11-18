//
//  HearingIntegrationSwiftTestingTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Testing
@testable import DietSolver

// MARK: - SwiftTesting Unit Tests
struct HearingIntegrationSwiftTestingTests {
    
    @Test("Hearing data models can be created")
    func testHearingDataModelCreation() async throws {
        let prescription = HearingPrescription(
            date: Date(),
            rightEar: HearingPrescription.EarPrescription(),
            leftEar: HearingPrescription.EarPrescription()
        )
        #expect(prescription.rightEar.hearingLossType == nil)
    }
    
    @Test("Daily audio hearing test can be created")
    func testDailyAudioHearingTestCreation() async throws {
        let test = DailyAudioHearingTest(
            date: Date(),
            testType: .quick,
            device: .iphone
        )
        #expect(test.testType == .quick)
        #expect(test.device == .iphone)
    }
    
    @Test("Music hearing session can be created")
    func testMusicHearingSessionCreation() async throws {
        let session = MusicHearingSession(
            date: Date(),
            duration: 30.0,
            musicType: .classical,
            volumeLevel: .moderate
        )
        #expect(session.duration == 30.0)
        #expect(session.musicType == .classical)
    }
    
    @Test("Health data can store hearing data")
    func testHealthDataWithHearingData() async throws {
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        healthData.dailyAudioHearingTests.append(
            DailyAudioHearingTest(date: Date(), testType: .quick)
        )
        healthData.musicHearingSessions.append(
            MusicHearingSession(date: Date(), duration: 30.0)
        )
        
        #expect(healthData.dailyAudioHearingTests.count == 1)
        #expect(healthData.musicHearingSessions.count == 1)
    }
    
    @Test("Exercise planner includes hearing activities in weekly plan")
    func testExercisePlannerIncludesHearingActivities() async throws {
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
        
        let hasHearingActivity = plan.weeklyPlan.contains { dayPlan in
            dayPlan.activities.contains { activity in
                activity.activity.name.contains("Music") ||
                activity.activity.name.contains("Hearing") ||
                activity.activity.name.contains("Binaural") ||
                activity.activity.name.contains("Nature Sounds")
            }
        }
        #expect(hasHearingActivity, "Weekly plan should include hearing-related activities")
    }
    
    @Test("Exercise planner recommends hearing exercises when no tests exist")
    func testExercisePlannerRecommendsHearingExercisesWhenNoTests() async throws {
        let healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        let planner = ExercisePlanner()
        let recommendations = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasHearingRecommendation = recommendations.contains { activity in
            activity.name.contains("Hearing") || activity.name.contains("Music")
        }
        #expect(hasHearingRecommendation, "Should recommend hearing exercises when no tests exist")
    }
    
    @Test("Exercise planner recommends hearing exercises for hearing loss")
    func testExercisePlannerRecommendsHearingExercisesForHearingLoss() async throws {
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 1000,
                threshold: 30.0, // Mild hearing loss
                ear: .right
            )
        ]
        healthData.dailyAudioHearingTests.append(test)
        
        let planner = ExercisePlanner()
        let recommendations = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasHearingExercise = recommendations.contains { activity in
            activity.name == "Hearing Exercise"
        }
        #expect(hasHearingExercise, "Should recommend hearing exercises for hearing loss")
    }
    
    @Test("Exercise planner recommends tinnitus therapy")
    func testExercisePlannerRecommendsTinnitusTherapy() async throws {
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.tinnitusPresence = true
        test.rightEar.tinnitusSeverity = .moderate
        healthData.dailyAudioHearingTests.append(test)
        
        let planner = ExercisePlanner()
        let recommendations = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTinnitusTherapy = recommendations.contains { activity in
            activity.name == "Nature Sounds Therapy" || activity.name == "Binaural Beats Session"
        }
        #expect(hasTinnitusTherapy, "Should recommend tinnitus therapy for tinnitus")
    }
    
    @Test("Exercise database contains hearing activities")
    func testExerciseDatabaseContainsHearingActivities() async throws {
        let database = ExerciseDatabase.shared
        let hearingActivities = database.activities.filter { activity in
            activity.name.contains("Music") ||
            activity.name.contains("Hearing") ||
            activity.name.contains("Binaural") ||
            activity.name.contains("Nature Sounds") ||
            activity.name.contains("Audio Book")
        }
        #expect(hearingActivities.count > 0, "Exercise database should contain hearing activities")
    }
}

// MARK: - SwiftTesting Regression Tests
struct HearingIntegrationSwiftTestingRegressionTests {
    
    @Test("Hearing data can be encoded and decoded")
    func testHearingDataPersistence() async throws {
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
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(healthData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HealthData.self, from: encoded)
        
        #expect(decoded.dailyAudioHearingTests.count == 1)
        #expect(decoded.musicHearingSessions.count == 1)
    }
    
    @Test("Exercise planner generates consistent results")
    func testExercisePlannerConsistency() async throws {
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
        
        #expect(plan1.weeklyPlan.count == plan2.weeklyPlan.count)
        for (day1, day2) in zip(plan1.weeklyPlan, plan2.weeklyPlan) {
            #expect(day1.activities.count == day2.activities.count)
        }
    }
}

// MARK: - SwiftTesting Black Box Tests
struct HearingIntegrationSwiftTestingBlackBoxTests {
    
    @Test("System handles no hearing data gracefully")
    func testSystemBehaviorWithNoHearingData() async throws {
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
        
        #expect(!plan.weeklyPlan.isEmpty)
        #expect(plan.focusAreas.contains { $0.contains("Hearing") || $0.contains("Music") })
    }
    
    @Test("System handles extensive hearing data")
    func testSystemBehaviorWithExtensiveHearingData() async throws {
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
        
        #expect(!plan.weeklyPlan.isEmpty)
        #expect(!plan.focusAreas.isEmpty)
    }
}

// MARK: - SwiftTesting UX Tests
struct HearingIntegrationSwiftTestingUXTests {
    
    @Test("Hearing activities have clear names and benefits")
    func testHearingActivitiesAreAccessible() async throws {
        let database = ExerciseDatabase.shared
        let hearingActivities = database.activities.filter { activity in
            activity.name.contains("Music") ||
            activity.name.contains("Hearing") ||
            activity.name.contains("Binaural") ||
            activity.name.contains("Nature Sounds")
        }
        
        for activity in hearingActivities {
            #expect(!activity.name.isEmpty)
            #expect(!activity.benefits.isEmpty)
            #expect(activity.benefits.contains { $0.contains("Hearing") || $0.contains("health") })
        }
    }
    
    @Test("Hearing recommendations match user's hearing status")
    func testHearingRecommendationsAreRelevant() async throws {
        var healthData = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        var test = DailyAudioHearingTest(date: Date())
        test.rightEar.tinnitusPresence = true
        healthData.dailyAudioHearingTests.append(test)
        
        let planner = ExercisePlanner()
        let recommendations = planner.recommendExercises(for: healthData, dayOfWeek: 0)
        
        let hasTinnitusActivity = recommendations.contains { activity in
            activity.name == "Nature Sounds Therapy" || activity.name == "Binaural Beats Session"
        }
        #expect(hasTinnitusActivity, "Should recommend relevant activities for tinnitus")
    }
}

// MARK: - SwiftTesting A-B Tests
struct HearingIntegrationSwiftTestingABTests {
    
    @Test("Different hearing activity variants exist")
    func testHearingActivityVariants() async throws {
        let database = ExerciseDatabase.shared
        
        let musicListening = database.activities.first { $0.name == "Music Listening Session" }
        let activeMusic = database.activities.first { $0.name == "Active Music Listening" }
        
        #expect(musicListening != nil)
        #expect(activeMusic != nil)
        
        if let music = musicListening, let active = activeMusic {
            #expect(music.id != active.id)
        }
    }
    
    @Test("Recommendation algorithm handles different variants")
    func testRecommendationAlgorithmVariants() async throws {
        let healthData1 = HealthData(
            age: 30,
            gender: .male,
            weight: 75.0,
            height: 175.0,
            activityLevel: .moderate
        )
        
        var healthData2 = healthData1
        healthData2.dailyAudioHearingTests.append(
            DailyAudioHearingTest(date: Date(), testType: .quick)
        )
        
        let planner = ExercisePlanner()
        let recA = planner.recommendExercises(for: healthData1, dayOfWeek: 0)
        let recB = planner.recommendExercises(for: healthData2, dayOfWeek: 0)
        
        #expect(!recA.isEmpty)
        #expect(!recB.isEmpty)
        
        let hearingRecsA = recA.filter { $0.name.contains("Hearing") || $0.name.contains("Music") }
        let hearingRecsB = recB.filter { $0.name.contains("Hearing") || $0.name.contains("Music") }
        
        #expect(hearingRecsA.count > 0)
        #expect(hearingRecsB.count > 0)
    }
}
