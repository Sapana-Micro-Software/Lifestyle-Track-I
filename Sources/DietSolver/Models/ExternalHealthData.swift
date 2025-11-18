//
//  ExternalHealthData.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
#if canImport(UIKit)
import UIKit // Import UIKit for UIImage on iOS
#endif

// MARK: - External Health Data
struct ExternalHealthData: Codable { // Define ExternalHealthData struct for external body health information
    var skinAnalysis: ExternalSkinAnalysis? // Optional skin analysis data
    var eyeAnalysis: ExternalEyeAnalysis? // Optional eye analysis data
    var noseAnalysis: ExternalNoseAnalysis? // Optional nose analysis data
    var nailAnalysis: ExternalNailAnalysis? // Optional nail analysis data
    var hairAnalysis: ExternalHairAnalysis? // Optional hair analysis data
    var beardAnalysis: ExternalBeardAnalysis? // Optional beard analysis data
    var lastAnalysisDate: Date? // Optional date of last analysis
    
    init() { // Initialize empty external health data
        self.skinAnalysis = nil // Set skin analysis to nil
        self.eyeAnalysis = nil // Set eye analysis to nil
        self.noseAnalysis = nil // Set nose analysis to nil
        self.nailAnalysis = nil // Set nail analysis to nil
        self.hairAnalysis = nil // Set hair analysis to nil
        self.beardAnalysis = nil // Set beard analysis to nil
        self.lastAnalysisDate = nil // Set last analysis date to nil
    }
}

// MARK: - Skin Analysis
struct ExternalSkinAnalysis: Codable { // Define ExternalSkinAnalysis struct for skin health information
    var conditions: [ExternalSkinCondition] // Array of detected skin conditions
    var texture: ExternalSkinTexture? // Optional skin texture assessment
    var color: ExternalSkinColor? // Optional skin color assessment
    var hydration: ExternalSkinHydration? // Optional skin hydration level
    var images: [String] // Array of image identifiers (base64 or file paths)
    var analysisDate: Date // Date of analysis
    var confidence: Double // Confidence score (0.0 to 1.0)
    
    enum ExternalSkinCondition: String, Codable { // Enum for skin conditions
        case acne = "acne" // Acne
        case eczema = "eczema" // Eczema
        case psoriasis = "psoriasis" // Psoriasis
        case rosacea = "rosacea" // Rosacea
        case dermatitis = "dermatitis" // Dermatitis
        case melasma = "melasma" // Melasma
        case vitiligo = "vitiligo" // Vitiligo
        case moles = "moles" // Moles
        case sunDamage = "sun_damage" // Sun damage
        case wrinkles = "wrinkles" // Wrinkles
        case dryness = "dryness" // Dryness
        case oiliness = "oiliness" // Oiliness
        case discoloration = "discoloration" // Discoloration
        case inflammation = "inflammation" // Inflammation
        case normal = "normal" // Normal skin
    }
    
    enum ExternalSkinTexture: String, Codable { // Enum for skin texture
        case smooth = "smooth" // Smooth
        case rough = "rough" // Rough
        case bumpy = "bumpy" // Bumpy
        case scaly = "scaly" // Scaly
        case normal = "normal" // Normal
    }
    
    enum ExternalSkinColor: String, Codable { // Enum for skin color assessment
        case fair = "fair" // Fair
        case light = "light" // Light
        case medium = "medium" // Medium
        case tan = "tan" // Tan
        case dark = "dark" // Dark
        case veryDark = "very_dark" // Very dark
    }
    
    enum ExternalSkinHydration: String, Codable { // Enum for skin hydration
        case wellHydrated = "well_hydrated" // Well hydrated
        case moderatelyHydrated = "moderately_hydrated" // Moderately hydrated
        case dehydrated = "dehydrated" // Dehydrated
        case veryDehydrated = "very_dehydrated" // Very dehydrated
    }
}

