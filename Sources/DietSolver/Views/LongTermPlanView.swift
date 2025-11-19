//
//  LongTermPlanView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

// MARK: - Long-Term Plan View
struct LongTermPlanView: View { // Define LongTermPlanView struct for displaying long-term plans
    @ObservedObject var viewModel: DietSolverViewModel // Observed view model
    @State private var selectedDay: Int? = nil // State for selected day
    @State private var selectedPhase: LongTermPlan.PlanPhase? = nil // State for selected phase
    
    var body: some View { // Define body property returning view hierarchy
        ScrollView { // Create scrollable view
            VStack(spacing: AppDesign.Spacing.lg) { // Create vertical stack
                // Header
                if let plan = viewModel.longTermPlan { // Check if plan exists
                    planHeaderSection(plan: plan) // Show plan header
                    
                    // Goals Summary
                    if !plan.goals.isEmpty { // Check if goals exist
                        goalsSection(goals: plan.goals) // Show goals section
                    }
                    
                    // Phases
                    if !plan.phases.isEmpty { // Check if phases exist
                        phasesSection(phases: plan.phases) // Show phases section
                    }
                    
                    // Milestones
                    if !plan.milestones.isEmpty { // Check if milestones exist
                        milestonesSection(milestones: plan.milestones) // Show milestones section
                    }
                    
                    // Daily Plans
                    if !viewModel.dailyPlans.isEmpty { // Check if daily plans exist
                        dailyPlansSection(plans: viewModel.dailyPlans) // Show daily plans section
                    } else { // If no daily plans
                        ModernCard {
                            VStack(spacing: AppDesign.Spacing.md) { // Create vertical stack
                                ProgressView()
                                Text("Generating daily plans...")
                                    .font(AppDesign.Typography.body)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            .padding()
                        }
                        .padding(.horizontal, AppDesign.Spacing.md)
                    }
                } else { // If no plan
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) { // Create vertical stack
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 50))
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            Text("No long-term plan generated yet")
                                .font(AppDesign.Typography.headline)
                            Text("Complete the health wizard to generate your personalized plan")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.bottom, AppDesign.Spacing.xl)
        }
        .navigationTitle("Long-Term Plan")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    // MARK: - Plan Header Section
    private func planHeaderSection(plan: LongTermPlan) -> some View { // Create plan header section
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
                HStack { // Create horizontal stack
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                        Text("Your \(plan.duration.rawValue) Plan")
                            .font(AppDesign.Typography.title)
                            .fontWeight(.bold)
                        
                        Text("\(plan.difficulty.rawValue) difficulty • \(plan.urgency.rawValue) urgency")
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    
                    Spacer() // Add spacer
                }
                
                Divider() // Add divider
                
                // Plan Stats
                HStack(spacing: AppDesign.Spacing.lg) { // Create horizontal stack
                    StatItem(label: "Duration", value: "\(plan.duration.days) days", icon: "calendar")
                    StatItem(label: "Goals", value: "\(plan.goals.count)", icon: "target")
                    StatItem(label: "Phases", value: "\(plan.phases.count)", icon: "chart.line.uptrend.xyaxis")
                }
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Goals Section
    private func goalsSection(goals: [TransformationGoal]) -> some View { // Create goals section
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            Text("Transformation Goals")
                .font(AppDesign.Typography.title2)
                .fontWeight(.bold)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(goals) { goal in // Iterate through goals
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                        HStack { // Create horizontal stack
                            Image(systemName: goalIcon(for: goal.category))
                                .foregroundColor(AppDesign.Colors.primary)
                            Text(goal.category.rawValue)
                                .font(AppDesign.Typography.headline)
                                .fontWeight(.semibold)
                            
                            Spacer() // Add spacer
                            
                            // Priority indicator
                            HStack(spacing: 2) { // Create horizontal stack
                                ForEach(0..<goal.priority, id: \.self) { _ in // Iterate for priority
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppDesign.Colors.accent)
                                }
                            }
                        }
                        
                        Text(goal.targetDescription)
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        
                        // Progress if values available
                        if let current = goal.currentValue, let target = goal.targetValue { // Check if values available
                            let progress = min(1.0, max(0.0, current / target)) // Calculate progress
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                                HStack { // Create horizontal stack
                                    Text("Progress")
                                        .font(AppDesign.Typography.caption)
                                    Spacer() // Add spacer
                                    Text("\(Int(progress * 100))%")
                                        .font(AppDesign.Typography.caption)
                                        .fontWeight(.semibold)
                                }
                                
                                GeometryReader { geometry in // Create geometry reader
                                    ZStack(alignment: .leading) { // Create z-stack
                                        Rectangle()
                                            .fill(AppDesign.Colors.primary.opacity(0.2))
                                            .frame(height: 8)
                                            .cornerRadius(4)
                                        
                                        Rectangle()
                                            .fill(AppDesign.Colors.primary)
                                            .frame(width: geometry.size.width * progress, height: 8)
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.top, AppDesign.Spacing.xs)
                        }
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Phases Section
    private func phasesSection(phases: [LongTermPlan.PlanPhase]) -> some View { // Create phases section
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            Text("Plan Phases")
                .font(AppDesign.Typography.title2)
                .fontWeight(.bold)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(phases) { phase in // Iterate through phases
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                        HStack { // Create horizontal stack
                            Text(phase.name)
                                .font(AppDesign.Typography.headline)
                                .fontWeight(.semibold)
                            
                            Spacer() // Add spacer
                            
                            Text("Days \(phase.startDay)-\(phase.endDay)")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Text(phase.focus)
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        
                        // Diet Adjustments
                        if !phase.dietAdjustments.isEmpty { // Check if adjustments exist
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                                Text("Diet Adjustments:")
                                    .font(AppDesign.Typography.subheadline)
                                    .fontWeight(.semibold)
                                
                                ForEach(phase.dietAdjustments, id: \.self) { adjustment in // Iterate through adjustments
                                    HStack(alignment: .top) { // Create horizontal stack
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppDesign.Colors.success)
                                            .font(.system(size: 12))
                                        Text(adjustment)
                                            .font(AppDesign.Typography.caption)
                                    }
                                }
                            }
                            .padding(.top, AppDesign.Spacing.xs)
                        }
                        
                        // Exercise Adjustments
                        if !phase.exerciseAdjustments.isEmpty { // Check if adjustments exist
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                                Text("Exercise Adjustments:")
                                    .font(AppDesign.Typography.subheadline)
                                    .fontWeight(.semibold)
                                
                                ForEach(phase.exerciseAdjustments, id: \.self) { adjustment in // Iterate through adjustments
                                    HStack(alignment: .top) { // Create horizontal stack
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppDesign.Colors.success)
                                            .font(.system(size: 12))
                                        Text(adjustment)
                                            .font(AppDesign.Typography.caption)
                                    }
                                }
                            }
                            .padding(.top, AppDesign.Spacing.xs)
                        }
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Milestones Section
    private func milestonesSection(milestones: [LongTermPlan.Milestone]) -> some View { // Create milestones section
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            Text("Milestones")
                .font(AppDesign.Typography.title2)
                .fontWeight(.bold)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(milestones) { milestone in // Iterate through milestones
                ModernCard {
                    HStack { // Create horizontal stack
                        Image(systemName: milestone.achieved ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(milestone.achieved ? AppDesign.Colors.success : AppDesign.Colors.textSecondary)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                            Text(milestone.name)
                                .font(AppDesign.Typography.headline)
                                .fontWeight(.semibold)
                            
                            Text(milestone.description)
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            
                            Text("Target: \(formatDate(milestone.targetDate))")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Spacer() // Add spacer
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Daily Plans Section
    private func dailyPlansSection(plans: [DailyPlanEntry]) -> some View { // Create daily plans section
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            Text("Daily Plans")
                .font(AppDesign.Typography.title2)
                .fontWeight(.bold)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            Text("\(plans.count) days of personalized recommendations")
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            // Show first 10 days as preview
            ForEach(plans.prefix(10)) { plan in // Iterate through first 10 plans
                DailyPlanCard(plan: plan) // Show daily plan card
            }
            
            if plans.count > 10 { // Check if more plans exist
                ModernCard {
                    Text("+ \(plans.count - 10) more days...")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func goalIcon(for category: TransformationGoal.GoalCategory) -> String { // Get goal icon
        switch category { // Switch on category
        case .weight: return "scalemass.fill" // Return icon
        case .muscleMass: return "dumbbell.fill" // Return icon
        case .cardiovascular: return "heart.fill" // Return icon
        case .mentalHealth: return "brain.head.profile" // Return icon
        case .skinHealth: return "face.smiling.fill" // Return icon
        default: return "target" // Return default icon
        }
    }
    
    private func formatDate(_ date: Date) -> String { // Format date
        let formatter = DateFormatter() // Create date formatter
        formatter.dateStyle = .medium // Set date style
        return formatter.string(from: date) // Return formatted string
    }
}

// MARK: - Daily Plan Card
struct DailyPlanCard: View { // Define DailyPlanCard struct
    let plan: DailyPlanEntry // Daily plan entry
    
    var body: some View { // Define body property
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                HStack { // Create horizontal stack
                    Text("Day \(plan.dayNumber)")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    Spacer() // Add spacer
                    
                    Text(formatDate(plan.date))
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                
                // Summary
                HStack(spacing: AppDesign.Spacing.md) { // Create horizontal stack
                    if let dietPlan = plan.dietPlan { // Check if diet plan exists
                        Label("\(dietPlan.meals.count) meals", systemImage: "fork.knife")
                            .font(AppDesign.Typography.caption)
                    }
                    
                    if let exercisePlan = plan.exercisePlan { // Check if exercise plan exists
                        Label("\(exercisePlan.weeklyPlan.count) days", systemImage: "figure.run")
                            .font(AppDesign.Typography.caption)
                    }
                    
                    Label("\(Int(plan.meditationMinutes)) min", systemImage: "leaf.fill")
                        .font(AppDesign.Typography.caption)
                }
                .foregroundColor(AppDesign.Colors.textSecondary)
                
                // Notes
                if let notes = plan.notes, !notes.isEmpty { // Check if notes exist
                    Text(notes)
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .lineLimit(2)
                        .padding(.top, AppDesign.Spacing.xs)
                }
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    private func formatDate(_ date: Date) -> String { // Format date
        let formatter = DateFormatter() // Create date formatter
        formatter.dateStyle = .short // Set date style
        return formatter.string(from: date) // Return formatted string
    }
}

// MARK: - Stat Item
struct StatItem: View { // Define StatItem struct
    let label: String // Label text
    let value: String // Value text
    let icon: String // Icon name
    
    var body: some View { // Define body property
        VStack(spacing: AppDesign.Spacing.xs) { // Create vertical stack
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppDesign.Colors.primary)
            
            Text(value)
                .font(AppDesign.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(AppDesign.Colors.textPrimary)
            
            Text(label)
                .font(AppDesign.Typography.caption)
                .foregroundColor(AppDesign.Colors.textSecondary)
        }
    }
}
