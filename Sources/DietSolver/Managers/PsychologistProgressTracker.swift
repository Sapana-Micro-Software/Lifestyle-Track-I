//
//  PsychologistProgressTracker.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Progress Tracker for Psychologist Chat
class PsychologistProgressTracker {
    static let shared = PsychologistProgressTracker()
    
    private init() {}
    
    // MARK: - Progress Analysis
    
    func analyzeProgress(profile: PsychologistUserProfile) -> PsychologistUserProfile.ProgressMetrics {
        let sessions = profile.conversationHistory
        
        // Calculate average sentiment
        let sentiments = sessions.compactMap { $0.averageSentiment }
        let averageSentiment = sentiments.isEmpty ? 0.0 : sentiments.reduce(0, +) / Double(sentiments.count)
        
        // Determine trend
        let trend = calculateSentimentTrend(sessions: sessions)
        
        // Calculate session frequency
        let sessionFrequency = calculateSessionFrequency(sessions: sessions)
        
        // Calculate engagement score
        let engagementScore = calculateEngagementScore(sessions: sessions)
        
        // Identify improvement areas
        let improvementAreas = identifyImprovementAreas(profile: profile)
        
        // Identify strengths
        let strengths = identifyStrengths(profile: profile)
        
        return PsychologistUserProfile.ProgressMetrics(
            averageSentiment: averageSentiment,
            sentimentTrend: trend,
            sessionFrequency: sessionFrequency,
            engagementScore: engagementScore,
            improvementAreas: improvementAreas,
            strengths: strengths
        )
    }
    
    private func calculateSentimentTrend(sessions: [ConversationSession]) -> PsychologistUserProfile.ProgressMetrics.SentimentTrend {
        guard sessions.count >= 2 else { return .stable }
        
        let recentSessions = Array(sessions.suffix(5))
        let olderSessions = Array(sessions.prefix(max(0, sessions.count - 5)))
        
        let recentAvg = recentSessions.compactMap { $0.averageSentiment }.reduce(0, +) / Double(recentSessions.count)
        let olderAvg = olderSessions.compactMap { $0.averageSentiment }.reduce(0, +) / Double(olderSessions.count)
        
        let difference = recentAvg - olderAvg
        
        if difference > 0.1 {
            return .improving
        } else if difference < -0.1 {
            return .declining
        } else if abs(difference) < 0.05 {
            return .stable
        } else {
            return .fluctuating
        }
    }
    
    private func calculateSessionFrequency(sessions: [ConversationSession]) -> Double {
        guard !sessions.isEmpty else { return 0.0 }
        
        let firstSession = sessions.first!.startDate
        let lastSession = sessions.last!.startDate
        let days = Calendar.current.dateComponents([.day], from: firstSession, to: lastSession).day ?? 1
        
        return Double(sessions.count) / Double(max(days, 1)) * 7.0 // sessions per week
    }
    
    private func calculateEngagementScore(sessions: [ConversationSession]) -> Double {
        guard !sessions.isEmpty else { return 0.0 }
        
        var totalScore: Double = 0.0
        
        for session in sessions {
            var sessionScore: Double = 0.0
            
            // Message count contribution
            let messageCount = session.messages.count
            sessionScore += min(Double(messageCount) / 20.0, 0.4) // Up to 40% for message count
            
            // Session duration contribution
            let duration = session.duration
            sessionScore += min(duration / 1800.0, 0.3) // Up to 30% for duration (30 min = max)
            
            // Insight count contribution
            sessionScore += min(Double(session.personalizedInsights.count) / 5.0, 0.3) // Up to 30% for insights
            
            totalScore += sessionScore
        }
        
        return min(totalScore / Double(sessions.count), 1.0)
    }
    
    private func identifyImprovementAreas(profile: PsychologistUserProfile) -> [String] {
        var areas: [String] = []
        
        // Analyze triggers
        let topTriggers = profile.triggers.sorted { $0.value > $1.value }.prefix(3)
        if !topTriggers.isEmpty {
            areas.append("Managing triggers: \(topTriggers.map { $0.key }.joined(separator: ", "))")
        }
        
        // Analyze emotional patterns
        let negativePatterns = profile.emotionalPatterns.filter { pattern in
            pattern.pattern.lowercased().contains("negative") ||
            pattern.pattern.lowercased().contains("stress") ||
            pattern.pattern.lowercased().contains("anxiety")
        }
        if !negativePatterns.isEmpty {
            areas.append("Addressing recurring negative emotional patterns")
        }
        
        // Analyze coping strategies effectiveness
        let lowEffectivenessStrategies = profile.copingStrategies.filter { $0.value < 0.5 }
        if !lowEffectivenessStrategies.isEmpty {
            areas.append("Developing more effective coping strategies")
        }
        
        return areas
    }
    
    private func identifyStrengths(profile: PsychologistUserProfile) -> [String] {
        var strengths: [String] = []
        
        // Regular engagement
        if profile.progressMetrics.sessionFrequency > 2.0 {
            strengths.append("Consistent engagement with therapy sessions")
        }
        
        // Effective coping strategies
        let effectiveStrategies = profile.copingStrategies.filter { $0.value > 0.7 }
        if !effectiveStrategies.isEmpty {
            strengths.append("Effective use of coping strategies: \(effectiveStrategies.map { $0.key }.joined(separator: ", "))")
        }
        
        // Progress on goals
        let progressingGoals = profile.goals.filter { $0.progress > 0.5 }
        if !progressingGoals.isEmpty {
            strengths.append("Making progress on therapy goals")
        }
        
        // Positive sentiment trend
        if profile.progressMetrics.sentimentTrend == .improving {
            strengths.append("Improving emotional well-being")
        }
        
        return strengths
    }
    
    // MARK: - Daily Check-In
    
    func generateDailyCheckIn() -> String {
        let greetings = [
            "Good morning! How are you feeling today?",
            "Hello! I'd like to check in with you. How has your day been so far?",
            "Hi there! How are things going for you today?",
            "Good to see you! What's on your mind today?"
        ]
        
        return greetings.randomElement() ?? "Hello! How are you feeling today?"
    }
    
    func shouldPromptCheckIn(lastSession: ConversationSession?) -> Bool {
        guard let lastSession = lastSession else { return true }
        
        let daysSinceLastSession = Calendar.current.dateComponents([.day], from: lastSession.startDate, to: Date()).day ?? 0
        
        // Prompt if it's been more than 2 days
        return daysSinceLastSession > 2
    }
}
