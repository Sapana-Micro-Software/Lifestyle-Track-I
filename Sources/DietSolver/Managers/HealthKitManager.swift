//
//  HealthKitManager.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
import HealthKit // Import HealthKit framework for health data access

// MARK: - HealthKit Biomarkers
struct HealthKitBiomarkers: Codable { // Define HealthKitBiomarkers struct for health data from HealthKit
    var date: Date // Date of biomarker collection
    var heartRate: HeartRateData? // Optional heart rate data
    var bloodPressure: BloodPressureData? // Optional blood pressure data
    var bodyMetrics: BodyMetricsData? // Optional body metrics data
    var activity: ActivityData? // Optional activity data
    var sleep: SleepData? // Optional sleep data
    var respiratory: RespiratoryData? // Optional respiratory data
    var cardiovascular: CardiovascularData? // Optional cardiovascular data
    var nutrition: NutritionData? // Optional nutrition data
    var mindfulness: MindfulnessData? // Optional mindfulness data
    
    struct HeartRateData: Codable { // Nested struct for heart rate data
        var resting: Double? // Optional resting heart rate in BPM
        var average: Double? // Optional average heart rate in BPM
        var max: Double? // Optional maximum heart rate in BPM
        var min: Double? // Optional minimum heart rate in BPM
        var heartRateVariability: Double? // Optional heart rate variability in milliseconds
        var walkingAverage: Double? // Optional walking average heart rate in BPM
    }
    
    struct BloodPressureData: Codable { // Nested struct for blood pressure data
        var systolic: Double // Systolic blood pressure in mmHg
        var diastolic: Double // Diastolic blood pressure in mmHg
        var timestamp: Date // Timestamp of measurement
    }
    
    struct BodyMetricsData: Codable { // Nested struct for body metrics data
        var weight: Double? // Optional weight in kilograms
        var bodyFatPercentage: Double? // Optional body fat percentage
        var leanBodyMass: Double? // Optional lean body mass in kilograms
        var bodyMassIndex: Double? // Optional BMI
        var height: Double? // Optional height in meters
        var waistCircumference: Double? // Optional waist circumference in centimeters
    }
    
    struct ActivityData: Codable { // Nested struct for activity data
        var steps: Int? // Optional step count
        var distance: Double? // Optional distance in meters
        var activeEnergyBurned: Double? // Optional active energy burned in kilocalories
        var basalEnergyBurned: Double? // Optional basal energy burned in kilocalories
        var flightsClimbed: Int? // Optional flights climbed
        var exerciseTime: TimeInterval? // Optional exercise time in seconds
        var standTime: TimeInterval? // Optional stand time in seconds
    }
    
    struct SleepData: Codable { // Nested struct for sleep data
        var totalSleepTime: TimeInterval? // Optional total sleep time in seconds
        var deepSleep: TimeInterval? // Optional deep sleep time in seconds
        var remSleep: TimeInterval? // Optional REM sleep time in seconds
        var lightSleep: TimeInterval? // Optional light sleep time in seconds
        var awakeTime: TimeInterval? // Optional awake time in seconds
        var sleepEfficiency: Double? // Optional sleep efficiency percentage
    }
    
    struct RespiratoryData: Codable { // Nested struct for respiratory data
        var respiratoryRate: Double? // Optional respiratory rate in breaths per minute
        var vo2Max: Double? // Optional VO2 max in mL/kg/min
        var forcedVitalCapacity: Double? // Optional forced vital capacity in liters
        var forcedExpiratoryVolume: Double? // Optional forced expiratory volume in liters
    }
    
    struct CardiovascularData: Codable { // Nested struct for cardiovascular data
        var restingHeartRate: Double? // Optional resting heart rate in BPM
        var walkingHeartRateAverage: Double? // Optional walking heart rate average in BPM
        var heartRateRecovery: Double? // Optional heart rate recovery in BPM
        var electrocardiogram: ECGData? // Optional ECG data
    }
    
