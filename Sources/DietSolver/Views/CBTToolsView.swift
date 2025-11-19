//
//  CBTToolsView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct CBTToolsView: View {
    @StateObject private var cbtManager = CBTToolsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTool: CBTToolType?
    
    enum CBTToolType: Identifiable {
        case thoughtRecord
        case behavioralExperiment
        
        var id: String {
            switch self {
            case .thoughtRecord: return "thoughtRecord"
            case .behavioralExperiment: return "behavioralExperiment"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("CBT Tools")
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
                    // Tool Cards
                    VStack(spacing: AppDesign.Spacing.md) {
                        Button(action: { selectedTool = .thoughtRecord }) {
                            ModernCard {
                                HStack {
                                    IconBadge(icon: "brain.head.profile", color: AppDesign.Colors.primary, size: 50)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Thought Record")
                                            .font(AppDesign.Typography.headline)
                                        Text("Challenge negative thoughts using CBT")
                                            .font(AppDesign.Typography.caption)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                                .padding(AppDesign.Spacing.md)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { selectedTool = .behavioralExperiment }) {
                            ModernCard {
                                HStack {
                                    IconBadge(icon: "flask.fill", color: AppDesign.Colors.secondary, size: 50)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Behavioral Experiment")
                                            .font(AppDesign.Typography.headline)
                                        Text("Test your thoughts through experiments")
                                            .font(AppDesign.Typography.caption)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                                .padding(AppDesign.Spacing.md)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
                .padding(.vertical, AppDesign.Spacing.lg)
            }
        }
        .background(AppDesign.Colors.background)
        .sheet(item: $selectedTool) { tool in
            switch tool {
            case .thoughtRecord:
                ThoughtRecordView()
            case .behavioralExperiment:
                BehavioralExperimentView()
            }
        }
    }
}

// MARK: - Thought Record View
struct ThoughtRecordView: View {
    @StateObject private var cbtManager = CBTToolsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var situation: String = ""
    @State private var automaticThought: String = ""
    @State private var emotions: [String] = []
    @State private var emotionIntensity: Double = 0.5
    @State private var evidenceFor: [String] = []
    @State private var evidenceAgainst: [String] = []
    @State private var cognitiveDistortions: [CBTThoughtRecord.CognitiveDistortion] = []
    @State private var balancedThought: String = ""
    @State private var outcome: String = ""
    @State private var outcomeIntensity: Double = 0.5
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDesign.Spacing.md) {
                    ModernInputField(title: "Situation", value: $situation, icon: "text.bubble", placeholder: "What happened?")
                    
                    ModernInputField(title: "Automatic Thought", value: $automaticThought, icon: "brain.head.profile", placeholder: "What thought came to mind?")
                        .onChange(of: automaticThought) { _ in
                            detectDistortions()
                        }
                    
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Emotion Intensity")
                            .font(AppDesign.Typography.headline)
                        Slider(value: $emotionIntensity, in: 0...1)
                        Text("\(Int(emotionIntensity * 100))%")
                            .font(AppDesign.Typography.caption)
                    }
                    
                    if !cognitiveDistortions.isEmpty {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            Text("Detected Cognitive Distortions")
                                .font(AppDesign.Typography.headline)
                            ForEach(cognitiveDistortions, id: \.self) { distortion in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading) {
                                        Text(distortion.rawValue)
                                            .font(AppDesign.Typography.body)
                                        Text(distortion.description)
                                            .font(AppDesign.Typography.caption)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                }
                                .padding(AppDesign.Spacing.sm)
                                .background(AppDesign.Colors.surface)
                                .cornerRadius(AppDesign.Radius.medium)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                        Text("Evidence For")
                            .font(AppDesign.Typography.headline)
                        TextEditor(text: Binding(
                            get: { evidenceFor.joined(separator: "\n") },
                            set: { evidenceFor = $0.components(separatedBy: "\n").filter { !$0.isEmpty } }
                        ))
                        .foregroundColor(.black)
                        .frame(height: 100)
                        .padding(AppDesign.Spacing.sm)
                        .background(AppDesign.Colors.surface)
                        .cornerRadius(AppDesign.Radius.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                        Text("Evidence Against")
                            .font(AppDesign.Typography.headline)
                        TextEditor(text: Binding(
                            get: { evidenceAgainst.joined(separator: "\n") },
                            set: { evidenceAgainst = $0.components(separatedBy: "\n").filter { !$0.isEmpty } }
                        ))
                        .foregroundColor(.black)
                        .frame(height: 100)
                        .padding(AppDesign.Spacing.sm)
                        .background(AppDesign.Colors.surface)
                        .cornerRadius(AppDesign.Radius.medium)
                    }
                    
                    ModernInputField(title: "Balanced Thought", value: $balancedThought, icon: "scale.3d", placeholder: "What's a more balanced way to think about this?")
                    
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Outcome Emotion Intensity")
                            .font(AppDesign.Typography.headline)
                        Slider(value: $outcomeIntensity, in: 0...1)
                        Text("\(Int(outcomeIntensity * 100))%")
                            .font(AppDesign.Typography.caption)
                    }
                    
                    ModernInputField(title: "Outcome", value: $outcome, icon: "checkmark.circle", placeholder: "How do you feel now?")
                    
                    Button("Save Thought Record") {
                        let record = CBTThoughtRecord(
                            situation: situation,
                            automaticThought: automaticThought,
                            emotions: emotions,
                            emotionIntensity: emotionIntensity,
                            evidenceFor: evidenceFor,
                            evidenceAgainst: evidenceAgainst,
                            cognitiveDistortions: cognitiveDistortions,
                            balancedThought: balancedThought.isEmpty ? nil : balancedThought,
                            outcome: outcome.isEmpty ? nil : outcome,
                            outcomeEmotionIntensity: outcomeIntensity
                        )
                        cbtManager.saveThoughtRecord(record)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, AppDesign.Spacing.md)
                }
                .padding(AppDesign.Spacing.md)
            }
            .navigationTitle("Thought Record")
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
    
    private func detectDistortions() {
        cognitiveDistortions = cbtManager.detectCognitiveDistortions(in: automaticThought)
    }
}

// MARK: - Behavioral Experiment View
struct BehavioralExperimentView: View {
    @StateObject private var cbtManager = CBTToolsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var prediction: String = ""
    @State private var experiment: String = ""
    @State private var actualOutcome: String = ""
    @State private var whatLearned: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDesign.Spacing.md) {
                    ModernInputField(title: "Prediction", value: $prediction, icon: "eye", placeholder: "What do you predict will happen?")
                    
                    ModernInputField(title: "Experiment", value: $experiment, icon: "flask.fill", placeholder: "What will you do to test this?")
                    
                    ModernInputField(title: "Actual Outcome", value: $actualOutcome, icon: "checkmark.circle.fill", placeholder: "What actually happened?")
                    
                    ModernInputField(title: "What I Learned", value: $whatLearned, icon: "lightbulb.fill", placeholder: "What did you learn from this experiment?")
                    
                    Button("Save Experiment") {
                        let experiment = BehavioralExperiment(
                            prediction: prediction,
                            experiment: experiment,
                            actualOutcome: actualOutcome.isEmpty ? nil : actualOutcome,
                            whatLearned: whatLearned.isEmpty ? nil : whatLearned,
                            completed: !actualOutcome.isEmpty
                        )
                        cbtManager.saveBehavioralExperiment(experiment)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, AppDesign.Spacing.md)
                }
                .padding(AppDesign.Spacing.md)
            }
            .navigationTitle("Behavioral Experiment")
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
