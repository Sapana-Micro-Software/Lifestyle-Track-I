//
//  TactileData.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Tactile Prescription
struct TactilePrescription: Codable {
    var date: Date
    var expirationDate: Date?
    var bodyRegions: [BodyRegionAssessment]
    var sensitivityLevels: SensitivityLevels
    var notes: String?
    
    struct BodyRegionAssessment: Codable, Identifiable {
        let id: UUID
        var region: BodyRegion
        var baselineSensitivity: Double // 0-1 scale
        var pressureThreshold: Double // grams
        var temperatureThreshold: TemperatureThreshold
        var vibrationThreshold: Double // Hz
        var twoPointDiscrimination: Double // mm
        
        enum BodyRegion: String, Codable, CaseIterable {
            case fingertips = "Fingertips"
            case palms = "Palms"
            case soles = "Soles"
            case lips = "Lips"
            case face = "Face"
            case back = "Back"
            case chest = "Chest"
            case arms = "Arms"
            case legs = "Legs"
            case other = "Other"
        }
        
        struct TemperatureThreshold: Codable {
            var cold: Double // Celsius
            var hot: Double // Celsius
        }
        
        init(id: UUID = UUID(), region: BodyRegion, baselineSensitivity: Double = 1.0, pressureThreshold: Double = 0.1, temperatureThreshold: TemperatureThreshold = TemperatureThreshold(cold: 15.0, hot: 45.0), vibrationThreshold: Double = 10.0, twoPointDiscrimination: Double = 2.0) {
            self.id = id
            self.region = region
            self.baselineSensitivity = baselineSensitivity
            self.pressureThreshold = pressureThreshold
            self.temperatureThreshold = temperatureThreshold
            self.vibrationThreshold = vibrationThreshold
            self.twoPointDiscrimination = twoPointDiscrimination
        }
    }
    
    struct SensitivityLevels: Codable {
        var overall: SensitivityLevel
        var fineTouch: SensitivityLevel
        var pressure: SensitivityLevel
        var temperature: SensitivityLevel
        var vibration: SensitivityLevel
        
        enum SensitivityLevel: String, Codable {
            case normal = "Normal"
            case reduced = "Reduced"
            case enhanced = "Enhanced"
            case absent = "Absent"
        }
    }
    
    init(date: Date = Date(), expirationDate: Date? = nil, bodyRegions: [BodyRegionAssessment] = [], sensitivityLevels: SensitivityLevels = SensitivityLevels(overall: .normal, fineTouch: .normal, pressure: .normal, temperature: .normal, vibration: .normal), notes: String? = nil) {
        self.date = date
        self.expirationDate = expirationDate
        self.bodyRegions = bodyRegions
        self.sensitivityLevels = sensitivityLevels
        self.notes = notes
    }
}

// MARK: - Daily Tactile Test
struct DailyTactileTest: Codable, Identifiable {
    let id: UUID
    var date: Date
    var time: Date
    var testType: TestType
    var bodyRegion: TactilePrescription.BodyRegionAssessment.BodyRegion
    var results: TestResults
    var device: TestDevice
    var environment: TestEnvironment
    var notes: String?
    
    struct TestResults: Codable {
        var pressureSensitivity: Double? // 0-1 scale
        var temperatureSensitivity: TemperatureSensitivity?
        var vibrationSensitivity: Double? // 0-1 scale
        var twoPointDiscrimination: Double? // mm
        var textureDiscrimination: TextureDiscrimination?
        var painSensitivity: PainSensitivity?
        var numbness: NumbnessLevel?
        var tingling: TinglingLevel?
        
        struct TemperatureSensitivity: Codable {
            var cold: Double // 0-1 scale
            var hot: Double // 0-1 scale
        }
        
        struct TextureDiscrimination: Codable {
            var smooth: Double // 0-1 scale
            var rough: Double // 0-1 scale
            var soft: Double // 0-1 scale
            var hard: Double // 0-1 scale
        }
        
