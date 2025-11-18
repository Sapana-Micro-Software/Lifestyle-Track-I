//
//  HealthData.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - User Health Data
struct HealthData: Codable { // Define HealthData struct conforming to Codable protocol for encoding/decoding
    var glucose: Double? // mg/dL
    var hemoglobin: Double? // g/dL
    var cholesterol: Double? // mg/dL
    var bloodPressure: BloodPressure?
    var age: Int
    var gender: Gender
    var weight: Double // kg
    var height: Double // cm
    var activityLevel: ActivityLevel
    
    // Exercise & Fitness
    var exerciseLogs: [DailyExerciseLog] = []
    var exerciseGoals: ExerciseGoals?
    var muscleMass: Double? // kg
    var bodyFatPercentage: Double? // %
    
    // Sexual Health
    var sexualHealth: SexualHealth?
    
    // Mental Health
    var mentalHealth: MentalHealth?
    
    // Medical Tests
    var medicalTests: MedicalTestCollection = MedicalTestCollection() // Initialize medical test collection with empty collection
    var medicalAnalysis: MedicalAnalysisReport? // Optional medical analysis report from test results
    
    // Cognitive Assessment
    var cognitiveAssessments: [CognitiveAssessment] = [] // Array of cognitive assessment results over time
    
    // Medical Specialties
    var medicalSpecialties: MedicalSpecialtyCollection = MedicalSpecialtyCollection() // Collection of specialty medical analyses
    
    // Sleep Data
    var sleepRecords: [SleepRecord] = [] // Array of sleep records for tracking sleep patterns
    var sleepAnalysis: SleepAnalysis? // Optional sleep analysis with recommendations and averages
    
    // Journal Data
    var journalCollection: JournalCollection = JournalCollection() // Journal collection for structured and unstructured entries
    
    // Vision Data
    var visionPrescription: VisionPrescription? // Optional vision prescription data
    var dailyVisionChecks: [DailyVisionCheck] = [] // Array of daily vision check records
    var visionGameSessions: [VisionGameSession] = [] // Array of vision game play sessions
    var visionAnalysis: VisionAnalysisReport? // Optional vision analysis report
    
    // Hearing Data
    var hearingPrescription: HearingPrescription? // Optional hearing prescription data
    var dailyAudioHearingTests: [DailyAudioHearingTest] = [] // Array of daily audio hearing test records
    var musicHearingSessions: [MusicHearingSession] = [] // Array of music hearing sessions
    var hearingAnalysis: HearingAnalysisReport? // Optional hearing analysis report
    
    // Tactile Data
    var tactilePrescription: TactilePrescription? // Optional tactile prescription data
    var dailyTactileTests: [DailyTactileTest] = [] // Array of daily tactile test records
    var tactileVitalitySessions: [TactileVitalitySession] = [] // Array of tactile vitality sessions
    var tactileAnalysis: TactileAnalysisReport? // Optional tactile analysis report
    
    // Tongue Data
    var tonguePrescription: TonguePrescription? // Optional tongue prescription data
    var dailyTongueTests: [DailyTongueTest] = [] // Array of daily tongue test records
    var tongueVitalitySessions: [TongueVitalitySession] = [] // Array of tongue vitality sessions
    var tongueAnalysis: TongueAnalysisReport? // Optional tongue analysis report
    
    // HealthKit Data
    var healthKitBiomarkers: [HealthKitBiomarkers] = [] // Array of HealthKit biomarker readings
    
