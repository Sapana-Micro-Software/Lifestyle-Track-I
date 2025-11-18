//
//  EmotionalHealth.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Emotional Health
struct EmotionalHealth: Codable, Identifiable {
    let id: UUID
    var date: Date
    var emotionalState: EmotionalState
    var moodScore: Double // 0-100
    var stressLevel: StressLevel
    var anxietyLevel: AnxietyLevel
    var happinessLevel: HappinessLevel
    var energyLevel: EnergyLevel
    var socialConnection: SocialConnection
    var emotionalTriggers: [EmotionalTrigger] = []
    var copingStrategies: [CopingStrategy] = []
    var notes: String?
    
    enum EmotionalState: String, Codable, CaseIterable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
        case critical = "Critical"
    }
    
    enum StressLevel: String, Codable, CaseIterable {
        case none = "None"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
        
        var score: Double {
            switch self {
            case .none: return 0.0
            case .low: return 25.0
            case .moderate: return 50.0
            case .high: return 75.0
            case .veryHigh: return 100.0
            }
        }
    }
    
    enum AnxietyLevel: String, Codable, CaseIterable {
        case none = "None"
        case mild = "Mild"
        case moderate = "Moderate"
        case severe = "Severe"
        case extreme = "Extreme"
        
        var score: Double {
            switch self {
            case .none: return 0.0
            case .mild: return 25.0
            case .moderate: return 50.0
            case .severe: return 75.0
            case .extreme: return 100.0
            }
        }
    }
    
    enum HappinessLevel: String, Codable, CaseIterable {
        case veryLow = "Very Low"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
        
        var score: Double {
            switch self {
            case .veryLow: return 20.0
            case .low: return 40.0
            case .moderate: return 60.0
            case .high: return 80.0
            case .veryHigh: return 100.0
            }
        }
    }
    
    enum EnergyLevel: String, Codable, CaseIterable {
        case veryLow = "Very Low"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
        
        var score: Double {
            switch self {
            case .veryLow: return 20.0
            case .low: return 40.0
            case .moderate: return 60.0
            case .high: return 80.0
            case .veryHigh: return 100.0
            }
        }
    }
    
    enum SocialConnection: String, Codable, CaseIterable {
        case isolated = "Isolated"
        case limited = "Limited"
        case moderate = "Moderate"
        case strong = "Strong"
        case veryStrong = "Very Strong"
        
        var score: Double {
            switch self {
            case .isolated: return 20.0
            case .limited: return 40.0
            case .moderate: return 60.0
            case .strong: return 80.0
            case .veryStrong: return 100.0
            }
        }
    }
    
    struct EmotionalTrigger: Codable, Identifiable {
        let id: UUID
        var trigger: String
        var intensity: Double // 0-100
        var category: TriggerCategory
        
        enum TriggerCategory: String, Codable, CaseIterable {
            case work = "Work"
            case relationships = "Relationships"
            case health = "Health"
            case financial = "Financial"
            case family = "Family"
            case other = "Other"
        }
        
        init(id: UUID = UUID(), trigger: String, intensity: Double, category: TriggerCategory) {
            self.id = id
            self.trigger = trigger
            self.intensity = intensity
            self.category = category
        }
    }
    
    struct CopingStrategy: Codable, Identifiable {
        let id: UUID
        var strategy: String
        var effectiveness: Double // 0-100
        var category: StrategyCategory
        
        enum StrategyCategory: String, Codable, CaseIterable {
            case exercise = "Exercise"
            case meditation = "Meditation"
            case social = "Social"
            case creative = "Creative"
            case professional = "Professional"
            case other = "Other"
        }
        
        init(id: UUID = UUID(), strategy: String, effectiveness: Double, category: StrategyCategory) {
            self.id = id
            self.strategy = strategy
            self.effectiveness = effectiveness
            self.category = category
        }
    }
    
    var overallEmotionalScore: Double {
        var score = moodScore * 0.3
        score += (100.0 - stressLevel.score) * 0.2
        score += (100.0 - anxietyLevel.score) * 0.2
        score += happinessLevel.score * 0.15
        score += energyLevel.score * 0.1
        score += socialConnection.score * 0.05
        return min(max(score, 0.0), 100.0)
    }
    
    init(id: UUID = UUID(), date: Date = Date(), emotionalState: EmotionalState, moodScore: Double, stressLevel: StressLevel, anxietyLevel: AnxietyLevel, happinessLevel: HappinessLevel, energyLevel: EnergyLevel, socialConnection: SocialConnection, emotionalTriggers: [EmotionalTrigger] = [], copingStrategies: [CopingStrategy] = [], notes: String? = nil) {
        self.id = id
        self.date = date
        self.emotionalState = emotionalState
        self.moodScore = moodScore
        self.stressLevel = stressLevel
        self.anxietyLevel = anxietyLevel
        self.happinessLevel = happinessLevel
        self.energyLevel = energyLevel
        self.socialConnection = socialConnection
        self.emotionalTriggers = emotionalTriggers
        self.copingStrategies = copingStrategies
        self.notes = notes
    }
}

