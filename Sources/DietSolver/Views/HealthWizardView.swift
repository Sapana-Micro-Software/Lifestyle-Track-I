//
//  HealthWizardView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI
#if canImport(PassKit)
import PassKit
#endif
#if canImport(CoreNFC)
import CoreNFC
#endif

// MARK: - Health Wizard View
struct HealthWizardView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    var dismiss: (() -> Void)?
    
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
    @State private var isReadingLicense = false // State for license reading in progress
    @State private var licenseReadError: String? // State for license reading errors
    @StateObject private var nfcManager = NFCManager() // NFC manager for reading physical licenses
    @StateObject private var passportManager = PassportManager() // Passport manager for reading passports
    @State private var showPassportMRZScanner = false // State for showing MRZ scanner
    @State private var showExternalHealthCapture = false // State for showing external health capture view
    
    // Step 2: Medical & Health Metrics
    @State private var glucose: String = ""
    @State private var hemoglobin: String = ""
    @State private var cholesterol: String = ""
    @State private var systolicBP: String = ""
    @State private var diastolicBP: String = ""
    @State private var restingPulse: String = "" // Resting pulse rate
    @State private var activePulse: String = "" // Active pulse rate
    @State private var maxPulse: String = "" // Maximum pulse rate
    @State private var pulseMeasurementMethod: HealthData.WristPulse.PulseMeasurementMethod = .manual // Pulse measurement method
    
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
    
    // Step 9: Dental Fitness
    @State private var dailyTeethScrubs: String = "2"
    @State private var dailyFlossingCount: String = "1"
    @State private var dailyMouthwashCleans: String = "1"
    @State private var dailyTongueScrapes: String = "1"
    @State private var dentalConcerns: String = ""
    @State private var dentalMedications: String = ""
    
    // Step 10: Plan Preferences
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
        "Dental Fitness",
        "External Health",
        "Plan Preferences"
    ]
    
    @State private var generationProgress: Double = 0.0
    @State private var generationStatus: String = "Initializing..."
    
    // Computed property for plan duration display text
    private var planDurationDisplayText: String {
        if useCustomDuration {
            if let years = Double(customDurationYears), years > 0 {
                let totalDays = Int(years * 365.0)
                if years < 1 {
                    let months = Int(years * 12.0)
                    return "Selected: \(totalDays) days (\(months) months)"
                } else {
                    return "Selected: \(totalDays) days (\(String(format: "%.1f", years)) years)"
                }
            } else {
                return "Selected: \(planDuration.days) days"
            }
        } else {
            return "Selected: \(planDuration.days) days (\(planDuration.months) months)"
        }
    }
    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // Reset any state that might cause issues
                isGeneratingPlan = false
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
            // Custom Header
            wizardHeader
            
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
                dentalFitnessStep.tag(8)
                externalHealthStep.tag(9)
                planPreferencesStep.tag(10)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            .animation(.easeInOut, value: currentStep)
            
            // Navigation Buttons
            navigationButtons
        }
    }
    
    // MARK: - Wizard Header
    private var wizardHeader: some View {
        HStack {
            Text("Health Wizard")
                .font(AppDesign.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(AppDesign.Colors.textPrimary)
            
            Spacer()
            
            CompactUnitSystemToggle(viewModel: viewModel)
            
            Button(action: {
                dismiss?()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.sm)
        .background(AppDesign.Colors.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppDesign.Colors.textSecondary.opacity(0.2)),
            alignment: .bottom
        )
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
                
                // Wallet & NFC Integration Buttons
                VStack(spacing: AppDesign.Spacing.md) {
                    // Wallet Integration Button (iOS 16+)
                    #if os(iOS)
                    if #available(iOS 16.0, *) {
                        if WalletManager.isAvailable() {
                            ModernCard {
                                VStack(spacing: AppDesign.Spacing.sm) {
                                    Button(action: {
                                        readDriversLicenseFromWallet()
                                    }) {
                                        HStack {
                                            Image(systemName: "creditcard.fill")
                                                .font(.system(size: 20))
                                            Text("Use Driver's License from Wallet")
                                                .font(AppDesign.Typography.headline)
                                            Spacer()
                                            if isReadingLicense {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .padding(.vertical, AppDesign.Spacing.md)
                                        .padding(.horizontal, AppDesign.Spacing.md)
                                        .background(
                                            LinearGradient(
                                                colors: [AppDesign.Colors.primary, AppDesign.Colors.secondary],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(AppDesign.Radius.medium)
                                    }
                                    .disabled(isReadingLicense)
                                }
                            }
                            .padding(.horizontal, AppDesign.Spacing.md)
                        }
                    }
                    #endif
                    
                    // NFC Reading Button (All Platforms)
                    if NFCManager.isAvailable() {
                        ModernCard {
                            VStack(spacing: AppDesign.Spacing.sm) {
                                Button(action: {
                                    readDriversLicenseWithNFC()
                                }) {
                                    HStack {
                                        Image(systemName: "wave.3.right.circle.fill")
                                            .font(.system(size: 20))
                                        Text("Scan Driver's License with NFC")
                                            .font(AppDesign.Typography.headline)
                                        Spacer()
                                        if nfcManager.isScanning {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, AppDesign.Spacing.md)
                                    .padding(.horizontal, AppDesign.Spacing.md)
                                    .background(
                                        LinearGradient(
                                            colors: [AppDesign.Colors.accent, AppDesign.Colors.primary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(AppDesign.Radius.medium)
                                }
                                .disabled(nfcManager.isScanning || isReadingLicense)
                                
                                if !nfcManager.scanProgress.isEmpty {
                                    Text(nfcManager.scanProgress)
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                        .padding(.top, AppDesign.Spacing.xs)
                                }
                                
                                if let error = nfcManager.errorMessage {
                                    Text(error)
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.error)
                                        .padding(.top, AppDesign.Spacing.xs)
                                }
                            }
                        }
                        .padding(.horizontal, AppDesign.Spacing.md)
                    }
                    
                    // Passport Integration Button (All Platforms)
                    if PassportManager.isAvailable() || PassportManager.isMRZScanningAvailable() {
                        ModernCard {
                            VStack(spacing: AppDesign.Spacing.sm) {
                                if PassportManager.isAvailable() {
                                    Button(action: {
                                        readPassportWithNFC()
                                    }) {
                                        HStack {
                                            Image(systemName: "book.closed.fill")
                                                .font(.system(size: 20))
                                            Text("Scan Passport with NFC")
                                                .font(AppDesign.Typography.headline)
                                            Spacer()
                                            if passportManager.isScanning {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .padding(.vertical, AppDesign.Spacing.md)
                                        .padding(.horizontal, AppDesign.Spacing.md)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.purple, AppDesign.Colors.primary],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(AppDesign.Radius.medium)
                                    }
                                    .disabled(passportManager.isScanning || isReadingLicense)
                                }
                                
                                #if canImport(UIKit)
                                if PassportManager.isMRZScanningAvailable() {
                                    Button(action: {
                                        showPassportMRZScanner = true
                                    }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 20))
                                            Text("Scan Passport MRZ (Machine Readable Zone)")
                                                .font(AppDesign.Typography.headline)
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        .padding(.vertical, AppDesign.Spacing.md)
                                        .padding(.horizontal, AppDesign.Spacing.md)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue, Color.purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(AppDesign.Radius.medium)
                                    }
                                    .disabled(passportManager.isScanning || isReadingLicense)
                                }
                                #endif
                                
                                if !passportManager.scanProgress.isEmpty {
                                    Text(passportManager.scanProgress)
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                        .padding(.top, AppDesign.Spacing.xs)
                                }
                                
                                if let error = passportManager.errorMessage {
                                    Text(error)
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.error)
                                        .padding(.top, AppDesign.Spacing.xs)
                                }
                            }
                        }
                        .padding(.horizontal, AppDesign.Spacing.md)
                    }
                    
                    if let error = licenseReadError {
                        Text(error)
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.error)
                            .padding(.horizontal, AppDesign.Spacing.md)
                    }
                }
                .sheet(isPresented: $showPassportMRZScanner) {
                    PassportMRZScannerView(passportManager: passportManager) { passportData in
                        if let data = passportData {
                            populateDataFromPassport(data)
                        }
                        showPassportMRZScanner = false
                    }
                }
                .sheet(isPresented: $showExternalHealthCapture) {
                    ExternalHealthCaptureView()
                }
                
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
                        
                        // Wrist Pulse Measurements
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                Image(systemName: "heart.pulse.fill")
                                    .foregroundColor(AppDesign.Colors.primary)
                                    .frame(width: 20)
                                Text("Wrist Pulse")
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            ModernInputField(
                                title: "Resting Pulse",
                                value: $restingPulse,
                                icon: "heart.fill",
                                unit: "bpm"
                            )
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            
                            ModernInputField(
                                title: "Active Pulse",
                                value: $activePulse,
                                icon: "heart.circle.fill",
                                unit: "bpm"
                            )
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            
                            ModernInputField(
                                title: "Maximum Pulse",
                                value: $maxPulse,
                                icon: "heart.circle.fill",
                                unit: "bpm"
                            )
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            
                            ModernPickerField(
                                title: "Measurement Method",
                                selection: $pulseMeasurementMethod,
                                options: HealthData.WristPulse.PulseMeasurementMethod.allCases,
                                icon: "waveform.path.ecg"
                            )
                        }
                        .padding(.top, AppDesign.Spacing.sm)
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
    private var dentalFitnessStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "tooth",
                    title: "Dental Fitness",
                    description: "Track your daily dental hygiene routine"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        ModernInputField(
                            title: "Daily Teeth Brushing",
                            value: $dailyTeethScrubs,
                            icon: "tooth.fill",
                            unit: "times/day"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Daily Flossing",
                            value: $dailyFlossingCount,
                            icon: "line.3.horizontal",
                            unit: "times/day"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Daily Mouthwash",
                            value: $dailyMouthwashCleans,
                            icon: "drop.fill",
                            unit: "times/day"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Daily Tongue Scraping",
                            value: $dailyTongueScrapes,
                            icon: "mouth",
                            unit: "times/day"
                        )
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        
                        ModernInputField(
                            title: "Dental Concerns (optional)",
                            value: $dentalConcerns,
                            icon: "exclamationmark.triangle.fill",
                            placeholder: "e.g., sensitivity, gum issues"
                        )
                        
                        ModernInputField(
                            title: "Dental Medications (optional)",
                            value: $dentalMedications,
                            icon: "pills.fill",
                            placeholder: "e.g., fluoride, mouthwash type"
                        )
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Step 10: External Health
    private var externalHealthStep: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                stepHeader(
                    icon: "camera.fill",
                    title: "External Health Analysis",
                    description: "Capture images of external body parts (skin, eyes, nose, nails, hair, beard) for Vision framework analysis"
                )
                
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        Text("Use the camera to capture images of external body parts for health analysis. The Vision framework will analyze these images for potential health conditions.")
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            showExternalHealthCapture = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Open External Health Capture")
                                    .font(AppDesign.Typography.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppDesign.Spacing.md)
                            .background(
                                LinearGradient(
                                    colors: [AppDesign.Colors.primary, AppDesign.Colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(AppDesign.Radius.medium)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            .padding(.top, AppDesign.Spacing.lg)
            .padding(.bottom, 100)
        }
    }
    
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
                                Text("Use Custom Duration (3 months to 10+ years)")
                                    .font(AppDesign.Typography.body)
                            }
                            .padding(.vertical, AppDesign.Spacing.xs)
                            
                            if useCustomDuration {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                    ModernInputField(
                                        title: "Duration",
                                        value: $customDurationYears,
                                        icon: "calendar.badge.clock",
                                        unit: "years (e.g., 0.25 for 3 months, 1 for 1 year)"
                                    )
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                    
                                    Text("Enter duration in years (0.25 = 3 months, 0.5 = 6 months, 1 = 1 year, etc.)")
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
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
                            
                            Text(planDurationDisplayText)
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
        
        // Add wrist pulse measurements
        var pulseData: HealthData.WristPulse? = nil
        if let resting = Int(restingPulse), !restingPulse.isEmpty {
            pulseData = HealthData.WristPulse(
                restingPulse: resting,
                activePulse: Int(activePulse).flatMap { !activePulse.isEmpty ? $0 : nil },
                maxPulse: Int(maxPulse).flatMap { !maxPulse.isEmpty ? $0 : nil },
                measurementDate: Date(),
                measurementMethod: pulseMeasurementMethod
            )
        } else if let active = Int(activePulse), !activePulse.isEmpty {
            pulseData = HealthData.WristPulse(
                restingPulse: nil,
                activePulse: active,
                maxPulse: Int(maxPulse).flatMap { !maxPulse.isEmpty ? $0 : nil },
                measurementDate: Date(),
                measurementMethod: pulseMeasurementMethod
            )
        } else if let max = Int(maxPulse), !maxPulse.isEmpty {
            pulseData = HealthData.WristPulse(
                restingPulse: nil,
                activePulse: nil,
                maxPulse: max,
                measurementDate: Date(),
                measurementMethod: pulseMeasurementMethod
            )
        }
        if pulseData != nil {
            healthData.wristPulse = pulseData
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
        
        // Add dental fitness data
        healthData.dentalFitness = HealthData.DentalFitness(
            dailyTeethScrubs: Int(dailyTeethScrubs) ?? 2,
            dailyFlossingCount: Int(dailyFlossingCount) ?? 1,
            dailyMouthwashCleans: Int(dailyMouthwashCleans) ?? 1,
            dailyTongueScrapes: Int(dailyTongueScrapes) ?? 1,
            lastDentalCheckup: nil,
            nextDentalCheckup: nil,
            dentalConcerns: dentalConcerns.isEmpty ? [] : dentalConcerns.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            dentalMedications: dentalMedications.isEmpty ? [] : dentalMedications.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
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
            // Parse custom duration (can be in years as decimal, e.g., 0.25 for 3 months)
            if let years = Double(customDurationYears), years > 0 {
                // Use closest matching duration based on years
                if years < 0.5 {
                    // Less than 6 months - use 3 months
                    finalDuration = .threeMonths
                    totalDays = 90
                } else if years < 1.0 {
                    // 6 months to 1 year
                    finalDuration = .sixMonths
                    totalDays = 180
                } else if years <= 1.0 {
                    finalDuration = .oneYear
                    totalDays = 365
                } else if years <= 2.0 {
                    finalDuration = .twoYears
                    totalDays = 730
                } else if years <= 5.0 {
                    finalDuration = .fiveYears
                    totalDays = 1825
                } else {
                    finalDuration = .tenYears // Use 10 years as base for longer plans
                    totalDays = Int(years * 365.0) // Calculate actual days for custom duration
                }
            } else {
                // Invalid input, use default
                finalDuration = planDuration
                totalDays = planDuration.days
            }
        } else {
            finalDuration = planDuration
            totalDays = planDuration.days
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.generationProgress = 0.6
            self.generationStatus = "Generating transformation goals..."
        }
        
        // Generate long-term plan with enhanced generator (on-device, anonymized)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.generationProgress = 0.7
            let yearsText = totalDays >= 365 ? "\(totalDays / 365) year" : "\(totalDays) day"
            self.generationStatus = "Creating personalized \(yearsText) plan with AI insights..."
            
            // Generate the plan (all processing happens on-device with anonymized data)
            // Pass custom days if duration exceeds enum limit
            let customDays = (useCustomDuration && totalDays > finalDuration.days) ? totalDays : nil // Calculate custom days
            viewModel.generateLongTermPlan(duration: finalDuration, urgency: urgencyLevel, customDays: customDays)
            
            // Check plan generation progress
            self.checkPlanGenerationProgress(totalDays: totalDays, startTime: Date())
        }
    }
    
    // MARK: - Check Plan Generation Progress
    private func checkPlanGenerationProgress(totalDays: Int, startTime: Date) {
        // Poll for plan completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Check if plan is generated
            if self.viewModel.longTermPlan != nil {
                self.generationProgress = 0.85
                self.generationStatus = "Plan structure created. Generating daily plans..."
                
                // Check for daily plans completion
                self.checkDailyPlansProgress(totalDays: totalDays)
            } else {
                // Plan not ready yet, check again
                self.checkPlanGenerationProgress(totalDays: totalDays, startTime: startTime)
            }
        }
    }
    
    // MARK: - Read Driver's License from Wallet
    #if os(iOS)
    @available(iOS 16.0, *)
    private func readDriversLicenseFromWallet() {
        isReadingLicense = true
        licenseReadError = nil
        
        Task {
            let walletManager = WalletManager()
            if let licenseData = await walletManager.readDriversLicense() {
                await MainActor.run {
                    // Pre-populate age if available
                    populateAgeFromLicenseData(licenseData.age, dateOfBirth: licenseData.dateOfBirth)
                    isReadingLicense = false
                }
            } else {
                await MainActor.run {
                    isReadingLicense = false
                    licenseReadError = walletManager.errorMessage ?? "Failed to read driver's license"
                }
            }
        }
    }
    #endif
    
    // MARK: - Read Driver's License with NFC
    private func readDriversLicenseWithNFC() {
        guard NFCManager.isAvailable() else { // Check if NFC available
            licenseReadError = "NFC reading is not available on this device" // Set error message
            return // Return early
        }
        
        nfcManager.errorMessage = nil // Clear error message
        nfcManager.scanProgress = "" // Clear progress
        
        nfcManager.startScanning { licenseData in // Start NFC scanning
            DispatchQueue.main.async { // Switch to main thread
                if let data = licenseData { // Check if data received
                    // Pre-populate age if available
                    self.populateAgeFromLicenseData(data.age, dateOfBirth: data.dateOfBirth) // Populate age
                    self.licenseReadError = nil // Clear error
                } else { // If no data
                    if let error = self.nfcManager.errorMessage { // Check if error exists
                        self.licenseReadError = error // Set error message
                    }
                }
            }
        }
    }
    
    // MARK: - Read Passport with NFC
    private func readPassportWithNFC() {
        guard PassportManager.isAvailable() else { // Check if passport reading available
            licenseReadError = "Passport NFC reading is not available on this device" // Set error message
            return // Return early
        }
        
        passportManager.errorMessage = nil // Clear error message
        passportManager.scanProgress = "" // Clear progress
        
        passportManager.startScanning { passportData in // Start passport scanning
            DispatchQueue.main.async { // Switch to main thread
                if let data = passportData { // Check if data received
                    // Pre-populate data from passport
                    self.populateDataFromPassport(data) // Populate data
                    self.licenseReadError = nil // Clear error
                } else { // If no data
                    if let error = self.passportManager.errorMessage { // Check if error exists
                        self.licenseReadError = error // Set error message
                    }
                }
            }
        }
    }
    
    // MARK: - Populate Data from Passport
    private func populateDataFromPassport(_ passportData: PassportData) { // Populate wizard fields from passport data
        // Pre-populate age
        populateAgeFromLicenseData(passportData.age, dateOfBirth: passportData.dateOfBirth) // Populate age
        
        // Pre-populate gender if available
        if let healthDataGender = passportData.toHealthDataGender() { // Check if gender can be converted
            gender = healthDataGender // Set gender
        }
    }
    
    // MARK: - Populate Age from License Data
    private func populateAgeFromLicenseData(_ calculatedAge: Int?, dateOfBirth: Date?) { // Populate age field from license data
        if let ageValue = calculatedAge { // Check if calculated age available
            age = String(ageValue) // Set age string
        } else if let dob = dateOfBirth { // Check if date of birth available
            let calendar = Calendar.current // Get calendar instance
            let ageComponents = calendar.dateComponents([.year], from: dob, to: Date()) // Calculate age components
            if let years = ageComponents.year { // Check if years available
                age = String(years) // Set age string
            }
        }
    }
    
    // MARK: - Check Daily Plans Progress
    private func checkDailyPlansProgress(totalDays: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let currentCount = self.viewModel.dailyPlans.count
            
            if currentCount > 0 {
                self.generationProgress = 0.7 + (Double(currentCount) / Double(totalDays)) * 0.2
                self.generationStatus = "Generated \(currentCount) of \(totalDays) daily plans..."
            }
            
            if currentCount >= totalDays {
                // All plans generated
                self.generationProgress = 1.0
                self.generationStatus = "Plan generated successfully! \(totalDays) days ready with personalized recommendations."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isGeneratingPlan = false
                    self.dismiss?()
                }
            } else {
                // Continue checking
                self.checkDailyPlansProgress(totalDays: totalDays)
            }
        }
    }
    
}

// MARK: - Health Wizard Wrapper
struct HealthWizardViewWrapper: View {
    @EnvironmentObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HealthWizardView(viewModel: viewModel, dismiss: { dismiss() })
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Ensure proper window lifecycle on macOS
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Window is ready - give extra time for sheet to fully initialize
            }
        }
        .onDisappear {
            // Clean up when wrapper disappears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Allow proper cleanup
            }
        }
        #endif
    }
}
