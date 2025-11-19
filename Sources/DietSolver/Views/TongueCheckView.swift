//
//  TongueCheckView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct TongueCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    var body: some View {
        ModernTongueCheckView(viewModel: viewModel)
    }
}

struct LegacyTongueCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    @State private var testType: DailyTongueTest.TestType = .quick
    @State private var device: DailyTongueTest.TestDevice = .mirror
    @State private var tongueColor: TonguePrescription.TongueAppearance.TongueColor = .pink
    @State private var coating: TonguePrescription.TongueAppearance.CoatingType = .none
    @State private var moisture: TonguePrescription.TongueAppearance.MoistureLevel = .normal
    @State private var painLevel: DailyTongueTest.Symptoms.PainLevel = .none
    @State private var tasteScore: Double = 0.8
    @State private var mobilityScore: Double = 0.8
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Tongue Test")
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
                        ForEach(DailyTongueTest.TestType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Device", selection: $device) {
                        ForEach(DailyTongueTest.TestDevice.allCases, id: \.self) { device in
                            Text(device.rawValue).tag(device)
                        }
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Color", selection: $tongueColor) {
                        ForEach(TonguePrescription.TongueAppearance.TongueColor.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    
                    Picker("Coating", selection: $coating) {
                        ForEach(TonguePrescription.TongueAppearance.CoatingType.allCases, id: \.self) { coating in
                            Text(coating.rawValue).tag(coating)
                        }
                    }
                    
                    Picker("Moisture", selection: $moisture) {
                        ForEach(TonguePrescription.TongueAppearance.MoistureLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section(header: Text("Symptoms")) {
                    Picker("Pain Level", selection: $painLevel) {
                        ForEach(DailyTongueTest.Symptoms.PainLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section(header: Text("Function")) {
                    Stepper("Taste Score: \(String(format: "%.2f", tasteScore))", value: $tasteScore, in: 0...1, step: 0.1)
                    Stepper("Mobility Score: \(String(format: "%.2f", mobilityScore))", value: $mobilityScore, in: 0...1, step: 0.1)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .foregroundColor(.black)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Tongue Test") {
                        saveTest()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func saveTest() {
        var test = DailyTongueTest(
            date: Date(),
            time: Date(),
            testType: testType,
            device: device
        )
        
        test.appearance.color = tongueColor
        test.appearance.coating = coating
        test.appearance.moisture = moisture
        test.symptoms.pain = painLevel
        
        test.tasteTest = DailyTongueTest.TasteTest(
            sweet: tasteScore,
            sour: tasteScore,
            salty: tasteScore,
            bitter: tasteScore,
            umami: tasteScore,
            overallScore: tasteScore
        )
        
        test.mobilityTest = DailyTongueTest.MobilityTest(
            rangeOfMotion: mobilityScore,
            strength: mobilityScore,
            coordination: mobilityScore,
            flexibility: mobilityScore,
            overallScore: mobilityScore
        )
        
        test.notes = notes.isEmpty ? nil : notes
        
        // Create health data if it doesn't exist (for fake data testing)
        var healthData = viewModel.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate)
        healthData.dailyTongueTests.append(test)
        viewModel.updateHealthData(healthData)
        dismiss()
    }
}
