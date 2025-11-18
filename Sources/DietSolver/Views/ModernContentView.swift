//
//  ModernContentView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Modern Content View
public struct ModernContentView: View {
    @StateObject private var viewModel = DietSolverViewModel()
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Home Dashboard
                HomeDashboardView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                // Health Tracking
                HealthTrackingView(viewModel: viewModel)
                    .tabItem {
                        Label("Health", systemImage: "heart.fill")
                    }
                    .tag(1)
                
                // Exercise
                ExerciseDashboardView(viewModel: viewModel)
                    .tabItem {
                        Label("Exercise", systemImage: "figure.run")
                    }
                    .tag(2)
                
                // Insights
                InsightsView(viewModel: viewModel)
                    .tabItem {
                        Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(3)
                
                // Tools
                ToolsView(viewModel: viewModel)
                    .tabItem {
                        Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                    }
                    .tag(6)
                
                // Badges
                BadgeGalleryView(controller: DietSolverController(viewModel: viewModel))
                    .tabItem {
                        Label("Badges", systemImage: "medal.fill")
                    }
                    .tag(4)
                
                // Health Studies
                HealthStudiesView()
                    .tabItem {
                        Label("Studies", systemImage: "chart.bar.doc.horizontal.fill")
                    }
                    .tag(5)
            }
            .accentColor(AppDesign.Colors.primary)
        }
    }
}

