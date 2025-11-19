//
//  EmotionRegulationView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct EmotionRegulationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTechnique: EmotionRegulationTechnique?
    @State private var emotionBefore: String = ""
    @State private var intensityBefore: Double = 0.5
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Emotion Regulation")
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
                    Text("Choose a technique to help regulate your emotions")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .padding(.horizontal, AppDesign.Spacing.md)
                    
                    VStack(spacing: AppDesign.Spacing.md) {
                        ForEach(EmotionRegulationTechnique.allCases, id: \.self) { technique in
                            Button(action: { selectedTechnique = technique }) {
                                ModernCard {
                                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                        HStack {
                                            Text(technique.title)
                                                .font(AppDesign.Typography.headline)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        
                                        Text(technique.description)
                                            .font(AppDesign.Typography.caption)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                        
                                        HStack {
                                            Label("\(Int(technique.duration / 60)) min", systemImage: "clock")
                                            Spacer()
                                            Text("Best for: \(technique.bestFor.joined(separator: ", "))")
                                        }
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                    .padding(AppDesign.Spacing.md)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.vertical, AppDesign.Spacing.lg)
            }
        }
        .background(AppDesign.Colors.background)
        .sheet(item: $selectedTechnique) { technique in
            EmotionRegulationTechniqueView(technique: technique)
        }
    }
}

// MARK: - Emotion Regulation Technique View
struct EmotionRegulationTechniqueView: View {
    let technique: EmotionRegulationTechnique
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: Int = 0
    @State private var isCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppDesign.Spacing.lg) {
                // Progress
                ProgressView(value: Double(currentStep), total: Double(technique.steps.count))
                    .padding(.horizontal, AppDesign.Spacing.md)
                
                // Current Step
                VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                    Text("Step \(currentStep + 1) of \(technique.steps.count)")
                        .font(AppDesign.Typography.headline)
                    
                    Text(technique.steps[currentStep])
                        .font(AppDesign.Typography.body)
                        .padding(AppDesign.Spacing.md)
                        .background(AppDesign.Colors.surface)
                        .cornerRadius(AppDesign.Radius.medium)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: AppDesign.Spacing.md) {
                    if currentStep > 0 {
                        Button("Previous") {
                            currentStep -= 1
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStep < technique.steps.count - 1 {
                        Button("Next") {
                            currentStep += 1
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Complete") {
                            isCompleted = true
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .navigationTitle(technique.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
