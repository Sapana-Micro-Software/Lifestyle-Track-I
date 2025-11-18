//
//  HearingCheckView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct HearingCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    var body: some View {
        ModernHearingCheckView(viewModel: viewModel)
    }
}

struct LegacyHearingCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    @State private var testType: DailyAudioHearingTest.TestType = .quick
    @State private var device: DailyAudioHearingTest.TestDevice = .iphone
    @State private var rightEarThreshold: Double = 20.0
    @State private var leftEarThreshold: Double = 20.0
    @State private var tinnitusPresence: Bool = false
    @State private var tinnitusSeverity: DailyAudioHearingTest.EarTest.TinnitusSeverity = .mild
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Hearing Test")
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
            
            Form {
                Section(header: Text("Test Information")) {
                    Picker("Test Type", selection: $testType) {
                        ForEach(DailyAudioHearingTest.TestType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Device", selection: $device) {
                        ForEach(DailyAudioHearingTest.TestDevice.allCases, id: \.self) { device in
                            Text(device.rawValue).tag(device)
                        }
                    }
                }
                
                Section(header: Text("Right Ear")) {
                    Stepper("Threshold: \(Int(rightEarThreshold)) dB HL", value: $rightEarThreshold, in: 0...100, step: 5)
                }
                
                Section(header: Text("Left Ear")) {
                    Stepper("Threshold: \(Int(leftEarThreshold)) dB HL", value: $leftEarThreshold, in: 0...100, step: 5)
                }
                
                Section(header: Text("Tinnitus")) {
                    Toggle("Tinnitus Present", isOn: $tinnitusPresence)
                    
                    if tinnitusPresence {
                        Picker("Severity", selection: $tinnitusSeverity) {
                            ForEach(DailyAudioHearingTest.EarTest.TinnitusSeverity.allCases, id: \.self) { severity in
                                Text(severity.rawValue).tag(severity)
                            }
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Hearing Test") {
                        saveTest()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func saveTest() {
        var test = DailyAudioHearingTest(
            date: Date(),
            time: Date(),
            testType: testType,
            device: device
        )
        
        // Set thresholds
        test.rightEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 1000,
                threshold: rightEarThreshold,
                ear: .right
            )
        ]
        
        test.leftEar.pureToneThresholds = [
            DailyAudioHearingTest.EarTest.FrequencyThreshold(
                frequency: 1000,
                threshold: leftEarThreshold,
                ear: .left
            )
        ]
        
        // Set tinnitus
        test.rightEar.tinnitusPresence = tinnitusPresence
        test.leftEar.tinnitusPresence = tinnitusPresence
        if tinnitusPresence {
            test.rightEar.tinnitusSeverity = tinnitusSeverity
            test.leftEar.tinnitusSeverity = tinnitusSeverity
        }
        
        test.notes = notes.isEmpty ? nil : notes
        
        // Create health data if it doesn't exist (for fake data testing)
        var healthData = viewModel.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate)
        healthData.dailyAudioHearingTests.append(test)
        viewModel.updateHealthData(healthData)
        dismiss()
    }
}
