//
//  tvOSView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

#if os(tvOS)
// MARK: - tvOS Specific Views
struct tvOSContentView: View {
    @StateObject private var controller = DietSolverController()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            tvOSHomeView(controller: controller)
                .tag(0)
            
            tvOSBadgesView(controller: controller)
                .tag(1)
            
            tvOSHealthView(controller: controller)
                .tag(2)
        }
    }
}

struct tvOSHomeView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 40) {
                if let plan = controller.dietPlan {
                    tvOSStatCard(title: "Meals", value: "\(plan.meals.count)", icon: "fork.knife", color: .blue)
                    tvOSStatCard(title: "Calories", value: "\(Int(plan.totalNutrients.calories))", icon: "flame.fill", color: .orange)
                    tvOSStatCard(title: "Taste", value: String(format: "%.1f", plan.overallTasteScore), icon: "star.fill", color: .yellow)
                }
            }
            .padding(40)
        }
        .navigationTitle("Home")
    }
}

struct tvOSStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 48, weight: .bold))
            Text(title)
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(width: 300, height: 300)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
        .focusable()
    }
}

struct tvOSBadgesView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 40) {
                ForEach(controller.getEarnedBadges().prefix(9)) { badge in
                    tvOSBadgeCard(badge: badge)
                }
            }
            .padding(40)
        }
        .navigationTitle("Badges")
    }
}

struct tvOSBadgeCard: View {
    let badge: HealthBadge
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: badge.icon)
                .font(.system(size: 60))
                .foregroundColor(Color(hex: badge.colorHex) ?? .blue)
            Text(badge.name)
                .font(.title2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(badge.level.rawValue)
                .font(.headline)
                .foregroundColor(Color(hex: badge.colorHex) ?? .blue)
        }
        .frame(width: 300, height: 300)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
        .focusable()
    }
}

struct tvOSHealthView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 40) {
                if let healthData = controller.healthData {
                    tvOSStatCard(title: "Age", value: "\(healthData.age)", icon: "person.fill", color: .green)
                    tvOSStatCard(title: "Weight", value: String(format: "%.1f kg", healthData.weight), icon: "scalemass.fill", color: .blue)
                }
            }
            .padding(40)
        }
        .navigationTitle("Health")
    }
}
#endif
