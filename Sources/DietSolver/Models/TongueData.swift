//
//  TongueData.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Tongue Prescription
struct TonguePrescription: Codable {
    var date: Date
    var expirationDate: Date?
    var baselineAppearance: TongueAppearance
    var tasteSensitivity: TasteSensitivity
    var mobilityAssessment: MobilityAssessment
    var notes: String?
    
    struct TongueAppearance: Codable {
        var color: TongueColor
        var coating: CoatingType
        var coatingThickness: CoatingThickness
        var moisture: MoistureLevel
        var texture: TextureType
        var size: SizeType
        var cracks: CracksPresence
        var spots: SpotsPresence
        
        enum TongueColor: String, Codable, CaseIterable {
            case pink = "Pink"
            case red = "Red"
            case pale = "Pale"
            case purple = "Purple"
            case yellow = "Yellow"
            case white = "White"
        }
        
        enum CoatingType: String, Codable, CaseIterable {
            case none = "None"
            case white = "White"
            case yellow = "Yellow"
            case brown = "Brown"
            case black = "Black"
            case thick = "Thick"
            case thin = "Thin"
        }
        
        enum CoatingThickness: String, Codable, CaseIterable {
            case none = "None"
            case thin = "Thin"
            case moderate = "Moderate"
            case thick = "Thick"
        }
        
        enum MoistureLevel: String, Codable, CaseIterable {
            case dry = "Dry"
            case normal = "Normal"
            case moist = "Moist"
            case veryMoist = "Very Moist"
        }
        
        enum TextureType: String, Codable, CaseIterable {
            case smooth = "Smooth"
            case rough = "Rough"
            case cracked = "Cracked"
            case geographic = "Geographic"
        }
        
        enum SizeType: String, Codable, CaseIterable {
            case normal = "Normal"
            case enlarged = "Enlarged"
            case small = "Small"
            case swollen = "Swollen"
        }
        
        enum CracksPresence: String, Codable, CaseIterable {
            case none = "None"
            case few = "Few"
            case many = "Many"
            case extensive = "Extensive"
        }
        
        enum SpotsPresence: String, Codable, CaseIterable {
            case none = "None"
            case few = "Few"
            case many = "Many"
            case extensive = "Extensive"
        }
    }
    
    struct TasteSensitivity: Codable {
        var sweet: SensitivityLevel
        var sour: SensitivityLevel
        var salty: SensitivityLevel
        var bitter: SensitivityLevel
        var umami: SensitivityLevel
        var overall: SensitivityLevel
        
        enum SensitivityLevel: String, Codable, CaseIterable {
            case normal = "Normal"
            case reduced = "Reduced"
            case enhanced = "Enhanced"
            case absent = "Absent"
        }
    }
    
    struct MobilityAssessment: Codable {
        var rangeOfMotion: RangeOfMotion
        var strength: StrengthLevel
        var coordination: CoordinationLevel
        var flexibility: FlexibilityLevel
        
        enum RangeOfMotion: String, Codable, CaseIterable {
            case normal = "Normal"
            case limited = "Limited"
            case restricted = "Restricted"
        }
        
        enum StrengthLevel: String, Codable, CaseIterable {
            case normal = "Normal"
            case weak = "Weak"
            case strong = "Strong"
        }
        
        enum CoordinationLevel: String, Codable, CaseIterable {
            case normal = "Normal"
            case impaired = "Impaired"
            case excellent = "Excellent"
        }
        
        enum FlexibilityLevel: String, Codable, CaseIterable {
            case normal = "Normal"
            case stiff = "Stiff"
            case flexible = "Flexible"
        }
    }
    
    init(date: Date = Date(), expirationDate: Date? = nil, baselineAppearance: TongueAppearance = TongueAppearance(color: .pink, coating: .none, coatingThickness: .none, moisture: .normal, texture: .smooth, size: .normal, cracks: .none, spots: .none), tasteSensitivity: TasteSensitivity = TasteSensitivity(sweet: .normal, sour: .normal, salty: .normal, bitter: .normal, umami: .normal, overall: .normal), mobilityAssessment: MobilityAssessment = MobilityAssessment(rangeOfMotion: .normal, strength: .normal, coordination: .normal, flexibility: .normal), notes: String? = nil) {
        self.date = date
        self.expirationDate = expirationDate
        self.baselineAppearance = baselineAppearance
        self.tasteSensitivity = tasteSensitivity
        self.mobilityAssessment = mobilityAssessment
        self.notes = notes
    }
}

// MARK: - Daily Tongue Test
struct DailyTongueTest: Codable, Identifiable {
    let id: UUID
    var date: Date
    var time: Date
    var testType: TestType
    var appearance: TonguePrescription.TongueAppearance
    var tasteTest: TasteTest?
    var mobilityTest: MobilityTest?
    var symptoms: Symptoms
    var device: TestDevice
    var notes: String?
    
    struct TasteTest: Codable {
        var sweet: Double // 0-1 scale
        var sour: Double // 0-1 scale
        var salty: Double // 0-1 scale
        var bitter: Double // 0-1 scale
        var umami: Double // 0-1 scale
        var overallScore: Double // 0-1 scale
    }
    
    struct MobilityTest: Codable {
        var rangeOfMotion: Double // 0-1 scale
        var strength: Double // 0-1 scale
        var coordination: Double // 0-1 scale
        var flexibility: Double // 0-1 scale
        var overallScore: Double // 0-1 scale
    }
    
    struct Symptoms: Codable {
        var pain: PainLevel
        var burning: BurningLevel
        var numbness: NumbnessLevel
        var swelling: SwellingLevel
        var discoloration: DiscolorationLevel
        
