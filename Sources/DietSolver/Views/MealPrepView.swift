//
//  MealPrepView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Meal Prep View
struct MealPrepView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var mealPrepSchedule: MealPrepSchedule?
    @State private var daysToPlan: Int = 7
    @State private var isGenerating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                    HStack(spacing: AppDesign.Spacing.sm) {
                        IconBadge(icon: "calendar.badge.clock", color: AppDesign.Colors.primary, size: 40, gradient: true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Meal Prep Planner")
                                .font(AppDesign.Typography.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            
                            Text("Plan your meal prep schedule for efficient cooking")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Generation Controls
                ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
                    VStack(spacing: AppDesign.Spacing.md) {
                        HStack {
                            IconBadge(icon: "calendar", color: AppDesign.Colors.primary, size: 24)
                            Text("Days to plan:")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            Spacer()
                            Picker("", selection: $daysToPlan) {
                                Text("3 days").tag(3)
                                Text("7 days").tag(7)
                                Text("14 days").tag(14)
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        
                        GradientButton(
                            title: isGenerating ? "Generating..." : "Generate Meal Prep Schedule",
                            icon: isGenerating ? nil : "calendar.badge.clock",
                            action: generateMealPrepSchedule,
                            style: .primary
                        )
                        .disabled(isGenerating || (viewModel.dailyPlans.isEmpty && viewModel.dietPlan == nil))
                        .opacity(isGenerating ? 0.7 : 1.0)
                        .overlay(
                            Group {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        )
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Schedule Display
                if let schedule = mealPrepSchedule {
                    mealPrepScheduleContent(schedule: schedule)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !isGenerating {
                    EmptyStateView(
                        icon: "calendar.badge.clock",
                        title: "No meal prep schedule generated yet",
                        message: "Generate a schedule from your meal plans"
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.bottom, AppDesign.Spacing.xl)
        }
        .navigationTitle("Meal Prep")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .background(AppDesign.Colors.background.ignoresSafeArea())
    }
    
    // MARK: - Generate Schedule
    private func generateMealPrepSchedule() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let schedule: MealPrepSchedule
            
            // Use daily plans if available, otherwise create from current diet plan
            if !viewModel.dailyPlans.isEmpty {
                schedule = MealPrepPlanner.shared.generateMealPrepSchedule(
                    from: viewModel.dailyPlans,
                    days: daysToPlan
                )
            } else if let dietPlan = viewModel.dietPlan {
                // Create a single-day plan entry from current diet plan
                let planEntry = DailyPlanEntry(
                    date: Date(),
                    dayNumber: 1,
                    dietPlan: dietPlan,
                    exercisePlan: nil,
                    supplements: [],
                    meditationMinutes: 0,
                    breathingPracticeMinutes: 0,
                    sleepTarget: 8,
                    waterIntake: 2,
                    notes: nil
                )
                schedule = MealPrepPlanner.shared.generateMealPrepSchedule(
                    from: [planEntry],
                    days: 1
                )
            } else {
                // No data available
                DispatchQueue.main.async {
                    self.isGenerating = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.mealPrepSchedule = schedule
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Schedule Content
    private func mealPrepScheduleContent(schedule: MealPrepSchedule) -> some View {
        VStack(spacing: AppDesign.Spacing.md) {
            // Summary
            ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
                VStack(spacing: AppDesign.Spacing.sm) {
                    HStack {
                        HStack(spacing: AppDesign.Spacing.xs) {
                            IconBadge(icon: "calendar.badge.clock", color: AppDesign.Colors.primary, size: 32)
                            Text("Schedule Summary")
                                .font(AppDesign.Typography.headline)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        Spacer()
                    }
                    
                    HStack(spacing: AppDesign.Spacing.lg) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                            Text("\(schedule.tasks.count)")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.primary)
                            Text("Tasks")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: AppDesign.Spacing.xs) {
                            Text("\(schedule.totalEstimatedTime) min")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.accent)
                            Text("Total Time")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(AppDesign.Spacing.md)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            .transition(.move(edge: .top).combined(with: .opacity))
            
            // Batch Cooking Recommendations
            let recommendations = MealPrepPlanner.shared.getBatchCookingRecommendations(from: viewModel.dailyPlans)
            if !recommendations.isEmpty {
                batchCookingSection(recommendations: recommendations)
            }
            
            // Tasks by Type
            let batchTasks = schedule.tasks.filter { $0.type == .batchCooking }
            let prepTasks = schedule.tasks.filter { $0.type == .prep }
            let dailyTasks = schedule.tasks.filter { $0.type == .daily }
            
            if !batchTasks.isEmpty {
                taskSection(title: "Batch Cooking", tasks: batchTasks, schedule: schedule)
            }
            
            if !prepTasks.isEmpty {
                taskSection(title: "Prep Tasks", tasks: prepTasks, schedule: schedule)
            }
            
            if !dailyTasks.isEmpty {
                taskSection(title: "Daily Tasks", tasks: dailyTasks, schedule: schedule)
            }
        }
    }
    
    // MARK: - Batch Cooking Section
    private func batchCookingSection(recommendations: [BatchCookingRecommendation]) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            HStack {
                IconBadge(icon: "flame.fill", color: AppDesign.Colors.accent, size: 28)
                Text("Batch Cooking Recommendations")
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(AppDesign.Colors.textPrimary)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(recommendations) { recommendation in
                ModernCard(shadow: AppDesign.Shadow.small, gradient: true) {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        HStack {
                            IconBadge(icon: "fork.knife", color: AppDesign.Colors.accent, size: 24)
                            Text(recommendation.food)
                                .font(AppDesign.Typography.headline)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            Spacer()
                            Text("Used \(recommendation.frequency)x")
                                .font(AppDesign.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppDesign.Colors.accent)
                                .padding(.horizontal, AppDesign.Spacing.sm)
                                .padding(.vertical, AppDesign.Spacing.xs)
                                .background(AppDesign.Colors.accent.opacity(0.1))
                                .cornerRadius(AppDesign.Radius.small)
                        }
                        
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                            HStack(spacing: 4) {
                                Image(systemName: "scalemass")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppDesign.Colors.primary)
                                Text("Batch Size: \(recommendation.recommendedBatchSize)")
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "archivebox")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppDesign.Colors.primary)
                                Text("Storage: \(recommendation.storageMethod)")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            HStack(alignment: .top, spacing: 4) {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppDesign.Colors.primary)
                                Text("Instructions: \(recommendation.prepInstructions)")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Task Section
    private func taskSection(title: String, tasks: [MealPrepTask], schedule: MealPrepSchedule) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            HStack {
                IconBadge(icon: "checklist", color: AppDesign.Colors.primary, size: 28)
                Text(title)
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(AppDesign.Colors.textPrimary)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                ModernCard(shadow: AppDesign.Shadow.small, gradient: true) {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                                Text(task.title)
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                                
                                Text(task.description)
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: AppDesign.Spacing.xs) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12))
                                    Text("\(task.estimatedTime) min")
                                        .font(AppDesign.Typography.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppDesign.Colors.textPrimary)
                                }
                                
                                // Priority badge
                                Text(task.priority.rawValue)
                                    .font(AppDesign.Typography.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(priorityColor(task.priority).opacity(0.2))
                                    .foregroundColor(priorityColor(task.priority))
                                    .cornerRadius(AppDesign.Radius.small)
                            }
                        }
                        
                        // Date
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(AppDesign.Colors.primary)
                            Text(formatDate(task.scheduledDate))
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        // Items
                        if !task.items.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppDesign.Colors.accent)
                                Text("Items: \(task.items.joined(separator: ", "))")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                        
                        // Completion Toggle
                        HStack {
                            Text("Completed")
                                .font(AppDesign.Typography.subheadline)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { task.isCompleted },
                                set: { _ in
                                    withAnimation(AppDesign.Animation.spring) {
                                        toggleTask(task, in: schedule)
                                    }
                                }
                            ))
                            .tint(AppDesign.Colors.success)
                        }
                        .padding(.top, AppDesign.Spacing.xs)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
    
    private func priorityColor(_ priority: MealPrepTask.Priority) -> Color {
        switch priority {
        case .low: return AppDesign.Colors.textSecondary
        case .medium: return AppDesign.Colors.accent
        case .high: return AppDesign.Colors.primary
        }
    }
    
    private func toggleTask(_ task: MealPrepTask, in schedule: MealPrepSchedule) {
        guard var updatedSchedule = mealPrepSchedule,
              let index = updatedSchedule.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        updatedSchedule.tasks[index].isCompleted.toggle()
        mealPrepSchedule = updatedSchedule
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
