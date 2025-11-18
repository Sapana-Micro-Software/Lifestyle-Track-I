//
//  VisionData.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Vision Prescription
struct VisionPrescription: Codable { // Define VisionPrescription struct for eye prescription data
    var date: Date // Date of prescription
    var expirationDate: Date? // Optional expiration date of prescription
    var rightEye: EyePrescription // Right eye prescription data
    var leftEye: EyePrescription // Left eye prescription data
    var pupillaryDistance: Double? // Optional pupillary distance in millimeters
    var notes: String? // Optional notes about prescription
    
    struct EyePrescription: Codable { // Nested struct for individual eye prescription
        var sphere: Double? // Sphere power in diopters (SPH)
        var cylinder: Double? // Cylinder power in diopters (CYL)
        var axis: Int? // Axis angle in degrees (0-180)
        var add: Double? // Addition power for reading glasses in diopters
        var prism: Double? // Prism power in diopters
        var base: PrismBase? // Optional prism base direction
        
        enum PrismBase: String, Codable, CaseIterable { // Enum for prism base directions
            case up = "Up" // Prism base up
            case down = "Down" // Prism base down
            case `in` = "In" // Prism base in (toward nose)
            case out = "Out" // Prism base out (away from nose)
        }
        
        init(sphere: Double? = nil, cylinder: Double? = nil, axis: Int? = nil, add: Double? = nil, prism: Double? = nil, base: PrismBase? = nil) {
            self.sphere = sphere // Initialize sphere power
            self.cylinder = cylinder // Initialize cylinder power
            self.axis = axis // Initialize axis angle
            self.add = add // Initialize addition power
            self.prism = prism // Initialize prism power
            self.base = base // Initialize prism base
        }
    }
    
    init(date: Date = Date(), expirationDate: Date? = nil, rightEye: EyePrescription = EyePrescription(), leftEye: EyePrescription = EyePrescription(), pupillaryDistance: Double? = nil, notes: String? = nil) {
        self.date = date // Initialize prescription date
        self.expirationDate = expirationDate // Initialize expiration date
        self.rightEye = rightEye // Initialize right eye prescription
        self.leftEye = leftEye // Initialize left eye prescription
        self.pupillaryDistance = pupillaryDistance // Initialize pupillary distance
        self.notes = notes // Initialize optional notes
    }
}

// MARK: - Daily Vision Check
struct DailyVisionCheck: Codable, Identifiable { // Define DailyVisionCheck struct for daily vision assessments
    let id: UUID // Unique identifier for vision check
    var date: Date // Date of vision check
    var time: Date // Time of vision check
    var rightEye: EyeCheck // Right eye check results
    var leftEye: EyeCheck // Left eye check results
    var bothEyes: BothEyesCheck // Both eyes combined check results
    var device: CheckDevice // Device used for check
    var environment: CheckEnvironment // Environment conditions during check
    var notes: String? // Optional notes about check
    
    struct EyeCheck: Codable { // Nested struct for individual eye check
        var visualAcuity: VisualAcuity? // Visual acuity measurement
        var contrastSensitivity: Double? // Contrast sensitivity score (0-1)
        var colorVision: ColorVisionTest? // Color vision test results
        var depthPerception: Double? // Depth perception score (0-1)
        var peripheralVision: PeripheralVisionTest? // Peripheral vision test results
        var eyeStrain: EyeStrainLevel? // Eye strain level assessment
        var dryness: DrynessLevel? // Eye dryness level
        var redness: RednessLevel? // Eye redness level
        
        enum VisualAcuity: String, Codable, CaseIterable { // Enum for visual acuity levels
            case perfect = "20/20" // Perfect vision
            case excellent = "20/25" // Excellent vision
            case good = "20/30" // Good vision
            case fair = "20/40" // Fair vision
            case poor = "20/50" // Poor vision
            case veryPoor = "20/70" // Very poor vision
            case legallyBlind = "20/200" // Legally blind
        }
        
        enum ColorVisionTest: String, Codable, CaseIterable { // Enum for color vision test results
            case normal = "Normal" // Normal color vision
            case mildDeficiency = "Mild Deficiency" // Mild color vision deficiency
            case moderateDeficiency = "Moderate Deficiency" // Moderate color vision deficiency
            case severeDeficiency = "Severe Deficiency" // Severe color vision deficiency
        }
        
