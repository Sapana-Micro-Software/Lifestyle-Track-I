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
                if let weightData = getWeightData() {
                    weightChartSection(data: weightData)
                }
                
                // Health Score Chart
                if let healthScoreData = getHealthScoreData() {
                    healthScoreChartSection(data: healthScoreData)
                }
                
                // Exercise Minutes Chart
                if let exerciseData = getExerciseData() {
                    exerciseChartSection(data: exerciseData)
                }
                
                // Nutrient Intake Chart
                if let nutrientData = getNutrientData() {
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
    
    // MARK: - Data Generation (Mock for now - would use HealthHistory in production)
    private func getWeightData() -> [WeightDataPoint]? {
        guard let healthData = viewModel.healthData else { return nil }
        
        // In production, this would come from HealthHistory
        let calendar = Calendar.current
        var data: [WeightDataPoint] = []
        
        for dayOffset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                // Simulate weight trend (in production, use actual historical data)
                let baseWeight = healthData.weight
                let variation = Double.random(in: -2...2)
                data.append(WeightDataPoint(date: date, weight: baseWeight + variation))
            }
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    private func getHealthScoreData() -> [HealthScoreDataPoint]? {
        // In production, calculate from HealthHistory
        let calendar = Calendar.current
        var data: [HealthScoreDataPoint] = []
        
        for dayOffset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let score = Double.random(in: 70...95)
                data.append(HealthScoreDataPoint(date: date, score: score))
            }
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    private func getExerciseData() -> [ExerciseDataPoint]? {
        // In production, use actual exercise logs
        let calendar = Calendar.current
        var data: [ExerciseDataPoint] = []
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let minutes = Double.random(in: 20...90)
                data.append(ExerciseDataPoint(date: date, minutes: minutes))
            }
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    private func getNutrientData() -> [NutrientDataPoint]? {
        guard let dietPlan = viewModel.dietPlan else { return nil }
        
        let nutrients = dietPlan.totalNutrients
        return [
            NutrientDataPoint(nutrient: "Calories", amount: nutrients.calories, color: AppDesign.Colors.primary),
            NutrientDataPoint(nutrient: "Protein", amount: nutrients.protein, color: AppDesign.Colors.accent),
            NutrientDataPoint(nutrient: "Carbs", amount: nutrients.carbohydrates, color: AppDesign.Colors.secondary),
            NutrientDataPoint(nutrient: "Fats", amount: nutrients.fats, color: AppDesign.Colors.success)
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
