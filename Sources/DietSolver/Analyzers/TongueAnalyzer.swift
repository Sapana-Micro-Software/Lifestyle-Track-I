//
//  TongueAnalyzer.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Tongue Analyzer
class TongueAnalyzer {
    func analyze(tests: [DailyTongueTest], sessions: [TongueVitalitySession], prescription: TonguePrescription? = nil) -> TongueAnalysisReport {
        guard !tests.isEmpty || !sessions.isEmpty else {
            return TongueAnalysisReport(
                summary: TongueHealthSummary(),
                testHistory: [],
                vitalitySessionHistory: [],
                patterns: TongueAnalysisReport.TonguePatterns(),
                recommendations: []
            )
        }
        
        let sortedTests = tests.sorted { $0.date < $1.date }
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        
        // Analyze tongue health summary
        let summary = analyzeSummary(tests: sortedTests, sessions: sortedSessions)
        
        // Analyze patterns
        let patterns = analyzePatterns(tests: sortedTests, sessions: sortedSessions)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            tests: sortedTests,
            sessions: sortedSessions,
            prescription: prescription
        )
        
        return TongueAnalysisReport(
            date: Date(),
            summary: summary,
            testHistory: sortedTests,
            vitalitySessionHistory: sortedSessions,
            patterns: patterns,
            recommendations: recommendations
        )
    }
    
    private func analyzeSummary(tests: [DailyTongueTest], sessions: [TongueVitalitySession]) -> TongueHealthSummary {
        let lastTestDate = tests.last?.date
        let averageTasteScore = calculateAverageTasteScore(tests: tests)
        let averageMobilityScore = calculateAverageMobilityScore(tests: tests)
        let trend = determineTrend(tests: tests)
        let vitalityFrequency = calculateVitalityFrequency(sessions: sessions)
        let avgDuration = calculateAverageDuration(sessions: sessions)
        
        return TongueHealthSummary(
            lastTestDate: lastTestDate,
            averageTasteScore: averageTasteScore,
            averageMobilityScore: averageMobilityScore,
            trend: trend,
            recommendations: [],
            nextTestDue: calculateNextTestDue(lastTest: lastTestDate),
            vitalitySessionFrequency: vitalityFrequency,
            averageSessionDuration: avgDuration
        )
    }
    
    private func calculateAverageTasteScore(tests: [DailyTongueTest]) -> Double? {
        let tasteScores = tests.compactMap { $0.tasteTest?.overallScore }
        guard !tasteScores.isEmpty else { return nil }
        return tasteScores.reduce(0, +) / Double(tasteScores.count)
    }
    
    private func calculateAverageMobilityScore(tests: [DailyTongueTest]) -> Double? {
        let mobilityScores = tests.compactMap { $0.mobilityTest?.overallScore }
        guard !mobilityScores.isEmpty else { return nil }
        return mobilityScores.reduce(0, +) / Double(mobilityScores.count)
    }
    
    private func determineTrend(tests: [DailyTongueTest]) -> TongueHealthSummary.TongueTrend {
        guard tests.count >= 2 else { return .stable }
        
        let recentTests = Array(tests.suffix(5))
        let olderTests = Array(tests.prefix(max(1, tests.count - 5)))
        
        let recentTaste = calculateAverageTasteScore(tests: recentTests) ?? 0
        let olderTaste = calculateAverageTasteScore(tests: olderTests) ?? 0
        let recentMobility = calculateAverageMobilityScore(tests: recentTests) ?? 0
        let olderMobility = calculateAverageMobilityScore(tests: olderTests) ?? 0
        
        let tasteDiff = recentTaste - olderTaste
        let mobilityDiff = recentMobility - olderMobility
        let overallDiff = (tasteDiff + mobilityDiff) / 2
        
        if abs(overallDiff) < 0.1 {
            return .stable
        } else if overallDiff < -0.2 {
            return .declining
        } else if overallDiff > 0.2 {
            return .improving
        } else {
            return .fluctuating
        }
    }
    
    private func calculateVitalityFrequency(sessions: [TongueVitalitySession]) -> Double? {
        guard !sessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let recentSessions = sessions.filter { $0.date >= weekAgo }
        return Double(recentSessions.count)
    }
    
    private func calculateAverageDuration(sessions: [TongueVitalitySession]) -> Double? {
        guard !sessions.isEmpty else { return nil }
        return sessions.map { $0.duration }.reduce(0, +) / Double(sessions.count)
    }
    
    private func calculateNextTestDue(lastTest: Date?) -> Date? {
        guard let lastTest = lastTest else { return Date() }
        return Calendar.current.date(byAdding: .day, value: 1, to: lastTest)
    }
    
    private func analyzePatterns(tests: [DailyTongueTest], sessions: [TongueVitalitySession]) -> TongueAnalysisReport.TonguePatterns {
        var patterns = TongueAnalysisReport.TonguePatterns()
        
        // Analyze appearance trends
        if tests.count >= 3 {
            let trend = determineTrend(tests: tests)
            patterns.appearanceTrends = "Trend: \(trend.rawValue)"
        }
        
        // Analyze taste trends
        let tasteScores = tests.compactMap { $0.tasteTest?.overallScore }
        if !tasteScores.isEmpty {
            let avg = tasteScores.reduce(0, +) / Double(tasteScores.count)
            patterns.tasteTrends = "Average taste score: \(String(format: "%.2f", avg))"
        }
        
        // Analyze mobility trends
        let mobilityScores = tests.compactMap { $0.mobilityTest?.overallScore }
        if !mobilityScores.isEmpty {
            let avg = mobilityScores.reduce(0, +) / Double(mobilityScores.count)
            patterns.mobilityTrends = "Average mobility score: \(String(format: "%.2f", avg))"
        }
        
        // Analyze symptom patterns
        let painTests = tests.filter { $0.symptoms.pain != .none }
        if !painTests.isEmpty {
            patterns.symptomPatterns = "Pain reported in \(painTests.count) tests"
        }
        
        // Analyze vitality patterns
        if !sessions.isEmpty {
            let activityTypes = sessions.map { $0.activityType }
            let mostCommon = Dictionary(grouping: activityTypes, by: { $0 })
                .max(by: { $0.value.count < $1.value.count })?.key
            patterns.vitalityPatterns = "Most common activity: \(mostCommon?.rawValue ?? "varied")"
        }
        
        return patterns
    }
    
    private func generateRecommendations(
        tests: [DailyTongueTest],
        sessions: [TongueVitalitySession],
        prescription: TonguePrescription?
    ) -> [TongueAnalysisReport.TongueRecommendation] {
        var recommendations: [TongueAnalysisReport.TongueRecommendation] = []
        
        // Check test frequency
        let recentTests = tests.filter { test in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(test.date) ?? false
        }
        if recentTests.count < 3 {
            recommendations.append(TongueAnalysisReport.TongueRecommendation(
                type: .test,
                priority: .medium,
                description: "Perform daily tongue tests to monitor your tongue health",
                actionItems: ["Take tongue test each day", "Track appearance and symptoms"]
            ))
        }
        
        // Check for taste issues
        if let latestTest = tests.last, let tasteTest = latestTest.tasteTest {
            if tasteTest.overallScore < 0.5 {
                recommendations.append(TongueAnalysisReport.TongueRecommendation(
                    type: .exercise,
                    priority: .high,
                    description: "Reduced taste sensitivity detected. Engage in taste training",
                    actionItems: ["Practice taste training daily", "Try tongue exercises", "Consider medical consultation"]
                ))
            }
        }
        
        // Check for mobility issues
        if let latestTest = tests.last, let mobilityTest = latestTest.mobilityTest {
            if mobilityTest.overallScore < 0.5 {
                recommendations.append(TongueAnalysisReport.TongueRecommendation(
                    type: .exercise,
                    priority: .high,
                    description: "Reduced tongue mobility detected. Practice tongue exercises",
                    actionItems: ["Perform tongue exercises daily", "Practice speech exercises", "Consider medical consultation"]
                ))
            }
        }
        
        // Check for symptoms
        if let latestTest = tests.last {
            if latestTest.symptoms.pain == .moderate || latestTest.symptoms.pain == .severe {
                recommendations.append(TongueAnalysisReport.TongueRecommendation(
                    type: .medical,
                    priority: .urgent,
                    description: "Tongue pain detected. Seek medical consultation",
                    actionItems: ["Schedule medical appointment", "Monitor symptoms", "Avoid irritants"]
                ))
            }
        }
        
        // Check vitality session frequency
        let recentSessions = sessions.filter { session in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
        }
        if recentSessions.count < 3 {
            recommendations.append(TongueAnalysisReport.TongueRecommendation(
                type: .vitality,
                priority: .medium,
                description: "Regular tongue vitality sessions support tongue health",
                actionItems: ["Schedule daily tongue exercises", "Practice taste training", "Maintain oral hygiene"]
            ))
        }
        
        return recommendations
    }
}