        struct PeripheralVisionTest: Codable { // Nested struct for peripheral vision test
            var upperField: Double // Upper field of vision in degrees
            var lowerField: Double // Lower field of vision in degrees
            var temporalField: Double // Temporal (side) field of vision in degrees
            var nasalField: Double // Nasal (nose side) field of vision in degrees
            var overallScore: Double // Overall peripheral vision score (0-1)
        }
        
        enum EyeStrainLevel: String, Codable, CaseIterable { // Enum for eye strain levels
            case none = "None" // No eye strain
            case mild = "Mild" // Mild eye strain
            case moderate = "Moderate" // Moderate eye strain
            case severe = "Severe" // Severe eye strain
        }
        
        enum DrynessLevel: String, Codable, CaseIterable { // Enum for dryness levels
            case none = "None" // No dryness
            case mild = "Mild" // Mild dryness
            case moderate = "Moderate" // Moderate dryness
            case severe = "Severe" // Severe dryness
        }
        
        enum RednessLevel: String, Codable, CaseIterable { // Enum for redness levels
            case none = "None" // No redness
            case mild = "Mild" // Mild redness
            case moderate = "Moderate" // Moderate redness
            case severe = "Severe" // Severe redness
        }
    }
    
    struct BothEyesCheck: Codable { // Nested struct for both eyes combined check
        var binocularVision: Double? // Binocular vision score (0-1)
        var convergence: Double? // Convergence ability score (0-1)
        var divergence: Double? // Divergence ability score (0-1)
        var accommodation: Double? // Accommodation ability score (0-1)
        var stereopsis: Double? // Stereopsis (depth perception) score in arcseconds
    }
    
    enum CheckDevice: String, Codable, CaseIterable { // Enum for check devices
        case appleWatch = "Apple Watch" // Apple Watch device
        case visionPro = "Vision Pro" // Apple Vision Pro device
        case iphone = "iPhone" // iPhone device
        case ipad = "iPad" // iPad device
        case manual = "Manual" // Manual check
        case other = "Other" // Other device
    }
    
    struct CheckEnvironment: Codable { // Nested struct for check environment
        var lighting: LightingCondition // Lighting condition during check
        var screenBrightness: Double? // Optional screen brightness level (0-1)
        var distance: Double? // Optional viewing distance in centimeters
        var timeSinceLastCheck: TimeInterval? // Optional time since last vision check
        
        enum LightingCondition: String, Codable, CaseIterable { // Enum for lighting conditions
            case bright = "Bright" // Bright lighting
            case normal = "Normal" // Normal lighting
            case dim = "Dim" // Dim lighting
            case dark = "Dark" // Dark lighting
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), time: Date = Date(), rightEye: EyeCheck = EyeCheck(), leftEye: EyeCheck = EyeCheck(), bothEyes: BothEyesCheck = BothEyesCheck(), device: CheckDevice = .iphone, environment: CheckEnvironment = CheckEnvironment(lighting: .normal), notes: String? = nil) {
        self.id = id // Initialize unique identifier
        self.date = date // Initialize check date
        self.time = time // Initialize check time
        self.rightEye = rightEye // Initialize right eye check
        self.leftEye = leftEye // Initialize left eye check
        self.bothEyes = bothEyes // Initialize both eyes check
        self.device = device // Initialize check device
        self.environment = environment // Initialize check environment
        self.notes = notes // Initialize optional notes
    }
}

// MARK: - Vision Health Summary
struct VisionHealthSummary: Codable { // Define VisionHealthSummary struct for vision health overview
    var lastCheckDate: Date? // Date of last vision check
    var averageVisualAcuity: Double? // Average visual acuity score
    var trend: VisionTrend // Vision health trend
    var recommendations: [String] // Array of vision health recommendations
    var nextCheckDue: Date? // Date when next check is due
    
    enum VisionTrend: String, Codable { // Enum for vision trends
        case improving = "Improving" // Vision is improving
        case stable = "Stable" // Vision is stable
        case declining = "Declining" // Vision is declining
        case fluctuating = "Fluctuating" // Vision is fluctuating
    }
    
    init(lastCheckDate: Date? = nil, averageVisualAcuity: Double? = nil, trend: VisionTrend = .stable, recommendations: [String] = [], nextCheckDue: Date? = nil) {
        self.lastCheckDate = lastCheckDate // Initialize last check date
        self.averageVisualAcuity = averageVisualAcuity // Initialize average visual acuity
        self.trend = trend // Initialize vision trend
        self.recommendations = recommendations // Initialize recommendations array
        self.nextCheckDue = nextCheckDue // Initialize next check due date
    }
}