    struct ECGData: Codable { // Nested struct for ECG data
        var averageHeartRate: Double? // Optional average heart rate from ECG
        var classification: ECGClassification? // Optional ECG classification
        var symptoms: [String] // Array of symptoms reported
        var timestamp: Date // Timestamp of ECG reading
        
        enum ECGClassification: String, Codable { // Enum for ECG classifications
            case sinusRhythm = "Sinus Rhythm" // Normal sinus rhythm
            case atrialFibrillation = "Atrial Fibrillation" // Atrial fibrillation detected
            case highHeartRate = "High Heart Rate" // High heart rate detected
            case lowHeartRate = "Low Heart Rate" // Low heart rate detected
            case inconclusive = "Inconclusive" // Inconclusive reading
        }
    }
    
    struct NutritionData: Codable { // Nested struct for nutrition data
        var water: Double? // Optional water intake in liters
        var caffeine: Double? // Optional caffeine intake in milligrams
        var dietaryEnergy: Double? // Optional dietary energy in kilocalories
    }
    
    struct MindfulnessData: Codable { // Nested struct for mindfulness data
        var mindfulMinutes: TimeInterval? // Optional mindful minutes in seconds
        var sessions: Int? // Optional number of mindfulness sessions
    }
    
    init(date: Date = Date(), heartRate: HeartRateData? = nil, bloodPressure: BloodPressureData? = nil, bodyMetrics: BodyMetricsData? = nil, activity: ActivityData? = nil, sleep: SleepData? = nil, respiratory: RespiratoryData? = nil, cardiovascular: CardiovascularData? = nil, nutrition: NutritionData? = nil, mindfulness: MindfulnessData? = nil) {
        self.date = date // Initialize date
        self.heartRate = heartRate // Initialize heart rate data
        self.bloodPressure = bloodPressure // Initialize blood pressure data
        self.bodyMetrics = bodyMetrics // Initialize body metrics data
        self.activity = activity // Initialize activity data
        self.sleep = sleep // Initialize sleep data
        self.respiratory = respiratory // Initialize respiratory data
        self.cardiovascular = cardiovascular // Initialize cardiovascular data
        self.nutrition = nutrition // Initialize nutrition data
        self.mindfulness = mindfulness // Initialize mindfulness data
    }
}

// MARK: - HealthKit Manager
class HealthKitManager { // Define HealthKitManager class for managing HealthKit access
    private let healthStore = HKHealthStore() // Private HealthKit health store instance
    
