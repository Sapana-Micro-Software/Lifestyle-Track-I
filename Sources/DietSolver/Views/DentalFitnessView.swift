//
//  DentalFitnessView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

// MARK: - Dental Fitness View
struct DentalFitnessView: View { // Define DentalFitnessView struct conforming to View protocol
    let dentalFitness: HealthData.DentalFitness // Dental fitness data to display
    
    var body: some View { // Define body property returning view hierarchy
        ScrollView { // Create scrollable view container
            VStack(spacing: AppDesign.Spacing.lg) { // Create vertical stack with large spacing
                // Header Card
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                        HStack {
                            Image(systemName: "tooth")
                                .font(.system(size: 32))
                                .foregroundColor(AppDesign.Colors.primary)
                            Text("Dental Fitness")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("Daily dental hygiene routine tracking")
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.md) {
                    DentalMetricCard(
                        title: "Teeth Brushing",
                        value: "\(dentalFitness.dailyTeethScrubs)",
                        unit: "times/day",
                        icon: "tooth.fill",
                        color: AppDesign.Colors.primary
                    )
                    
                    DentalMetricCard(
                        title: "Flossing",
                        value: "\(dentalFitness.dailyFlossingCount)",
                        unit: "times/day",
                        icon: "line.3.horizontal",
                        color: AppDesign.Colors.secondary
                    )
                    
                    DentalMetricCard(
                        title: "Mouthwash",
                        value: "\(dentalFitness.dailyMouthwashCleans)",
                        unit: "times/day",
                        icon: "drop.fill",
                        color: AppDesign.Colors.accent
                    )
                    
                    DentalMetricCard(
                        title: "Tongue Scraping",
                        value: "\(dentalFitness.dailyTongueScrapes)",
                        unit: "times/day",
                        icon: "mouth",
                        color: AppDesign.Colors.accent
                    )
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Additional Information
                if !dentalFitness.dentalConcerns.isEmpty || !dentalFitness.dentalMedications.isEmpty {
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                            if !dentalFitness.dentalConcerns.isEmpty {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(AppDesign.Colors.warning)
                                        Text("Dental Concerns")
                                            .font(AppDesign.Typography.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    ForEach(dentalFitness.dentalConcerns, id: \.self) { concern in
                                        Text("• \(concern)")
                                            .font(AppDesign.Typography.body)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                }
                            }
                            
                            if !dentalFitness.dentalMedications.isEmpty {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                                    HStack {
                                        Image(systemName: "pills.fill")
                                            .foregroundColor(AppDesign.Colors.primary)
                                        Text("Dental Medications")
                                            .font(AppDesign.Typography.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    ForEach(dentalFitness.dentalMedications, id: \.self) { medication in
                                        Text("• \(medication)")
                                            .font(AppDesign.Typography.body)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.vertical, AppDesign.Spacing.lg)
        }
        .background(AppDesign.Colors.background)
    }
}

// MARK: - Dental Metric Card
struct DentalMetricCard: View { // Define DentalMetricCard struct for individual metric display
    let title: String // Metric title
    let value: String // Metric value
    let unit: String // Metric unit
    let icon: String // Icon name
    let color: Color // Card color
    
    var body: some View { // Define body property returning view hierarchy
        ModernCard {
            VStack(spacing: AppDesign.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(value)
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                
                Text(unit)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                
                Text(title)
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(AppDesign.Spacing.md)
        }
    }
}