// MARK: - Emotional Health Summary
struct EmotionalHealthSummary: Codable {
    var totalEntries: Int
    var averageMoodScore: Double
    var averageStressLevel: Double
    var averageAnxietyLevel: Double
    var averageHappinessLevel: Double
    var averageEnergyLevel: Double
    var averageSocialConnection: Double
    var averageOverallScore: Double
    var trend: EmotionalTrend
    var commonTriggers: [String: Int] // trigger -> count
    var effectiveStrategies: [String: Double] // strategy -> average effectiveness
    
    enum EmotionalTrend: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
        case fluctuating = "Fluctuating"
    }
    
    init(entries: [EmotionalHealth]) {
        self.totalEntries = entries.count
        guard !entries.isEmpty else {
            self.averageMoodScore = 0
            self.averageStressLevel = 0
            self.averageAnxietyLevel = 0
            self.averageHappinessLevel = 0
            self.averageEnergyLevel = 0
            self.averageSocialConnection = 0
            self.averageOverallScore = 0
            self.trend = .stable
            self.commonTriggers = [:]
            self.effectiveStrategies = [:]
            return
        }
        
        self.averageMoodScore = entries.reduce(0.0) { $0 + $1.moodScore } / Double(entries.count)
        self.averageStressLevel = entries.reduce(0.0) { $0 + $1.stressLevel.score } / Double(entries.count)
        self.averageAnxietyLevel = entries.reduce(0.0) { $0 + $1.anxietyLevel.score } / Double(entries.count)
        self.averageHappinessLevel = entries.reduce(0.0) { $0 + $1.happinessLevel.score } / Double(entries.count)
        self.averageEnergyLevel = entries.reduce(0.0) { $0 + $1.energyLevel.score } / Double(entries.count)
        self.averageSocialConnection = entries.reduce(0.0) { $0 + $1.socialConnection.score } / Double(entries.count)
        self.averageOverallScore = entries.reduce(0.0) { $0 + $1.overallEmotionalScore } / Double(entries.count)
        
        // Calculate trend
        if entries.count >= 2 {
            let recent = entries.suffix(entries.count / 2)
            let older = entries.prefix(entries.count / 2)
            let recentAvg = recent.reduce(0.0) { $0 + $1.overallEmotionalScore } / Double(recent.count)
            let olderAvg = older.reduce(0.0) { $0 + $1.overallEmotionalScore } / Double(older.count)
            
            if recentAvg > olderAvg + 5 {
                self.trend = .improving
            } else if recentAvg < olderAvg - 5 {
                self.trend = .declining
            } else if abs(recentAvg - olderAvg) > 10 {
                self.trend = .fluctuating
            } else {
                self.trend = .stable
            }
        } else {
            self.trend = .stable
        }
        
        // Common triggers
        var triggerCounts: [String: Int] = [:]
        for entry in entries {
            for trigger in entry.emotionalTriggers {
                triggerCounts[trigger.trigger, default: 0] += 1
            }
        }
        self.commonTriggers = triggerCounts
        
        // Effective strategies
        var strategyEffectiveness: [String: [Double]] = [:]
        for entry in entries {
            for strategy in entry.copingStrategies {
                strategyEffectiveness[strategy.strategy, default: []].append(strategy.effectiveness)
            }
        }
        self.effectiveStrategies = strategyEffectiveness.mapValues { values in
            values.reduce(0.0, +) / Double(values.count)
        }
    }
}