        struct PainSensitivity: Codable {
            var level: PainLevel
            var location: String?
            var duration: Double? // minutes
            
            enum PainLevel: String, Codable, CaseIterable {
                case none = "None"
                case mild = "Mild"
                case moderate = "Moderate"
                case severe = "Severe"
            }
        }
        
        enum NumbnessLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
            case complete = "Complete"
        }
        
        enum TinglingLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
    }
    
    enum TestType: String, Codable, CaseIterable {
        case pressure = "Pressure Sensitivity"
        case temperature = "Temperature Sensitivity"
        case vibration = "Vibration Sensitivity"
        case twoPoint = "Two-Point Discrimination"
        case texture = "Texture Discrimination"
        case comprehensive = "Comprehensive"
        case quick = "Quick Check"
    }
    
    enum TestDevice: String, Codable, CaseIterable {
        case monofilament = "Monofilament"
        case tuningFork = "Tuning Fork"
        case temperatureProbe = "Temperature Probe"
        case twoPointDiscriminator = "Two-Point Discriminator"
        case iphone = "iPhone"
        case ipad = "iPad"
        case appleWatch = "Apple Watch"
        case manual = "Manual"
        case other = "Other"
    }
    
    struct TestEnvironment: Codable {
        var roomTemperature: Double? // Celsius
        var skinTemperature: Double? // Celsius
        var humidity: Double? // percentage
        var timeSinceLastTest: TimeInterval?
        
        init(roomTemperature: Double? = nil, skinTemperature: Double? = nil, humidity: Double? = nil, timeSinceLastTest: TimeInterval? = nil) {
            self.roomTemperature = roomTemperature
            self.skinTemperature = skinTemperature
            self.humidity = humidity
            self.timeSinceLastTest = timeSinceLastTest
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), time: Date = Date(), testType: TestType = .quick, bodyRegion: TactilePrescription.BodyRegionAssessment.BodyRegion = .fingertips, results: TestResults = TestResults(), device: TestDevice = .manual, environment: TestEnvironment = TestEnvironment(), notes: String? = nil) {
        self.id = id
        self.date = date
        self.time = time
        self.testType = testType
        self.bodyRegion = bodyRegion
        self.results = results
        self.device = device
        self.environment = environment
        self.notes = notes
    }
}

// MARK: - Tactile Vitality Session
struct TactileVitalitySession: Codable, Identifiable {
    let id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var duration: Double // minutes
    var activityType: ActivityType
    var bodyRegions: [TactilePrescription.BodyRegionAssessment.BodyRegion]
    var intensity: IntensityLevel
    var sensations: Sensations
    var notes: String?
    
    enum ActivityType: String, Codable, CaseIterable {
        case massage = "Massage"
        case textureExploration = "Texture Exploration"
        case temperatureTherapy = "Temperature Therapy"
        case pressureTherapy = "Pressure Therapy"
        case vibrationTherapy = "Vibration Therapy"
        case tactileStimulation = "Tactile Stimulation"
        case sensoryIntegration = "Sensory Integration"
        case reflexology = "Reflexology"
        case acupressure = "Acupressure"
        case other = "Other"
    }
    
    enum IntensityLevel: String, Codable, CaseIterable {
        case veryLight = "Very Light"
        case light = "Light"
        case moderate = "Moderate"
        case strong = "Strong"
        case veryStrong = "Very Strong"
    }
    
    struct Sensations: Codable {
        var comfort: ComfortLevel
        var awareness: AwarenessLevel
        var relaxation: RelaxationLevel
        var energy: EnergyLevel
        
        enum ComfortLevel: String, Codable, CaseIterable {
            case veryUncomfortable = "Very Uncomfortable"
            case uncomfortable = "Uncomfortable"
            case neutral = "Neutral"
            case comfortable = "Comfortable"
            case veryComfortable = "Very Comfortable"
        }
        