        enum PainLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
        
        enum BurningLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
        
        enum NumbnessLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
        
        enum SwellingLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
        
        enum DiscolorationLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
    }
    
    enum TestType: String, Codable, CaseIterable {
        case appearance = "Appearance Check"
        case taste = "Taste Test"
        case mobility = "Mobility Test"
        case comprehensive = "Comprehensive"
        case quick = "Quick Check"
    }
    
    enum TestDevice: String, Codable, CaseIterable {
        case mirror = "Mirror"
        case camera = "Camera"
        case iphone = "iPhone"
        case ipad = "iPad"
        case tasteStrips = "Taste Strips"
        case manual = "Manual"
        case other = "Other"
    }
    
    init(id: UUID = UUID(), date: Date = Date(), time: Date = Date(), testType: TestType = .quick, appearance: TonguePrescription.TongueAppearance = TonguePrescription.TongueAppearance(color: .pink, coating: .none, coatingThickness: .none, moisture: .normal, texture: .smooth, size: .normal, cracks: .none, spots: .none), tasteTest: TasteTest? = nil, mobilityTest: MobilityTest? = nil, symptoms: Symptoms = Symptoms(pain: .none, burning: .none, numbness: .none, swelling: .none, discoloration: .none), device: TestDevice = .mirror, notes: String? = nil) {
        self.id = id
        self.date = date
        self.time = time
        self.testType = testType
        self.appearance = appearance
        self.tasteTest = tasteTest
        self.mobilityTest = mobilityTest
        self.symptoms = symptoms
        self.device = device
        self.notes = notes
    }
}

// MARK: - Tongue Vitality Session
struct TongueVitalitySession: Codable, Identifiable {
    let id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var duration: Double // minutes
    var activityType: ActivityType
    var intensity: IntensityLevel
    var sensations: Sensations
    var notes: String?
    
    enum ActivityType: String, Codable, CaseIterable {
        case tongueExercises = "Tongue Exercises"
        case tasteTraining = "Taste Training"
        case oralHygiene = "Oral Hygiene"
        case tongueScraping = "Tongue Scraping"
        case oilPulling = "Oil Pulling"
        case tasteExploration = "Taste Exploration"
        case speechPractice = "Speech Practice"
        case therapeutic = "Therapeutic"
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
        var freshness: FreshnessLevel
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
        
        enum FreshnessLevel: String, Codable, CaseIterable {
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
    
    init(id: UUID = UUID(), date: Date = Date(), startTime: Date = Date(), endTime: Date? = nil, duration: Double = 0, activityType: ActivityType = .other, intensity: IntensityLevel = .moderate, sensations: Sensations = Sensations(comfort: .neutral, awareness: .moderate, freshness: .moderate, energy: .moderate), notes: String? = nil) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.activityType = activityType
        self.intensity = intensity
        self.sensations = sensations
        self.notes = notes
    }
}

// MARK: - Tongue Health Summary
struct TongueHealthSummary: Codable {
    var lastTestDate: Date?
    var averageTasteScore: Double? // 0-1 scale
    var averageMobilityScore: Double? // 0-1 scale
    var trend: TongueTrend
    var recommendations: [String]
    var nextTestDue: Date?
    var vitalitySessionFrequency: Double? // sessions per week
    var averageSessionDuration: Double? // minutes
    
    enum TongueTrend: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
        case fluctuating = "Fluctuating"
    }
    
    init(lastTestDate: Date? = nil, averageTasteScore: Double? = nil, averageMobilityScore: Double? = nil, trend: TongueTrend = .stable, recommendations: [String] = [], nextTestDue: Date? = nil, vitalitySessionFrequency: Double? = nil, averageSessionDuration: Double? = nil) {
        self.lastTestDate = lastTestDate
        self.averageTasteScore = averageTasteScore
        self.averageMobilityScore = averageMobilityScore
        self.trend = trend
        self.recommendations = recommendations
        self.nextTestDue = nextTestDue
        self.vitalitySessionFrequency = vitalitySessionFrequency
        self.averageSessionDuration = averageSessionDuration
    }
}

// MARK: - Tongue Analysis Report
struct TongueAnalysisReport: Codable {
    var date: Date
    var summary: TongueHealthSummary
    var testHistory: [DailyTongueTest]
    var vitalitySessionHistory: [TongueVitalitySession]
    var patterns: TonguePatterns
    var recommendations: [TongueRecommendation]
    
    struct TonguePatterns: Codable {
        var appearanceTrends: String?
        var tasteTrends: String?
        var mobilityTrends: String?
        var symptomPatterns: String?
        var vitalityPatterns: String?
    }
    
    struct TongueRecommendation: Codable, Identifiable {
        let id: UUID
        var type: RecommendationType
        var priority: Priority
        var description: String
        var actionItems: [String]
        
        enum RecommendationType: String, Codable {
            case test = "Tongue Test"
            case vitality = "Vitality Session"
            case therapy = "Tongue Therapy"
            case exercise = "Tongue Exercise"
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
    
    init(date: Date = Date(), summary: TongueHealthSummary = TongueHealthSummary(), testHistory: [DailyTongueTest] = [], vitalitySessionHistory: [TongueVitalitySession] = [], patterns: TonguePatterns = TonguePatterns(), recommendations: [TongueRecommendation] = []) {
        self.date = date
        self.summary = summary
        self.testHistory = testHistory
        self.vitalitySessionHistory = vitalitySessionHistory
        self.patterns = patterns
        self.recommendations = recommendations
    }
}
