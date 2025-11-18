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
    
    var body: some View {
        NavigationView {
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
                        NavigationLink(destination: GroceryListView(viewModel: viewModel)) {
                            ToolCard(
                                title: "Grocery List",
                                description: "Generate shopping lists from your meal plans",
                                icon: "cart.fill",
                                color: AppDesign.Colors.primary
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Recipe Library
                        NavigationLink(destination: RecipeLibraryView(viewModel: viewModel)) {
                            ToolCard(
                                title: "Recipe Library",
                                description: "Save and organize your favorite recipes",
                                icon: "book.fill",
                                color: AppDesign.Colors.secondary
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Meal Prep Planner
                        NavigationLink(destination: MealPrepView(viewModel: viewModel)) {
                            ToolCard(
                                title: "Meal Prep Planner",
                                description: "Plan your meal prep schedule for the week",
                                icon: "calendar.badge.clock",
                                color: AppDesign.Colors.accent
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Progress Charts
                        NavigationLink(destination: ProgressChartsView(viewModel: viewModel)) {
                            ToolCard(
                                title: "Progress Charts",
                                description: "Visualize your health progress over time",
                                icon: "chart.line.uptrend.xyaxis",
                                color: AppDesign.Colors.success
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Health Report
                        NavigationLink(destination: HealthReportView(viewModel: viewModel)) {
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
                            NavigationLink(destination: LongTermPlanView(viewModel: viewModel)) {
                                ToolCard(
                                    title: "Long-Term Plan",
                                    description: "View your \(viewModel.longTermPlan?.duration.rawValue ?? "") transformation plan",
                                    icon: "calendar.badge.clock",
                                    color: AppDesign.Colors.accent
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
            .navigationTitle("Tools")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
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
