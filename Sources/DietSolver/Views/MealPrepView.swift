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
                    Text("Meal Prep Planner")
                        .font(AppDesign.Typography.title)
                        .fontWeight(.bold)
                    
                    Text("Plan your meal prep schedule for efficient cooking")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Generation Controls
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        HStack {
                            Text("Days to plan:")
                                .font(AppDesign.Typography.body)
                            Spacer()
                            Picker("", selection: $daysToPlan) {
                                Text("3 days").tag(3)
                                Text("7 days").tag(7)
                                Text("14 days").tag(14)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Button(action: generateMealPrepSchedule) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "calendar.badge.clock")
                                    Text("Generate Meal Prep Schedule")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppDesign.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating || viewModel.dailyPlans.isEmpty)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Schedule Display
                if let schedule = mealPrepSchedule {
                    mealPrepScheduleContent(schedule: schedule)
                } else if !isGenerating {
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 50))
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            Text("No meal prep schedule generated yet")
                                .font(AppDesign.Typography.headline)
                            Text("Generate a schedule from your meal plans")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        .padding()
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.bottom, AppDesign.Spacing.xl)
        }
        .navigationTitle("Meal Prep")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    // MARK: - Generate Schedule
    private func generateMealPrepSchedule() {
        guard !viewModel.dailyPlans.isEmpty else { return }
        
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let schedule = MealPrepPlanner.shared.generateMealPrepSchedule(
                from: viewModel.dailyPlans,
                days: daysToPlan
            )
            
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
            ModernCard {
                VStack(spacing: AppDesign.Spacing.sm) {
                    HStack {
                        Text("Schedule Summary")
                            .font(AppDesign.Typography.headline)
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(schedule.tasks.count)")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                            Text("Tasks")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(schedule.totalEstimatedTime) min")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                            Text("Total Time")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(AppDesign.Spacing.md)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            
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
            Text("Batch Cooking Recommendations")
                .font(AppDesign.Typography.headline)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(recommendations) { recommendation in
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        HStack {
                            Text(recommendation.food)
                                .font(AppDesign.Typography.headline)
                            Spacer()
                            Text("Used \(recommendation.frequency)x this week")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                            HStack {
                                Text("Batch Size:")
                                    .font(AppDesign.Typography.subheadline)
                                    .fontWeight(.semibold)
                                Text(recommendation.recommendedBatchSize)
                            }
                            
                            HStack {
                                Text("Storage:")
                                    .font(AppDesign.Typography.subheadline)
                                    .fontWeight(.semibold)
                                Text(recommendation.storageMethod)
                                    .font(AppDesign.Typography.caption)
                            }
                            
                            HStack {
                                Text("Instructions:")
                                    .font(AppDesign.Typography.subheadline)
                                    .fontWeight(.semibold)
                                Text(recommendation.prepInstructions)
                                    .font(AppDesign.Typography.caption)
                            }
                        }
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Task Section
    private func taskSection(title: String, tasks: [MealPrepTask], schedule: MealPrepSchedule) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            Text(title)
                .font(AppDesign.Typography.headline)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(tasks) { task in
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                                Text(task.title)
                                    .font(AppDesign.Typography.headline)
                                
                                Text(task.description)
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(task.estimatedTime) min")
                                    .font(AppDesign.Typography.subheadline)
                                    .fontWeight(.semibold)
                                
                                // Priority badge
                                Text(task.priority.rawValue)
                                    .font(AppDesign.Typography.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(priorityColor(task.priority).opacity(0.2))
                                    .foregroundColor(priorityColor(task.priority))
                                    .cornerRadius(4)
                            }
                        }
                        
                        // Date
                        Text(formatDate(task.scheduledDate))
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        
                        // Items
                        if !task.items.isEmpty {
                            Text("Items: \(task.items.joined(separator: ", "))")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        // Completion Toggle
                        Toggle("Completed", isOn: Binding(
                            get: { task.isCompleted },
                            set: { _ in toggleTask(task, in: schedule) }
                        ))
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
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
