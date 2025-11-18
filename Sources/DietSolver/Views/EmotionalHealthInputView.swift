//
//  EmotionalHealthInputView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct EmotionalHealthInputView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var moodScore: Double = 70.0
    @State private var stressLevel: EmotionalHealth.StressLevel = .moderate
    @State private var anxietyLevel: EmotionalHealth.AnxietyLevel = .none
    @State private var happinessLevel: EmotionalHealth.HappinessLevel = .moderate
    @State private var energyLevel: EmotionalHealth.EnergyLevel = .moderate
    @State private var socialConnection: EmotionalHealth.SocialConnection = .moderate
    @State private var emotionalTriggers: [EmotionalHealth.EmotionalTrigger] = []
    @State private var copingStrategies: [EmotionalHealth.CopingStrategy] = []
    @State private var currentTrigger: TriggerInput = TriggerInput()
    @State private var currentStrategy: StrategyInput = StrategyInput()
    @State private var notes: String = ""
    
    struct TriggerInput {
        var trigger: String = ""
        var intensity: Double = 50.0
        var category: EmotionalHealth.EmotionalTrigger.TriggerCategory = .other
    }
    
    struct StrategyInput {
        var strategy: String = ""
        var effectiveness: Double = 50.0
        var category: EmotionalHealth.CopingStrategy.StrategyCategory = .other
    }
    
    private var overallScore: Double {
        var score = moodScore * 0.3
        score += (100.0 - stressLevel.score) * 0.2
        score += (100.0 - anxietyLevel.score) * 0.2
        score += happinessLevel.score * 0.15
        score += energyLevel.score * 0.1
        score += socialConnection.score * 0.05
        return min(max(score, 0.0), 100.0)
    }
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Header with Score
                    ModernCard(shadow: AppDesign.Shadow.medium) {
                        VStack(spacing: AppDesign.Spacing.md) {
                            IconBadge(icon: "heart.circle.fill", color: AppDesign.Colors.accent, size: 60)
                            Text("Emotional Health")
                                .font(AppDesign.Typography.title2)
                            
                            ProgressRing(progress: overallScore / 100.0, color: scoreColor, size: 80)
                            
                            Text("Overall Score: \(Int(overallScore))")
                                .font(AppDesign.Typography.headline)
                                .foregroundColor(scoreColor)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.top, AppDesign.Spacing.lg)
                    
                    // Mood Score
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                Text("Mood Score")
                                    .font(AppDesign.Typography.subheadline)
                                Spacer()
                                Text("\(Int(moodScore))")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.primary)
                            }
                            Slider(value: $moodScore, in: 0...100, step: 1)
                                .tint(AppDesign.Colors.primary)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Stress and Anxiety
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Stress Level")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: $stressLevel) {
                                    ForEach(EmotionalHealth.StressLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Anxiety Level")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: $anxietyLevel) {
                                    ForEach(EmotionalHealth.AnxietyLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Happiness and Energy
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Happiness Level")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: $happinessLevel) {
                                    ForEach(EmotionalHealth.HappinessLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Energy Level")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: $energyLevel) {
                                    ForEach(EmotionalHealth.EnergyLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                Text("Social Connection")
                                    .font(AppDesign.Typography.subheadline)
                                Picker("", selection: $socialConnection) {
                                    ForEach(EmotionalHealth.SocialConnection.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Emotional Triggers
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                            Text("Emotional Triggers")
                                .font(AppDesign.Typography.headline)
                            
                            VStack(spacing: AppDesign.Spacing.sm) {
                                TextField("Trigger description", text: $currentTrigger.trigger)
                                    .textFieldStyle(.roundedBorder)
                                
                                HStack {
                                    Text("Intensity: \(Int(currentTrigger.intensity))")
                                    Spacer()
                                    Slider(value: $currentTrigger.intensity, in: 0...100, step: 1)
                                        .frame(width: 150)
                                }
                                
                                Picker("Category", selection: $currentTrigger.category) {
                                    ForEach(EmotionalHealth.EmotionalTrigger.TriggerCategory.allCases, id: \.self) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                
                                Button(action: addTrigger) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Trigger")
                                    }
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppDesign.Spacing.sm)
                                    .background(AppDesign.Colors.accent)
                                    .cornerRadius(AppDesign.Radius.medium)
                                }
                            }
                            
                            if !emotionalTriggers.isEmpty {
                                Divider()
                                ForEach(emotionalTriggers) { trigger in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(trigger.trigger)
                                                .font(AppDesign.Typography.body)
                                            Text("\(trigger.category.rawValue) • Intensity: \(Int(trigger.intensity))")
                                                .font(AppDesign.Typography.caption)
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        Spacer()
                                        Button(action: { removeTrigger(trigger) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Coping Strategies
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                            Text("Coping Strategies")
                                .font(AppDesign.Typography.headline)
                            
                            VStack(spacing: AppDesign.Spacing.sm) {
                                TextField("Strategy description", text: $currentStrategy.strategy)
                                    .textFieldStyle(.roundedBorder)
                                
                                HStack {
                                    Text("Effectiveness: \(Int(currentStrategy.effectiveness))")
                                    Spacer()
                                    Slider(value: $currentStrategy.effectiveness, in: 0...100, step: 1)
                                        .frame(width: 150)
                                }
                                
                                Picker("Category", selection: $currentStrategy.category) {
                                    ForEach(EmotionalHealth.CopingStrategy.StrategyCategory.allCases, id: \.self) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                
                                Button(action: addStrategy) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Strategy")
                                    }
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppDesign.Spacing.sm)
                                    .background(AppDesign.Colors.secondary)
                                    .cornerRadius(AppDesign.Radius.medium)
                                }
                            }
                            
                            if !copingStrategies.isEmpty {
                                Divider()
                                ForEach(copingStrategies) { strategy in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(strategy.strategy)
                                                .font(AppDesign.Typography.body)
                                            Text("\(strategy.category.rawValue) • Effectiveness: \(Int(strategy.effectiveness))")
                                                .font(AppDesign.Typography.caption)
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        Spacer()
                                        Button(action: { removeStrategy(strategy) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Notes
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            Text("Notes")
                                .font(AppDesign.Typography.subheadline)
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Radius.small)
                                        .stroke(AppDesign.Colors.primary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Save Button
                    GradientButton(
                        title: "Save Emotional Health",
                        icon: "checkmark.circle.fill",
                        action: saveEmotionalHealth
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.bottom, AppDesign.Spacing.xl)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Text("Emotional Health")
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
        }
    }
    
    private var scoreColor: Color {
        if overallScore >= 80 {
            return AppDesign.Colors.success
        } else if overallScore >= 60 {
            return AppDesign.Colors.secondary
        } else if overallScore >= 40 {
            return AppDesign.Colors.warning
        } else {
            return AppDesign.Colors.error
        }
    }
    
    private func addTrigger() {
        guard !currentTrigger.trigger.isEmpty else { return }
        let trigger = EmotionalHealth.EmotionalTrigger(
            trigger: currentTrigger.trigger,
            intensity: currentTrigger.intensity,
            category: currentTrigger.category
        )
        emotionalTriggers.append(trigger)
        currentTrigger = TriggerInput()
    }
    
    private func removeTrigger(_ trigger: EmotionalHealth.EmotionalTrigger) {
        emotionalTriggers.removeAll { $0.id == trigger.id }
    }
    
    private func addStrategy() {
        guard !currentStrategy.strategy.isEmpty else { return }
        let strategy = EmotionalHealth.CopingStrategy(
            strategy: currentStrategy.strategy,
            effectiveness: currentStrategy.effectiveness,
            category: currentStrategy.category
        )
        copingStrategies.append(strategy)
        currentStrategy = StrategyInput()
    }
    
    private func removeStrategy(_ strategy: EmotionalHealth.CopingStrategy) {
        copingStrategies.removeAll { $0.id == strategy.id }
    }
    
    private func saveEmotionalHealth() {
        let emotionalState: EmotionalHealth.EmotionalState = {
            if overallScore >= 80 { return .excellent }
            else if overallScore >= 60 { return .good }
            else if overallScore >= 40 { return .fair }
            else if overallScore >= 20 { return .poor }
            else { return .critical }
        }()
        
        let entry = EmotionalHealth(
            date: Date(),
            emotionalState: emotionalState,
            moodScore: moodScore,
            stressLevel: stressLevel,
            anxietyLevel: anxietyLevel,
            happinessLevel: happinessLevel,
            energyLevel: energyLevel,
            socialConnection: socialConnection,
            emotionalTriggers: emotionalTriggers,
            copingStrategies: copingStrategies,
            notes: notes.isEmpty ? nil : notes
        )
        
        // Create health data if it doesn't exist (for fake data testing)
        var healthData = viewModel.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate)
        healthData.emotionalHealth.append(entry)
        viewModel.updateHealthData(healthData)
        dismiss()
    }
}
