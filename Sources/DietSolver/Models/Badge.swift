//
//  Badge.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Badge System
struct HealthBadge: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let category: BadgeCategory
    let level: BadgeLevel
    let icon: String
    let colorHex: String
    let criteria: BadgeCriteria
    let earnedDate: Date?
    let progress: Double // 0.0 to 1.0
    
    enum BadgeCategory: String, Codable, CaseIterable {
        case nutrition = "Nutrition"
        case exercise = "Exercise"
        case health = "Health"
        case consistency = "Consistency"
        case achievement = "Achievement"
        case wellness = "Wellness"
    }
    
    enum BadgeLevel: String, Codable, CaseIterable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"
        case diamond = "Diamond"
        case usaMaster = "USA Master of Health"
        case internationalMaster = "International Master of Health"
        case grandmaster = "Grandmaster of Health"
        case worldGrandmaster = "World Grandmaster of Health"
        
        var multiplier: Double {
            switch self {
            case .bronze: return 1.0
            case .silver: return 1.5
            case .gold: return 2.0
            case .platinum: return 3.0
            case .diamond: return 5.0
            case .usaMaster: return 10.0
            case .internationalMaster: return 15.0
            case .grandmaster: return 25.0
            case .worldGrandmaster: return 50.0
            }
        }
        
        var requiresCertificate: Bool {
            switch self {
            case .usaMaster, .internationalMaster, .grandmaster, .worldGrandmaster:
                return true
            default:
                return false
            }
        }
    }
    
    var isEarned: Bool {
        progress >= 1.0
    }
    
    var displayProgress: String {
        if isEarned {
            return "Earned"
        }
        return "\(Int(progress * 100))%"
    }
}

// MARK: - Badge Criteria
struct BadgeCriteria: Codable, Equatable {
    let type: CriteriaType
    let target: Double
    let duration: Int? // days
    let condition: String?
    
    enum CriteriaType: String, Codable {
        case dailyCalories = "daily_calories"
        case weeklyExercise = "weekly_exercise"
        case consecutiveDays = "consecutive_days"
        case totalMeals = "total_meals"
        case healthScore = "health_score"
        case visionScore = "vision_score"
        case hearingScore = "hearing_score"
        case tactileScore = "tactile_score"
        case tongueScore = "tongue_score"
        case consistency = "consistency"
        case weightLoss = "weight_loss"
        case weightGain = "weight_gain"
        case muscleGain = "muscle_gain"
        case flexibility = "flexibility"
        case cardiovascular = "cardiovascular"
        case eatingScore = "eating_score"
        case emotionalScore = "emotional_score"
        case healthStreak = "health_streak"
        case outstandingHealthStreak = "outstanding_health_streak"
    }
}

// MARK: - Badge Manager
class BadgeManager {
    static let shared = BadgeManager()
    
    private var allBadges: [HealthBadge] = []
    private var earnedBadges: Set<UUID> = []
    
    private init() {
        initializeBadges()
    }
    
