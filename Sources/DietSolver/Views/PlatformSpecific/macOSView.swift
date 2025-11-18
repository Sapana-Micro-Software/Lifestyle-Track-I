//
//  macOSView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - macOS Specific Views
struct macOSContentView: View {
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
            .frame(minWidth: 200)
        } detail: {
            Group {
                switch selectedSidebar {
                case .home:
                    macOSHomeView(controller: controller)
                case .health:
                    macOSHealthView(controller: controller)
                case .exercise:
                    macOSExerciseView(controller: controller)
                case .badges:
                    macOSBadgesView(controller: controller)
                case .insights:
                    macOSInsightsView(controller: controller)
                case .none:
                    Text("Select an item from the sidebar")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 600, minHeight: 400)
        }
    }
}

struct macOSHomeView: View {
    @ObservedObject var controller: DietSolverController
    @State private var showHealthWizard = false
    
    var body: some View {
        Group {
            if controller.healthData == nil {
                welcomeScreen
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                        if let plan = controller.dietPlan {
                            StatCard(title: "Meals", value: "\(plan.meals.count)", icon: "fork.knife", color: AppDesign.Colors.primary)
                            StatCard(title: "Calories", value: "\(Int(plan.totalNutrients.calories))", icon: "flame.fill", color: AppDesign.Colors.accent)
                            StatCard(title: "Taste", value: String(format: "%.1f", plan.overallTasteScore), icon: "star.fill", color: AppDesign.Colors.secondary)
                            StatCard(title: "Badges", value: "\(controller.getEarnedBadges().count)", icon: "medal.fill", color: Color.purple)
                        }
                        
                        ForEach(controller.getEarnedBadges().prefix(8)) { badge in
                            macOSBadgeCard(badge: badge)
                        }
                    }
                    .padding(AppDesign.Spacing.lg)
                }
            }
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if controller.healthData == nil {
                    Button(action: { showHealthWizard = true }) {
                        Label("Get Started", systemImage: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showHealthWizard) {
            HealthWizardViewWrapper()
                .frame(minWidth: 800, minHeight: 600)
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: AppDesign.Spacing.xl) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 100))
                .foregroundColor(AppDesign.Colors.primary)
            
            Text("Welcome to Health & Wellness Lifestyle Solver")
                .font(AppDesign.Typography.largeTitle)
                .foregroundColor(AppDesign.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Create your personalized 10+ year daily plan")
                .font(AppDesign.Typography.title2)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showHealthWizard = true }) {
                HStack {
                    Text("Get Started")
                        .font(AppDesign.Typography.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppDesign.Spacing.xl)
                .padding(.vertical, AppDesign.Spacing.md)
                .background(
                    LinearGradient(
                        colors: [AppDesign.Colors.gradientStart, AppDesign.Colors.gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppDesign.Radius.medium)
                .shadow(color: AppDesign.Shadow.medium.color, radius: AppDesign.Shadow.medium.radius, x: AppDesign.Shadow.medium.x, y: AppDesign.Shadow.medium.y)
            }
            .padding(.top, AppDesign.Spacing.lg)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppDesign.Colors.background)
    }
}

struct macOSHealthView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                if let healthData = controller.healthData {
                    HealthOverviewCard(healthData: healthData)
                }
            }
            .padding(AppDesign.Spacing.lg)
        }
        .navigationTitle("Health")
    }
}

struct macOSExerciseView: View {
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

struct macOSBadgesView: View {
    @ObservedObject var controller: DietSolverController
    @State private var selectedCategory: HealthBadge.BadgeCategory? = nil
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                ForEach(filteredBadges) { badge in
                    macOSBadgeCard(badge: badge)
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

struct macOSBadgeCard: View {
    let badge: HealthBadge
    
    var body: some View {
        ModernCard(shadow: AppDesign.Shadow.medium) {
            VStack(spacing: AppDesign.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: badge.colorHex)?.opacity(0.2) ?? AppDesign.Colors.primary.opacity(0.2))
                        .frame(width: 100, height: 100)
                    Image(systemName: badge.icon)
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                }
                
                Text(badge.name)
                    .font(AppDesign.Typography.title2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.description)
                    .font(AppDesign.Typography.body)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text(badge.level.rawValue)
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.vertical, AppDesign.Spacing.sm)
                    .background(Color(hex: badge.colorHex)?.opacity(0.1) ?? AppDesign.Colors.primary.opacity(0.1))
                    .cornerRadius(AppDesign.Radius.medium)
                
                ProgressRing(progress: badge.progress, color: Color(hex: badge.colorHex) ?? AppDesign.Colors.primary, size: 60)
                
                Text(badge.displayProgress)
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
    }
}

struct macOSInsightsView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.lg) {
                StatCard(title: "Earned Badges", value: "\(controller.getEarnedBadges().count)", icon: "medal.fill", color: AppDesign.Colors.primary)
                StatCard(title: "Total Badges", value: "\(controller.badges.count)", icon: "star.fill", color: AppDesign.Colors.secondary)
            }
            .padding(AppDesign.Spacing.lg)
        }
        .navigationTitle("Insights")
    }
}
