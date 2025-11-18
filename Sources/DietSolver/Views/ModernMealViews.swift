//
//  ModernMealViews.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Modern Meals View
struct ModernMealsView: View {
    let plan: DailyDietPlan
    @State private var expandedMeal: UUID? = nil
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.md) {
                    // Summary Card
                    summaryCard
                    
                    // Meals
                    ForEach(plan.meals) { meal in
                        ModernMealCard(
                            meal: meal,
                            isExpanded: expandedMeal == meal.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                expandedMeal = expandedMeal == meal.id ? nil : meal.id
                            }
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
    }
    
    private var summaryCard: some View {
        ModernCard(shadow: AppDesign.Shadow.medium) {
            VStack(spacing: AppDesign.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Total")
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        Text("\(Int(plan.totalNutrients.calories))")
                            .font(AppDesign.Typography.largeTitle)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        Text("kcal")
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        NutrientPill(label: "Protein", value: "\(Int(plan.totalNutrients.protein))g", color: .blue)
                        NutrientPill(label: "Carbs", value: "\(Int(plan.totalNutrients.carbohydrates))g", color: .orange)
                        NutrientPill(label: "Fats", value: "\(Int(plan.totalNutrients.fats))g", color: .purple)
                    }
                }
            }
        }
    }
}

struct ModernMealCard: View {
    let meal: Meal
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        ModernCard {
            VStack(spacing: 0) {
                // Header
                Button(action: onTap) {
                    HStack {
                        HStack(spacing: AppDesign.Spacing.md) {
                            IconBadge(
                                icon: mealIcon(for: meal.mealType),
                                color: AppDesign.Colors.primary,
                                size: 40
                            )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.name)
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                                Text("\(meal.items.count) items")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(Int(meal.totalNutrients.calories))")
                                .font(AppDesign.Typography.title2)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            Text("kcal")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Expanded Content
                if isExpanded {
                    VStack(spacing: AppDesign.Spacing.sm) {
                        Divider()
                            .padding(.vertical, AppDesign.Spacing.sm)
                        
                        ForEach(meal.items) { item in
                            MealItemRow(item: item)
                        }
                        
                        // Scores
                        HStack(spacing: AppDesign.Spacing.lg) {
                            ScoreBadge(
                                icon: "star.fill",
                                label: "Taste",
                                value: String(format: "%.1f", meal.tasteScore),
                                color: AppDesign.Colors.accent
                            )
                            ScoreBadge(
                                icon: "heart.fill",
                                label: "Digestion",
                                value: String(format: "%.1f", meal.digestionScore),
                                color: AppDesign.Colors.success
                            )
                        }
                        .padding(.top, AppDesign.Spacing.sm)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    private func mealIcon(for type: Meal.MealType) -> String {
        switch type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

struct MealItemRow: View {
    let item: MealItem
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.md) {
            Circle()
                .fill(AppDesign.Colors.primary.opacity(0.2))
                .frame(width: 8, height: 8)
            Text(item.food.name)
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textPrimary)
            Spacer()
            Text("\(Int(item.amount))g")
                .font(AppDesign.Typography.subheadline)
                .foregroundColor(AppDesign.Colors.textSecondary)
        }
    }
}

struct NutrientPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(AppDesign.Typography.caption)
            Text(value)
                .font(AppDesign.Typography.caption)
                .bold()
        }
        .padding(.horizontal, AppDesign.Spacing.sm)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(AppDesign.Radius.large)
    }
}

struct ScoreBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(label)
                .font(AppDesign.Typography.caption)
            Text(value)
                .font(AppDesign.Typography.subheadline)
                .bold()
        }
        .padding(.horizontal, AppDesign.Spacing.sm)
        .padding(.vertical, AppDesign.Spacing.xs)
        .background(color.opacity(0.1))
        .cornerRadius(AppDesign.Radius.medium)
    }
}

// MARK: - Modern Health Check Views
struct ModernHearingCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    @State private var testType: DailyAudioHearingTest.TestType = .quick
    @State private var rightThreshold: Double = 20.0
    @State private var leftThreshold: Double = 20.0
    @State private var tinnitus: Bool = false
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Quick Test Card
                    ModernCard(shadow: AppDesign.Shadow.medium) {
                        VStack(spacing: AppDesign.Spacing.md) {
                            IconBadge(icon: "ear.fill", color: AppDesign.Colors.secondary, size: 60)
                            Text("Hearing Test")
                                .font(AppDesign.Typography.title2)
                            
                            VStack(spacing: AppDesign.Spacing.md) {
                                ThresholdSlider(
                                    title: "Right Ear",
                                    value: $rightThreshold,
                                    color: AppDesign.Colors.primary
                                )
                                ThresholdSlider(
                                    title: "Left Ear",
                                    value: $leftThreshold,
                                    color: AppDesign.Colors.secondary
                                )
                            }
                            
                            Toggle(isOn: $tinnitus) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Tinnitus Present")
                                }
                                .font(AppDesign.Typography.body)
                            }
                            .tint(AppDesign.Colors.warning)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.top, AppDesign.Spacing.lg)
                    
                    GradientButton(
                        title: "Save Test",
                        icon: "checkmark.circle.fill",
                        action: saveTest
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        .navigationTitle("Hearing Test")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func saveTest() {
        var test = DailyAudioHearingTest(date: Date(), testType: .quick)
        test.rightEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 1000,
                threshold: rightThreshold,
                ear: .right
            )
        ]
        test.leftEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 1000,
                threshold: leftThreshold,
                ear: .left
            )
        ]
        test.rightEar.tinnitusPresence = tinnitus
        test.leftEar.tinnitusPresence = tinnitus
        
        if var healthData = viewModel.healthData {
            healthData.dailyAudioHearingTests.append(test)
            viewModel.healthData = healthData
        }
        dismiss()
    }
}

