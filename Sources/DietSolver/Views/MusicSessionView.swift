//
//  MusicSessionView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct MusicSessionView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    @State private var musicType: MusicHearingSession.MusicType = .classical
    @State private var genre: String = ""
    @State private var volumeLevel: MusicHearingSession.VolumeLevel = .moderate
    @State private var device: MusicHearingSession.MusicDevice = .airpods
    @State private var listeningMode: MusicHearingSession.ListeningMode = .active
    @State private var duration: Double = 30.0
    @State private var hearingProtection: Bool = false
    @State private var hearingFatigue: MusicHearingSession.HearingFatigueLevel? = nil
    @State private var enjoyment: MusicHearingSession.EnjoymentLevel = .moderate
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Music Session")
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
                Section(header: Text("Session Details")) {
                    Picker("Music Type", selection: $musicType) {
                        ForEach(MusicHearingSession.MusicType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Genre (optional)", text: $genre)
                    
                    Stepper("Duration: \(Int(duration)) minutes", value: $duration, in: 1...180, step: 5)
                }
                
                Section(header: Text("Listening Settings")) {
                    Picker("Volume Level", selection: $volumeLevel) {
                        ForEach(MusicHearingSession.VolumeLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Device", selection: $device) {
                        ForEach(MusicHearingSession.MusicDevice.allCases, id: \.self) { device in
                            Text(device.rawValue).tag(device)
                        }
                    }
                    
                    Picker("Listening Mode", selection: $listeningMode) {
                        ForEach(MusicHearingSession.ListeningMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    Toggle("Hearing Protection Used", isOn: $hearingProtection)
                }
                
                Section(header: Text("After Session")) {
                    Picker("Hearing Fatigue", selection: Binding(
                        get: { hearingFatigue ?? MusicHearingSession.HearingFatigueLevel.none },
                        set: { hearingFatigue = $0 == MusicHearingSession.HearingFatigueLevel.none ? nil : $0 }
                    )) {
                        Text("None").tag(MusicHearingSession.HearingFatigueLevel.none)
                        ForEach([MusicHearingSession.HearingFatigueLevel.mild, .moderate, .severe], id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Enjoyment Level", selection: $enjoyment) {
                        ForEach(MusicHearingSession.EnjoymentLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Music Session") {
                        saveSession()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func saveSession() {
        let session = MusicHearingSession(
            date: Date(),
            startTime: Date(),
            duration: duration,
            musicType: musicType,
            genre: genre.isEmpty ? nil : genre,
            volumeLevel: volumeLevel,
            device: device,
            listeningMode: listeningMode,
            hearingProtection: hearingProtection,
            hearingFatigue: hearingFatigue,
            enjoyment: enjoyment,
            notes: notes.isEmpty ? nil : notes
        )
        
        if var healthData = viewModel.healthData {
            healthData.musicHearingSessions.append(session)
            viewModel.healthData = healthData
        }
        dismiss()
    }
}