// MARK: - Eye Analysis
struct ExternalEyeAnalysis: Codable { // Define ExternalEyeAnalysis struct for eye health information
    var conditions: [EyeCondition] // Array of detected eye conditions
    var redness: RednessLevel? // Optional redness level
    var clarity: ClarityLevel? // Optional clarity assessment
    var images: [String] // Array of image identifiers
    var analysisDate: Date // Date of analysis
    var confidence: Double // Confidence score
    
    enum EyeCondition: String, Codable { // Enum for eye conditions
        case conjunctivitis = "conjunctivitis" // Conjunctivitis (pink eye)
        case stye = "stye" // Stye
        case dryEye = "dry_eye" // Dry eye
        case bloodshot = "bloodshot" // Bloodshot eyes
        case jaundice = "jaundice" // Jaundice (yellowing)
        case cataracts = "cataracts" // Cataracts (cloudy appearance)
        case pterygium = "pterygium" // Pterygium
        case normal = "normal" // Normal
    }
    
    enum RednessLevel: String, Codable { // Enum for redness level
        case none = "none" // No redness
        case mild = "mild" // Mild redness
        case moderate = "moderate" // Moderate redness
        case severe = "severe" // Severe redness
    }
    
    enum ClarityLevel: String, Codable { // Enum for clarity level
        case clear = "clear" // Clear
        case slightlyCloudy = "slightly_cloudy" // Slightly cloudy
        case cloudy = "cloudy" // Cloudy
        case veryCloudy = "very_cloudy" // Very cloudy
    }
}

// MARK: - Nose Analysis
struct ExternalNoseAnalysis: Codable { // Define ExternalNoseAnalysis struct for nose health information
    var conditions: [NoseCondition] // Array of detected nose conditions
    var inflammation: InflammationLevel? // Optional inflammation level
    var images: [String] // Array of image identifiers
    var analysisDate: Date // Date of analysis
    var confidence: Double // Confidence score
    
    enum NoseCondition: String, Codable { // Enum for nose conditions
        case rhinitis = "rhinitis" // Rhinitis
        case sinusitis = "sinusitis" // Sinusitis
        case nasalPolyps = "nasal_polyps" // Nasal polyps
        case deviatedSeptum = "deviated_septum" // Deviated septum
        case congestion = "congestion" // Congestion
        case dryness = "dryness" // Dryness
        case irritation = "irritation" // Irritation
        case normal = "normal" // Normal
    }
    
    enum InflammationLevel: String, Codable { // Enum for inflammation level
        case none = "none" // No inflammation
        case mild = "mild" // Mild inflammation
        case moderate = "moderate" // Moderate inflammation
        case severe = "severe" // Severe inflammation
    }
}

// MARK: - Nail Analysis
struct ExternalNailAnalysis: Codable { // Define ExternalNailAnalysis struct for nail health information
    var conditions: [NailCondition] // Array of detected nail conditions
    var color: NailColor? // Optional nail color assessment
    var texture: NailTexture? // Optional nail texture
    var images: [String] // Array of image identifiers
    var analysisDate: Date // Date of analysis
    var confidence: Double // Confidence score
    
    enum NailCondition: String, Codable { // Enum for nail conditions
        case fungalInfection = "fungal_infection" // Fungal infection
        case psoriasis = "psoriasis" // Psoriasis
        case onycholysis = "onycholysis" // Onycholysis (separation)
        case clubbing = "clubbing" // Clubbing
        case spoonNails = "spoon_nails" // Spoon nails (koilonychia)
        case beauLines = "beau_lines" // Beau's lines
        case whiteSpots = "white_spots" // White spots
        case ridges = "ridges" // Ridges
        case brittleness = "brittleness" // Brittleness
        case discoloration = "discoloration" // Discoloration
        case normal = "normal" // Normal
    }
    
