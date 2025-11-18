//
//  HearingAnalyzer.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Hearing Analyzer
class HearingAnalyzer {
    func analyze(tests: [DailyAudioHearingTest], sessions: [MusicHearingSession], prescription: HearingPrescription? = nil) -> HearingAnalysisReport {
        guard !tests.isEmpty || !sessions.isEmpty else {
            return HearingAnalysisReport(
                summary: HearingHealthSummary(),
                testHistory: [],
                musicSessionHistory: [],
                patterns: HearingAnalysisReport.HearingPatterns(),
                recommendations: []
            )
        }
        
        let sortedTests = tests.sorted { $0.date < $1.date }
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        
        // Analyze hearing health summary
        let summary = analyzeSummary(tests: sortedTests, sessions: sortedSessions)
        
        // Analyze patterns
        let patterns = analyzePatterns(tests: sortedTests, sessions: sortedSessions)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            tests: sortedTests,
            sessions: sortedSessions,
            prescription: prescription
        )
        
        return HearingAnalysisReport(
            date: Date(),
            summary: summary,
            testHistory: sortedTests,
            musicSessionHistory: sortedSessions,
            patterns: patterns,
            recommendations: recommendations
        )
    }
    
    private func analyzeSummary(tests: [DailyAudioHearingTest], sessions: [MusicHearingSession]) -> HearingHealthSummary {
        let lastTestDate = tests.last?.date
        let averageThreshold = calculateAverageThreshold(tests: tests)
        let trend = determineTrend(tests: tests)
        let musicFrequency = calculateMusicFrequency(sessions: sessions)
        let avgDuration = calculateAverageDuration(sessions: sessions)
        
        return HearingHealthSummary(
            lastTestDate: lastTestDate,
            averageHearingThreshold: averageThreshold,
            trend: trend,
            recommendations: [],
            nextTestDue: calculateNextTestDue(lastTest: lastTestDate),
            musicSessionFrequency: musicFrequency,
            averageSessionDuration: avgDuration
        )
    }
    
    private func calculateAverageThreshold(tests: [DailyAudioHearingTest]) -> Double? {
        var thresholds: [Double] = []
        
        for test in tests {
            if let rightThresholds = test.rightEar.pureToneThresholds {
                thresholds.append(contentsOf: rightThresholds.map { $0.threshold })
            }
            if let leftThresholds = test.leftEar.pureToneThresholds {
                thresholds.append(contentsOf: leftThresholds.map { $0.threshold })
            }
        }
        
        guard !thresholds.isEmpty else { return nil }
        return thresholds.reduce(0, +) / Double(thresholds.count)
    }
    
    private func determineTrend(tests: [DailyAudioHearingTest]) -> HearingHealthSummary.HearingTrend {
        guard tests.count >= 2 else { return .stable }
        
        let recentTests = Array(tests.suffix(5))
        let olderTests = Array(tests.prefix(max(1, tests.count - 5)))
        
        let recentAvg = calculateAverageThreshold(tests: recentTests) ?? 0
        let olderAvg = calculateAverageThreshold(tests: olderTests) ?? 0
        
        let difference = recentAvg - olderAvg
        
        if abs(difference) < 2 {
            return .stable
        } else if difference > 5 {
            return .declining
        } else if difference < -5 {
            return .improving
        } else {
            return .fluctuating
        }
    }
    
    private func calculateMusicFrequency(sessions: [MusicHearingSession]) -> Double? {
        guard !sessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let recentSessions = sessions.filter { $0.date >= weekAgo }
        return Double(recentSessions.count)
    }
    
    private func calculateAverageDuration(sessions: [MusicHearingSession]) -> Double? {
        guard !sessions.isEmpty else { return nil }
        return sessions.map { $0.duration }.reduce(0, +) / Double(sessions.count)
    }
    
    private func calculateNextTestDue(lastTest: Date?) -> Date? {
        guard let lastTest = lastTest else { return Date() }
        return Calendar.current.date(byAdding: .day, value: 1, to: lastTest)
    }
    
    private func analyzePatterns(tests: [DailyAudioHearingTest], sessions: [MusicHearingSession]) -> HearingAnalysisReport.HearingPatterns {
        var patterns = HearingAnalysisReport.HearingPatterns()
        
        // Analyze hearing loss progression
        if tests.count >= 3 {
            let trend = determineTrend(tests: tests)
            patterns.hearingLossProgression = "Trend: \(trend.rawValue)"
        }
        
        // Analyze music listening patterns
        if !sessions.isEmpty {
            let genres = sessions.compactMap { $0.genre }
            let mostCommonGenre = Dictionary(grouping: genres, by: { $0 })
                .max(by: { $0.value.count < $1.value.count })?.key
            patterns.musicListeningPatterns = "Most common genre: \(mostCommonGenre ?? "varied")"
        }
        
        // Analyze fatigue patterns
        let fatigueSessions = sessions.filter { $0.hearingFatigue.map { $0 != .none } ?? false }
        if !fatigueSessions.isEmpty {
            patterns.fatiguePatterns = "Fatigue reported in \(fatigueSessions.count) sessions"
        }
        
        // Analyze volume preferences
        let volumeLevels = sessions.map { $0.volumeLevel }
        let mostCommonVolume = Dictionary(grouping: volumeLevels, by: { $0 })
            .max(by: { $0.value.count < $1.value.count })?.key
        patterns.volumePreferenceTrends = "Preferred volume: \(mostCommonVolume?.rawValue ?? "moderate")"
        
        return patterns
    }
    
    private func generateRecommendations(
        tests: [DailyAudioHearingTest],
        sessions: [MusicHearingSession],
        prescription: HearingPrescription?
    ) -> [HearingAnalysisReport.HearingRecommendation] {
        var recommendations: [HearingAnalysisReport.HearingRecommendation] = []
        
        // Check test frequency
        let recentTests = tests.filter { test in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(test.date) ?? false
        }
        if recentTests.count < 3 {
            recommendations.append(HearingAnalysisReport.HearingRecommendation(
                type: .test,
                priority: .medium,
                description: "Perform daily hearing tests to monitor your hearing health",
                actionItems: ["Take hearing test each morning", "Track results over time"]
            ))
        }
        
        // Check for hearing loss
        if let latestTest = tests.last {
            if let rightThreshold = latestTest.rightEar.pureToneThresholds?.first?.threshold,
               rightThreshold > 25 {
                recommendations.append(HearingAnalysisReport.HearingRecommendation(
                    type: .exercise,
                    priority: .high,
                    description: "Hearing loss detected. Engage in hearing exercises and consider medical consultation",
                    actionItems: ["Perform hearing exercises daily", "Schedule audiologist appointment", "Use hearing protection"]
                ))
            }
            
            // Check for tinnitus
            if latestTest.rightEar.tinnitusPresence == true || latestTest.leftEar.tinnitusPresence == true {
                recommendations.append(HearingAnalysisReport.HearingRecommendation(
                    type: .music,
                    priority: .high,
                    description: "Tinnitus detected. Use therapeutic music and nature sounds for relief",
                    actionItems: ["Try nature sounds therapy", "Use binaural beats sessions", "Avoid loud environments"]
                ))
            }
        }
        
        // Check music session frequency
        let recentSessions = sessions.filter { session in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
        }
        if recentSessions.count < 3 {
            recommendations.append(HearingAnalysisReport.HearingRecommendation(
                type: .music,
                priority: .medium,
                description: "Regular music listening sessions support hearing health",
                actionItems: ["Schedule daily music listening", "Try active listening sessions", "Explore therapeutic music"]
            ))
        }
        
        // Check volume levels
        let loudSessions = sessions.filter { $0.volumeLevel == .loud || $0.volumeLevel == .veryLoud }
        if loudSessions.count > sessions.count / 2 {
            recommendations.append(HearingAnalysisReport.HearingRecommendation(
                type: .protection,
                priority: .high,
                description: "High volume listening detected. Protect your hearing",
                actionItems: ["Reduce volume levels", "Use hearing protection", "Take breaks between sessions"]
            ))
        }
        
        return recommendations
    }
}