        enum AwarenessLevel: String, Codable, CaseIterable {
            case veryLow = "Very Low"
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
            case veryHigh = "Very High"
        }
        
        enum RelaxationLevel: String, Codable, CaseIterable {
            case veryLow = "Very Low"
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
            case veryHigh = "Very High"
        }
        
        enum EnergyLevel: String, Codable, CaseIterable {
            case veryLow = "Very Low"
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
            case veryHigh = "Very High"
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), startTime: Date = Date(), endTime: Date? = nil, duration: Double = 0, activityType: ActivityType = .other, bodyRegions: [TactilePrescription.BodyRegionAssessment.BodyRegion] = [], intensity: IntensityLevel = .moderate, sensations: Sensations = Sensations(comfort: .neutral, awareness: .moderate, relaxation: .moderate, energy: .moderate), notes: String? = nil) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.activityType = activityType
        self.bodyRegions = bodyRegions
        self.intensity = intensity
        self.sensations = sensations
        self.notes = notes
    }
}

// MARK: - Tactile Health Summary
struct TactileHealthSummary: Codable {
    var lastTestDate: Date?
    var averageSensitivity: Double? // 0-1 scale
    var trend: TactileTrend
    var recommendations: [String]
    var nextTestDue: Date?
    var vitalitySessionFrequency: Double? // sessions per week
    var averageSessionDuration: Double? // minutes
    
    enum TactileTrend: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
        case fluctuating = "Fluctuating"
    }
    
    init(lastTestDate: Date? = nil, averageSensitivity: Double? = nil, trend: TactileTrend = .stable, recommendations: [String] = [], nextTestDue: Date? = nil, vitalitySessionFrequency: Double? = nil, averageSessionDuration: Double? = nil) {
        self.lastTestDate = lastTestDate
        self.averageSensitivity = averageSensitivity
        self.trend = trend
        self.recommendations = recommendations
        self.nextTestDue = nextTestDue
        self.vitalitySessionFrequency = vitalitySessionFrequency
        self.averageSessionDuration = averageSessionDuration
    }
}

// MARK: - Tactile Analysis Report
struct TactileAnalysisReport: Codable {
    var date: Date
    var summary: TactileHealthSummary
    var testHistory: [DailyTactileTest]
    var vitalitySessionHistory: [TactileVitalitySession]
    var patterns: TactilePatterns
    var recommendations: [TactileRecommendation]
    
    struct TactilePatterns: Codable {
        var sensitivityTrends: String?
        var vitalityPatterns: String?
        var numbnessPatterns: String?
        var painPatterns: String?
        var regionSpecificTrends: String?
    }
    
    struct TactileRecommendation: Codable, Identifiable {
        let id: UUID
        var type: RecommendationType
        var priority: Priority
        var description: String
        var actionItems: [String]
        
        enum RecommendationType: String, Codable {
            case test = "Tactile Test"
            case vitality = "Vitality Session"
            case therapy = "Tactile Therapy"
            case exercise = "Tactile Exercise"
            case medical = "Medical Consultation"
            case lifestyle = "Lifestyle Change"
        }
        
        enum Priority: String, Codable {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
            case urgent = "Urgent"
        }
        
        init(id: UUID = UUID(), type: RecommendationType, priority: Priority, description: String, actionItems: [String] = []) {
            self.id = id
            self.type = type
            self.priority = priority
            self.description = description
            self.actionItems = actionItems
        }
    }
    
    init(date: Date = Date(), summary: TactileHealthSummary = TactileHealthSummary(), testHistory: [DailyTactileTest] = [], vitalitySessionHistory: [TactileVitalitySession] = [], patterns: TactilePatterns = TactilePatterns(), recommendations: [TactileRecommendation] = []) {
        self.date = date
        self.summary = summary
        self.testHistory = testHistory
        self.vitalitySessionHistory = vitalitySessionHistory
        self.patterns = patterns
        self.recommendations = recommendations
    }
}
