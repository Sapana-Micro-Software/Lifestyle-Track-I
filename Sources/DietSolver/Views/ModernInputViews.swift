//
//  ModernInputViews.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Modern Health Data Input
struct ModernHealthDataInputView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep = 0
    @State private var age: String = "30"
    @State private var gender: HealthData.Gender = .male
    @State private var weight: String = "70"
    @State private var height: String = "170"
    @State private var activityLevel: HealthData.ActivityLevel = .moderate
    
    private let steps = ["Basic Info", "Physical", "Activity"]
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                
                // Content
                TabView(selection: $currentStep) {
                    basicInfoStep
                        .tag(0)
                    physicalStep
                        .tag(1)
                    activityStep
                        .tag(2)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .animation(.easeInOut, value: currentStep)
                
                // Navigation
                navigationButtons
            }
        }
        .navigationTitle("Health Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private var progressIndicator: some View {
        HStack(spacing: AppDesign.Spacing.xs) {
            ForEach(0..<steps.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? AppDesign.Colors.primary : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.sm)
    }
    
    private var basicInfoStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Age",
                            value: $age,
                            icon: "calendar"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        ModernPickerField(
                            title: "Gender",
                            selection: $gender,
                            options: HealthData.Gender.allCases,
                            icon: "person.fill"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.top, AppDesign.Spacing.lg)
            }
        }
    }
    
    private var physicalStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Weight",
                            value: $weight,
                            icon: "scalemass.fill",
                            unit: "kg"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        ModernInputField(
                            title: "Height",
                            value: $height,
                            icon: "ruler.fill",
                            unit: "cm"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.top, AppDesign.Spacing.lg)
            }
        }
    }
    
    private var activityStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernPickerField(
                            title: "Activity Level",
                            selection: $activityLevel,
                            options: HealthData.ActivityLevel.allCases,
                            icon: "figure.walk"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .padding(.top, AppDesign.Spacing.lg)
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: AppDesign.Spacing.md) {
            if currentStep > 0 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    Text("Back")
                        .font(AppDesign.Typography.headline)
                        .foregroundColor(AppDesign.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppDesign.Spacing.md)
                        .background(AppDesign.Colors.surface)
                        .cornerRadius(AppDesign.Radius.medium)
                }
            }
            
            GradientButton(
                title: currentStep < steps.count - 1 ? "Next" : "Complete",
                icon: currentStep < steps.count - 1 ? "arrow.right" : "checkmark",
                action: {
                    if currentStep < steps.count - 1 {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        saveHealthData()
                    }
                }
            )
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.md)
        .background(AppDesign.Colors.surface)
    }
    
    private func saveHealthData() {
        let healthData = HealthData(
            age: Int(age) ?? 30,
            gender: gender,
            weight: Double(weight) ?? 70.0,
            height: Double(height) ?? 170.0,
            activityLevel: activityLevel
        )
        viewModel.updateHealthData(healthData)
        dismiss()
    }
}

// MARK: - Modern Input Field
struct ModernInputField: View {
    let title: String
    @Binding var value: String
    let icon: String
    #if os(iOS)
    var keyboardType: UIKeyboardType = .default
    #endif
    var unit: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppDesign.Colors.primary)
                    .frame(width: 20)
                Text(title)
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            
            HStack {
                #if os(iOS)
                TextField("", text: $value)
                    .keyboardType(keyboardType)
                    .font(AppDesign.Typography.title2)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                #else
                TextField("", text: $value)
                    .font(AppDesign.Typography.title2)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                #endif
                
                if let unit = unit {
                    Text(unit)
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AppDesign.Colors.primary.opacity(0.3)),
                alignment: .bottom
            )
        }
    }
}

// MARK: - Modern Picker Field
struct ModernPickerField<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    let options: [T]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppDesign.Colors.primary)
                    .frame(width: 20)
                Text(title)
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.rawValue.capitalized).tag(option)
                }
            }
            .pickerStyle(.menu)
            .font(AppDesign.Typography.title2)
            .foregroundColor(AppDesign.Colors.textPrimary)
            .padding(.vertical, AppDesign.Spacing.sm)
        }
    }
}

// MARK: - Modern Solving View
struct ModernSolvingView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var progress: Double = 0
    @State private var currentMessage = "Initializing..."
    
    private let messages = [
        "Analyzing your health data...",
        "Optimizing nutrient balance...",
        "Selecting seasonal foods...",
        "Balancing taste and digestion...",
        "Creating your personalized plan..."
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppDesign.Colors.gradientStart.opacity(0.1), AppDesign.Colors.gradientEnd.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: AppDesign.Spacing.xl) {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(AppDesign.Colors.primary.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    ProgressRing(progress: progress, color: AppDesign.Colors.primary, size: 120)
                    
                    Image(systemName: progress >= 1.0 ? "checkmark.circle.fill" : "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(AppDesign.Colors.primary)
                        #if os(iOS)
                        .symbolEffect(.pulse, options: .repeating)
                        #endif
                }
                
                VStack(spacing: AppDesign.Spacing.sm) {
                    Text(progress >= 1.0 ? "Complete!" : "Optimizing")
                        .font(AppDesign.Typography.title)
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    
                    Text(currentMessage)
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppDesign.Spacing.xl)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
            viewModel.solveDiet()
        }
    }
    
    private func startAnimation() {
        let messageInterval = 1.0
        let totalDuration = Double(messages.count) * messageInterval
        
        for (index, message) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * messageInterval) {
                withAnimation(.easeInOut) {
                    currentMessage = message
                    progress = Double(index + 1) / Double(messages.count)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            withAnimation {
                progress = 1.0
                currentMessage = "Your personalized plan is ready!"
            }
        }
    }
}
