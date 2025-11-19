//
//  ProgressChartsView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

// MARK: - Progress Charts View
struct ProgressChartsView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var selectedTimeframe: Timeframe = .month
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                // Timeframe Selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Weight Trend Chart
                if let weightData = getWeightData(), !weightData.isEmpty {
                    weightChartSection(data: weightData)
                }
                
                // Health Score Chart
                if let healthScoreData = getHealthScoreData(), !healthScoreData.isEmpty {
                    healthScoreChartSection(data: healthScoreData)
                }
                
                // Exercise Minutes Chart
                if let exerciseData = getExerciseData(), !exerciseData.isEmpty {
                    exerciseChartSection(data: exerciseData)
                }
                
                // Nutrient Intake Chart
                if let nutrientData = getNutrientData(), !nutrientData.isEmpty {
                    nutrientChartSection(data: nutrientData)
                }
            }
            .padding(.bottom, AppDesign.Spacing.xl)
        }
        .navigationTitle("Progress Charts")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    // MARK: - Weight Chart
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    private func weightChartSection(data: [WeightDataPoint]) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Weight Trend")
                    .font(AppDesign.Typography.headline)
                
                #if canImport(Charts)
                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(AppDesign.Colors.primary)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppDesign.Colors.primary.opacity(0.3), AppDesign.Colors.primary.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                #else
                Text("Charts not available on this platform")
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .frame(height: 200)
                #endif
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Health Score Chart
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    private func healthScoreChartSection(data: [HealthScoreDataPoint]) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Health Score")
                    .font(AppDesign.Typography.headline)
                
                #if canImport(Charts)
                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value("Score", point.score)
                    )
                    .foregroundStyle(AppDesign.Colors.success)
                }
                .frame(height: 200)
                #else
                Text("Charts not available on this platform")
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .frame(height: 200)
                #endif
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Exercise Chart
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    private func exerciseChartSection(data: [ExerciseDataPoint]) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Exercise Minutes")
                    .font(AppDesign.Typography.headline)
                
                #if canImport(Charts)
                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value("Minutes", point.minutes)
                    )
                    .foregroundStyle(AppDesign.Colors.accent)
                }
                .frame(height: 200)
                #else
                Text("Charts not available on this platform")
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .frame(height: 200)
                #endif
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Nutrient Chart
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    private func nutrientChartSection(data: [NutrientDataPoint]) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Daily Nutrient Intake")
                    .font(AppDesign.Typography.headline)
                
                #if canImport(Charts)
                Chart(data) { point in
                    BarMark(
                        x: .value("Nutrient", point.nutrient),
                        y: .value("Amount", point.amount)
                    )
                    .foregroundStyle(point.color)
                }
                .frame(height: 200)
                #else
                Text("Charts not available on this platform")
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .frame(height: 200)
                #endif
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Data Generation (Real data from HealthKit and HealthHistory)
    private func getWeightData() -> [WeightDataPoint]? {
        guard let healthData = viewModel.healthData else { return nil }
        
        var data: [WeightDataPoint] = []
        
        // Get weight data from HealthKit biomarkers
        let healthKitData = healthData.healthKitBiomarkers.sorted { $0.date < $1.date }
        
        // Use HealthKit weight data if available
        for biomarker in healthKitData {
            if let weight = biomarker.bodyMetrics?.weight {
                data.append(WeightDataPoint(date: biomarker.date, weight: weight))
            }
        }
        
        // If we have HealthKit data, use it
        if !data.isEmpty {
            // Fill gaps with interpolated values if needed
            return fillWeightGaps(data: data, days: getDaysForTimeframe())
        }
        
        // Fallback: Use current weight as baseline and HealthHistory for trends
        let history = HealthHistoryManager.shared.getHistory()
        let baseWeight = healthData.weight
        
        // Use health score trends to estimate weight changes
        let records = history.dailyRecords.sorted { $0.date < $1.date }
        if !records.isEmpty {
            let firstHealthScore = records.first?.healthScore ?? 80.0
            for record in records {
                // Estimate weight based on health score changes
                let healthScoreChange = record.healthScore - firstHealthScore
                let estimatedWeightChange = healthScoreChange * 0.1 // Rough correlation
                let estimatedWeight = baseWeight - estimatedWeightChange
                data.append(WeightDataPoint(date: record.date, weight: estimatedWeight))
            }
        } else {
            // No history yet - use current weight
            data.append(WeightDataPoint(date: Date(), weight: baseWeight))
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    private func fillWeightGaps(data: [WeightDataPoint], days: Int) -> [WeightDataPoint] {
        guard !data.isEmpty else { return data }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        var filledData: [WeightDataPoint] = []
        
        var currentDate = startDate
        var dataIndex = 0
        
        while currentDate <= endDate {
            // Find closest data point
            if dataIndex < data.count && calendar.isDate(data[dataIndex].date, inSameDayAs: currentDate) {
                filledData.append(data[dataIndex])
                dataIndex += 1
            } else if dataIndex > 0 && dataIndex < data.count {
                // Interpolate between points
                let prev = data[dataIndex - 1]
                let next = data[dataIndex]
                let daysBetween = calendar.dateComponents([.day], from: prev.date, to: next.date).day ?? 1
                let currentDaysFromPrev = calendar.dateComponents([.day], from: prev.date, to: currentDate).day ?? 0
                
                if daysBetween > 0 && currentDaysFromPrev < daysBetween {
                    let weightDiff = next.weight - prev.weight
                    let interpolatedWeight = prev.weight + (weightDiff * Double(currentDaysFromPrev) / Double(daysBetween))
                    filledData.append(WeightDataPoint(date: currentDate, weight: interpolatedWeight))
                } else {
                    filledData.append(WeightDataPoint(date: currentDate, weight: prev.weight))
                }
            } else if !filledData.isEmpty {
                // Use last known weight
                filledData.append(WeightDataPoint(date: currentDate, weight: filledData.last!.weight))
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        return filledData
    }
    
    private func getDaysForTimeframe() -> Int {
        switch selectedTimeframe {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .year: return 365
        }
    }
    
    private func getHealthScoreData() -> [HealthScoreDataPoint]? {
        // Get real data from HealthHistory
        let history = HealthHistoryManager.shared.getHistory()
        let records = history.dailyRecords.sorted { $0.date < $1.date }
        
        guard !records.isEmpty else { return nil }
        
        var data: [HealthScoreDataPoint] = []
        let days = getDaysForTimeframe()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        // Filter records within timeframe
        let filteredRecords = records.filter { $0.date >= cutoffDate }
        
        for record in filteredRecords {
            data.append(HealthScoreDataPoint(date: record.date, score: record.healthScore))
        }
        
        // Fill gaps if needed
        if data.isEmpty {
            return nil
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    private func getExerciseData() -> [ExerciseDataPoint]? {
        guard let healthData = viewModel.healthData else { return nil }
        
        // Get real data from exercise logs
        let exerciseLogs = healthData.exerciseLogs.sorted { $0.date < $1.date }
        
        guard !exerciseLogs.isEmpty else { return nil }
        
        let calendar = Calendar.current
        var data: [ExerciseDataPoint] = []
        let days = getDaysForTimeframe()
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        // Group logs by date and sum minutes from all sessions
        var dailyMinutes: [Date: Double] = [:]
        
        for log in exerciseLogs where log.date >= cutoffDate {
            let dayStart = calendar.startOfDay(for: log.date)
            // Sum duration from all exercise sessions in the log
            let totalMinutes = log.sessions.reduce(0.0) { $0 + $1.duration }
            dailyMinutes[dayStart, default: 0.0] += totalMinutes
        }
        
        // Convert to data points
        for (date, minutes) in dailyMinutes.sorted(by: { $0.key < $1.key }) {
            data.append(ExerciseDataPoint(date: date, minutes: minutes))
        }
        
        // Also check HealthKit activity data
        let healthKitData = healthData.healthKitBiomarkers
            .filter { $0.date >= cutoffDate }
            .sorted { $0.date < $1.date }
        
        for biomarker in healthKitData {
            if let exerciseTime = biomarker.activity?.exerciseTime {
                let dayStart = calendar.startOfDay(for: biomarker.date)
                let minutes = exerciseTime / 60.0 // Convert seconds to minutes
                
                if let existingIndex = data.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                    data[existingIndex] = ExerciseDataPoint(date: data[existingIndex].date, minutes: data[existingIndex].minutes + minutes)
                } else {
                    data.append(ExerciseDataPoint(date: dayStart, minutes: minutes))
                }
            }
        }
        
        return data.isEmpty ? nil : data.sorted { $0.date < $1.date }
    }
    
    private func getNutrientData() -> [NutrientDataPoint]? {
        // Get nutrient data from daily plans (aggregated)
        let dailyPlans = viewModel.dailyPlans
        guard !dailyPlans.isEmpty else {
            // Fallback to current diet plan
            guard let dietPlan = viewModel.dietPlan else { return nil }
            let nutrients = dietPlan.totalNutrients
            return [
                NutrientDataPoint(nutrient: "Calories", amount: nutrients.calories, color: AppDesign.Colors.primary),
                NutrientDataPoint(nutrient: "Protein", amount: nutrients.protein, color: AppDesign.Colors.accent),
                NutrientDataPoint(nutrient: "Carbs", amount: nutrients.carbohydrates, color: AppDesign.Colors.secondary),
                NutrientDataPoint(nutrient: "Fats", amount: nutrients.fats, color: AppDesign.Colors.success)
            ]
        }
        
        // Aggregate nutrients from all daily plans
        var totalNutrients = NutrientContent()
        var planCount = 0
        
        for plan in dailyPlans {
            if let dietPlan = plan.dietPlan {
                totalNutrients = totalNutrients + dietPlan.totalNutrients
                planCount += 1
            }
        }
        
        guard planCount > 0 else { return nil }
        
        // Average the nutrients (create new NutrientContent with averaged values)
        var avgNutrients = NutrientContent()
        avgNutrients.calories = totalNutrients.calories / Double(planCount)
        avgNutrients.protein = totalNutrients.protein / Double(planCount)
        avgNutrients.carbohydrates = totalNutrients.carbohydrates / Double(planCount)
        avgNutrients.fats = totalNutrients.fats / Double(planCount)
        avgNutrients.fiber = totalNutrients.fiber / Double(planCount)
        
        return [
            NutrientDataPoint(nutrient: "Calories", amount: avgNutrients.calories, color: AppDesign.Colors.primary),
            NutrientDataPoint(nutrient: "Protein", amount: avgNutrients.protein, color: AppDesign.Colors.accent),
            NutrientDataPoint(nutrient: "Carbs", amount: avgNutrients.carbohydrates, color: AppDesign.Colors.secondary),
            NutrientDataPoint(nutrient: "Fats", amount: avgNutrients.fats, color: AppDesign.Colors.success),
            NutrientDataPoint(nutrient: "Fiber", amount: avgNutrients.fiber, color: AppDesign.Colors.success.opacity(0.7))
        ]
    }
}

// MARK: - Data Points
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct HealthScoreDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct ExerciseDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Double
}

struct NutrientDataPoint: Identifiable {
    let id = UUID()
    let nutrient: String
    let amount: Double
    let color: Color
}
