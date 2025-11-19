//
//  PsychologistBadges.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Mental Health Badge Extensions
extension HealthBadge {
    static func psychologistBadges() -> [HealthBadge] {
        return [
            // Therapy Session Streaks
            HealthBadge(
                id: UUID(),
                name: "First Step",
                description: "Complete your first therapy session",
                category: .wellness,
                level: .bronze,
                icon: "heart.circle.fill",
                colorHex: "#CD7F32",
                criteria: BadgeCriteria(type: .consecutiveDays, target: 1, duration: nil, condition: "therapy_session"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Weekly Warrior",
                description: "Complete 7 therapy sessions",
                category: .wellness,
                level: .silver,
                icon: "calendar.badge.clock",
                colorHex: "#C0C0C0",
                criteria: BadgeCriteria(type: .consecutiveDays, target: 7, duration: nil, condition: "therapy_session"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Monthly Mindful",
                description: "Complete 30 therapy sessions",
                category: .wellness,
                level: .gold,
                icon: "moon.stars.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .consecutiveDays, target: 30, duration: nil, condition: "therapy_session"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Mood Improvement
            HealthBadge(
                id: UUID(),
                name: "Mood Lifter",
                description: "Show consistent mood improvement over 7 days",
                category: .wellness,
                level: .bronze,
                icon: "arrow.up.circle.fill",
                colorHex: "#CD7F32",
                criteria: BadgeCriteria(type: .emotionalScore, target: 7, duration: 7, condition: "improvement"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Emotional Champion",
                description: "Maintain positive mood trend for 30 days",
                category: .wellness,
                level: .gold,
                icon: "sun.max.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .emotionalScore, target: 30, duration: 30, condition: "positive_trend"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Coping Strategy Mastery
            HealthBadge(
                id: UUID(),
                name: "Coping Master",
                description: "Successfully use 10 different coping strategies",
                category: .wellness,
                level: .silver,
                icon: "shield.fill",
                colorHex: "#C0C0C0",
                criteria: BadgeCriteria(type: .consistency, target: 10, duration: nil, condition: "coping_strategies"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Crisis Resilience
            HealthBadge(
                id: UUID(),
                name: "Resilience Builder",
                description: "Successfully navigate 5 difficult situations",
                category: .wellness,
                level: .gold,
                icon: "mountain.2.fill",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .consistency, target: 5, duration: nil, condition: "crisis_resilience"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Mindfulness Practice
            HealthBadge(
                id: UUID(),
                name: "Mindful Beginner",
                description: "Complete 10 mindfulness exercises",
                category: .wellness,
                level: .bronze,
                icon: "leaf.fill",
                colorHex: "#CD7F32",
                criteria: BadgeCriteria(type: .consistency, target: 10, duration: nil, condition: "mindfulness"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Mindfulness Master",
                description: "Complete 100 mindfulness exercises",
                category: .wellness,
                level: .platinum,
                icon: "sparkles",
                colorHex: "#E5E4E2",
                criteria: BadgeCriteria(type: .consistency, target: 100, duration: nil, condition: "mindfulness"),
                earnedDate: nil,
                progress: 0.0
            ),
            
            // Progress Milestones
            HealthBadge(
                id: UUID(),
                name: "Progress Pioneer",
                description: "Achieve your first therapy goal",
                category: .achievement,
                level: .bronze,
                icon: "star.fill",
                colorHex: "#CD7F32",
                criteria: BadgeCriteria(type: .consistency, target: 1, duration: nil, condition: "therapy_goal"),
                earnedDate: nil,
                progress: 0.0
            ),
            HealthBadge(
                id: UUID(),
                name: "Goal Getter",
                description: "Complete 5 therapy goals",
                category: .achievement,
                level: .gold,
                icon: "target",
                colorHex: "#FFD700",
                criteria: BadgeCriteria(type: .consistency, target: 5, duration: nil, condition: "therapy_goal"),
                earnedDate: nil,
                progress: 0.0
            )
        ]
    }
}

// MARK: - Psychologist Badge Tracker
class PsychologistBadgeTracker {
    static let shared = PsychologistBadgeTracker()
    
    private var earnedBadgeIds: Set<UUID> = []
    
    private init() {
        loadEarnedBadges()
    }
    
    func checkPsychologistBadges(sessionCount: Int, moodImprovement: Bool, copingStrategiesUsed: Int, mindfulnessCount: Int, goalsCompleted: Int, crisisResilience: Int) {
        let psychologistBadges = HealthBadge.psychologistBadges()
        
        for badge in psychologistBadges {
            var progress: Double = 0.0
            
            switch badge.criteria.type {
            case .consecutiveDays:
                if badge.criteria.condition == "therapy_session" {
                    progress = min(Double(sessionCount) / badge.criteria.target, 1.0)
                }
            case .emotionalScore:
                if badge.criteria.condition == "improvement" && moodImprovement {
                    progress = 1.0
                } else if badge.criteria.condition == "positive_trend" && moodImprovement {
                    progress = 1.0
                }
            case .consistency:
                if badge.criteria.condition == "coping_strategies" {
                    progress = min(Double(copingStrategiesUsed) / badge.criteria.target, 1.0)
                } else if badge.criteria.condition == "mindfulness" {
                    progress = min(Double(mindfulnessCount) / badge.criteria.target, 1.0)
                } else if badge.criteria.condition == "therapy_goal" {
                    progress = min(Double(goalsCompleted) / badge.criteria.target, 1.0)
                } else if badge.criteria.condition == "crisis_resilience" {
                    progress = min(Double(crisisResilience) / badge.criteria.target, 1.0)
                }
            default:
                break
            }
            
            if progress >= 1.0 && !earnedBadgeIds.contains(badge.id) {
                earnedBadgeIds.insert(badge.id)
                saveEarnedBadges()
                // Badge earned - can trigger notification here if needed
            }
        }
    }
    
    func hasEarnedBadge(_ badgeId: UUID) -> Bool {
        return earnedBadgeIds.contains(badgeId)
    }
    
    private func saveEarnedBadges() {
        let badgeIds = Array(earnedBadgeIds).map { $0.uuidString }
        UserDefaults.standard.set(badgeIds, forKey: "psychologistEarnedBadges")
    }
    
    private func loadEarnedBadges() {
        if let badgeIds = UserDefaults.standard.array(forKey: "psychologistEarnedBadges") as? [String] {
            earnedBadgeIds = Set(badgeIds.compactMap { UUID(uuidString: $0) })
        }
    }
}
