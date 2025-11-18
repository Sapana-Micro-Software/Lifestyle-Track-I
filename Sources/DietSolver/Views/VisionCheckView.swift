//
//  VisionCheckView.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

struct VisionCheckView: View { // Define VisionCheckView struct conforming to View protocol
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    @State private var rightEyeAcuity: DailyVisionCheck.EyeCheck.VisualAcuity? // State for right eye acuity
    @State private var leftEyeAcuity: DailyVisionCheck.EyeCheck.VisualAcuity? // State for left eye acuity
    @State private var rightEyeStrain: DailyVisionCheck.EyeCheck.EyeStrainLevel = .none // State for right eye strain
    @State private var leftEyeStrain: DailyVisionCheck.EyeCheck.EyeStrainLevel = .none // State for left eye strain
    @State private var rightEyeDryness: DailyVisionCheck.EyeCheck.DrynessLevel = .none // State for right eye dryness
    @State private var leftEyeDryness: DailyVisionCheck.EyeCheck.DrynessLevel = .none // State for left eye dryness
    @State private var device: DailyVisionCheck.CheckDevice = .iphone // State for check device
    @State private var notes: String = "" // State for notes
    
    var body: some View { // Define body property returning view hierarchy
        NavigationView { // Create navigation view container
            Form { // Create form container
                Section(header: Text("Right Eye")) { // Create section for right eye
                    Picker("Visual Acuity", selection: $rightEyeAcuity) { // Create acuity picker
                        Text("Not Tested").tag(nil as DailyVisionCheck.EyeCheck.VisualAcuity?) // Not tested option
                        ForEach(DailyVisionCheck.EyeCheck.VisualAcuity.allCases, id: \.self) { acuity in // Loop through acuity levels
                            Text(acuity.rawValue).tag(acuity as DailyVisionCheck.EyeCheck.VisualAcuity?) // Acuity option
                        }
                    }
                    Picker("Eye Strain", selection: $rightEyeStrain) { // Create strain picker
                        ForEach(DailyVisionCheck.EyeCheck.EyeStrainLevel.allCases, id: \.self) { level in // Loop through strain levels
                            Text(level.rawValue).tag(level) // Strain level option
                        }
                    }
                    Picker("Dryness", selection: $rightEyeDryness) { // Create dryness picker
                        ForEach(DailyVisionCheck.EyeCheck.DrynessLevel.allCases, id: \.self) { level in // Loop through dryness levels
                            Text(level.rawValue).tag(level) // Dryness level option
                        }
                    }
                }
                
                Section(header: Text("Left Eye")) { // Create section for left eye
                    Picker("Visual Acuity", selection: $leftEyeAcuity) { // Create acuity picker
                        Text("Not Tested").tag(nil as DailyVisionCheck.EyeCheck.VisualAcuity?) // Not tested option
                        ForEach(DailyVisionCheck.EyeCheck.VisualAcuity.allCases, id: \.self) { acuity in // Loop through acuity levels
                            Text(acuity.rawValue).tag(acuity as DailyVisionCheck.EyeCheck.VisualAcuity?) // Acuity option
                        }
                    }
                    Picker("Eye Strain", selection: $leftEyeStrain) { // Create strain picker
                        ForEach(DailyVisionCheck.EyeCheck.EyeStrainLevel.allCases, id: \.self) { level in // Loop through strain levels
                            Text(level.rawValue).tag(level) // Strain level option
                        }
                    }
                    Picker("Dryness", selection: $leftEyeDryness) { // Create dryness picker
                        ForEach(DailyVisionCheck.EyeCheck.DrynessLevel.allCases, id: \.self) { level in // Loop through dryness levels
                            Text(level.rawValue).tag(level) // Dryness level option
                        }
                    }
                }
                
                Section(header: Text("Check Details")) { // Create section for check details
                    Picker("Device", selection: $device) { // Create device picker
                        ForEach(DailyVisionCheck.CheckDevice.allCases, id: \.self) { device in // Loop through devices
                            Text(device.rawValue).tag(device) // Device option
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical) // Create notes text field
                        .lineLimit(3...6) // Set line limit
                }
                
                Section { // Create section for save button
                    Button("Save Vision Check") { // Create save button
                        saveVisionCheck() // Call save function
                    }
                    .frame(maxWidth: .infinity) // Set frame to fill width
                }
            }
            .navigationTitle("Daily Vision Check") // Set navigation title
        }
    }
    
    private func saveVisionCheck() { // Private function to save vision check
        guard var healthData = viewModel.healthData else { return } // Check if health data exists
        
        let rightEye = DailyVisionCheck.EyeCheck( // Create right eye check
            visualAcuity: rightEyeAcuity, // Set visual acuity
            contrastSensitivity: nil, // Set contrast to nil
            colorVision: nil, // Set color vision to nil
            depthPerception: nil, // Set depth perception to nil
            peripheralVision: nil, // Set peripheral vision to nil
            eyeStrain: rightEyeStrain, // Set eye strain
            dryness: rightEyeDryness, // Set dryness
            redness: DailyVisionCheck.EyeCheck.RednessLevel.none // Set redness to none
        )
        
        let leftEye = DailyVisionCheck.EyeCheck( // Create left eye check
            visualAcuity: leftEyeAcuity, // Set visual acuity
            contrastSensitivity: nil, // Set contrast to nil
            colorVision: nil, // Set color vision to nil
            depthPerception: nil, // Set depth perception to nil
            peripheralVision: nil, // Set peripheral vision to nil
            eyeStrain: leftEyeStrain, // Set eye strain
            dryness: leftEyeDryness, // Set dryness
            redness: DailyVisionCheck.EyeCheck.RednessLevel.none // Set redness to none
        )
        
        let visionCheck = DailyVisionCheck( // Create vision check
            date: Date(), // Set current date
            time: Date(), // Set current time
            rightEye: rightEye, // Set right eye check
            leftEye: leftEye, // Set left eye check
            bothEyes: DailyVisionCheck.BothEyesCheck(), // Set both eyes check
            device: device, // Set device
            environment: DailyVisionCheck.CheckEnvironment(lighting: .normal), // Set environment
            notes: notes.isEmpty ? nil : notes // Set optional notes
        )
        
        healthData.dailyVisionChecks.append(visionCheck) // Add vision check to health data
        viewModel.updateHealthData(healthData) // Update health data in view model
    }
}
