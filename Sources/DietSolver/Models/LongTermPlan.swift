//
//  LongTermPlan.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Plan Duration
enum PlanDuration: String, Codable, CaseIterable {
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
    case twoYears = "2 Years"
    case fiveYears = "5 Years"
    case tenYears = "10 Years"
    
    var days: Int {
        switch self {
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        case .twoYears: return 730
        case .fiveYears: return 1825
        case .tenYears: return 3650
        }
    }
    
    var months: Int {
        switch self {
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .oneYear: return 12
        case .twoYears: return 24
        case .fiveYears: return 60
        case .tenYears: return 120
        }
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, Codable, CaseIterable {
    case gentle = "Gentle"
    case moderate = "Moderate"
    case aggressive = "Aggressive"
    case extreme = "Extreme"
    
    var intensityMultiplier: Double {
        switch self {
        case .gentle: return 0.5
        case .moderate: return 1.0
        case .aggressive: return 1.5
        case .extreme: return 2.0
        }
    }
}

// MARK: - Urgency Level
enum UrgencyLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    func recommendedDifficulty() -> DifficultyLevel {
        switch self {
        case .low: return .gentle
        case .medium: return .moderate
        case .high: return .aggressive
        case .critical: return .extreme
        }
    }
    
    func recommendedDuration() -> PlanDuration {
        switch self {
        case .low: return .oneYear
        case .medium: return .sixMonths
        case .high: return .threeMonths
        case .critical: return .threeMonths
        }
    }
}

// MARK: - Transformation Goal
struct TransformationGoal: Codable, Identifiable {
    let id: UUID
    var category: GoalCategory
    var targetValue: Double?
    var targetDescription: String
    var currentValue: Double?
    var priority: Int // 1-10
    var deadline: Date?
    
    enum GoalCategory: String, Codable, CaseIterable {
        case weight = "Weight"
        case muscleMass = "Muscle Mass"
        case bodyFat = "Body Fat"
        case cardiovascular = "Cardiovascular Health"
        case strength = "Strength"
        case flexibility = "Flexibility"
        case mentalHealth = "Mental Health"
        case cognitive = "Cognitive Function"
        case organHealth = "Organ Health"
        case hormonal = "Hormonal Balance"
        case skinHealth = "Skin Health"
        case sexualHealth = "Sexual Health"
    }
    
    init(id: UUID = UUID(), category: GoalCategory, targetValue: Double? = nil, targetDescription: String, currentValue: Double? = nil, priority: Int = 5, deadline: Date? = nil) {
        self.id = id
        self.category = category
        self.targetValue = targetValue
        self.targetDescription = targetDescription
        self.currentValue = currentValue
        self.priority = priority
        self.deadline = deadline
    }
}

// MARK: - Long-Term Plan
struct LongTermPlan: Codable, Identifiable {
    let id: UUID
    var duration: PlanDuration
    var difficulty: DifficultyLevel
    var urgency: UrgencyLevel
    var startDate: Date
    var endDate: Date
    var goals: [TransformationGoal]
    var phases: [PlanPhase]
    var milestones: [Milestone]
    
    struct PlanPhase: Codable, Identifiable {
        let id: UUID
        var name: String
        var startDay: Int
        var endDay: Int
        var focus: String
        var dietAdjustments: [String]
        var exerciseAdjustments: [String]
        var supplementRecommendations: [String]
        
        init(id: UUID = UUID(), name: String, startDay: Int, endDay: Int, focus: String, dietAdjustments: [String] = [], exerciseAdjustments: [String] = [], supplementRecommendations: [String] = []) {
            self.id = id
            self.name = name
            self.startDay = startDay
            self.endDay = endDay
            self.focus = focus
            self.dietAdjustments = dietAdjustments
            self.exerciseAdjustments = exerciseAdjustments
            self.supplementRecommendations = supplementRecommendations
        }
    }
    
    struct Milestone: Codable, Identifiable {
        let id: UUID
        var name: String
        var targetDate: Date
        var description: String
        var metrics: [String: Double]
        var achieved: Bool
        
        init(id: UUID = UUID(), name: String, targetDate: Date, description: String, metrics: [String: Double] = [:], achieved: Bool = false) {
            self.id = id
            self.name = name
            self.targetDate = targetDate
            self.description = description
            self.metrics = metrics
            self.achieved = achieved
        }
    }
    
    init(id: UUID = UUID(), duration: PlanDuration, difficulty: DifficultyLevel, urgency: UrgencyLevel, startDate: Date = Date(), endDate: Date? = nil, goals: [TransformationGoal] = [], phases: [PlanPhase] = [], milestones: [Milestone] = []) {
        self.id = id
        self.duration = duration
        self.difficulty = difficulty
        self.urgency = urgency
        self.startDate = startDate
        if let endDate = endDate {
            self.endDate = endDate
        } else {
            let calendar = Calendar.current
            self.endDate = calendar.date(byAdding: .day, value: duration.days, to: startDate) ?? startDate
        }
        self.goals = goals
        self.phases = phases
        self.milestones = milestones
    }
}

// MARK: - Daily Plan Entry
struct DailyPlanEntry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var dayNumber: Int
    var dietPlan: DailyDietPlan?
    var exercisePlan: ExercisePlan?
    var supplements: [SupplementRecommendation]
    var meditationMinutes: Double
    var breathingPracticeMinutes: Double
    var sleepTarget: Double // hours
    var waterIntake: Double // liters
    var notes: String?
    
    struct SupplementRecommendation: Codable, Identifiable {
        let id: UUID
        var name: String
        var dosage: String
        var timing: String
        var purpose: String
        
        init(id: UUID = UUID(), name: String, dosage: String, timing: String, purpose: String) {
            self.id = id
            self.name = name
            self.dosage = dosage
            self.timing = timing
            self.purpose = purpose
        }
    }
    
    init(id: UUID = UUID(), date: Date, dayNumber: Int, dietPlan: DailyDietPlan? = nil, exercisePlan: ExercisePlan? = nil, supplements: [SupplementRecommendation] = [], meditationMinutes: Double = 0, breathingPracticeMinutes: Double = 0, sleepTarget: Double = 8, waterIntake: Double = 2.5, notes: String? = nil) {
        self.id = id
        self.date = date
        self.dayNumber = dayNumber
        self.dietPlan = dietPlan
        self.exercisePlan = exercisePlan
        self.supplements = supplements
        self.meditationMinutes = meditationMinutes
        self.breathingPracticeMinutes = breathingPracticeMinutes
        self.sleepTarget = sleepTarget
        self.waterIntake = waterIntake
        self.notes = notes
    }
}
