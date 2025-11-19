//
//  watchOSView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

#if os(watchOS)
// MARK: - watchOS Specific Views
struct watchOSContentView: View {
    @StateObject private var controller = DietSolverController()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            watchOSHomeView(controller: controller)
                .tag(0)
            
            watchOSBadgesView(controller: controller)
                .tag(1)
            
            watchOSHealthView(controller: controller)
                .tag(2)
        }
    }
}

struct watchOSHomeView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let plan = controller.dietPlan {
                    VStack {
                        Text("\(plan.meals.count)")
                            .font(.title)
                        Text("Meals")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    
                    VStack {
                        Text("\(Int(plan.totalNutrients.calories))")
                            .font(.title)
                        Text("Calories")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Home")
    }
}

struct watchOSBadgesView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(controller.getEarnedBadges().prefix(5)) { badge in
                    watchOSBadgeCard(badge: badge)
                }
            }
            .padding()
        }
        .navigationTitle("Badges")
    }
}

struct watchOSBadgeCard: View {
    let badge: HealthBadge
    
    var body: some View {
        HStack {
            Image(systemName: badge.icon.isEmpty ? "star.fill" : badge.icon)
                .foregroundColor(Color(hex: badge.colorHex) ?? .blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .font(.caption)
                    .lineLimit(1)
                Text(badge.level.rawValue)
                    .font(.caption2)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct watchOSHealthView: View {
    @ObservedObject var controller: DietSolverController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let healthData = controller.healthData {
                    VStack {
                        Text("\(healthData.age)")
                            .font(.title2)
                        Text("Age")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    
                    VStack {
                        Text(String(format: "%.1f", healthData.weight))
                            .font(.title2)
                        Text("kg")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Health")
    }
}
#endif
