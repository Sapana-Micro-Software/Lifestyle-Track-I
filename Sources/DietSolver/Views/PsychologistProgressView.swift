//
//  PsychologistProgressView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct PsychologistProgressView: View {
    @StateObject private var chatbotManager = PsychologistChatbotManager.shared
    private let progressTracker = PsychologistProgressTracker.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Therapy Progress")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.primary)
                .padding(.trailing, AppDesign.Spacing.md)
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Progress Metrics
                    progressMetricsSection
                    
                    // Goals
                    goalsSection
                    
                    // Emotional Patterns
                    patternsSection
                    
                    // Session History
                    sessionHistorySection
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.vertical, AppDesign.Spacing.lg)
            }
        }
        .background(AppDesign.Colors.background)
        .onAppear {
            updateProgressMetrics()
        }
    }
    
    private var progressMetricsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Progress Overview")
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                
                let metrics = progressTracker.analyzeProgress(profile: chatbotManager.userProfile)
                
                ProgressMetricRow(
                    title: "Average Sentiment",
                    value: String(format: "%.1f", metrics.averageSentiment),
                    trend: metrics.sentimentTrend
                )
                
                ProgressMetricRow(
                    title: "Session Frequency",
                    value: String(format: "%.1f/week", metrics.sessionFrequency),
                    trend: nil
                )
                
                ProgressMetricRow(
                    title: "Engagement Score",
                    value: String(format: "%.0f%%", metrics.engagementScore * 100),
                    trend: nil
                )
                
                if !metrics.improvementAreas.isEmpty {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Areas for Improvement")
                            .font(AppDesign.Typography.headline)
                        ForEach(metrics.improvementAreas, id: \.self) { area in
                            Text("• \(area)")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                
                if !metrics.strengths.isEmpty {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Strengths")
                            .font(AppDesign.Typography.headline)
                        ForEach(metrics.strengths, id: \.self) { strength in
                            Text("• \(strength)")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.success)
                        }
                    }
                }
            }
            .padding(AppDesign.Spacing.md)
        }
    }
    
    private var goalsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Therapy Goals")
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                
                if chatbotManager.userProfile.goals.isEmpty {
                    Text("No goals set yet")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                } else {
                    ForEach(chatbotManager.userProfile.goals) { goal in
                        GoalProgressView(goal: goal)
                    }
                }
            }
            .padding(AppDesign.Spacing.md)
        }
    }
    
    private var patternsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Emotional Patterns")
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                
                if chatbotManager.userProfile.emotionalPatterns.isEmpty {
                    Text("No patterns identified yet")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                } else {
                    ForEach(chatbotManager.userProfile.emotionalPatterns) { pattern in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pattern.pattern)
                                .font(AppDesign.Typography.headline)
                            Text("Frequency: \(pattern.frequency) times")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            Text("Context: \(pattern.context)")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        .padding(.vertical, AppDesign.Spacing.sm)
                    }
                }
            }
            .padding(AppDesign.Spacing.md)
        }
    }
    
    private var sessionHistorySection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Session History")
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                
                if chatbotManager.userProfile.conversationHistory.isEmpty {
                    Text("No sessions yet")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                } else {
                    ForEach(chatbotManager.userProfile.conversationHistory.suffix(10)) { session in
                        SessionSummaryView(session: session)
                    }
                }
            }
            .padding(AppDesign.Spacing.md)
        }
    }
    
    private func updateProgressMetrics() {
        let metrics = progressTracker.analyzeProgress(profile: chatbotManager.userProfile)
        chatbotManager.userProfile.progressMetrics = metrics
    }
}

// MARK: - Progress Metric Row
struct ProgressMetricRow: View {
    let title: String
    let value: String
    let trend: PsychologistUserProfile.ProgressMetrics.SentimentTrend?
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppDesign.Typography.body)
            Spacer()
            Text(value)
                .font(AppDesign.Typography.headline)
            if let trend = trend {
                Text(trend.rawValue)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(trendColor(trend))
            }
        }
    }
    
    private func trendColor(_ trend: PsychologistUserProfile.ProgressMetrics.SentimentTrend) -> Color {
        switch trend {
        case .improving: return AppDesign.Colors.success
        case .declining: return AppDesign.Colors.error
        case .stable: return AppDesign.Colors.textSecondary
        case .fluctuating: return AppDesign.Colors.warning
        }
    }
}

// MARK: - Goal Progress View
struct GoalProgressView: View {
    let goal: PsychologistUserProfile.TherapyGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            HStack {
                Text(goal.goal)
                    .font(AppDesign.Typography.headline)
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(AppDesign.Colors.primary)
            }
            
            ProgressView(value: goal.progress)
                .tint(AppDesign.Colors.primary)
            
            if !goal.milestones.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(goal.milestones) { milestone in
                        HStack {
                            Image(systemName: milestone.achieved ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(milestone.achieved ? AppDesign.Colors.success : AppDesign.Colors.textSecondary)
                            Text(milestone.description)
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(milestone.achieved ? AppDesign.Colors.success : AppDesign.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, AppDesign.Spacing.sm)
    }
}

// MARK: - Session Summary View
struct SessionSummaryView: View {
    let session: ConversationSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
            HStack {
                Text(session.startDate, style: .date)
                    .font(AppDesign.Typography.headline)
                Spacer()
                if let avgSentiment = session.averageSentiment {
                    Text(String(format: "Sentiment: %.2f", avgSentiment))
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            
            if let summary = session.sessionSummary {
                if !summary.keyTopics.isEmpty {
                    Text("Topics: \(summary.keyTopics.joined(separator: ", "))")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            
            Text("\(session.messages.count) messages • \(Int(session.duration / 60)) min")
                .font(AppDesign.Typography.caption)
                .foregroundColor(AppDesign.Colors.textSecondary)
        }
        .padding(.vertical, AppDesign.Spacing.sm)
    }
}
