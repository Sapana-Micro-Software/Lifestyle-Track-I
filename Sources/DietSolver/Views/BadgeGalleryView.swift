//
//  BadgeGalleryView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct BadgeGalleryView: View {
    @ObservedObject var controller: DietSolverController
    @State private var selectedCategory: HealthBadge.BadgeCategory? = nil
    @State private var selectedBadge: HealthBadge? = nil
    @State private var showCertificate: HealthCertificate? = nil
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Summary Stats
                    summarySection
                    
                    // Category Filter
                    categoryFilter
                    
                    // Badges Grid
                    badgesGrid
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        .navigationTitle("Badge Gallery")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .sheet(item: $selectedBadge) { badge in
            if badge.level.requiresCertificate, let certificate = getCertificate(for: badge) {
                NavigationView {
                    CertificateView(certificate: certificate)
                }
            } else {
                NavigationView {
                    BadgeDetailView(badge: badge, controller: controller)
                }
            }
        }
    }
    
    private var summarySection: some View {
        ModernCard(shadow: AppDesign.Shadow.medium) {
            HStack(spacing: AppDesign.Spacing.lg) {
                VStack {
                    Text("\(controller.getEarnedBadges().count)")
                        .font(AppDesign.Typography.largeTitle)
                        .foregroundColor(AppDesign.Colors.primary)
                    Text("Earned")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                Divider()
                VStack {
                    Text("\(controller.badges.count)")
                        .font(AppDesign.Typography.largeTitle)
                        .foregroundColor(AppDesign.Colors.secondary)
                    Text("Total")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                Divider()
                VStack {
                    Text("\(masterBadgesCount)")
                        .font(AppDesign.Typography.largeTitle)
                        .foregroundColor(AppDesign.Colors.accent)
                    Text("Master")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            .padding(.vertical, AppDesign.Spacing.sm)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.top, AppDesign.Spacing.lg)
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
    
    private var badgesGrid: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: AppDesign.Spacing.md) {
            ForEach(filteredBadges) { badge in
                BadgeCard(badge: badge) {
                    selectedBadge = badge
                }
            }
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    private var filteredBadges: [HealthBadge] {
        let badges = selectedCategory == nil ? controller.badges : controller.badges.filter { $0.category == selectedCategory }
        return badges.sorted { badge1, badge2 in
            // Sort: earned first, then by level, then by name
            if badge1.isEarned != badge2.isEarned {
                return badge1.isEarned
            }
            if badge1.level.multiplier != badge2.level.multiplier {
                return badge1.level.multiplier > badge2.level.multiplier
            }
            return badge1.name < badge2.name
        }
    }
    
    private var masterBadgesCount: Int {
        controller.getEarnedBadges().filter { $0.level.requiresCertificate }.count
    }
    
    private func getCertificate(for badge: HealthBadge) -> HealthCertificate? {
        // In a real implementation, fetch from CertificateManager
        return nil
    }
}

struct BadgeCard: View {
    let badge: HealthBadge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ModernCard(shadow: badge.isEarned ? AppDesign.Shadow.medium : AppDesign.Shadow.small) {
                VStack(spacing: AppDesign.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: badge.colorHex)?.opacity(badge.isEarned ? 0.2 : 0.1) ?? AppDesign.Colors.primary.opacity(0.1))
                            .frame(width: 70, height: 70)
                        Image(systemName: badge.icon)
                            .font(.system(size: 35))
                            .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                            .opacity(badge.isEarned ? 1.0 : 0.5)
                    }
                    
                    Text(badge.name)
                        .font(AppDesign.Typography.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    
                    Text(badge.level.rawValue)
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                        .padding(.horizontal, AppDesign.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Color(hex: badge.colorHex)?.opacity(0.1) ?? AppDesign.Colors.primary.opacity(0.1))
                        .cornerRadius(AppDesign.Radius.medium)
                    
                    ProgressRing(progress: badge.progress, color: Color(hex: badge.colorHex) ?? AppDesign.Colors.primary, size: 50)
                    
                    Text(badge.displayProgress)
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    
                    if badge.isEarned {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppDesign.Colors.success)
                            Text("Earned")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.success)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BadgeDetailView: View {
    let badge: HealthBadge
    @ObservedObject var controller: DietSolverController
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Badge Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: badge.colorHex)?.opacity(0.2) ?? AppDesign.Colors.primary.opacity(0.2))
                            .frame(width: 120, height: 120)
                        Image(systemName: badge.icon)
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                    }
                    .padding(.top, AppDesign.Spacing.xl)
                    
                    // Badge Info
                    ModernCard(shadow: AppDesign.Shadow.medium) {
                        VStack(spacing: AppDesign.Spacing.md) {
                            Text(badge.name)
                                .font(AppDesign.Typography.title)
                                .multilineTextAlignment(.center)
                            
                            Text(badge.level.rawValue)
                                .font(AppDesign.Typography.headline)
                                .foregroundColor(Color(hex: badge.colorHex) ?? AppDesign.Colors.primary)
                                .padding(.horizontal, AppDesign.Spacing.md)
                                .padding(.vertical, AppDesign.Spacing.sm)
                                .background(Color(hex: badge.colorHex)?.opacity(0.1) ?? AppDesign.Colors.primary.opacity(0.1))
                                .cornerRadius(AppDesign.Radius.medium)
                            
                            Text(badge.description)
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Divider()
                            
                            // Progress
                            VStack(spacing: AppDesign.Spacing.sm) {
                                ProgressRing(progress: badge.progress, color: Color(hex: badge.colorHex) ?? AppDesign.Colors.primary, size: 80)
                                Text(badge.displayProgress)
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                            }
                            
                            if let earnedDate = badge.earnedDate {
                                Divider()
                                VStack(spacing: AppDesign.Spacing.xs) {
                                    Text("Earned on")
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                    Text(formatDate(earnedDate))
                                        .font(AppDesign.Typography.subheadline)
                                }
                            }
                            
                            // Criteria
                            Divider()
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Requirements")
                                    .font(AppDesign.Typography.headline)
                                Text("Type: \(badge.criteria.type.rawValue)")
                                    .font(AppDesign.Typography.body)
                                Text("Target: \(String(format: "%.1f", badge.criteria.target))")
                                    .font(AppDesign.Typography.body)
                                if let duration = badge.criteria.duration {
                                    Text("Duration: \(duration) days")
                                        .font(AppDesign.Typography.body)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        .navigationTitle("Badge Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
