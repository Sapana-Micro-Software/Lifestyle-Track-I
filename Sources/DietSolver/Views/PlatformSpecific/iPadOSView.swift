//
//  iPadOSView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - iPadOS Specific Views
struct iPadOSContentView: View {
    @EnvironmentObject var controller: DietSolverController
    @State private var selectedSidebar: SidebarItem? = .home
    
    enum SidebarItem: String, CaseIterable, Identifiable {
        case home = "Home"
        case health = "Health"
        case exercise = "Exercise"
        case badges = "Badges"
        case insights = "Insights"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .health: return "heart.fill"
            case .exercise: return "figure.run"
            case .badges: return "medal.fill"
            case .insights: return "chart.line.uptrend.xyaxis"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSidebar) {
                ForEach(SidebarItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label(item.rawValue, systemImage: item.icon)
                    }
                }
            }
            .navigationTitle("Lifestyle Track")
        } detail: {
            Group {
                switch selectedSidebar {
                case .home:
                    iPadOSHomeView(controller: controller)
                case .health:
                    iPadOSHealthView(controller: controller)
                case .exercise:
                    iPadOSExerciseView(controller: controller)
                case .badges:
                    iPadOSBadgesView(controller: controller)
                case .insights:
                    iPadOSInsightsView(controller: controller)
                case .none:
                    Text("Select an item")
                }
            }
        }
    }
}

struct iPadOSHomeView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                if let plan = controller.dietPlan {
                    StatCard(title: "Meals", value: "\(plan.meals.count)", icon: "fork.knife", color: AppDesign.Colors.primary)
                    StatCard(title: "Calories", value: "\(Int(plan.totalNutrients.calories))", icon: "flame.fill", color: AppDesign.Colors.accent)
                    StatCard(title: "Taste", value: String(format: "%.1f", plan.overallTasteScore), icon: "star.fill", color: AppDesign.Colors.secondary)
                }
                
                ForEach(controller.getEarnedBadges().prefix(6)) { badge in
                    iPadOSBadgeCard(badge: badge)
                }
            }
            .padding(AppDesign.Spacing.lg)
        }
        .navigationTitle("Home")
    }
}

struct iPadOSHealthView: View {
    @ObservedObject var controller: DietSolverController
    @EnvironmentObject var viewModel: DietSolverViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                if let healthData = controller.healthData {
                    HealthOverviewCard(healthData: healthData)
                        .environmentObject(viewModel)
                }
            }
            .padding(AppDesign.Spacing.lg)
        }
        .navigationTitle("Health")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                CompactUnitSystemToggle(viewModel: viewModel)
            }
        }
    }
}

struct iPadOSExerciseView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            if let plan = controller.exercisePlan {
                ExercisePlanView(plan: plan, healthData: controller.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate))
            }
        }
        .navigationTitle("Exercise")
    }
}

struct iPadOSBadgesView: View {
    @ObservedObject var controller: DietSolverController
    @State private var selectedCategory: HealthBadge.BadgeCategory? = nil
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                ForEach(filteredBadges) { badge in
                    iPadOSBadgeCard(badge: badge)
                }
            }
            .padding(AppDesign.Spacing.lg)
        }
        .navigationTitle("Badges")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button("All") { selectedCategory = nil }
                    ForEach(HealthBadge.BadgeCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) { selectedCategory = category }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    private var filteredBadges: [HealthBadge] {
        if let category = selectedCategory {
            return controller.badges.filter { $0.category == category }
        }
        return controller.badges
    }
}

struct iPadOSBadgeCard: View {
    let badge: HealthBadge
    
    var body: some View {
        ModernCard(shadow: AppDesign.Shadow.medium) {
            VStack(spacing: AppDesign.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: badge.colorHex)?.opacity(0.2) ?? AppDesign.Colors.primary.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: badge.icon)
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                }
                
                Text(badge.name)
                    .font(AppDesign.Typography.title2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.description)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text(badge.level.rawValue)
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                    .padding(.horizontal, AppDesign.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Color(hex: badge.colorHex)?.opacity(0.1) ?? AppDesign.Colors.primary.opacity(0.1))
                    .cornerRadius(AppDesign.Radius.medium)
                
                ProgressRing(progress: badge.progress, color: Color(hex: badge.colorHex) ?? AppDesign.Colors.primary, size: 50)
                
                Text(badge.displayProgress)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
    }
}

struct iPadOSInsightsView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                    StatCard(title: "Earned Badges", value: "\(controller.getEarnedBadges().count)", icon: "medal.fill", color: AppDesign.Colors.primary)
                    StatCard(title: "Total Badges", value: "\(controller.badges.count)", icon: "star.fill", color: AppDesign.Colors.secondary)
                }
            }
            .padding(AppDesign.Spacing.lg)
        }
        .navigationTitle("Insights")
    }
}
