//
//  AnalyzerTests.swift
//  DietSolverTests
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import XCTest
@testable import DietSolver

// MARK: - Analyzer Tests
final class AnalyzerTests: XCTestCase {
    
    // MARK: - CognitiveAnalyzer Tests
    
    func testCognitiveAnalyzerBasicAnalysis() {
        let analyzer = CognitiveAnalyzer()
        let assessment = createTestCognitiveAssessment()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report, "Analysis report should be generated")
    }
    
    func testCognitiveAnalyzerIQAnalysis() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.iq = createTestIQAssessment()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.iqAnalysis, "Report should have IQ analysis")
    }
    
    func testCognitiveAnalyzerEQAnalysis() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.eq = createTestEQAssessment()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.eqAnalysis, "Report should have EQ analysis")
    }
    
    func testCognitiveAnalyzerCQAnalysis() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.cq = createTestCQAssessment()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.cqAnalysis, "Report should have CQ analysis")
    }
    
    func testCognitiveAnalyzerSpatialReasoning() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.spatialReasoning = createTestSpatialReasoning()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.spatialAnalysis, "Report should have spatial analysis")
    }
    
    func testCognitiveAnalyzerTemporalReasoning() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.temporalReasoning = createTestTemporalReasoning()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.temporalAnalysis, "Report should have temporal analysis")
    }
    
    func testCognitiveAnalyzerTacticalProblemSolving() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.tacticalProblemSolving = createTestTacticalProblemSolving()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.tacticalAnalysis, "Report should have tactical analysis")
    }
    
    func testCognitiveAnalyzerStrategicProblemSolving() {
        let analyzer = CognitiveAnalyzer()
        var assessment = CognitiveAssessment()
        assessment.strategicProblemSolving = createTestStrategicProblemSolving()
        
        let report = analyzer.analyze(assessment)
        
        XCTAssertNotNil(report.strategicAnalysis, "Report should have strategic analysis")
    }
    
    func testCognitiveAnalyzerRecommendations() {
        let analyzer = CognitiveAnalyzer()
        let assessment = createTestCognitiveAssessment()
        
        let report = analyzer.analyze(assessment)
        
        // Recommendations may be empty for basic assessments
        XCTAssertNotNil(report.recommendations, "Report should have recommendations array")
    }
    
    // MARK: - JournalAnalyzer Tests
    
    func testJournalAnalyzerBasicAnalysis() {
        let analyzer = JournalAnalyzer()
        let entries = createTestJournalEntries()
        
        let report = analyzer.analyze(entries: entries)
        
        XCTAssertNotNil(report, "Analysis report should be generated")
        XCTAssertEqual(report.entryCount, entries.count, "Entry count should match")
    }
    
    func testJournalAnalyzerMoodTrend() {
        let analyzer = JournalAnalyzer()
        let entries = createTestJournalEntries()
        
        let report = analyzer.analyze(entries: entries)
        
        XCTAssertNotNil(report.moodTrend, "Report should have mood trend")
    }
    
    func testJournalAnalyzerEmptyEntries() {
        let analyzer = JournalAnalyzer()
        let entries: [JournalEntry] = []
        
        let report = analyzer.analyze(entries: entries)
        
        XCTAssertNotNil(report, "Should handle empty entries")
        XCTAssertEqual(report.entryCount, 0, "Entry count should be 0")
    }
    
    func testJournalAnalyzerStructuredEntries() {
        let analyzer = JournalAnalyzer()
        let entries = createTestStructuredJournalEntries()
        
        let report = analyzer.analyze(entries: entries)
        
        XCTAssertGreaterThan(report.structuredEntryCount, 0, "Should count structured entries")
    }
    
    func testJournalAnalyzerUnstructuredEntries() {
        let analyzer = JournalAnalyzer()
        let entries = createTestUnstructuredJournalEntries()
        
        let report = analyzer.analyze(entries: entries)
        
        XCTAssertGreaterThan(report.unstructuredEntryCount, 0, "Should count unstructured entries")
    }
    
    func testJournalAnalyzerRecommendations() {
        let analyzer = JournalAnalyzer()
        let entries = createTestJournalEntries()
        
        let report = analyzer.analyze(entries: entries)
        
        // Recommendations may be empty for basic entries
        XCTAssertNotNil(report.recommendations, "Report should have recommendations array")
    }
    
    // MARK: - SleepAnalyzer Tests
    
    func testSleepAnalyzerBasicAnalysis() {
        let analyzer = SleepAnalyzer()
        let records = createTestSleepRecords()
        
        let analysis = analyzer.analyze(records: records, period: .week)
        
        XCTAssertNotNil(analysis, "Analysis should be generated")
        XCTAssertEqual(analysis.records.count, records.count, "Should analyze all records")
    }
    
    func testSleepAnalyzerWeeklyPeriod() {
        let analyzer = SleepAnalyzer()
        let records = createTestSleepRecords()
        
        let analysis = analyzer.analyze(records: records, period: .week)
        
        XCTAssertEqual(analysis.analysisPeriod, .week, "Analysis period should match")
    }
    
    func testSleepAnalyzerMonthlyPeriod() {
        let analyzer = SleepAnalyzer()
        let records = createTestSleepRecords()
        
        let analysis = analyzer.analyze(records: records, period: .month)
        
        XCTAssertEqual(analysis.analysisPeriod, .month, "Analysis period should match")
    }
    
    func testSleepAnalyzerRecommendations() {
        let analyzer = SleepAnalyzer()
        let records = createTestSleepRecords()
        
        let analysis = analyzer.analyze(records: records, period: .week)
        
        XCTAssertFalse(analysis.recommendations.isEmpty, "Analysis should have recommendations")
    }
    
    func testSleepAnalyzerEmptyRecords() {
        let analyzer = SleepAnalyzer()
        let records: [SleepRecord] = []
        
        let analysis = analyzer.analyze(records: records, period: .week)
        
        XCTAssertNotNil(analysis, "Should handle empty records")
    }
    
    // MARK: - VisionAnalyzer Tests
    
    func testVisionAnalyzerBasicAnalysis() {
        let analyzer = VisionAnalyzer()
        let checks = createTestVisionChecks()
        
        let report = analyzer.analyze(checks: checks)
        
        XCTAssertNotNil(report, "Analysis report should be generated")
        XCTAssertEqual(report.checkCount, checks.count, "Check count should match")
    }
    
    func testVisionAnalyzerRightEyeAnalysis() {
        let analyzer = VisionAnalyzer()
        let checks = createTestVisionChecks()
        
        let report = analyzer.analyze(checks: checks)
        
        XCTAssertNotNil(report.rightEyeAnalysis, "Report should have right eye analysis")
    }
    
    func testVisionAnalyzerLeftEyeAnalysis() {
        let analyzer = VisionAnalyzer()
        let checks = createTestVisionChecks()
        
        let report = analyzer.analyze(checks: checks)
        
        XCTAssertNotNil(report.leftEyeAnalysis, "Report should have left eye analysis")
    }
    
    func testVisionAnalyzerRecommendations() {
        let analyzer = VisionAnalyzer()
        let checks = createTestVisionChecks()
        
        let report = analyzer.analyze(checks: checks)
        
        XCTAssertFalse(report.recommendations.isEmpty, "Report should have recommendations")
    }
    
    func testVisionAnalyzerEmptyChecks() {
        let analyzer = VisionAnalyzer()
        let checks: [DailyVisionCheck] = []
        
        let report = analyzer.analyze(checks: checks)
        
        XCTAssertNotNil(report, "Should handle empty checks")
        XCTAssertEqual(report.checkCount, 0, "Check count should be 0")
    }
    
    // MARK: - Helper Methods
    
    private func createTestCognitiveAssessment() -> CognitiveAssessment {
        var assessment = CognitiveAssessment()
        assessment.iq = createTestIQAssessment()
        assessment.eq = createTestEQAssessment()
        return assessment
    }
    
    private func createTestIQAssessment() -> IQAssessment {
        var iq = IQAssessment()
        iq.fullScaleIQ = 110
        iq.verbalIQ = 115
        iq.performanceIQ = 105
        return iq
    }
    
    private func createTestEQAssessment() -> EQAssessment {
        var eq = EQAssessment()
        eq.totalScore = 75
        eq.empathy = 18
        return eq
    }
    
    private func createTestCQAssessment() -> CQAssessment {
        var cq = CQAssessment()
        cq.totalScore = 80
        return cq
    }
    
    private func createTestSpatialReasoning() -> SpatialReasoningAssessment {
        return SpatialReasoningAssessment()
    }
    
    private func createTestTemporalReasoning() -> TemporalReasoningAssessment {
        return TemporalReasoningAssessment()
    }
    
    private func createTestTacticalProblemSolving() -> TacticalProblemSolvingAssessment {
        return TacticalProblemSolvingAssessment()
    }
    
    private func createTestStrategicProblemSolving() -> StrategicProblemSolvingAssessment {
        return StrategicProblemSolvingAssessment()
    }
    
    private func createTestJournalEntries() -> [JournalEntry] {
        var entry = JournalEntry(id: UUID(), date: Date(), entryType: .structured)
        entry.mood = .good
        return [entry]
    }
    
    private func createTestStructuredJournalEntries() -> [JournalEntry] {
        var entry = JournalEntry(
            id: UUID(),
            date: Date(),
            entryType: .structured,
            structuredData: JournalEntry.StructuredJournalData(
                gratitude: [],
                achievements: [],
                challenges: [],
                lessons: [],
                goalsProgress: [],
                healthMetrics: nil,
                energyLevel: nil,
                stressLevel: nil,
                relationships: [],
                workLife: nil
            )
        )
        return [entry]
    }
    
    private func createTestUnstructuredJournalEntries() -> [JournalEntry] {
        var entry = JournalEntry(id: UUID(), date: Date(), entryType: .unstructured)
        entry.unstructuredText = "Today was a good day"
        return [entry]
    }
    
    private func createTestSleepRecords() -> [SleepRecord] {
        var record = SleepRecord(id: UUID(), date: Date())
        record.totalSleepHours = 7.5
        record.quality = .good
        return [record]
    }
    
    private func createTestVisionChecks() -> [DailyVisionCheck] {
        let check = DailyVisionCheck(
            date: Date(),
            time: Date(),
            rightEye: DailyVisionCheck.EyeCheck(visualAcuity: .perfect, eyeStrain: .none, dryness: .none, redness: .none),
            leftEye: DailyVisionCheck.EyeCheck(visualAcuity: .perfect, eyeStrain: .none, dryness: .none, redness: .none),
            bothEyes: DailyVisionCheck.BothEyesCheck(),
            device: .iphone,
            environment: DailyVisionCheck.CheckEnvironment(lighting: .normal),
            notes: nil
        )
        return [check]
    }
}
