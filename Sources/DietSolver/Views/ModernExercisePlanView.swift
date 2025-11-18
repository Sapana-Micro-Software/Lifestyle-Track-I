//
//  ModernExercisePlanView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Modern Exercise Plan View
struct ModernExercisePlanView: View {
    let plan: ExercisePlan
    let healthData: HealthData
    @State private var selectedDay: Int? = nil
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Header Stats
                    headerStatsSection
                    
                    // Focus Areas
                    if !plan.focusAreas.isEmpty {
                        focusAreasSection
                    }
                    
                    // Weekly Plan
                    weeklyPlanSection
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
    }
    
    private var headerStatsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppDesign.Spacing.md) {
                StatCard(
                    title: "Activities",
                    value: "\(plan.weeklyPlan.reduce(0) { $0 + $1.activities.count })",
                    icon: "figure.run",
                    color: AppDesign.Colors.primary
                )
                StatCard(
                    title: "Focus Areas",
                    value: "\(plan.focusAreas.count)",
                    icon: "target",
                    color: AppDesign.Colors.secondary
                )
                StatCard(
                    title: "Cardio Goal",
                    value: "\(Int(plan.goals.weeklyCardioMinutes)) min",
                    icon: "heart.fill",
                    color: AppDesign.Colors.accent
                )
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private var focusAreasSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Focus Areas")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppDesign.Spacing.sm) {
                    ForEach(plan.focusAreas, id: \.self) { area in
                        FocusChip(title: area)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    private var weeklyPlanSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("This Week")
            
            ForEach(plan.weeklyPlan) { dayPlan in
                ModernDayPlanCard(dayPlan: dayPlan, healthData: healthData)
                    .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
}