struct ThresholdSlider: View {
    let title: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
            HStack {
                Text(title)
                    .font(AppDesign.Typography.subheadline)
                Spacer()
                Text("\(Int(value)) dB HL")
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(color)
            }
            Slider(value: $value, in: 0...100, step: 5)
                .tint(color)
        }
    }
}

// Similar modern views for Tactile and Tongue
struct ModernTactileCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    @State private var pressureSensitivity: Double = 0.8
    @State private var vibrationSensitivity: Double = 0.8
    @State private var numbness: DailyTactileTest.TestResults.NumbnessLevel? = nil
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    ModernCard(shadow: AppDesign.Shadow.medium) {
                        VStack(spacing: AppDesign.Spacing.lg) {
                            IconBadge(icon: "hand.tap.fill", color: AppDesign.Colors.accent, size: 60)
                            Text("Tactile Test")
                                .font(AppDesign.Typography.title2)
                            
                            SensitivitySlider(
                                title: "Pressure Sensitivity",
                                value: $pressureSensitivity,
                                color: AppDesign.Colors.primary
                            )
                            SensitivitySlider(
                                title: "Vibration Sensitivity",
                                value: $vibrationSensitivity,
                                color: AppDesign.Colors.secondary
                            )
                            
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Numbness")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: Binding(
                                    get: { numbness ?? DailyTactileTest.TestResults.NumbnessLevel.none },
                                    set: { numbness = $0 == DailyTactileTest.TestResults.NumbnessLevel.none ? nil : $0 }
                                )) {
                                    Text("None").tag(DailyTactileTest.TestResults.NumbnessLevel.none)
                                    ForEach([DailyTactileTest.TestResults.NumbnessLevel.mild, .moderate, .severe, .complete], id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.top, AppDesign.Spacing.lg)
                    
                    GradientButton(
                        title: "Save Test",
                        icon: "checkmark.circle.fill",
                        action: saveTest
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        .navigationTitle("Tactile Test")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func saveTest() {
        var test = DailyTactileTest(date: Date(), testType: .quick, bodyRegion: .fingertips)
        test.results.pressureSensitivity = pressureSensitivity
        test.results.vibrationSensitivity = vibrationSensitivity
        test.results.numbness = numbness
        
        if var healthData = viewModel.healthData {
            healthData.dailyTactileTests.append(test)
            viewModel.healthData = healthData
        }
        dismiss()
    }
}

struct SensitivitySlider: View {
    let title: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
            HStack {
                Text(title)
                    .font(AppDesign.Typography.subheadline)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(color)
            }
            Slider(value: $value, in: 0...1, step: 0.1)
                .tint(color)
        }
    }
}

struct ModernTongueCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    @State private var tasteScore: Double = 0.8
    @State private var mobilityScore: Double = 0.8
    @State private var tongueColor: TonguePrescription.TongueAppearance.TongueColor = .pink
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    ModernCard(shadow: AppDesign.Shadow.medium) {
                        VStack(spacing: AppDesign.Spacing.lg) {
                            IconBadge(icon: "mouth.fill", color: Color.purple, size: 60)
                            Text("Tongue Test")
                                .font(AppDesign.Typography.title2)
                            
                            SensitivitySlider(
                                title: "Taste Sensitivity",
                                value: $tasteScore,
                                color: AppDesign.Colors.primary
                            )
                            SensitivitySlider(
                                title: "Mobility",
                                value: $mobilityScore,
                                color: AppDesign.Colors.secondary
                            )
                            
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Tongue Color")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: $tongueColor) {
                                    ForEach(TonguePrescription.TongueAppearance.TongueColor.allCases, id: \.self) { color in
                                        Text(color.rawValue).tag(color)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.top, AppDesign.Spacing.lg)
                    
                    GradientButton(
                        title: "Save Test",
                        icon: "checkmark.circle.fill",
                        action: saveTest
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        .navigationTitle("Tongue Test")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func saveTest() {
        var test = DailyTongueTest(date: Date(), testType: .quick)
        test.appearance.color = tongueColor
        test.tasteTest = DailyTongueTest.TasteTest(
            sweet: tasteScore,
            sour: tasteScore,
            salty: tasteScore,
            bitter: tasteScore,
            umami: tasteScore,
            overallScore: tasteScore
        )
        test.mobilityTest = DailyTongueTest.MobilityTest(
            rangeOfMotion: mobilityScore,
            strength: mobilityScore,
            coordination: mobilityScore,
            flexibility: mobilityScore,
            overallScore: mobilityScore
        )
        
        if var healthData = viewModel.healthData {
            healthData.dailyTongueTests.append(test)
            viewModel.healthData = healthData
        }
        dismiss()
    }
}
