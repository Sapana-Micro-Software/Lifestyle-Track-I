//
//  TactileCheckView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct TactileCheckView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var testType: DailyTactileTest.TestType = .quick
    @State private var bodyRegion: TactilePrescription.BodyRegionAssessment.BodyRegion = .fingertips
    @State private var device: DailyTactileTest.TestDevice = .manual
    @State private var pressureSensitivity: Double = 0.8
    @State private var vibrationSensitivity: Double = 0.8
    @State private var numbness: DailyTactileTest.TestResults.NumbnessLevel? = nil
    @State private var painLevel: DailyTactileTest.TestResults.PainSensitivity.PainLevel = .none
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Test Information")) {
                    Picker("Test Type", selection: $testType) {
                        ForEach(DailyTactileTest.TestType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Body Region", selection: $bodyRegion) {
                        ForEach(TactilePrescription.BodyRegionAssessment.BodyRegion.allCases, id: \.self) { region in
                            Text(region.rawValue).tag(region)
                        }
                    }
                    
                    Picker("Device", selection: $device) {
                        ForEach(DailyTactileTest.TestDevice.allCases, id: \.self) { device in
                            Text(device.rawValue).tag(device)
                        }
                    }
                }
                
                Section(header: Text("Sensitivity")) {
                    Stepper("Pressure: \(String(format: "%.2f", pressureSensitivity))", value: $pressureSensitivity, in: 0...1, step: 0.1)
                    Stepper("Vibration: \(String(format: "%.2f", vibrationSensitivity))", value: $vibrationSensitivity, in: 0...1, step: 0.1)
                }
                
                Section(header: Text("Symptoms")) {
                    Picker("Numbness", selection: Binding(
                        get: { numbness ?? DailyTactileTest.TestResults.NumbnessLevel.none },
                        set: { numbness = $0 == DailyTactileTest.TestResults.NumbnessLevel.none ? nil : $0 }
                    )) {
                        Text("None").tag(DailyTactileTest.TestResults.NumbnessLevel.none)
                        ForEach([DailyTactileTest.TestResults.NumbnessLevel.mild, .moderate, .severe, .complete], id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Pain Level", selection: $painLevel) {
                        ForEach(DailyTactileTest.TestResults.PainSensitivity.PainLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Tactile Test") {
                        saveTest()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Tactile Test")
        }
    }
    
    private func saveTest() {
        var test = DailyTactileTest(
            date: Date(),
            time: Date(),
            testType: testType,
            bodyRegion: bodyRegion,
            device: device
        )
        
        test.results.pressureSensitivity = pressureSensitivity
        test.results.vibrationSensitivity = vibrationSensitivity
        test.results.numbness = numbness
        
        if painLevel != .none {
            test.results.painSensitivity = DailyTactileTest.TestResults.PainSensitivity(
                level: painLevel,
                location: nil,
                duration: nil
            )
        }
        
        test.notes = notes.isEmpty ? nil : notes
        
        if var healthData = viewModel.healthData {
            healthData.dailyTactileTests.append(test)
            viewModel.healthData = healthData
        }
    }
}
