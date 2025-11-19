//
//  PsychologistChat.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
import NaturalLanguage
import Vision
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Chat Message
struct ChatMessage: Codable, Identifiable {
    let id: UUID
    var timestamp: Date
    var role: MessageRole
    var content: String
    var sentiment: SentimentAnalysis?
    var entities: [NamedEntity]?
    var intent: MessageIntent?
    var imageAnalysis: ImageEmotionalAnalysis?
    var therapyTechnique: TherapyTechnique?
    
    enum MessageRole: String, Codable {
        case user = "user"
        case psychologist = "psychologist"
        case system = "system"
    }
    
    enum MessageIntent: String, Codable {
        case greeting = "greeting"
        case question = "question"
        case statement = "statement"
        case request = "request"
        case crisis = "crisis"
        case gratitude = "gratitude"
        case concern = "concern"
        case progress = "progress"
    }
    
    init(id: UUID = UUID(), timestamp: Date = Date(), role: MessageRole, content: String, sentiment: SentimentAnalysis? = nil, entities: [NamedEntity]? = nil, intent: MessageIntent? = nil, imageAnalysis: ImageEmotionalAnalysis? = nil, therapyTechnique: TherapyTechnique? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.role = role
        self.content = content
        self.sentiment = sentiment
        self.entities = entities
        self.intent = intent
        self.imageAnalysis = imageAnalysis
        self.therapyTechnique = therapyTechnique
    }
}

// MARK: - Sentiment Analysis
struct SentimentAnalysis: Codable {
    var score: Double // -1.0 (very negative) to 1.0 (very positive)
    var magnitude: Double // 0.0 to 1.0 (strength of sentiment)
    var dominantEmotion: Emotion
    var emotionScores: [Emotion: Double]
    
    enum Emotion: String, Codable, CaseIterable {
        case joy = "Joy"
        case sadness = "Sadness"
        case anger = "Anger"
        case fear = "Fear"
        case surprise = "Surprise"
        case disgust = "Disgust"
        case neutral = "Neutral"
        case anxiety = "Anxiety"
        case stress = "Stress"
        case hope = "Hope"
        case gratitude = "Gratitude"
    }
    
    var riskLevel: RiskLevel {
        if score < -0.7 || dominantEmotion == .sadness || dominantEmotion == .fear || dominantEmotion == .anxiety {
            if magnitude > 0.8 {
                return .high
            }
            return .moderate
        }
        return .low
    }
    
    enum RiskLevel: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case critical = "Critical"
    }
}

// MARK: - Named Entity
struct NamedEntity: Codable, Identifiable {
    let id: UUID
    var text: String
    var category: EntityCategory
    var confidence: Double
    
    enum EntityCategory: String, Codable {
        case person = "Person"
        case location = "Location"
        case organization = "Organization"
        case date = "Date"
        case event = "Event"
        case emotion = "Emotion"
        case trigger = "Trigger"
        case medication = "Medication"
        case symptom = "Symptom"
    }
    
    init(id: UUID = UUID(), text: String, category: EntityCategory, confidence: Double) {
        self.id = id
        self.text = text
        self.category = category
        self.confidence = confidence
    }
}

// MARK: - Image Emotional Analysis
struct ImageEmotionalAnalysis: Codable {
    var facialExpressions: [FacialExpression]
    var emotionalState: EmotionalState
    var bodyLanguage: BodyLanguage?
    var environment: EnvironmentContext?
    
    struct FacialExpression: Codable {
        var emotion: SentimentAnalysis.Emotion
        var confidence: Double
        var intensity: Double // 0.0 to 1.0
    }
    
    enum EmotionalState: String, Codable {
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        case mixed = "Mixed"
    }
    
    struct BodyLanguage: Codable {
        var posture: Posture
        var openness: Double // 0.0 (closed) to 1.0 (open)
        var tension: Double // 0.0 (relaxed) to 1.0 (tense)
        
        enum Posture: String, Codable {
            case open = "Open"
            case closed = "Closed"
            case defensive = "Defensive"
            case relaxed = "Relaxed"
        }
    }
    
    struct EnvironmentContext: Codable {
        var lighting: String?
        var setting: String?
        var timeOfDay: String?
    }
}

// MARK: - Therapy Technique
enum TherapyTechnique: String, Codable, CaseIterable {
    case cbt = "CBT"
    case personCentered = "Person-Centered"
    case solutionFocused = "Solution-Focused"
    case mindfulness = "Mindfulness"
    case dbt = "DBT"
    case gestalt = "Gestalt"
    case psychodynamic = "Psychodynamic"
    case existential = "Existential"
    case narrative = "Narrative"
    case acceptance = "Acceptance and Commitment"
    
    var description: String {
        switch self {
        case .cbt: return "Cognitive Behavioral Therapy - focuses on identifying and changing negative thought patterns"
        case .personCentered: return "Person-Centered Therapy - emphasizes empathy and unconditional positive regard"
        case .solutionFocused: return "Solution-Focused Therapy - focuses on solutions rather than problems"
        case .mindfulness: return "Mindfulness-Based Therapy - emphasizes present-moment awareness"
        case .dbt: return "Dialectical Behavior Therapy - combines CBT with mindfulness"
        case .gestalt: return "Gestalt Therapy - focuses on present experience and awareness"
        case .psychodynamic: return "Psychodynamic Therapy - explores unconscious patterns"
        case .existential: return "Existential Therapy - explores meaning and purpose"
        case .narrative: return "Narrative Therapy - helps reframe personal stories"
        case .acceptance: return "Acceptance and Commitment Therapy - focuses on acceptance and values"
        }
    }
}