    func requestAuthorization() async -> Bool { // Async function to request HealthKit authorization
        guard HKHealthStore.isHealthDataAvailable() else { // Check if HealthKit is available
            return false // Return false if not available
        }
        
        let typesToRead: Set<HKObjectType> = [ // Set of types to read from HealthKit
            HKObjectType.quantityType(forIdentifier: .heartRate)!, // Heart rate type
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!, // Systolic BP type
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!, // Diastolic BP type
            HKObjectType.quantityType(forIdentifier: .bodyMass)!, // Body mass type
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!, // Body fat percentage type
            HKObjectType.quantityType(forIdentifier: .height)!, // Height type
            HKObjectType.quantityType(forIdentifier: .stepCount)!, // Step count type
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, // Distance type
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, // Active energy type
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!, // Basal energy type
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!, // Flights climbed type
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, // Sleep analysis type
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!, // Respiratory rate type
            HKObjectType.quantityType(forIdentifier: .vo2Max)!, // VO2 max type
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, // HRV type
            HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)!, // High heart rate event type
            HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)!, // Low heart rate event type
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!, // Water intake type
            HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!, // Caffeine intake type
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)! // Dietary energy type
        ]
        
        do { // Try to request authorization
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead) // Request read authorization
            return true // Return true on success
        } catch { // Catch errors
            return false // Return false on error
        }
    }
    
    func readBiomarkers(for date: Date = Date()) async -> HealthKitBiomarkers? { // Async function to read biomarkers
        let calendar = Calendar.current // Get calendar instance
        let startDate = calendar.startOfDay(for: date) // Get start of day
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate // Get end of day
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate) // Create date predicate
        
        var biomarkers = HealthKitBiomarkers(date: date) // Initialize biomarkers struct
        
        // Read heart rate
        if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) { // Check if heart rate type exists
            let heartRateData = await readQuantitySamples(type: heartRateType, predicate: predicate) // Read heart rate samples
            if !heartRateData.isEmpty { // Check if data exists
                let values = heartRateData.map { $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) } // Convert to BPM
                biomarkers.heartRate = HealthKitBiomarkers.HeartRateData( // Create heart rate data
                    resting: values.min(), // Set minimum as resting
                    average: values.reduce(0, +) / Double(values.count), // Calculate average
                    max: values.max(), // Set maximum
                    min: values.min(), // Set minimum
                    heartRateVariability: nil, // Set HRV to nil (would need separate query)
                    walkingAverage: nil // Set walking average to nil
                )
            }
        }
        
        // Read blood pressure
        if let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic), // Check if systolic type exists
           let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) { // Check if diastolic type exists
            let systolicData = await readQuantitySamples(type: systolicType, predicate: predicate) // Read systolic samples
            let diastolicData = await readQuantitySamples(type: diastolicType, predicate: predicate) // Read diastolic samples
            if !systolicData.isEmpty && !diastolicData.isEmpty { // Check if data exists
                let systolic = systolicData.last!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()) // Get last systolic value
                let diastolic = diastolicData.last!.quantity.doubleValue(for: HKUnit.millimeterOfMercury()) // Get last diastolic value
                biomarkers.bloodPressure = HealthKitBiomarkers.BloodPressureData( // Create blood pressure data
                    systolic: systolic, // Set systolic value
                    diastolic: diastolic, // Set diastolic value
                    timestamp: systolicData.last!.endDate // Set timestamp
                )
            }
        }
        
        // Read body metrics
        if let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) { // Check if weight type exists
            let weightData = await readQuantitySamples(type: weightType, predicate: predicate) // Read weight samples
            if let lastWeight = weightData.last { // Check if data exists
                let weight = lastWeight.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)) // Convert to kilograms
                biomarkers.bodyMetrics = HealthKitBiomarkers.BodyMetricsData( // Create body metrics data
                    weight: weight, // Set weight
                    bodyFatPercentage: nil, // Set body fat to nil
                    leanBodyMass: nil, // Set lean body mass to nil
                    bodyMassIndex: nil, // Set BMI to nil
                    height: nil, // Set height to nil
                    waistCircumference: nil // Set waist circumference to nil
                )
            }
        }
        
        // Read activity data
        if let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) { // Check if steps type exists
            let stepsData = await readQuantitySamples(type: stepsType, predicate: predicate) // Read step samples
            let totalSteps = stepsData.reduce(0) { $0 + $1.quantity.doubleValue(for: HKUnit.count()) } // Calculate total steps
            biomarkers.activity = HealthKitBiomarkers.ActivityData( // Create activity data
                steps: Int(totalSteps), // Set step count
                distance: nil, // Set distance to nil
                activeEnergyBurned: nil, // Set active energy to nil
                basalEnergyBurned: nil, // Set basal energy to nil
                flightsClimbed: nil, // Set flights climbed to nil
                exerciseTime: nil, // Set exercise time to nil
                standTime: nil // Set stand time to nil
            )
        }
        
        return biomarkers // Return biomarkers struct
    }
    
    private func readQuantitySamples(type: HKQuantityType, predicate: NSPredicate) async -> [HKQuantitySample] { // Private function to read quantity samples
        return await withCheckedContinuation { continuation in // Use continuation for async
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, samples, error in // Create sample query
                if let samples = samples as? [HKQuantitySample] { // Check if samples exist
                    continuation.resume(returning: samples) // Resume with samples
                } else { // If no samples
                    continuation.resume(returning: []) // Resume with empty array
                }
            }
            healthStore.execute(query) // Execute query
        }
    }
}
