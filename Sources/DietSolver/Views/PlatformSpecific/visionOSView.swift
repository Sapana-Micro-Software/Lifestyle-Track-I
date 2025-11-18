//
//  visionOSView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

#if os(visionOS)
// MARK: - visionOS Specific Views
struct visionOSContentView: View {
    @StateObject private var controller = DietSolverController()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            visionOSHomeView(controller: controller)
                .tag(0)
            
            visionOSBadgesView(controller: controller)
                .tag(1)
            
            visionOSHealthView(controller: controller)
                .tag(2)
        }
        .padding(20)
    }
}

struct visionOSHomeView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                if let plan = controller.dietPlan {
                    visionOSStatCard(title: "Meals", value: "\(plan.meals.count)", icon: "fork.knife", color: AppDesign.Colors.primary)
                    visionOSStatCard(title: "Calories", value: "\(Int(plan.totalNutrients.calories))", icon: "flame.fill", color: AppDesign.Colors.accent)
                }
                
                ForEach(controller.getEarnedBadges().prefix(4)) { badge in
                    visionOSBadgeCard(badge: badge)
                }
            }
            .padding(20)
        }
        .navigationTitle("Home")
    }
}

struct visionOSStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        ModernCard(shadow: AppDesign.Shadow.large) {
            VStack(spacing: AppDesign.Spacing.md) {
                IconBadge(icon: icon, color: color, size: 60)
                Text(value)
                    .font(AppDesign.Typography.largeTitle)
                Text(title)
                    .font(AppDesign.Typography.body)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
    }
}

struct visionOSBadgesView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(controller.getEarnedBadges()) { badge in
                    visionOSBadgeCard(badge: badge)
                }
            }
            .padding(20)
        }
        .navigationTitle("Badges")
    }
}

struct visionOSBadgeCard: View {
    let badge: HealthBadge
    
    var body: some View {
        ModernCard(shadow: AppDesign.Shadow.large) {
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
                
                Text(badge.level.rawValue)
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
            }
        }
    }
}

struct visionOSHealthView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                if let healthData = controller.healthData {
                    visionOSStatCard(title: "Age", value: "\(healthData.age)", icon: "person.fill", color: AppDesign.Colors.primary)
                    visionOSStatCard(title: "Weight", value: String(format: "%.1f kg", healthData.weight), icon: "scalemass.fill", color: AppDesign.Colors.secondary)
                }
            }
            .padding(20)
        }
        .navigationTitle("Health")
    }
}
#endif