    enum NailColor: String, Codable { // Enum for nail color
        case pink = "pink" // Pink (healthy)
        case white = "white" // White
        case yellow = "yellow" // Yellow
        case blue = "blue" // Blue
        case brown = "brown" // Brown
        case black = "black" // Black
        case green = "green" // Green
    }
    
    enum NailTexture: String, Codable { // Enum for nail texture
        case smooth = "smooth" // Smooth
        case ridged = "ridged" // Ridged
        case pitted = "pitted" // Pitted
        case thickened = "thickened" // Thickened
        case brittle = "brittle" // Brittle
        case normal = "normal" // Normal
    }
}

// MARK: - Hair Analysis
struct ExternalHairAnalysis: Codable { // Define ExternalHairAnalysis struct for hair health information
    var conditions: [HairCondition] // Array of detected hair conditions
    var texture: HairTexture? // Optional hair texture
    var thickness: HairThickness? // Optional hair thickness
    var health: HairHealth? // Optional hair health assessment
    var images: [String] // Array of image identifiers
    var analysisDate: Date // Date of analysis
    var confidence: Double // Confidence score
    
    enum HairCondition: String, Codable { // Enum for hair conditions
        case dandruff = "dandruff" // Dandruff
        case seborrheicDermatitis = "seborrheic_dermatitis" // Seborrheic dermatitis
        case alopecia = "alopecia" // Alopecia (hair loss)
        case thinning = "thinning" // Thinning
        case dryness = "dryness" // Dryness
        case oiliness = "oiliness" // Oiliness
        case splitEnds = "split_ends" // Split ends
        case breakage = "breakage" // Breakage
        case scalpIrritation = "scalp_irritation" // Scalp irritation
        case normal = "normal" // Normal
    }
    
    enum HairTexture: String, Codable { // Enum for hair texture
        case fine = "fine" // Fine
        case medium = "medium" // Medium
        case coarse = "coarse" // Coarse
    }
    
    enum HairThickness: String, Codable { // Enum for hair thickness
        case thin = "thin" // Thin
        case medium = "medium" // Medium
        case thick = "thick" // Thick
    }
    
    enum HairHealth: String, Codable { // Enum for hair health
        case healthy = "healthy" // Healthy
        case fair = "fair" // Fair
        case poor = "poor" // Poor
    }
}

// MARK: - Beard Analysis
struct ExternalBeardAnalysis: Codable { // Define ExternalBeardAnalysis struct for beard health information
    var conditions: [BeardCondition] // Array of detected beard conditions
    var texture: BeardTexture? // Optional beard texture
    var thickness: BeardThickness? // Optional beard thickness
    var health: BeardHealth? // Optional beard health assessment
    var images: [String] // Array of image identifiers
    var analysisDate: Date // Date of analysis
    var confidence: Double // Confidence score
    
    enum BeardCondition: String, Codable { // Enum for beard conditions
        case folliculitis = "folliculitis" // Folliculitis
        case ingrownHairs = "ingrown_hairs" // Ingrown hairs
        case razorBurn = "razor_burn" // Razor burn
        case dryness = "dryness" // Dryness
        case irritation = "irritation" // Irritation
        case patchiness = "patchiness" // Patchiness
        case normal = "normal" // Normal
    }
    
    enum BeardTexture: String, Codable { // Enum for beard texture
        case soft = "soft" // Soft
        case medium = "medium" // Medium
        case coarse = "coarse" // Coarse
        case wiry = "wiry" // Wiry
    }
    
    enum BeardThickness: String, Codable { // Enum for beard thickness
        case sparse = "sparse" // Sparse
        case medium = "medium" // Medium
        case thick = "thick" // Thick
        case veryThick = "very_thick" // Very thick
    }
    
    enum BeardHealth: String, Codable { // Enum for beard health
        case healthy = "healthy" // Healthy
        case fair = "fair" // Fair
        case poor = "poor" // Poor
    }
}