// MARK: - Home Dashboard
struct HomeDashboardView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var showHealthInput = false
    @State private var showDietPlan = false
    @State private var showLongTermPlan = false
    @State private var showGroceryList = false
    @State private var showRecipeLibrary = false
    
    var body: some View {
        VStack {
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppDesign.Spacing.lg) {
                        // Header
                        headerSection
                        
                        if viewModel.healthData == nil {
                            EmptyStateView(
                                icon: "person.crop.circle.badge.plus",
                                title: "Welcome to Lifestyle Track",
                                message: "Get started by adding your health information to create a personalized wellness plan.",
                                actionTitle: "Get Started",
                                action: { showHealthInput = true }
                            )
                        } else if viewModel.dietPlan == nil {
                            ModernSolvingView(viewModel: viewModel)
                        } else {
                            // Quick Stats
                            quickStatsSection
                            
                            // Today's Plan
                            todaysPlanSection
                            
                            // Quick Actions
                            quickActionsSection
                            
                            // Recent Activity
                            recentActivitySection
                            
                            // Full Diet Plan Link
                            Button(action: { showDietPlan = true }) {
                                ModernCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("View Full Diet Plan")
                                                .font(AppDesign.Typography.headline)
                                            Text("See all meals, recipes, and nutrition details")
                                                .font(AppDesign.Typography.caption)
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(AppDesign.Colors.primary)
                                            .font(.title2)
                                    }
                                }
                                .padding(.horizontal, AppDesign.Spacing.md)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Long-Term Plan Link
                            if viewModel.longTermPlan != nil {
                                Button(action: { showLongTermPlan = true }) {
                                    ModernCard {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("View Long-Term Plan")
                                                    .font(AppDesign.Typography.headline)
                                                Text("See your \(viewModel.longTermPlan?.duration.rawValue ?? "") transformation plan with daily recommendations")
                                                    .font(AppDesign.Typography.caption)
                                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                            }
                                            Spacer()
                                            Image(systemName: "calendar.badge.clock")
                                                .foregroundColor(AppDesign.Colors.primary)
                                                .font(.title2)
                                        }
                                    }
                                    .padding(.horizontal, AppDesign.Spacing.md)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Quick Tools
                            VStack(spacing: AppDesign.Spacing.sm) {
                                Button(action: { showGroceryList = true }) {
                                    ModernCard {
                                        HStack {
                                            Image(systemName: "cart.fill")
                                                .foregroundColor(AppDesign.Colors.primary)
                                                .font(.title2)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Grocery List")
                                                    .font(AppDesign.Typography.headline)
                                                Text("Generate shopping list from meal plans")
                                                    .font(AppDesign.Typography.caption)
                                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, AppDesign.Spacing.md)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { showRecipeLibrary = true }) {
                                    ModernCard {
                                        HStack {
                                            Image(systemName: "book.fill")
                                                .foregroundColor(AppDesign.Colors.secondary)
                                                .font(.title2)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Recipe Library")
                                                    .font(AppDesign.Typography.headline)
                                                Text("Save and organize favorite recipes")
                                                    .font(AppDesign.Typography.caption)
                                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, AppDesign.Spacing.md)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
                
                // Floating Action Button
                if viewModel.healthData != nil && viewModel.dietPlan != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            FloatingActionButton(icon: "plus") {
                                // Quick add action
                            }
                            .padding(.trailing, AppDesign.Spacing.lg)
                            .padding(.bottom, AppDesign.Spacing.lg)
                        }
                    }
                }
            }
            .navigationTitle("Lifestyle Track")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .sheet(isPresented: $showHealthInput) {
                ModernHealthDataInputView(viewModel: viewModel)
            }
            .sheet(isPresented: $showDietPlan) {
                DietPlanView(viewModel: viewModel)
            }
            .sheet(isPresented: $showLongTermPlan) {
                LongTermPlanView(viewModel: viewModel)
            }
            .sheet(isPresented: $showGroceryList) {
                GroceryListView(viewModel: viewModel)
            }
            .sheet(isPresented: $showRecipeLibrary) {
                RecipeLibraryView(viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello")
                        .font(AppDesign.Typography.title2)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    Text("Ready to optimize?")
                        .font(AppDesign.Typography.largeTitle)
                        .foregroundColor(AppDesign.Colors.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Today's Overview")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppDesign.Spacing.md) {
                    if let plan = viewModel.dietPlan {
                        StatCard(
                            title: "Meals",
                            value: "\(plan.meals.count)",
                            icon: "fork.knife",
                            color: AppDesign.Colors.primary
                        )
                        StatCard(
                            title: "Calories",
                            value: "\(Int(plan.totalNutrients.calories))",
                            icon: "flame.fill",
                            color: AppDesign.Colors.accent
                        )
                        StatCard(
                            title: "Taste Score",
                            value: String(format: "%.1f", plan.overallTasteScore),
                            icon: "star.fill",
                            color: AppDesign.Colors.secondary
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    private var todaysPlanSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Today's Plan", action: {
                // Navigate to full plan
            })
            
            if let plan = viewModel.dietPlan {
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ForEach(plan.meals.prefix(3)) { meal in
                            MealRowCard(meal: meal)
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Quick Actions")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppDesign.Spacing.md) {
                QuickActionButton(
                    title: "Vision",
                    icon: "eye.fill",
                    color: AppDesign.Colors.primary
                ) {
                    // Navigate to vision
                }
                QuickActionButton(
                    title: "Hearing",
                    icon: "ear.fill",
                    color: AppDesign.Colors.secondary
                ) {
                    // Navigate to hearing
                }
                QuickActionButton(
                    title: "Tactile",
                    icon: "hand.tap.fill",
                    color: AppDesign.Colors.accent
                ) {
                    // Navigate to tactile
                }
                QuickActionButton(
                    title: "Tongue",
                    icon: "mouth.fill",
                    color: Color.purple
                ) {
                    // Navigate to tongue
                }
                QuickActionButton(
                    title: "Eating",
                    icon: "fork.knife.circle.fill",
                    color: AppDesign.Colors.primary
                ) {
                    // Navigate to eating metrics
                }
                QuickActionButton(
                    title: "Emotional",
                    icon: "heart.circle.fill",
                    color: AppDesign.Colors.accent
                ) {
                    // Navigate to emotional health
                }
                QuickActionButton(
                    title: "Badges",
                    icon: "medal.fill",
                    color: AppDesign.Colors.secondary
                ) {
                    // Navigate to badges
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Recent Activity")
            
            ModernCard {
                VStack(spacing: AppDesign.Spacing.sm) {
                    ActivityRow(icon: "checkmark.circle.fill", title: "Morning Exercise", time: "8:00 AM", color: .green)
                    ActivityRow(icon: "fork.knife", title: "Breakfast", time: "9:00 AM", color: AppDesign.Colors.primary)
                    ActivityRow(icon: "eye.fill", title: "Vision Check", time: "10:00 AM", color: AppDesign.Colors.secondary)
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
}

// MARK: - Supporting Views
struct MealRowCard: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.md) {
            IconBadge(
                icon: mealIcon(for: meal.mealType),
                color: AppDesign.Colors.primary,
                size: 40
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(AppDesign.Typography.headline)
                Text("\(meal.items.count) items")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(meal.totalNutrients.calories))")
                    .font(AppDesign.Typography.headline)
                Text("kcal")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
        .padding(.vertical, AppDesign.Spacing.xs)
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

struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(AppDesign.Typography.body)
            Spacer()
            Text(time)
                .font(AppDesign.Typography.caption)
                .foregroundColor(AppDesign.Colors.textSecondary)
        }
    }
}

// MARK: - Health Tracking View
struct HealthTrackingView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var selectedCategory: HealthCategory = .overview
    
    enum HealthCategory: String, CaseIterable {
        case overview = "Overview"
        case vision = "Vision"
        case hearing = "Hearing"
        case tactile = "Tactile"
        case tongue = "Tongue"
        case eating = "Eating"
        case emotional = "Emotional"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Health Tracking")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppDesign.Spacing.lg) {
                        // Category Picker
                        categoryPicker
                        
                        // Content based on selection
                        categoryContent
                    }
                    .padding(.bottom, 80)
                }
            }
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppDesign.Spacing.sm) {
                ForEach(HealthCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private var categoryContent: some View {
        Group {
            switch selectedCategory {
            case .overview:
                healthOverviewContent
            case .vision:
                VisionCheckView(viewModel: viewModel)
            case .hearing:
                HearingCheckView(viewModel: viewModel)
            case .tactile:
                TactileCheckView(viewModel: viewModel)
            case .tongue:
                TongueCheckView(viewModel: viewModel)
            case .eating:
                EatingMetricsInputView(viewModel: viewModel)
            case .emotional:
                EmotionalHealthInputView(viewModel: viewModel)
            }
        }
    }
    
    private var healthOverviewContent: some View {
        VStack(spacing: AppDesign.Spacing.lg) {
            if let healthData = viewModel.healthData {
                // Health Metrics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppDesign.Spacing.md) {
                    StatCard(
                        title: "Age",
                        value: "\(healthData.age)",
                        icon: "person.fill",
                        color: AppDesign.Colors.primary
                    )
                    StatCard(
                        title: "Weight",
                        value: String(format: "%.1f kg", healthData.weight),
                        icon: "scalemass.fill",
                        color: AppDesign.Colors.secondary
                    )
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Quick Test Cards
                VStack(spacing: AppDesign.Spacing.md) {
                    SectionHeader("Quick Tests")
                    
                    QuickTestCard(
                        title: "Vision Check",
                        icon: "eye.fill",
                        color: AppDesign.Colors.primary,
                        lastTest: healthData.dailyVisionChecks.last?.date
                    ) {
                        selectedCategory = .vision
                    }
                    QuickTestCard(
                        title: "Hearing Test",
                        icon: "ear.fill",
                        color: AppDesign.Colors.secondary,
                        lastTest: healthData.dailyAudioHearingTests.last?.date
                    ) {
                        selectedCategory = .hearing
                    }
                    QuickTestCard(
                        title: "Tactile Test",
                        icon: "hand.tap.fill",
                        color: AppDesign.Colors.accent,
                        lastTest: healthData.dailyTactileTests.last?.date
                    ) {
                        selectedCategory = .tactile
                    }
                    QuickTestCard(
                        title: "Tongue Test",
                        icon: "mouth.fill",
                        color: Color.purple,
                        lastTest: healthData.dailyTongueTests.last?.date
                    ) {
                        selectedCategory = .tongue
                    }
                    QuickTestCard(
                        title: "Eating Metrics",
                        icon: "fork.knife.circle.fill",
                        color: AppDesign.Colors.primary,
                        lastTest: healthData.eatingMetrics.last?.date
                    ) {
                        selectedCategory = .eating
                    }
                    QuickTestCard(
                        title: "Emotional Health",
                        icon: "heart.circle.fill",
                        color: AppDesign.Colors.accent,
                        lastTest: healthData.emotionalHealth.last?.date
                    ) {
                        selectedCategory = .emotional
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppDesign.Typography.subheadline)
                .foregroundColor(isSelected ? .white : AppDesign.Colors.textPrimary)
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.vertical, AppDesign.Spacing.sm)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [AppDesign.Colors.gradientStart, AppDesign.Colors.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            AppDesign.Colors.surface
                        }
                    }
                )
                .cornerRadius(AppDesign.Radius.large)
                .shadow(color: AppDesign.Shadow.small.color, radius: AppDesign.Shadow.small.radius, x: AppDesign.Shadow.small.x, y: AppDesign.Shadow.small.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickTestCard: View {
    let title: String
    let icon: String
    let color: Color
    let lastTest: Date?
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif
            action()
        }) {
            ModernCard {
                HStack(spacing: AppDesign.Spacing.md) {
                    IconBadge(icon: icon, color: color, size: 44)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(AppDesign.Typography.headline)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        if let lastTest = lastTest {
                            Text("Last: \(formatDate(lastTest))")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        } else {
                            Text("Not tested yet")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.warning)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Exercise Dashboard
struct ExerciseDashboardView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Exercise")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                if let plan = viewModel.exercisePlan, let healthData = viewModel.healthData {
                    ScrollView {
                        VStack(spacing: AppDesign.Spacing.lg) {
                            // Weekly Progress
                            weeklyProgressSection(plan: plan)
                            
                            // Today's Activities
                            todaysActivitiesSection(plan: plan, healthData: healthData)
                            
                            // Focus Areas
                            focusAreasSection(plan: plan)
                            
                            // Full Week Plan
                            fullWeekPlanSection(plan: plan, healthData: healthData)
                        }
                        .padding(.bottom, 80)
                    }
                } else {
                    EmptyStateView(
                        icon: "figure.run",
                        title: "No Exercise Plan",
                        message: "Generate your personalized exercise plan to get started.",
                        actionTitle: "Generate Plan"
                    ) {
                        // Generate plan
                    }
                }
            }
        }
    }
    
    private func weeklyProgressSection(plan: ExercisePlan) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Weekly Progress")
            
            ModernCard {
                HStack(spacing: AppDesign.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Week")
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        Text("\(plan.weeklyPlan.count) days")
                            .font(AppDesign.Typography.title2)
                    }
                    Spacer()
                    ProgressRing(progress: 0.6, color: AppDesign.Colors.primary, size: 60)
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private func todaysActivitiesSection(plan: ExercisePlan, healthData: HealthData) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Today")
            
            if let todayPlan = plan.weeklyPlan.first(where: { $0.dayOfWeek == Calendar.current.component(.weekday, from: Date()) - 1 }) {
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ForEach(todayPlan.activities.prefix(3)) { activity in
                            ModernActivityRow(activity: activity, healthData: healthData)
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    private func focusAreasSection(plan: ExercisePlan) -> some View {
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
    
    private func fullWeekPlanSection(plan: ExercisePlan, healthData: HealthData) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("This Week")
            
            VStack(spacing: AppDesign.Spacing.sm) {
                ForEach(plan.weeklyPlan) { dayPlan in
                    ModernDayPlanCard(dayPlan: dayPlan, healthData: healthData)
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
}

struct ModernActivityRow: View {
    let activity: ExercisePlan.DayPlan.PlannedActivity
    let healthData: HealthData
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.md) {
            IconBadge(
                icon: activityIcon(for: activity.activity.category),
                color: AppDesign.Colors.categoryColor(activity.activity.category),
                size: 36
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.activity.name)
                    .font(AppDesign.Typography.headline)
                HStack(spacing: AppDesign.Spacing.sm) {
                    Label("\(Int(activity.duration)) min", systemImage: "clock.fill")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    Text("•")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    Text(activity.timeOfDay.rawValue)
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            Spacer()
        }
    }
    
    private func activityIcon(for category: ExerciseCategory) -> String {
        switch category {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .flexibility: return "figure.flexibility"
        case .mindBody: return "leaf.fill"
        case .breathing: return "wind"
        case .dance: return "music.note"
        case .martialArts: return "figure.martial.arts"
        case .functional: return "figure.strengthtraining.functional"
        }
    }
}

struct ModernDayPlanCard: View {
    let dayPlan: ExercisePlan.DayPlan
    let healthData: HealthData
    
    private var dayName: String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[dayPlan.dayOfWeek]
    }
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                HStack {
                    Text(dayName)
                        .font(AppDesign.Typography.headline)
                    Spacer()
                    Text("\(dayPlan.activities.count) activities")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                
                ForEach(dayPlan.activities.prefix(2)) { activity in
                    ModernActivityRow(activity: activity, healthData: healthData)
                }
                
                if dayPlan.activities.count > 2 {
                    Text("+ \(dayPlan.activities.count - 2) more")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.primary)
                }
            }
        }
    }
}

struct FocusChip: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(AppDesign.Typography.caption)
            .foregroundColor(AppDesign.Colors.primary)
            .padding(.horizontal, AppDesign.Spacing.md)
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.primary.opacity(0.1))
            .cornerRadius(AppDesign.Radius.large)
    }
}

// MARK: - Insights View
struct InsightsView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Insights")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ZStack {
                AppDesign.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppDesign.Spacing.lg) {
                        // Analytics Cards
                        analyticsSection
                        
                        // Recommendations
                        recommendationsSection
                        
                        // Trends
                        trendsSection
                    }
                    .padding(.bottom, 80)
                }
            }
        }
    }
    
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Analytics")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppDesign.Spacing.md) {
                StatCard(
                    title: "Health Score",
                    value: "85",
                    icon: "heart.fill",
                    color: AppDesign.Colors.success,
                    trend: "+5%"
                )
                StatCard(
                    title: "Consistency",
                    value: "92%",
                    icon: "chart.bar.fill",
                    color: AppDesign.Colors.primary,
                    trend: "+3%"
                )
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Recommendations")
            
            ModernCard {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                    RecommendationRow(
                        icon: "lightbulb.fill",
                        title: "Increase Water Intake",
                        description: "You're below your daily target",
                        color: AppDesign.Colors.primary
                    )
                    RecommendationRow(
                        icon: "moon.fill",
                        title: "Improve Sleep Quality",
                        description: "Aim for 7-8 hours nightly",
                        color: AppDesign.Colors.secondary
                    )
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            SectionHeader("Trends")
            
            ModernCard {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                    TrendRow(title: "Exercise Frequency", trend: "↗ Improving", color: .green)
                    TrendRow(title: "Nutrition Balance", trend: "→ Stable", color: .blue)
                    TrendRow(title: "Sleep Quality", trend: "↘ Declining", color: .orange)
                }
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
}

struct RecommendationRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.md) {
            IconBadge(icon: icon, color: color, size: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppDesign.Typography.headline)
                Text(description)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            Spacer()
        }
    }
}

struct TrendRow: View {
    let title: String
    let trend: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppDesign.Typography.body)
            Spacer()
            Text(trend)
                .font(AppDesign.Typography.subheadline)
                .foregroundColor(color)
        }
    }
}
