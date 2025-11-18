//
//  HealthReportGenerator.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
#if canImport(PDFKit)
import PDFKit
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Report Timeframe
enum ReportTimeframe: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
}

// MARK: - Health Report Generator
class HealthReportGenerator {
    static let shared = HealthReportGenerator()
    
    private init() {}
    
    // MARK: - Generate Health Report
    func generateHealthReport(
        healthData: HealthData,
        longTermPlan: LongTermPlan?,
        dailyPlans: [DailyPlanEntry],
        timeframe: ReportTimeframe = .monthly
    ) -> HealthReport {
        let reportDate = Date()
        let calendar = Calendar.current
        let startDate: Date
        let endDate = reportDate
        
        switch timeframe {
        case .weekly:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        case .monthly:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        case .quarterly:
            startDate = calendar.date(byAdding: .month, value: -3, to: endDate) ?? endDate
        case .yearly:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate) ?? endDate
        }
        
        // Generate sections
        let summary = generateSummary(healthData: healthData, longTermPlan: longTermPlan)
        let goals = generateGoalsSection(longTermPlan: longTermPlan)
        let progress = generateProgressSection(healthData: healthData, dailyPlans: dailyPlans, startDate: startDate, endDate: endDate)
        let recommendations = generateRecommendations(healthData: healthData, longTermPlan: longTermPlan)
        let trends = generateTrendsSection(healthData: healthData, startDate: startDate, endDate: endDate)
        
        return HealthReport(
            id: UUID(),
            generatedDate: reportDate,
            timeframe: timeframe,
            startDate: startDate,
            endDate: endDate,
            summary: summary,
            goals: goals,
            progress: progress,
            recommendations: recommendations,
            trends: trends
        )
    }
    
    // MARK: - Generate Summary
    private func generateSummary(healthData: HealthData, longTermPlan: LongTermPlan?) -> ReportSummary {
        let bmi = calculateBMI(weight: healthData.weight, height: healthData.height)
        let healthScore = calculateHealthScore(healthData: healthData)
        
        return ReportSummary(
            currentWeight: healthData.weight,
            currentBMI: bmi,
            healthScore: healthScore,
            planDuration: longTermPlan?.duration.rawValue ?? "N/A",
            goalsCount: longTermPlan?.goals.count ?? 0,
            milestonesAchieved: longTermPlan?.milestones.filter { $0.achieved }.count ?? 0,
            totalMilestones: longTermPlan?.milestones.count ?? 0
        )
    }
    
    // MARK: - Generate Goals Section
    private func generateGoalsSection(longTermPlan: LongTermPlan?) -> [GoalProgress] {
        guard let plan = longTermPlan else { return [] }
        
        return plan.goals.map { goal in
            let progress = calculateGoalProgress(goal: goal)
            return GoalProgress(
                goalName: goal.targetDescription,
                category: goal.category.rawValue,
                currentValue: goal.currentValue,
                targetValue: goal.targetValue,
                progress: progress,
                priority: goal.priority
            )
        }
    }
    
    // MARK: - Generate Progress Section
    private func generateProgressSection(healthData: HealthData, dailyPlans: [DailyPlanEntry], startDate: Date, endDate: Date) -> ProgressMetrics {
        let plansInRange = dailyPlans.filter { $0.date >= startDate && $0.date <= endDate }
        
        let totalMeals = plansInRange.reduce(0) { $0 + ($1.dietPlan?.meals.count ?? 0) }
        let totalExerciseMinutes = plansInRange.reduce(0.0) { $0 + ($1.exercisePlan?.weeklyPlan.reduce(0.0) { sum, day in
            sum + day.activities.reduce(0.0) { $0 + $1.duration }
        } ?? 0) }
        
        let averageWaterIntake = plansInRange.isEmpty ? 0 : plansInRange.reduce(0.0) { $0 + $1.waterIntake } / Double(plansInRange.count)
        let averageSleep = plansInRange.isEmpty ? 0 : plansInRange.reduce(0.0) { $0 + $1.sleepTarget } / Double(plansInRange.count)
        
        return ProgressMetrics(
            daysTracked: plansInRange.count,
            totalMeals: totalMeals,
            totalExerciseMinutes: totalExerciseMinutes,
            averageWaterIntake: averageWaterIntake,
            averageSleepHours: averageSleep,
            planAdherence: calculateAdherence(plans: plansInRange)
        )
    }
    
    // MARK: - Generate Recommendations
    private func generateRecommendations(healthData: HealthData, longTermPlan: LongTermPlan?) -> [String] {
        var recommendations: [String] = []
        
        // BMI recommendations
        let bmi = calculateBMI(weight: healthData.weight, height: healthData.height)
        if bmi > 25 {
            recommendations.append("Consider gradual weight loss through balanced diet and regular exercise")
        } else if bmi < 18.5 {
            recommendations.append("Consider consulting with a healthcare provider about healthy weight gain strategies")
        }
        
        // Exercise recommendations
        if let exerciseGoals = healthData.exerciseGoals {
            if exerciseGoals.weeklyCardioMinutes < 150 {
                recommendations.append("Aim for at least 150 minutes of moderate-intensity cardio per week")
            }
        }
        
        // Water intake recommendations
        recommendations.append("Maintain adequate hydration - aim for 2-3 liters of water daily")
        
        // Sleep recommendations
        recommendations.append("Prioritize 7-9 hours of quality sleep per night for optimal health")
        
        return recommendations
    }
    
    // MARK: - Generate Trends Section
    private func generateTrendsSection(healthData: HealthData, startDate: Date, endDate: Date) -> [Trend] {
        var trends: [Trend] = []
        
        // In production, this would analyze actual historical data
        // For now, provide placeholder trends
        
        trends.append(Trend(
            metric: "Weight",
            direction: .stable,
            change: 0.0,
            description: "Weight has remained stable"
        ))
        
        return trends
    }
    
    // MARK: - Helper Methods
    private func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    private func calculateHealthScore(healthData: HealthData) -> Double {
        // Simplified health score calculation
        var score = 50.0
        
        // BMI contribution
        let bmi = calculateBMI(weight: healthData.weight, height: healthData.height)
        if bmi >= 18.5 && bmi <= 25 {
            score += 20.0
        } else if bmi > 25 && bmi <= 30 {
            score += 10.0
        }
        
        // Exercise contribution
        if healthData.exerciseGoals != nil {
            score += 15.0
        }
        
        // Medical tests contribution
        if !healthData.medicalTests.bloodTests.isEmpty {
            score += 15.0
        }
        
        return min(score, 100.0)
    }
    
    private func calculateGoalProgress(goal: TransformationGoal) -> Double {
        guard let current = goal.currentValue, let target = goal.targetValue else { return 0.0 }
        return min(1.0, max(0.0, current / target))
    }
    
    private func calculateAdherence(plans: [DailyPlanEntry]) -> Double {
        // Calculate how well user followed the plan
        // Simplified - in production would be more sophisticated
        return plans.isEmpty ? 0.0 : 75.0 // Placeholder
    }
    
    // MARK: - Export to PDF
    #if canImport(UIKit)
    func exportToPDF(_ report: HealthReport) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Diet Solver",
            kCGPDFContextAuthor: "Health Report",
            kCGPDFContextTitle: "Health Report - \(formatDate(report.generatedDate))"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            let margin: CGFloat = 50
            let contentWidth = pageWidth - (margin * 2)
            
            // Title
            let title = "Health Report"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Date
            let dateText = "Generated: \(formatDate(report.generatedDate))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            dateText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Summary
            let summaryText = "Summary:\nWeight: \(String(format: "%.1f", report.summary.currentWeight)) kg\nBMI: \(String(format: "%.1f", report.summary.currentBMI))\nHealth Score: \(String(format: "%.0f", report.summary.healthScore))"
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let summarySize = summaryText.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: summaryAttributes, context: nil)
            summaryText.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: summarySize.height), withAttributes: summaryAttributes)
            yPosition += summarySize.height + 20
            
            // Add more sections as needed...
        }
        
        return data
    }
    #else
    func exportToPDF(_ report: HealthReport) -> Data? {
        // macOS/other platforms - use PDFKit or alternative
        // For now, return nil - can be implemented with PDFKit on macOS
        return nil
    }
    #endif
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Health Report
struct HealthReport: Codable, Identifiable {
    let id: UUID
    var generatedDate: Date
    var timeframe: ReportTimeframe
    var startDate: Date
    var endDate: Date
    var summary: ReportSummary
    var goals: [GoalProgress]
    var progress: ProgressMetrics
    var recommendations: [String]
    var trends: [Trend]
}

