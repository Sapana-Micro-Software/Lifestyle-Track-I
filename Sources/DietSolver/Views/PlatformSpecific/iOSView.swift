//
//  iOSView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - iOS Specific Views
struct iOSContentView: View {
    @EnvironmentObject var controller: DietSolverController
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            iOSHomeView(controller: controller)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            iOSHealthView(controller: controller)
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                .tag(1)
            
            iOSExerciseView(controller: controller)
                .tabItem {
                    Label("Exercise", systemImage: "figure.run")
                }
                .tag(2)
            
            iOSBadgesView(controller: controller)
                .tabItem {
                    Label("Badges", systemImage: "medal.fill")
                }
                .tag(3)
            
            HealthStudiesView()
                .tabItem {
                    Label("Studies", systemImage: "chart.bar.doc.horizontal.fill")
                }
                .tag(4)
        }
        .accentColor(AppDesign.Colors.primary)
    }
}

struct iOSHomeView: View {
    @ObservedObject var controller: DietSolverController
    @EnvironmentObject var viewModel: DietSolverViewModel
    @State private var showHealthWizard = false
    
    var body: some View {
        NavigationView {
            Group {
                if controller.healthData == nil {
                    // Show welcome screen with Health Wizard button
                    welcomeScreen
                } else {
                    ScrollView {
                        VStack(spacing: AppDesign.Spacing.lg) {
                            // Quick Stats
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.md) {
                                if let plan = controller.dietPlan {
                                    StatCard(title: "Meals", value: "\(plan.meals.count)", icon: "fork.knife", color: AppDesign.Colors.primary)
                                    StatCard(title: "Calories", value: "\(Int(plan.totalNutrients.calories))", icon: "flame.fill", color: AppDesign.Colors.accent)
                                }
                            }
                            .padding(.horizontal, AppDesign.Spacing.md)
                            
                            // Earned Badges Preview
                            if !controller.getEarnedBadges().isEmpty {
                                iOSBadgePreviewSection(controller: controller)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if controller.healthData == nil {
                        Button(action: { showHealthWizard = true }) {
                            Label("Get Started", systemImage: "person.crop.circle.badge.plus")
                        }
                    } else {
                        CompactUnitSystemToggle(viewModel: viewModel)
                    }
                }
            }
            .sheet(isPresented: $showHealthWizard) {
                HealthWizardViewWrapper()
            }
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: AppDesign.Spacing.xl) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(AppDesign.Colors.primary)
            
            Text("Welcome to Health & Wellness Lifestyle Solver")
                .font(AppDesign.Typography.title)
                .foregroundColor(AppDesign.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDesign.Spacing.lg)
            
            Text("Create your personalized 10+ year daily plan")
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDesign.Spacing.lg)
            
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

struct iOSHealthView: View {
    @ObservedObject var controller: DietSolverController
    @EnvironmentObject var viewModel: DietSolverViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    if let healthData = controller.healthData {
                        HealthOverviewCard(healthData: healthData)
                            .environmentObject(viewModel)
                    }
                }
            }
            .navigationTitle("Health")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    CompactUnitSystemToggle(viewModel: viewModel)
                }
            }
        }
    }
}

struct iOSExerciseView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let plan = controller.exercisePlan {
                    ExercisePlanView(plan: plan, healthData: controller.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate))
                }
            }
            .navigationTitle("Exercise")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

struct iOSBadgesView: View {
    @ObservedObject var controller: DietSolverController
    @State private var selectedCategory: HealthBadge.BadgeCategory? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Category Filter
                    categoryFilter
                    
                    // Badges Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.md) {
                        ForEach(filteredBadges) { badge in
                            iOSBadgeCard(badge: badge)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .navigationTitle("Badges")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppDesign.Spacing.sm) {
                CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(HealthBadge.BadgeCategory.allCases, id: \.self) { category in
                    CategoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private var filteredBadges: [HealthBadge] {
        if let category = selectedCategory {
            return controller.badges.filter { $0.category == category }
        }
        return controller.badges
    }
}

struct iOSBadgeCard: View {
    let badge: HealthBadge
    
    var body: some View {
        ModernCard {
            VStack(spacing: AppDesign.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color(hex: badge.colorHex)?.opacity(0.2) ?? AppDesign.Colors.primary.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Image(systemName: badge.icon.isEmpty ? "star.fill" : badge.icon)
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                }
                
                Text(badge.name)
                    .font(AppDesign.Typography.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.level.rawValue)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                
                ProgressRing(progress: badge.progress, color: Color(hex: badge.colorHex) ?? AppDesign.Colors.primary, size: 40)
                
                Text(badge.displayProgress)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
    }
}

struct iOSBadgePreviewSection: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Recent Badges")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppDesign.Spacing.md) {
                    ForEach(controller.getEarnedBadges().prefix(5)) { badge in
                        iOSBadgeCard(badge: badge)
                            .frame(width: 150)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
}

struct HealthOverviewCard: View {
    let healthData: HealthData
    @EnvironmentObject var viewModel: DietSolverViewModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Health Overview")
                    .font(AppDesign.Typography.title2)
                
                HStack {
                    StatCard(title: "Age", value: "\(healthData.age)", icon: "person.fill", color: AppDesign.Colors.primary)
                    StatCard(
                        title: "Weight",
                        value: UnitConverter.shared.formatWeight(healthData.weight, system: viewModel.unitSystem),
                        icon: "scalemass.fill",
                        color: AppDesign.Colors.secondary
                    )
                }
            }
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
