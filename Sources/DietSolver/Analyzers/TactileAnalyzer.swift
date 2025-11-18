//
//  TactileAnalyzer.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Tactile Analyzer
class TactileAnalyzer {
    func analyze(tests: [DailyTactileTest], sessions: [TactileVitalitySession], prescription: TactilePrescription? = nil) -> TactileAnalysisReport {
        guard !tests.isEmpty || !sessions.isEmpty else {
            return TactileAnalysisReport(
                summary: TactileHealthSummary(),
                testHistory: [],
                vitalitySessionHistory: [],
                patterns: TactileAnalysisReport.TactilePatterns(),
                recommendations: []
            )
        }
        
        let sortedTests = tests.sorted { $0.date < $1.date }
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        
        // Analyze tactile health summary
        let summary = analyzeSummary(tests: sortedTests, sessions: sortedSessions)
        
        // Analyze patterns
        let patterns = analyzePatterns(tests: sortedTests, sessions: sortedSessions)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            tests: sortedTests,
            sessions: sortedSessions,
            prescription: prescription
        )
        
        return TactileAnalysisReport(
            date: Date(),
            summary: summary,
            testHistory: sortedTests,
            vitalitySessionHistory: sortedSessions,
            patterns: patterns,
            recommendations: recommendations
        )
    }
    
    private func analyzeSummary(tests: [DailyTactileTest], sessions: [TactileVitalitySession]) -> TactileHealthSummary {
        let lastTestDate = tests.last?.date
        let averageSensitivity = calculateAverageSensitivity(tests: tests)
        let trend = determineTrend(tests: tests)
        let vitalityFrequency = calculateVitalityFrequency(sessions: sessions)
        let avgDuration = calculateAverageDuration(sessions: sessions)
        
        return TactileHealthSummary(
            lastTestDate: lastTestDate,
            averageSensitivity: averageSensitivity,
            trend: trend,
            recommendations: [],
            nextTestDue: calculateNextTestDue(lastTest: lastTestDate),
            vitalitySessionFrequency: vitalityFrequency,
            averageSessionDuration: avgDuration
        )
    }
    
    private func calculateAverageSensitivity(tests: [DailyTactileTest]) -> Double? {
        var sensitivities: [Double] = []
        
        for test in tests {
            if let pressure = test.results.pressureSensitivity {
                sensitivities.append(pressure)
            }
            if let vibration = test.results.vibrationSensitivity {
                sensitivities.append(vibration)
            }
        }
        
        guard !sensitivities.isEmpty else { return nil }
        return sensitivities.reduce(0, +) / Double(sensitivities.count)
    }
    
    private func determineTrend(tests: [DailyTactileTest]) -> TactileHealthSummary.TactileTrend {
        guard tests.count >= 2 else { return .stable }
        
        let recentTests = Array(tests.suffix(5))
        let olderTests = Array(tests.prefix(max(1, tests.count - 5)))
        
        let recentAvg = calculateAverageSensitivity(tests: recentTests) ?? 0
        let olderAvg = calculateAverageSensitivity(tests: olderTests) ?? 0
        
        let difference = recentAvg - olderAvg
        
        if abs(difference) < 0.1 {
            return .stable
        } else if difference < -0.2 {
            return .declining
        } else if difference > 0.2 {
            return .improving
        } else {
            return .fluctuating
        }
    }
    
    private func calculateVitalityFrequency(sessions: [TactileVitalitySession]) -> Double? {
        guard !sessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let recentSessions = sessions.filter { $0.date >= weekAgo }
        return Double(recentSessions.count)
    }
    
    private func calculateAverageDuration(sessions: [TactileVitalitySession]) -> Double? {
        guard !sessions.isEmpty else { return nil }
        return sessions.map { $0.duration }.reduce(0, +) / Double(sessions.count)
    }
    
    private func calculateNextTestDue(lastTest: Date?) -> Date? {
        guard let lastTest = lastTest else { return Date() }
        return Calendar.current.date(byAdding: .day, value: 1, to: lastTest)
    }
    
    private func analyzePatterns(tests: [DailyTactileTest], sessions: [TactileVitalitySession]) -> TactileAnalysisReport.TactilePatterns {
        var patterns = TactileAnalysisReport.TactilePatterns()
        
        // Analyze sensitivity trends
        if tests.count >= 3 {
            let trend = determineTrend(tests: tests)
            patterns.sensitivityTrends = "Trend: \(trend.rawValue)"
        }
        
        // Analyze vitality patterns
        if !sessions.isEmpty {
            let activityTypes = sessions.map { $0.activityType }
            let mostCommon = Dictionary(grouping: activityTypes, by: { $0 })
                .max(by: { $0.value.count < $1.value.count })?.key
            patterns.vitalityPatterns = "Most common activity: \(mostCommon?.rawValue ?? "varied")"
        }
        
        // Analyze numbness patterns
        let numbnessTests = tests.filter { $0.results.numbness != nil && $0.results.numbness != DailyTactileTest.TestResults.NumbnessLevel.none }
        if !numbnessTests.isEmpty {
            patterns.numbnessPatterns = "Numbness reported in \(numbnessTests.count) tests"
        }
        
        // Analyze pain patterns
        let painTests = tests.filter { $0.results.painSensitivity != nil && $0.results.painSensitivity?.level != DailyTactileTest.TestResults.PainSensitivity.PainLevel.none }
        if !painTests.isEmpty {
            patterns.painPatterns = "Pain reported in \(painTests.count) tests"
        }
        
        return patterns
    }
    
    private func generateRecommendations(
        tests: [DailyTactileTest],
        sessions: [TactileVitalitySession],
        prescription: TactilePrescription?
    ) -> [TactileAnalysisReport.TactileRecommendation] {
        var recommendations: [TactileAnalysisReport.TactileRecommendation] = []
        
        // Check test frequency
        let recentTests = tests.filter { test in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(test.date) ?? false
        }
        if recentTests.count < 3 {
            recommendations.append(TactileAnalysisReport.TactileRecommendation(
                type: .test,
                priority: .medium,
                description: "Perform daily tactile tests to monitor your tactile health",
                actionItems: ["Take tactile test each day", "Track results over time"]
            ))
        }
        
        // Check for numbness
        if let latestTest = tests.last {
            if latestTest.results.numbness == .moderate || latestTest.results.numbness == .severe {
                recommendations.append(TactileAnalysisReport.TactileRecommendation(
                    type: .therapy,
                    priority: .high,
                    description: "Numbness detected. Engage in tactile stimulation and consider medical consultation",
                    actionItems: ["Perform tactile stimulation daily", "Try texture exploration", "Schedule medical appointment"]
                ))
            }
            
            // Check for pain
            if latestTest.results.painSensitivity?.level == .moderate || latestTest.results.painSensitivity?.level == .severe {
                recommendations.append(TactileAnalysisReport.TactileRecommendation(
                    type: .therapy,
                    priority: .high,
                    description: "Pain sensitivity detected. Use temperature therapy and consider medical consultation",
                    actionItems: ["Try temperature therapy", "Use gentle massage", "Schedule medical appointment"]
                ))
            }
        }
        
        // Check vitality session frequency
        let recentSessions = sessions.filter { session in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
        }
        if recentSessions.count < 2 {
            recommendations.append(TactileAnalysisReport.TactileRecommendation(
                type: .vitality,
                priority: .medium,
                description: "Regular tactile vitality sessions support tactile health",
                actionItems: ["Schedule weekly massage therapy", "Try texture exploration", "Practice tactile stimulation"]
            ))
        }
        
        return recommendations
    }
}