// MARK: - Report Summary
struct ReportSummary: Codable {
    var currentWeight: Double
    var currentBMI: Double
    var healthScore: Double
    var planDuration: String
    var goalsCount: Int
    var milestonesAchieved: Int
    var totalMilestones: Int
}

// MARK: - Goal Progress
struct GoalProgress: Codable, Identifiable {
    let id: UUID
    var goalName: String
    var category: String
    var currentValue: Double?
    var targetValue: Double?
    var progress: Double
    var priority: Int
    
    init(id: UUID = UUID(), goalName: String, category: String, currentValue: Double?, targetValue: Double?, progress: Double, priority: Int) {
        self.id = id
        self.goalName = goalName
        self.category = category
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.progress = progress
        self.priority = priority
    }
}

// MARK: - Progress Metrics
struct ProgressMetrics: Codable {
    var daysTracked: Int
    var totalMeals: Int
    var totalExerciseMinutes: Double
    var averageWaterIntake: Double
    var averageSleepHours: Double
    var planAdherence: Double
}

// MARK: - Trend
struct Trend: Codable, Identifiable {
    let id: UUID
    var metric: String
    var direction: TrendDirection
    var change: Double
    var description: String
    
    enum TrendDirection: String, Codable {
        case improving = "Improving"
        case declining = "Declining"
        case stable = "Stable"
    }
    
    init(id: UUID = UUID(), metric: String, direction: TrendDirection, change: Double, description: String) {
        self.id = id
        self.metric = metric
        self.direction = direction
        self.change = change
        self.description = description
    }
}