// MARK: - Conversation Session
struct ConversationSession: Codable, Identifiable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var messages: [ChatMessage]
    var therapyApproach: TherapyTechnique?
    var sessionSummary: SessionSummary?
    var crisisDetected: Bool
    var crisisLevel: SentimentAnalysis.RiskLevel?
    var personalizedInsights: [PersonalizedInsight]
    
    struct SessionSummary: Codable {
        var keyTopics: [String]
        var emotionalPatterns: [String]
        var progressNotes: [String]
        var recommendations: [String]
        var nextSessionFocus: String?
    }
    
    struct PersonalizedInsight: Codable, Identifiable {
        let id: UUID
        var insight: String
        var basedOn: InsightSource
        var confidence: Double
        
        enum InsightSource: String, Codable {
            case conversation = "Conversation"
            case healthData = "Health Data"
            case journal = "Journal"
            case imageAnalysis = "Image Analysis"
            case historical = "Historical Patterns"
        }
        
        init(id: UUID = UUID(), insight: String, basedOn: InsightSource, confidence: Double) {
            self.id = id
            self.insight = insight
            self.basedOn = basedOn
            self.confidence = confidence
        }
    }
    
    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }
    
    var averageSentiment: Double? {
        let userMessages = messages.filter { $0.role == .user }
        guard !userMessages.isEmpty else { return nil }
        let sentiments = userMessages.compactMap { $0.sentiment?.score }
        guard !sentiments.isEmpty else { return nil }
        return sentiments.reduce(0, +) / Double(sentiments.count)
    }
    
    init(id: UUID = UUID(), startDate: Date = Date(), endDate: Date? = nil, messages: [ChatMessage] = [], therapyApproach: TherapyTechnique? = nil, sessionSummary: SessionSummary? = nil, crisisDetected: Bool = false, crisisLevel: SentimentAnalysis.RiskLevel? = nil, personalizedInsights: [PersonalizedInsight] = []) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.messages = messages
        self.therapyApproach = therapyApproach
        self.sessionSummary = sessionSummary
        self.crisisDetected = crisisDetected
        self.crisisLevel = crisisLevel
        self.personalizedInsights = personalizedInsights
    }
}

// MARK: - User Profile for Personalization
struct PsychologistUserProfile: Codable {
    var conversationHistory: [ConversationSession]
    var preferredTherapyApproach: TherapyTechnique?
    var emotionalPatterns: [EmotionalPattern]
    var triggers: [String: Int] // trigger -> frequency
    var copingStrategies: [String: Double] // strategy -> effectiveness
    var goals: [TherapyGoal]
    var progressMetrics: ProgressMetrics
    
    struct EmotionalPattern: Codable, Identifiable {
        let id: UUID
        var pattern: String
        var frequency: Int
        var context: String
        var dateRange: DateInterval
        
        init(id: UUID = UUID(), pattern: String, frequency: Int, context: String, dateRange: DateInterval) {
            self.id = id
            self.pattern = pattern
            self.frequency = frequency
            self.context = context
            self.dateRange = dateRange
        }
    }
    
    struct TherapyGoal: Codable, Identifiable {
        let id: UUID
        var goal: String
        var progress: Double // 0.0 to 1.0
        var targetDate: Date?
        var milestones: [Milestone]
        
        struct Milestone: Codable, Identifiable {
            let id: UUID
            var description: String
            var achieved: Bool
            var achievedDate: Date?
            
            init(id: UUID = UUID(), description: String, achieved: Bool = false, achievedDate: Date? = nil) {
                self.id = id
                self.description = description
                self.achieved = achieved
                self.achievedDate = achievedDate
            }
        }
        
        init(id: UUID = UUID(), goal: String, progress: Double = 0.0, targetDate: Date? = nil, milestones: [Milestone] = []) {
            self.id = id
            self.goal = goal
            self.progress = progress
            self.targetDate = targetDate
            self.milestones = milestones
        }
    }
    
    struct ProgressMetrics: Codable {
        var averageSentiment: Double
        var sentimentTrend: SentimentTrend
        var sessionFrequency: Double // sessions per week
        var engagementScore: Double // 0.0 to 1.0
        var improvementAreas: [String]
        var strengths: [String]
        
        enum SentimentTrend: String, Codable {
            case improving = "Improving"
            case stable = "Stable"
            case declining = "Declining"
            case fluctuating = "Fluctuating"
        }
    }
    
    init(conversationHistory: [ConversationSession] = [], preferredTherapyApproach: TherapyTechnique? = nil, emotionalPatterns: [EmotionalPattern] = [], triggers: [String: Int] = [:], copingStrategies: [String: Double] = [:], goals: [TherapyGoal] = [], progressMetrics: ProgressMetrics = ProgressMetrics(averageSentiment: 0.0, sentimentTrend: .stable, sessionFrequency: 0.0, engagementScore: 0.0, improvementAreas: [], strengths: [])) {
        self.conversationHistory = conversationHistory
        self.preferredTherapyApproach = preferredTherapyApproach
        self.emotionalPatterns = emotionalPatterns
        self.triggers = triggers
        self.copingStrategies = copingStrategies
        self.goals = goals
        self.progressMetrics = progressMetrics
    }
}
