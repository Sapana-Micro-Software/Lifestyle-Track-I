//
//  HealthHistory.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Health History for Streak Tracking
struct HealthHistory: Codable {
    var dailyRecords: [DailyHealthRecord] = []
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var streakStartDate: Date?
    
    struct DailyHealthRecord: Codable, Identifiable {
        let id: UUID
        var date: Date
        var healthScore: Double
        var eatingScore: Double?
        var emotionalScore: Double?
        var metCriteria: Bool // Whether met criteria for streak (e.g., 95+ health score)
        
        init(id: UUID = UUID(), date: Date, healthScore: Double, eatingScore: Double? = nil, emotionalScore: Double? = nil, metCriteria: Bool) {
            self.id = id
            self.date = date
            self.healthScore = healthScore
            self.eatingScore = eatingScore
            self.emotionalScore = emotionalScore
            self.metCriteria = metCriteria
        }
    }
    
    mutating func addRecord(_ record: DailyHealthRecord) {
        dailyRecords.append(record)
        updateStreaks()
    }
    
    mutating func updateStreaks() {
        // Sort by date
        dailyRecords.sort { $0.date < $1.date }
        
        // Calculate current streak
        var streak = 0
        var streakStart: Date?
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if today has a record
        let todayRecord = dailyRecords.last { calendar.isDate($0.date, inSameDayAs: today) }
        if let todayRecord = todayRecord, todayRecord.metCriteria {
            streak = 1
            streakStart = todayRecord.date
            
            // Count backwards
            var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
            while let record = dailyRecords.first(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }),
                  record.metCriteria {
                streak += 1
                streakStart = record.date
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            }
        }
        
        currentStreak = streak
        streakStartDate = streakStart
        
        // Calculate longest streak
        var longestStreak = 0
        var currentRun = 0
        var lastDate: Date?
        
        for record in dailyRecords where record.metCriteria {
            if let last = lastDate {
                let daysBetween = calendar.dateComponents([.day], from: last, to: record.date).day ?? 0
                if daysBetween == 1 {
                    currentRun += 1
                } else {
                    longestStreak = max(longestStreak, currentRun)
                    currentRun = 1
                }
            } else {
                currentRun = 1
            }
            lastDate = record.date
        }
        longestStreak = max(longestStreak, currentRun)
        self.longestStreak = longestStreak
    }
    
    func getStreakDays(for criteria: BadgeCriteria) -> Int {
        switch criteria.type {
        case .outstandingHealthStreak:
            return currentStreak
        case .healthStreak:
            return currentStreak
        default:
            return 0
        }
    }
}

// MARK: - Health History Manager
class HealthHistoryManager {
    static let shared = HealthHistoryManager()
    
    private var history: HealthHistory = HealthHistory()
    
    private init() {}
    
    func updateHistory(healthData: HealthData?) {
        guard let healthData = healthData else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have a record for today
        if let existingIndex = history.dailyRecords.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            // Update existing record
            let overallScore = BadgeManager.shared.calculateOverallHealthScore(healthData: healthData)
            let eatingScore = healthData.eatingMetrics.isEmpty ? nil : EatingMetricsSummary(metrics: healthData.eatingMetrics).optimalEatingScore
            let emotionalScore = healthData.emotionalHealth.isEmpty ? nil : EmotionalHealthSummary(entries: healthData.emotionalHealth).averageOverallScore
            let metCriteria = overallScore >= 95.0
            
            history.dailyRecords[existingIndex] = HealthHistory.DailyHealthRecord(
                date: today,
                healthScore: overallScore,
                eatingScore: eatingScore,
                emotionalScore: emotionalScore,
                metCriteria: metCriteria
            )
        } else {
            // Add new record
            let overallScore = BadgeManager.shared.calculateOverallHealthScore(healthData: healthData)
            let eatingScore = healthData.eatingMetrics.isEmpty ? nil : EatingMetricsSummary(metrics: healthData.eatingMetrics).optimalEatingScore
            let emotionalScore = healthData.emotionalHealth.isEmpty ? nil : EmotionalHealthSummary(entries: healthData.emotionalHealth).averageOverallScore
            let metCriteria = overallScore >= 95.0
            
            let record = HealthHistory.DailyHealthRecord(
                date: today,
                healthScore: overallScore,
                eatingScore: eatingScore,
                emotionalScore: emotionalScore,
                metCriteria: metCriteria
            )
            history.addRecord(record)
        }
    }
    
    func getHistory() -> HealthHistory {
        return history
    }
    
    func getCurrentStreak() -> Int {
        return history.currentStreak
    }
}
