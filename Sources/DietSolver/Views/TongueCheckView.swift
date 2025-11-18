//
//  TongueCheckView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct TongueCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
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
        NavigationView {
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
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Tongue Test") {
                        saveTest()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Tongue Test")
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
        
        if var healthData = viewModel.healthData {
            healthData.dailyTongueTests.append(test)
            viewModel.healthData = healthData
        }
    }
}
