//
//  BreathingVisualizationView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct BreathingVisualizationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isBreathing: Bool = false
    @State private var isInhaling: Bool = true
    @State private var cycleCount: Int = 0
    @State private var timer: Timer?
    
    let technique: BreathingTechnique
    
    enum BreathingTechnique: String, CaseIterable {
        case box = "Box Breathing"
        case fourSevenEight = "4-7-8 Breathing"
        case deep = "Deep Breathing"
        
        var inhaleDuration: TimeInterval {
            switch self {
            case .box: return 4.0
            case .fourSevenEight: return 4.0
            case .deep: return 4.0
            }
        }
        
        var holdDuration: TimeInterval {
            switch self {
            case .box: return 4.0
            case .fourSevenEight: return 7.0
            case .deep: return 0.0
            }
        }
        
        var exhaleDuration: TimeInterval {
            switch self {
            case .box: return 4.0
            case .fourSevenEight: return 8.0
            case .deep: return 6.0
            }
        }
        
        var instructions: String {
            switch self {
            case .box:
                return "Breathe in for 4, hold for 4, out for 4, hold for 4"
            case .fourSevenEight:
                return "Breathe in for 4, hold for 7, out for 8"
            case .deep:
                return "Breathe in slowly, breathe out slowly"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(technique.rawValue)
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
                Button("Done") {
                    stopBreathing()
                    dismiss()
                }
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.primary)
                .padding(.trailing, AppDesign.Spacing.md)
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            VStack(spacing: AppDesign.Spacing.xl) {
                Spacer()
                
                // Breathing Circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isInhaling ? 
                                    [AppDesign.Colors.primary.opacity(0.3), AppDesign.Colors.primary] :
                                    [AppDesign.Colors.secondary.opacity(0.3), AppDesign.Colors.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isBreathing ? (isInhaling ? 200 : 100) : 150,
                               height: isBreathing ? (isInhaling ? 200 : 100) : 150)
                        .animation(.easeInOut(duration: technique.inhaleDuration), value: isInhaling)
                    
                    Text(isInhaling ? "Breathe In" : "Breathe Out")
                        .font(AppDesign.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Instructions
                VStack(spacing: AppDesign.Spacing.sm) {
                    Text(technique.instructions)
                        .font(AppDesign.Typography.headline)
                    
                    Text("Cycle: \(cycleCount)")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                
                Spacer()
                
                // Control Button
                Button(action: {
                    if isBreathing {
                        stopBreathing()
                    } else {
                        startBreathing()
                    }
                }) {
                    Text(isBreathing ? "Stop" : "Start")
                        .font(AppDesign.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isBreathing ? AppDesign.Colors.error : AppDesign.Colors.primary)
                        .cornerRadius(AppDesign.Radius.large)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.bottom, AppDesign.Spacing.lg)
            }
        }
        .background(AppDesign.Colors.background)
        .onDisappear {
            stopBreathing()
        }
    }
    
    private func startBreathing() {
        isBreathing = true
        isInhaling = true
        cycleCount = 0
        performBreathingCycle()
    }
    
    private func stopBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
    }
    
    private func performBreathingCycle() {
        // Inhale
        isInhaling = true
        timer = Timer.scheduledTimer(withTimeInterval: technique.inhaleDuration, repeats: false) { _ in
            // Hold (if applicable)
            if technique.holdDuration > 0 {
                timer = Timer.scheduledTimer(withTimeInterval: technique.holdDuration, repeats: false) { _ in
                    // Exhale
                    isInhaling = false
                    timer = Timer.scheduledTimer(withTimeInterval: technique.exhaleDuration, repeats: false) { _ in
                        // Hold after exhale (for box breathing)
                        if technique == .box {
                            timer = Timer.scheduledTimer(withTimeInterval: technique.holdDuration, repeats: false) { _ in
                                cycleCount += 1
                                if isBreathing {
                                    performBreathingCycle()
                                }
                            }
                        } else {
                            cycleCount += 1
                            if isBreathing {
                                performBreathingCycle()
                            }
                        }
                    }
                }
            } else {
                // Exhale (no hold)
                isInhaling = false
                timer = Timer.scheduledTimer(withTimeInterval: technique.exhaleDuration, repeats: false) { _ in
                    cycleCount += 1
                    if isBreathing {
                        performBreathingCycle()
                    }
                }
            }
        }
    }
}
