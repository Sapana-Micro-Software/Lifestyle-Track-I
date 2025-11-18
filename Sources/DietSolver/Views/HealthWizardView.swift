//
//  HealthWizardView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Health Wizard View
struct HealthWizardView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep = 0
    @State private var isGeneratingPlan = false
    
    // Step 1: Basic Information
    @State private var age: String = ""
    @State private var gender: HealthData.Gender = .male
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var heightFeet: String = "" // For imperial height input
    @State private var heightInches: String = "" // For imperial height input
    @State private var activityLevel: HealthData.ActivityLevel = .moderate
    @State private var previousUnitSystem: UnitSystem = .metric // Track previous unit system for conversion
    
    // Step 2: Medical & Health Metrics
    @State private var glucose: String = ""
    @State private var hemoglobin: String = ""
    @State private var cholesterol: String = ""
    @State private var systolicBP: String = ""
    @State private var diastolicBP: String = ""
    
    // Step 3: Fitness & Exercise
    @State private var muscleMass: String = ""
    @State private var bodyFatPercentage: String = ""
    @State private var exerciseFrequency: String = "3" // days per week
    
    // Step 4: Mental Health
    @State private var stressLevel: HealthData.MentalHealth.StressLevel = .moderate
    @State private var anxietyLevel: HealthData.MentalHealth.AnxietyLevel = .none
    @State private var sleepQuality: HealthData.MentalHealth.SleepQuality = .good
    @State private var currentTherapy: Bool = false
    @State private var mentalHealthMedications: String = ""
    
    // Step 5: Sexual Health
    @State private var libidoLevel: HealthData.SexualHealth.LibidoLevel = .moderate
    @State private var sexualHealthConcerns: String = ""
    @State private var sexualHealthMedications: String = ""
    
    // Step 6: Lifestyle
    @State private var waterIntake: String = "2.5" // liters per day (will convert based on unit system)
    @State private var mealFrequency: String = "3" // meals per day
    
    // Step 7: Exercise Goals
    @State private var weeklyCardioMinutes: String = "150"
    @State private var weeklyStrengthSessions: String = "2"
    @State private var weeklyFlexibilityMinutes: String = "60"
    @State private var weeklyMindBodyMinutes: String = "120"
    
    // Step 8: Sleep & Habits
    @State private var averageSleepHours: String = "8"
    @State private var sleepIssues: String = ""
    @State private var currentMedications: String = ""
    @State private var allergies: String = ""
    @State private var dietaryRestrictions: String = ""
    
    // Step 9: Plan Preferences
    @State private var planDuration: PlanDuration = .tenYears
    @State private var urgencyLevel: UrgencyLevel = .medium
    @State private var customDurationYears: String = "10"
    @State private var useCustomDuration: Bool = false
    
    private let steps = [
        "Basic Info",
        "Medical Metrics",
        "Fitness",
        "Mental Health",
        "Sexual Health",
        "Lifestyle",
        "Exercise Goals",
        "Sleep & Habits",
        "Plan Preferences"
    ]
    
    @State private var generationProgress: Double = 0.0
    @State private var generationStatus: String = "Initializing..."
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            if isGeneratingPlan {
                planGenerationView
            } else {
                wizardContentView
            }
        }
        .navigationTitle("Health Wizard")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                CompactUnitSystemToggle(viewModel: viewModel)
            }
        }
        .onChange(of: viewModel.unitSystem) { newSystem in
            convertValues(from: previousUnitSystem, to: newSystem)
            previousUnitSystem = newSystem
        }
        .onAppear {
            previousUnitSystem = viewModel.unitSystem
            updateDefaultValues()
        }
        .onDisappear {
            // Clean up state when view disappears to prevent ViewBridge errors
            #if os(macOS)
            // Give SwiftUI time to properly clean up view hierarchy
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Any cleanup needed
            }
            #endif
        }
    }
    
    // MARK: - Update Default Values
    private func updateDefaultValues() {
        if viewModel.unitSystem == .imperial {
            // Set default imperial values if fields are empty
            if weight.isEmpty {
                weight = "154" // ~70 kg in lbs
            }
            if height.isEmpty {
                heightFeet = "5"
                heightInches = "7"
            }
            if waterIntake == "2.5" {
                waterIntake = "0.66" // ~2.5L in gallons
            }
        } else {
            // Set default metric values if fields are empty
            if weight.isEmpty {
                weight = "70"
            }
            if height.isEmpty {
                height = "170"
            }
            if waterIntake.isEmpty || waterIntake == "0.66" {
                waterIntake = "2.5"
            }
        }
    }
    
    // MARK: - Convert Values
    private func convertValues(from: UnitSystem, to: UnitSystem) {
        let converter = UnitConverter.shared
        
        // Convert weight
        if let weightValue = Double(weight), !weight.isEmpty {
            let converted = converter.convertWeight(weightValue, from: from, to: to)
            weight = String(format: "%.1f", converted)
        }
        
        // Convert height
        if viewModel.unitSystem == .imperial {
            // Convert to feet/inches
            if let heightValue = Double(height), !height.isEmpty {
                let inches = converter.convertHeight(heightValue, from: from, to: to)
                let (feet, remainingInches) = converter.heightToFeetInches(inches)
                heightFeet = String(feet)
                heightInches = String(format: "%.1f", remainingInches)
                height = "" // Clear metric height
            }
        } else {
            // Convert to cm
            if !heightFeet.isEmpty || !heightInches.isEmpty {
                let feet = Int(heightFeet) ?? 0
                let inches = Double(heightInches) ?? 0
                let totalInches = converter.feetInchesToHeight(feet: feet, inches: inches)
                let cm = converter.convertHeight(totalInches, from: .imperial, to: .metric)
                height = String(format: "%.1f", cm)
                heightFeet = ""
                heightInches = ""
            }
        }
        
        // Convert water intake
        if let waterValue = Double(waterIntake), !waterIntake.isEmpty {
            let converted = converter.convertVolume(waterValue, from: from, to: to)
            waterIntake = String(format: "%.2f", converted)
        }
        
        // Convert muscle mass
        if let muscleValue = Double(muscleMass), !muscleMass.isEmpty {
            let converted = converter.convertWeight(muscleValue, from: from, to: to)
            muscleMass = String(format: "%.1f", converted)
        }
    }
    
    private var wizardContentView: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            progressIndicator
            
            // Step Content
            TabView(selection: $currentStep) {
                basicInfoStep.tag(0)
                medicalMetricsStep.tag(1)
                fitnessStep.tag(2)
                mentalHealthStep.tag(3)
                sexualHealthStep.tag(4)
                lifestyleStep.tag(5)
                exerciseGoalsStep.tag(6)
                sleepHabitsStep.tag(7)
                planPreferencesStep.tag(8)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            .animation(.easeInOut, value: currentStep)
            
            // Navigation Buttons
            navigationButtons
        }
    }
    
    private var planGenerationView: some View {
        VStack(spacing: AppDesign.Spacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(AppDesign.Colors.primary.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                ProgressRing(progress: generationProgress, color: AppDesign.Colors.primary, size: 120)
                
                VStack(spacing: AppDesign.Spacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundColor(AppDesign.Colors.primary)
                        #if os(iOS)
                        .symbolEffect(.pulse, options: .repeating)
                        #endif
                    
                    Text("\(Int(generationProgress * 100))%")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.primary)
                }
            }
            
            VStack(spacing: AppDesign.Spacing.sm) {
                Text("Generating Your Plan")
                    .font(AppDesign.Typography.title)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                
                Text(generationStatus)
                    .font(AppDesign.Typography.body)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppDesign.Spacing.xl)
                
                if planDuration == .tenYears || useCustomDuration {
                    Text("This may take a few minutes for a 10+ year plan")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .padding(.top, AppDesign.Spacing.xs)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: AppDesign.Spacing.sm) {
            HStack(spacing: AppDesign.Spacing.xs) {
                ForEach(0..<steps.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= currentStep ? AppDesign.Colors.primary : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.spring(), value: currentStep)
                }
            }
            
            HStack {
                Text("Step \(currentStep + 1) of \(steps.count)")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                Spacer()
                Text(steps[currentStep])
                    .font(AppDesign.Typography.subheadline)
                    .foregroundColor(AppDesign.Colors.primary)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.sm)
        .background(AppDesign.Colors.surface)
    }
    
    // MARK: - Step 1: Basic Information
    private var basicInfoStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "person.fill",
                    title: "Basic Information",
                    description: "Tell us about yourself to personalize your plan"
                )
                
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
                        
                        ModernInputField(
                            title: "Weight",
                            value: $weight,
                            icon: "scalemass.fill",
                            unit: viewModel.unitSystem.weightUnit
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        if viewModel.unitSystem == .metric {
                            ModernInputField(
                                title: "Height",
                                value: $height,
                                icon: "ruler.fill",
                                unit: viewModel.unitSystem.heightUnit
                            )
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        } else {
                            // Imperial height input (feet and inches)
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                                HStack {
                                    Image(systemName: "ruler.fill")
                                        .foregroundColor(AppDesign.Colors.primary)
                                        .frame(width: 20)
                                    Text("Height")
                                        .font(AppDesign.Typography.subheadline)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                                
                                HStack(spacing: AppDesign.Spacing.sm) {
                                    ModernInputField(
                                        title: "Feet",
                                        value: $heightFeet,
                                        icon: "",
                                        unit: "ft"
                                    )
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                    
                                    ModernInputField(
                                        title: "Inches",
                                        value: $heightInches,
                                        icon: "",
                                        unit: "in"
                                    )
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                }
                            }
                        }
                        
                        ModernPickerField(
                            title: "Activity Level",
                            selection: $activityLevel,
                            options: HealthData.ActivityLevel.allCases,
                            icon: "figure.walk"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 2: Medical & Health Metrics
    private var medicalMetricsStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "heart.text.square.fill",
                    title: "Medical Metrics",
                    description: "Share your recent health test results (optional but recommended)"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Glucose",
                            value: $glucose,
                            icon: "drop.fill",
                            unit: "mg/dL"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        ModernInputField(
                            title: "Hemoglobin",
                            value: $hemoglobin,
                            icon: "heart.fill",
                            unit: "g/dL"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        ModernInputField(
                            title: "Cholesterol",
                            value: $cholesterol,
                            icon: "waveform.path.ecg",
                            unit: "mg/dL"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        HStack(spacing: AppDesign.Spacing.md) {
                            ModernInputField(
                                title: "Systolic BP",
                                value: $systolicBP,
                                icon: "heart.circle.fill",
                                unit: "mmHg"
                            )
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            
                            ModernInputField(
                                title: "Diastolic BP",
                                value: $diastolicBP,
                                icon: "heart.circle.fill",
                                unit: "mmHg"
                            )
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 3: Fitness & Exercise
    private var fitnessStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "figure.strengthtraining.functional",
                    title: "Fitness & Exercise",
                    description: "Help us understand your current fitness level"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Muscle Mass",
                            value: $muscleMass,
                            icon: "dumbbell.fill",
                            unit: viewModel.unitSystem.weightUnit
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        ModernInputField(
                            title: "Body Fat Percentage",
                            value: $bodyFatPercentage,
                            icon: "percent",
                            unit: "%"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        ModernInputField(
                            title: "Exercise Frequency",
                            value: $exerciseFrequency,
                            icon: "calendar.badge.clock",
                            unit: "days/week"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 4: Mental Health
    private var mentalHealthStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "brain.head.profile",
                    title: "Mental Health",
                    description: "Understanding your mental well-being helps us create a balanced plan"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernPickerField(
                            title: "Stress Level",
                            selection: $stressLevel,
                            options: HealthData.MentalHealth.StressLevel.allCases,
                            icon: "exclamationmark.triangle.fill"
                        )
                        
                        ModernPickerField(
                            title: "Anxiety Level",
                            selection: $anxietyLevel,
                            options: HealthData.MentalHealth.AnxietyLevel.allCases,
                            icon: "brain.head.profile"
                        )
                        
                        ModernPickerField(
                            title: "Sleep Quality",
                            selection: $sleepQuality,
                            options: HealthData.MentalHealth.SleepQuality.allCases,
                            icon: "moon.fill"
                        )
                        
                        Toggle(isOn: $currentTherapy) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .foregroundColor(AppDesign.Colors.primary)
                                Text("Currently in Therapy")
                                    .font(AppDesign.Typography.body)
                            }
                        }
                        .padding(.vertical, AppDesign.Spacing.sm)
                        
                        ModernInputField(
                            title: "Mental Health Medications",
                            value: $mentalHealthMedications,
                            icon: "pills.fill",
                            placeholder: "List any medications (optional)"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 5: Sexual Health
    private var sexualHealthStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "heart.circle.fill",
                    title: "Sexual Health",
                    description: "This information helps optimize hormonal balance"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernPickerField(
                            title: "Libido Level",
                            selection: $libidoLevel,
                            options: HealthData.SexualHealth.LibidoLevel.allCases,
                            icon: "heart.fill"
                        )
                        
                        ModernInputField(
                            title: "Concerns",
                            value: $sexualHealthConcerns,
                            icon: "exclamationmark.circle.fill",
                            placeholder: "Any concerns (optional)"
                        )
                        
                        ModernInputField(
                            title: "Medications",
                            value: $sexualHealthMedications,
                            icon: "pills.fill",
                            placeholder: "List any medications (optional)"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 6: Lifestyle
    private var lifestyleStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "leaf.fill",
                    title: "Lifestyle",
                    description: "Tell us about your daily habits"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Daily Water Intake",
                            value: $waterIntake,
                            icon: "drop.fill",
                            unit: viewModel.unitSystem == .metric ? "liters" : "gallons"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        ModernInputField(
                            title: "Meals Per Day",
                            value: $mealFrequency,
                            icon: "fork.knife",
                            unit: "meals"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 7: Exercise Goals
    private var exerciseGoalsStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "figure.strengthtraining.traditional",
                    title: "Exercise Goals",
                    description: "Set your weekly exercise targets"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Weekly Cardio Minutes",
                            value: $weeklyCardioMinutes,
                            icon: "heart.fill",
                            unit: "min/week"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Weekly Strength Sessions",
                            value: $weeklyStrengthSessions,
                            icon: "dumbbell.fill",
                            unit: "sessions/week"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Weekly Flexibility Minutes",
                            value: $weeklyFlexibilityMinutes,
                            icon: "figure.flexibility",
                            unit: "min/week"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Weekly Mind-Body Minutes",
                            value: $weeklyMindBodyMinutes,
                            icon: "brain.head.profile",
                            unit: "min/week"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 8: Sleep & Habits
    private var sleepHabitsStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "moon.zzz.fill",
                    title: "Sleep & Habits",
                    description: "Tell us about your sleep and health habits"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Average Sleep Hours",
                            value: $averageSleepHours,
                            icon: "bed.double.fill",
                            unit: "hours/night"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        
                        ModernInputField(
                            title: "Sleep Issues",
                            value: $sleepIssues,
                            icon: "exclamationmark.triangle.fill",
                            placeholder: "Insomnia, sleep apnea, etc. (optional)"
                        )
                        
                        ModernInputField(
                            title: "Current Medications",
                            value: $currentMedications,
                            icon: "pills.fill",
                            placeholder: "List medications (optional)"
                        )
                        
                        ModernInputField(
                            title: "Allergies",
                            value: $allergies,
                            icon: "allergens",
                            placeholder: "Food, medication, etc. (optional)"
                        )
                        
                        ModernInputField(
                            title: "Dietary Restrictions",
                            value: $dietaryRestrictions,
                            icon: "fork.knife",
                            placeholder: "Vegetarian, vegan, keto, etc. (optional)"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step 9: Plan Preferences
    private var planPreferencesStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "calendar.badge.clock",
                    title: "Plan Preferences",
                    description: "Configure your long-term plan"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(AppDesign.Colors.primary)
                                    .frame(width: 20)
                                Text("Plan Duration")
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            Toggle(isOn: $useCustomDuration) {
                                Text("Use Custom Duration (10+ years)")
                                    .font(AppDesign.Typography.body)
                            }
                            .padding(.vertical, AppDesign.Spacing.xs)
                            
                            if useCustomDuration {
                                ModernInputField(
                                    title: "Years",
                                    value: $customDurationYears,
                                    icon: "calendar.badge.clock",
                                    unit: "years"
                                )
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            } else {
                                Picker("", selection: $planDuration) {
                                    ForEach(PlanDuration.allCases, id: \.self) { duration in
                                        Text(duration.rawValue).tag(duration)
                                    }
                                }
                                .pickerStyle(.menu)
                                .font(AppDesign.Typography.title2)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                                .padding(.vertical, AppDesign.Spacing.sm)
                            }
                            
                            let totalDays = useCustomDuration ? (Int(customDurationYears) ?? 10) * 365 : planDuration.days
                            Text("Selected: \(totalDays) days (\(totalDays / 365) years)")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                Image(systemName: "gauge.high")
                                    .foregroundColor(AppDesign.Colors.primary)
                                    .frame(width: 20)
                                Text("Urgency Level")
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            Picker("", selection: $urgencyLevel) {
                                ForEach(UrgencyLevel.allCases, id: \.self) { urgency in
                                    Text(urgency.rawValue).tag(urgency)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(AppDesign.Typography.title2)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                            .padding(.vertical, AppDesign.Spacing.sm)
                            
                            Text("Recommended difficulty: \(urgencyLevel.recommendedDifficulty().rawValue)")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Summary Card
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text("Plan Summary")
                            .font(AppDesign.Typography.headline)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text(planDuration.rawValue)
                                .fontWeight(.semibold)
                        }
                        .font(AppDesign.Typography.body)
                        
                        HStack {
                            Text("Difficulty:")
                            Spacer()
                            Text(urgencyLevel.recommendedDifficulty().rawValue)
                                .fontWeight(.semibold)
                        }
                        .font(AppDesign.Typography.body)
                        
                        HStack {
                            Text("Total Days:")
                            Spacer()
                            Text("\(useCustomDuration ? (Int(customDurationYears) ?? 10) * 365 : planDuration.days)")
                                .fontWeight(.semibold)
                        }
                        .font(AppDesign.Typography.body)
                        
                        HStack {
                            Text("Years:")
                            Spacer()
                            Text("\(useCustomDuration ? (Int(customDurationYears) ?? 10) : planDuration.days / 365)")
                                .fontWeight(.semibold)
                        }
                        .font(AppDesign.Typography.body)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Step Header
    private func stepHeader(icon: String, title: String, description: String) -> some View {
        VStack(spacing: AppDesign.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppDesign.Colors.primary)
                .padding(.bottom, AppDesign.Spacing.sm)
            
            Text(title)
                .font(AppDesign.Typography.title)
                .foregroundColor(AppDesign.Colors.textPrimary)
            
            Text(description)
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDesign.Spacing.lg)
        }
        .padding(.vertical, AppDesign.Spacing.lg)
    }
    
    // MARK: - Navigation Buttons
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
            
            Button(action: {
                if currentStep < steps.count - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    generatePlan()
                }
            }) {
                HStack {
                    Text(currentStep < steps.count - 1 ? "Next" : "Generate 10+ Year Plan")
                        .font(AppDesign.Typography.headline)
                        .foregroundColor(.white)
                    
                    Image(systemName: currentStep < steps.count - 1 ? "arrow.right" : "sparkles")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppDesign.Spacing.md)
                .background(
                    LinearGradient(
                        colors: [AppDesign.Colors.gradientStart, AppDesign.Colors.gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppDesign.Radius.medium)
                .shadow(color: AppDesign.Shadow.medium.color, radius: AppDesign.Shadow.medium.radius, x: AppDesign.Shadow.medium.x, y: AppDesign.Shadow.medium.y)
            }
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.md)
        .background(AppDesign.Colors.surface)
    }
    
    // MARK: - Generate Plan
    private func generatePlan() {
        isGeneratingPlan = true
        generationProgress = 0.0
        generationStatus = "Building health profile..."
        
        // Convert inputs to metric (internal storage is always metric)
        let converter = UnitConverter.shared
        var finalWeight: Double = 70.0
        var finalHeight: Double = 170.0
        
        if let weightValue = Double(weight), !weight.isEmpty {
            finalWeight = converter.convertWeight(weightValue, from: viewModel.unitSystem, to: .metric)
        }
        
        if viewModel.unitSystem == .metric {
            if let heightValue = Double(height), !height.isEmpty {
                finalHeight = heightValue
            }
        } else {
            // Convert feet/inches to cm
            let feet = Int(heightFeet) ?? 0
            let inches = Double(heightInches) ?? 0
            let totalInches = converter.feetInchesToHeight(feet: feet, inches: inches)
            finalHeight = converter.convertHeight(totalInches, from: .imperial, to: .metric)
        }
        
        // Build HealthData from wizard inputs (always in metric internally)
        var healthData = HealthData(
            age: Int(age) ?? 30,
            gender: gender,
            weight: finalWeight,
            height: finalHeight,
            activityLevel: activityLevel
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.generationProgress = 0.1
            self.generationStatus = "Processing medical metrics..."
        }
        
        // Add optional medical metrics
        if let glucoseValue = Double(glucose), !glucose.isEmpty {
            healthData.glucose = glucoseValue
        }
        if let hemoglobinValue = Double(hemoglobin), !hemoglobin.isEmpty {
            healthData.hemoglobin = hemoglobinValue
        }
        if let cholesterolValue = Double(cholesterol), !cholesterol.isEmpty {
            healthData.cholesterol = cholesterolValue
        }
        if let systolic = Int(systolicBP), let diastolic = Int(diastolicBP),
           !systolicBP.isEmpty, !diastolicBP.isEmpty {
            healthData.bloodPressure = HealthData.BloodPressure(
                systolic: systolic,
                diastolic: diastolic
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.generationProgress = 0.2
            self.generationStatus = "Analyzing fitness data..."
        }
        
        // Add fitness data (convert to metric)
        if let muscle = Double(muscleMass), !muscleMass.isEmpty {
            healthData.muscleMass = converter.convertWeight(muscle, from: viewModel.unitSystem, to: .metric)
        }
        if let bodyFat = Double(bodyFatPercentage), !bodyFatPercentage.isEmpty {
            healthData.bodyFatPercentage = bodyFat
        }
        
        // Add exercise goals
        healthData.exerciseGoals = ExerciseGoals(
            weeklyCardioMinutes: Double(weeklyCardioMinutes) ?? 150.0,
            weeklyStrengthSessions: Int(weeklyStrengthSessions) ?? 2,
            weeklyFlexibilityMinutes: Double(weeklyFlexibilityMinutes) ?? 60.0,
            weeklyMindBodyMinutes: Double(weeklyMindBodyMinutes) ?? 120.0
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.generationProgress = 0.3
            self.generationStatus = "Integrating mental health data..."
        }
        
        // Add mental health
        healthData.mentalHealth = HealthData.MentalHealth(
            stressLevel: stressLevel,
            anxietyLevel: anxietyLevel,
            depressionSymptoms: [],
            currentTherapy: currentTherapy,
            medications: mentalHealthMedications.isEmpty ? [] : [mentalHealthMedications],
            sleepQuality: sleepQuality
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.generationProgress = 0.4
            self.generationStatus = "Processing sexual health information..."
        }
        
        // Add sexual health
        healthData.sexualHealth = HealthData.SexualHealth(
            libidoLevel: libidoLevel,
            concerns: sexualHealthConcerns.isEmpty ? [] : [sexualHealthConcerns],
            medications: sexualHealthMedications.isEmpty ? [] : [sexualHealthMedications]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.generationProgress = 0.5
            self.generationStatus = "Setting up long-term plan structure..."
        }
        
        // Update view model
        viewModel.setHealthData(healthData)
        
        // Determine plan duration
        let finalDuration: PlanDuration
        let totalDays: Int
        
        if useCustomDuration {
            let years = max(10, Int(customDurationYears) ?? 10) // Minimum 10 years
            totalDays = years * 365
            
            // Use closest matching duration or create custom
            if years <= 2 {
                finalDuration = .twoYears
            } else if years <= 5 {
                finalDuration = .fiveYears
            } else {
                finalDuration = .tenYears // Use 10 years as base, will generate more days
            }
        } else {
            finalDuration = planDuration
            totalDays = planDuration.days
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.generationProgress = 0.6
            self.generationStatus = "Generating transformation goals..."
        }
        
        // Generate long-term plan
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.generationProgress = 0.7
            self.generationStatus = "Creating \(totalDays / 365) year plan..."
            
            viewModel.generateLongTermPlan(duration: finalDuration, urgency: urgencyLevel)
            
            // Wait for plan generation to complete
            // The ViewModel handles generating all daily plans in the background
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.generationProgress = 0.9
                self.generationStatus = "Finalizing your personalized \(totalDays / 365) year plan..."
                
                // For very long plans, show extended progress
                if totalDays > 3650 {
                    self.generationStatus = "Generating \(totalDays) daily plans... This may take a few minutes."
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.generationProgress = 1.0
                    self.generationStatus = "Plan generated successfully! \(totalDays) days ready."
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isGeneratingPlan = false
                        self.dismiss()
                    }
                }
            }
        }
    }
    
}

// MARK: - Health Wizard Wrapper
struct HealthWizardViewWrapper: View {
    @EnvironmentObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            HealthWizardView(viewModel: viewModel)
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Ensure proper window lifecycle on macOS
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Window is ready
            }
        }
        #endif
    }
}
