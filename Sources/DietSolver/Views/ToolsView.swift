//
//  ToolsView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Tools View
struct ToolsView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    @State private var selectedTool: ToolType?
    
    enum ToolType: Identifiable {
        case groceryList
        case recipeLibrary
        case mealPrep
        case progressCharts
        case healthReport
        case longTermPlan
        case psychologistChat
        
        var id: String {
            switch self {
            case .groceryList: return "groceryList"
            case .recipeLibrary: return "recipeLibrary"
            case .mealPrep: return "mealPrep"
            case .progressCharts: return "progressCharts"
            case .healthReport: return "healthReport"
            case .longTermPlan: return "longTermPlan"
            case .psychologistChat: return "psychologistChat"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Tools")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Tools & Utilities")
                            .font(AppDesign.Typography.title)
                            .fontWeight(.bold)
                        
                        Text("Helpful tools to support your health journey")
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Tool Cards
                    VStack(spacing: AppDesign.Spacing.md) {
                        // Grocery List
                        Button(action: { selectedTool = .groceryList }) {
                            ToolCard(
                                title: "Grocery List",
                                description: "Generate shopping lists from your meal plans",
                                icon: "cart.fill",
                                color: AppDesign.Colors.primary
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Recipe Library
                        Button(action: { selectedTool = .recipeLibrary }) {
                            ToolCard(
                                title: "Recipe Library",
                                description: "Save and organize your favorite recipes",
                                icon: "book.fill",
                                color: AppDesign.Colors.secondary
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Meal Prep Planner
                        Button(action: { selectedTool = .mealPrep }) {
                            ToolCard(
                                title: "Meal Prep Planner",
                                description: "Plan your meal prep schedule for the week",
                                icon: "calendar.badge.clock",
                                color: AppDesign.Colors.accent
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Progress Charts
                        Button(action: { selectedTool = .progressCharts }) {
                            ToolCard(
                                title: "Progress Charts",
                                description: "Visualize your health progress over time",
                                icon: "chart.line.uptrend.xyaxis",
                                color: AppDesign.Colors.success
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Health Report
                        Button(action: { selectedTool = .healthReport }) {
                            ToolCard(
                                title: "Health Report",
                                description: "Generate comprehensive health reports",
                                icon: "doc.text.fill",
                                color: AppDesign.Colors.primary
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Long-Term Plan
                        if viewModel.longTermPlan != nil {
                            Button(action: { selectedTool = .longTermPlan }) {
                                ToolCard(
                                    title: "Long-Term Plan",
                                    description: "View your \(viewModel.longTermPlan?.duration.rawValue ?? "") transformation plan",
                                    icon: "calendar.badge.clock",
                                    color: AppDesign.Colors.accent
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Psychologist Chat
                        Button(action: { selectedTool = .psychologistChat }) {
                            ToolCard(
                                title: "Psychologist Chat",
                                description: "Talk with an AI psychologist for personalized mental health support",
                                icon: "message.fill",
                                color: Color.green
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        .sheet(item: $selectedTool) { tool in
            switch tool {
            case .groceryList:
                GroceryListView(viewModel: viewModel)
            case .recipeLibrary:
                RecipeLibraryView(viewModel: viewModel)
            case .mealPrep:
                MealPrepView(viewModel: viewModel)
            case .progressCharts:
                ProgressChartsView(viewModel: viewModel)
            case .healthReport:
                HealthReportView(viewModel: viewModel)
            case .longTermPlan:
                LongTermPlanView(viewModel: viewModel)
            case .psychologistChat:
                PsychologistChatView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Tool Card
struct ToolCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        ModernCard {
            HStack(spacing: AppDesign.Spacing.md) {
                IconBadge(icon: icon, color: color, size: 50)
                
                VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                    Text(title)
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            .padding(AppDesign.Spacing.md)
        }
    }
}