    enum Gender: String, Codable, CaseIterable {
        case male, female, other
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case light = "Lightly Active"
        case moderate = "Moderately Active"
        case active = "Very Active"
        case extraActive = "Extra Active"
        
        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .light: return 1.375
            case .moderate: return 1.55
            case .active: return 1.725
            case .extraActive: return 1.9
            }
        }
    }
    
    struct BloodPressure: Codable {
        var systolic: Int
        var diastolic: Int
    }
    
    struct SexualHealth: Codable {
        var libidoLevel: LibidoLevel
        var concerns: [String]
        var medications: [String]
        
        enum LibidoLevel: String, Codable, CaseIterable {
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
        }
    }
    
    struct MentalHealth: Codable {
        var stressLevel: StressLevel
        var anxietyLevel: AnxietyLevel
        var depressionSymptoms: [String]
        var currentTherapy: Bool
        var medications: [String]
        var sleepQuality: SleepQuality
        
        enum StressLevel: String, Codable, CaseIterable {
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
            case veryHigh = "Very High"
        }
        
        enum AnxietyLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
        
        enum SleepQuality: String, Codable, CaseIterable {
            case poor = "Poor"
            case fair = "Fair"
            case good = "Good"
            case excellent = "Excellent"
        }
    }
    
    func adjustedCalorieRequirement() -> Double {
        let baseCalories: Double
        if gender == .male {
            baseCalories = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            baseCalories = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
        
        var multiplier = activityLevel.multiplier
        
        // Adjust for exercise
        if let recentLog = exerciseLogs.last {
            let exerciseCalories = recentLog.totalCaloriesBurned
            // Add 50% of exercise calories to account for EPOC (Excess Post-Exercise Oxygen Consumption)
            multiplier += (exerciseCalories / baseCalories) * 0.5
        }
        
        // Adjust for muscle mass (higher muscle mass = higher metabolism)
        if let muscleMass = muscleMass {
            let musclePercentage = (muscleMass / weight) * 100
            if musclePercentage > 40 { // Above average muscle mass
                multiplier += 0.1
            }
        }
        
        return baseCalories * multiplier
    }
    
    func adjustedNutrientRequirements() -> [String: NutrientRequirement] {
        let base = gender == .male ? USDANutrientGuidelines.adultMale : USDANutrientGuidelines.adultFemale
        var adjusted = base
        
        // Use medical test data if available, otherwise use basic health data
        if let latestBlood = medicalTests.bloodTests.last {
            // Adjust based on glucose from blood test
            if let testGlucose = latestBlood.glucose {
                if testGlucose > 140 {
                    if var carbs = adjusted["carbs"] {
                        carbs.dailyValue *= 0.7
                        adjusted["carbs"] = carbs
                    }
                }
            }
            
            // Adjust based on hemoglobin from blood test
            if let testHemoglobin = latestBlood.hemoglobin {
                if testHemoglobin < 12 {
                    if var iron = adjusted["iron"] {
                        iron.dailyValue *= 1.5
                        adjusted["iron"] = iron
                    }
                }
            }
            
            // Adjust based on vitamin deficiencies
            if let vitD = latestBlood.vitaminD {
                if vitD < 30 {
                    if var vitDReq = adjusted["vitamin_d"] {
                        vitDReq.dailyValue *= 1.5
                        adjusted["vitamin_d"] = vitDReq
                    }
                }
            }
            
            if let vitB12 = latestBlood.vitaminB12 {
                if vitB12 < 200 {
                    if var b12Req = adjusted["vitamin_b12"] {
                        b12Req.dailyValue *= 2.0
                        adjusted["vitamin_b12"] = b12Req
                    }
                }
            }
            
            // Adjust based on iron status
            if let ferritin = latestBlood.ferritin {
                if ferritin < 15 {
                    if var iron = adjusted["iron"] {
                        iron.dailyValue *= 1.8
                        adjusted["iron"] = iron
                    }
                }
            }
        } else {
            // Fallback to basic health data
            if let glucose = glucose {
                if glucose > 140 {
                    if var carbs = adjusted["carbs"] {
                        carbs.dailyValue *= 0.7
                        adjusted["carbs"] = carbs
                    }
                }
            }
            
            if let hemoglobin = hemoglobin {
                if hemoglobin < 12 {
                    if var iron = adjusted["iron"] {
                        iron.dailyValue *= 1.5
                        adjusted["iron"] = iron
                    }
                }
            }
        }
        
        // Use urine analysis for ketone monitoring
        if let latestUrine = medicalTests.urineAnalyses.last {
            if let ketones = latestUrine.ketones, ketones > 0 {
                // If ketones present, may need to adjust macronutrients
                // This would depend on whether user is intentionally in ketosis
            }
        }
        
        // Use hair analysis for heavy metal concerns
        if let latestHair = medicalTests.hairAnalyses.last {
            if let mercury = latestHair.mercury, mercury > 1.0 {
                // Increase selenium for mercury detoxification
                if var selenium = adjusted["selenium"] {
                    selenium.dailyValue *= 1.3
                    adjusted["selenium"] = selenium
                }
            }
            
            if let lead = latestHair.lead, lead > 1.0 {
                // Increase calcium and iron for lead binding
                if var calcium = adjusted["calcium"] {
                    calcium.dailyValue *= 1.2
                    adjusted["calcium"] = calcium
                }
            }
        }
        
        // Adjust calories based on activity and exercise
        if var calories = adjusted["calories"] {
            calories.dailyValue = adjustedCalorieRequirement()
            adjusted["calories"] = calories
        }
        
        // Adjust protein for muscle building if doing strength training
        if let recentLog = exerciseLogs.last {
            let hasStrengthTraining = recentLog.sessions.contains { session in
                session.activity.category == .strength
            }
            if hasStrengthTraining, var protein = adjusted["protein"] {
                // Increase protein for muscle recovery and growth
                protein.dailyValue *= 1.3
                adjusted["protein"] = protein
            }
        }
        
        // Adjust nutrients for mental health
        if let mentalHealth = mentalHealth {
            // Increase B vitamins and magnesium for stress
            if mentalHealth.stressLevel == .high || mentalHealth.stressLevel == .veryHigh {
                if var magnesium = adjusted["magnesium"] {
                    magnesium.dailyValue *= 1.2
                    adjusted["magnesium"] = magnesium
                }
                if var thiamin = adjusted["thiamin"] {
                    thiamin.dailyValue *= 1.2
                    adjusted["thiamin"] = thiamin
                }
            }
            
            // Increase omega-3 for mood support
            // (Note: omega-3 not in base requirements, would need to add)
        }
        
        // Adjust for sexual health
        if let sexualHealth = sexualHealth {
            if sexualHealth.libidoLevel == .low {
                // Increase zinc and vitamin D for hormonal health
                if var zinc = adjusted["zinc"] {
                    zinc.dailyValue *= 1.2
                    adjusted["zinc"] = zinc
                }
                if var vitaminD = adjusted["vitamin_d"] {
                    vitaminD.dailyValue *= 1.2
                    adjusted["vitamin_d"] = vitaminD
                }
            }
        }
        
        return adjusted
    }
}