    private func initializeBadges() {
        allBadges = [
            // Nutrition Badges
            HealthBadge(
                id: UUID(),
                name: "Nutrition Master",
                description: "Maintain optimal nutrition for 30 consecutive days",
                category: .nutrition,
                level: .gold,
                icon: "fork.knife",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .consistency, target: 30, duration: 30, condition: "nutrition"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Calorie Champion",
                description: "Meet daily calorie goals for 7 days",
                category: .nutrition,
                level: .bronze,
                icon: "flame.fill",
                colorHex: "#CD7F32",
                criteria: BadgeCriteria(type: .dailyCalories, target: 7, duration: 7, condition: nil),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Exercise Badges
            HealthBadge(
                id: UUID(),
                name: "Fitness Warrior",
                description: "Complete 100 exercise sessions",
                category: .exercise,
                level: .platinum,
                icon: "figure.run",
                colorHex: "#E5E4E2",
                criteria: BadgeCriteria(type: .totalMeals, target: 100, duration: nil, condition: "exercise"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Cardio King",
                description: "Complete 500 minutes of cardio in a week",
                category: .exercise,
                level: .gold,
                icon: "heart.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .weeklyExercise, target: 500, duration: 7, condition: "cardio"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Health Badges
            HealthBadge(
                id: UUID(),
                name: "Perfect Vision",
                description: "Maintain excellent vision health for 90 days",
                category: .health,
                level: .diamond,
                icon: "eye.fill",
                colorHex: "#B9F2FF",
                criteria: BadgeCriteria(type: .visionScore, target: 90, duration: 90, condition: "excellent"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Eagle Ears",
                description: "Maintain excellent hearing health for 90 days",
                category: .health,
                level: .diamond,
                icon: "ear.fill",
                colorHex: "#B9F2FF",
                criteria: BadgeCriteria(type: .hearingScore, target: 90, duration: 90, condition: "excellent"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Touch Master",
                description: "Maintain excellent tactile health for 90 days",
                category: .health,
                level: .diamond,
                icon: "hand.tap.fill",
                colorHex: "#B9F2FF",
                criteria: BadgeCriteria(type: .tactileScore, target: 90, duration: 90, condition: "excellent"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Taste Expert",
                description: "Maintain excellent tongue health for 90 days",
                category: .health,
                level: .diamond,
                icon: "mouth.fill",
                colorHex: "#B9F2FF",
                criteria: BadgeCriteria(type: .tongueScore, target: 90, duration: 90, condition: "excellent"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Consistency Badges
            HealthBadge(
                id: UUID(),
                name: "Streak Master",
                description: "Maintain a 100-day streak",
                category: .consistency,
                level: .platinum,
                icon: "flame.fill",
                colorHex: "#E5E4E2",
                criteria: BadgeCriteria(type: .consecutiveDays, target: 100, duration: 100, condition: nil),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Achievement Badges
            HealthBadge(
                id: UUID(),
                name: "Outstanding Health",
                description: "Achieve an overall health score of 95+",
                category: .achievement,
                level: .diamond,
                icon: "star.fill",
                colorHex: "#B9F2FF",
                criteria: BadgeCriteria(type: .healthScore, target: 95, duration: nil, condition: nil),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Great Health",
                description: "Achieve an overall health score of 85+",
                category: .achievement,
                level: .gold,
                icon: "star.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .healthScore, target: 85, duration: nil, condition: nil),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Master Level Badges
            HealthBadge(
                id: UUID(),
                name: "USA Master of Health",
                description: "Maintain outstanding health (95+ score) for 365 consecutive days in USA",
                category: .achievement,
                level: .usaMaster,
                icon: "star.circle.fill",
                colorHex: "#1E90FF",
                criteria: BadgeCriteria(type: .outstandingHealthStreak, target: 365, duration: 365, condition: "usa"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "International Master of Health",
                description: "Maintain outstanding health (95+ score) for 365 consecutive days internationally",
                category: .achievement,
                level: .internationalMaster,
                icon: "globe.americas.fill",
                colorHex: "#4169E1",
                criteria: BadgeCriteria(type: .outstandingHealthStreak, target: 365, duration: 365, condition: "international"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Grandmaster of Health",
                description: "Maintain outstanding health (95+ score) for 730 consecutive days with excellent eating and emotional health",
                category: .achievement,
                level: .grandmaster,
                icon: "crown.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .outstandingHealthStreak, target: 730, duration: 730, condition: "grandmaster"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "World Grandmaster of Health",
                description: "Maintain outstanding health (95+ score) for 1095 consecutive days with perfect eating metrics and emotional health",
                category: .achievement,
                level: .worldGrandmaster,
                icon: "star.circle.fill",
                colorHex: "#FF1493",
                criteria: BadgeCriteria(type: .outstandingHealthStreak, target: 1095, duration: 1095, condition: "world_grandmaster"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Eating Metrics Badges
            HealthBadge(
                id: UUID(),
                name: "Optimal Eater",
                description: "Maintain optimal eating speed and chewing habits for 30 days",
                category: .wellness,
                level: .gold,
                icon: "fork.knife.circle.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .eatingScore, target: 85, duration: 30, condition: nil),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Emotional Health Badges
            HealthBadge(
                id: UUID(),
                name: "Emotional Master",
                description: "Maintain excellent emotional health (90+ score) for 90 days",
                category: .wellness,
                level: .platinum,
                icon: "heart.circle.fill",
                colorHex: "#E5E4E2",
                criteria: BadgeCriteria(type: .emotionalScore, target: 90, duration: 90, condition: nil),
                earnedDate: nil,
                progress: 0.0
            ),
        ]
    }
    
    func evaluateBadges(healthData: HealthData?, dietPlan: DailyDietPlan?, exercisePlan: ExercisePlan?) -> [HealthBadge] {
        var updatedBadges: [HealthBadge] = []
        
        for badge in allBadges {
            let progress = calculateProgress(for: badge, healthData: healthData, dietPlan: dietPlan, exercisePlan: exercisePlan)
            let earnedDate = progress >= 1.0 && !earnedBadges.contains(badge.id) ? Date() : badge.earnedDate
            
            if progress >= 1.0 {
                earnedBadges.insert(badge.id)
            }
            
            var updatedBadge = badge
            updatedBadge = HealthBadge(
                id: badge.id,
                name: badge.name,
                description: badge.description,
                category: badge.category,
                level: badge.level,
                icon: badge.icon,
                colorHex: badge.colorHex,
                criteria: badge.criteria,
                earnedDate: earnedDate,
                progress: progress
            )
            updatedBadges.append(updatedBadge)
        }
        
        return updatedBadges
    }
    
    private func calculateProgress(for badge: HealthBadge, healthData: HealthData?, dietPlan: DailyDietPlan?, exercisePlan: ExercisePlan?) -> Double {
        switch badge.criteria.type {
        case .healthScore:
            // Calculate overall health score
            let score = calculateOverallHealthScore(healthData: healthData)
            return min(score / badge.criteria.target, 1.0)
            
        case .visionScore:
            if let visionAnalysis = healthData?.visionAnalysis {
                let score = calculateVisionScore(visionAnalysis)
                return min(score / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .hearingScore:
            if let hearingAnalysis = healthData?.hearingAnalysis {
                let score = calculateHearingScore(hearingAnalysis)
                return min(score / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .tactileScore:
            if let tactileAnalysis = healthData?.tactileAnalysis {
                let score = calculateTactileScore(tactileAnalysis)
                return min(score / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .tongueScore:
            if let tongueAnalysis = healthData?.tongueAnalysis {
                let score = calculateTongueScore(tongueAnalysis)
                return min(score / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .dailyCalories:
            // Would need historical data
            return 0.0
            
        case .weeklyExercise:
            if let plan = exercisePlan {
                let totalMinutes = plan.weeklyPlan.reduce(0.0) { sum, day in
                    sum + day.activities.reduce(0.0) { $0 + $1.duration }
                }
                return min(totalMinutes / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .consistency:
            // Would need historical data
            return 0.0
            
        case .consecutiveDays:
            // Would need historical data
            return 0.0
            
        case .totalMeals:
            // Would need historical data
            return 0.0
            
        case .weightLoss, .weightGain, .muscleGain, .flexibility, .cardiovascular:
            // Would need historical data
            return 0.0
            
        case .eatingScore:
            if let eatingMetrics = healthData?.eatingMetrics, !eatingMetrics.isEmpty {
                let summary = EatingMetricsSummary(metrics: eatingMetrics)
                return min(summary.optimalEatingScore / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .emotionalScore:
            if let emotionalHealth = healthData?.emotionalHealth, !emotionalHealth.isEmpty {
                let summary = EmotionalHealthSummary(entries: emotionalHealth)
                return min(summary.averageOverallScore / badge.criteria.target, 1.0)
            }
            return 0.0
            
        case .healthStreak:
            // Would need historical data to calculate streak
            return 0.0
            
        case .outstandingHealthStreak:
            // Calculate outstanding health streak using history
            let history = HealthHistoryManager.shared.getHistory()
            let streakDays = history.getStreakDays(for: badge.criteria)
            
            // Check additional criteria based on condition
            if let condition = badge.criteria.condition {
                switch condition {
                case "grandmaster", "world_grandmaster":
                    // Require excellent eating and emotional health
                    if let healthData = healthData {
                        let eatingScore = healthData.eatingMetrics.isEmpty ? 0.0 : EatingMetricsSummary(metrics: healthData.eatingMetrics).optimalEatingScore
                        let emotionalScore = healthData.emotionalHealth.isEmpty ? 0.0 : EmotionalHealthSummary(entries: healthData.emotionalHealth).averageOverallScore
                        if eatingScore < 85.0 || emotionalScore < 90.0 {
                            return 0.0
                        }
                    }
                default:
                    break
                }
            }
            
            return min(Double(streakDays) / badge.criteria.target, 1.0)
        }
    }
    
    func calculateOverallHealthScore(healthData: HealthData?) -> Double {
        guard let healthData = healthData else { return 0.0 }
        
        var score = 50.0 // Base score
        
        // Vision health
        if let visionAnalysis = healthData.visionAnalysis {
            score += calculateVisionScore(visionAnalysis) * 0.15
        }
        
        // Hearing health
        if let hearingAnalysis = healthData.hearingAnalysis {
            score += calculateHearingScore(hearingAnalysis) * 0.15
        }
        
        // Tactile health
        if let tactileAnalysis = healthData.tactileAnalysis {
            score += calculateTactileScore(tactileAnalysis) * 0.1
        }
        
        // Tongue health
        if let tongueAnalysis = healthData.tongueAnalysis {
            score += calculateTongueScore(tongueAnalysis) * 0.1
        }
        
        // Medical tests
        if !healthData.medicalTests.bloodTests.isEmpty {
            score += 10.0
        }
        
        return min(score, 100.0)
    }
    
    private func calculateVisionScore(_ analysis: VisionAnalysisReport) -> Double {
        var score = 50.0
        
        // Acuity score
        if let rightAcuity = analysis.rightEyeAnalysis?.averageAcuity {
            score += (rightAcuity / 20.0) * 20.0 // Normalize to 0-20 scale
        }
        if let leftAcuity = analysis.leftEyeAnalysis?.averageAcuity {
            score += (leftAcuity / 20.0) * 20.0
        }
        
        // Strain penalty
        if let strain = analysis.rightEyeAnalysis?.averageStrain {
            switch strain {
            case .none: break
            case .mild: score -= 5.0
            case .moderate: score -= 10.0
            case .severe: score -= 20.0
            }
        }
        
        return min(max(score, 0.0), 100.0)
    }
    
    private func calculateHearingScore(_ analysis: HearingAnalysisReport) -> Double {
        var score = 50.0
        
        if let threshold = analysis.summary.averageHearingThreshold {
            // Lower threshold is better (0-25 dB is normal)
            if threshold <= 25.0 {
                score = 100.0
            } else if threshold <= 40.0 {
                score = 80.0
            } else if threshold <= 55.0 {
                score = 60.0
            } else {
                score = 40.0
            }
        }
        
        return min(max(score, 0.0), 100.0)
    }
    
    private func calculateTactileScore(_ analysis: TactileAnalysisReport) -> Double {
        var score = 50.0
        
        if let sensitivity = analysis.summary.averageSensitivity {
            score = sensitivity * 100.0
        }
        
        return min(max(score, 0.0), 100.0)
    }
    
    private func calculateTongueScore(_ analysis: TongueAnalysisReport) -> Double {
        var score = 50.0
        
        if let tasteScore = analysis.summary.averageTasteScore {
            score += tasteScore * 25.0
        }
        if let mobilityScore = analysis.summary.averageMobilityScore {
            score += mobilityScore * 25.0
        }
        
        return min(max(score, 0.0), 100.0)
    }
    
    func getEarnedBadges() -> [HealthBadge] {
        return allBadges.filter { $0.isEarned }
    }
    
    func getBadgesByCategory(_ category: HealthBadge.BadgeCategory) -> [HealthBadge] {
        return allBadges.filter { $0.category == category }
    }
}
