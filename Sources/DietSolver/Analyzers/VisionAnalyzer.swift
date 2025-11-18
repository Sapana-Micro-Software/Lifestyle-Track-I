//
//  VisionAnalyzer.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Vision Analysis Report
struct VisionAnalysisReport: Codable { // Define VisionAnalysisReport struct for vision health analysis
    var analysisDate: Date // Date of analysis
    var timeRange: DateInterval // Time range of analyzed checks
    var checkCount: Int // Total number of vision checks analyzed
    var rightEyeAnalysis: EyeAnalysis? // Optional right eye analysis
    var leftEyeAnalysis: EyeAnalysis? // Optional left eye analysis
    var bothEyesAnalysis: BothEyesAnalysis? // Optional both eyes analysis
    var trends: VisionTrends // Vision health trends
    var recommendations: [String] // Array of vision health recommendations
    var riskFactors: [RiskFactor] // Array of identified risk factors
    var improvements: [String] // Array of improvement areas
    
    struct EyeAnalysis: Codable { // Nested struct for individual eye analysis
        var averageAcuity: Double? // Average visual acuity score
        var acuityTrend: TrendDirection // Visual acuity trend direction
        var averageContrast: Double? // Average contrast sensitivity score
        var contrastTrend: TrendDirection // Contrast sensitivity trend direction
        var averageStrain: EyeStrainLevel? // Average eye strain level
        var strainTrend: TrendDirection // Eye strain trend direction
        var averageDryness: DrynessLevel? // Average dryness level
        var drynessTrend: TrendDirection // Dryness trend direction
        var colorVisionStatus: ColorVisionStatus // Color vision status
        var peripheralVisionScore: Double? // Peripheral vision score
        
        enum TrendDirection: String, Codable { // Enum for trend directions
            case improving = "Improving" // Trend is improving
            case stable = "Stable" // Trend is stable
            case declining = "Declining" // Trend is declining
            case fluctuating = "Fluctuating" // Trend is fluctuating
        }
        
        enum EyeStrainLevel: String, Codable { // Enum for eye strain levels
            case none = "None" // No eye strain
            case mild = "Mild" // Mild eye strain
            case moderate = "Moderate" // Moderate eye strain
            case severe = "Severe" // Severe eye strain
        }
        
        enum DrynessLevel: String, Codable { // Enum for dryness levels
            case none = "None" // No dryness
            case mild = "Mild" // Mild dryness
            case moderate = "Moderate" // Moderate dryness
            case severe = "Severe" // Severe dryness
        }
        
        enum ColorVisionStatus: String, Codable { // Enum for color vision status
            case normal = "Normal" // Normal color vision
            case deficiency = "Deficiency Detected" // Color vision deficiency detected
            case unknown = "Unknown" // Color vision status unknown
        }
    }
    
    struct BothEyesAnalysis: Codable { // Nested struct for both eyes analysis
        var binocularVisionScore: Double? // Binocular vision score
        var convergenceAbility: Double? // Convergence ability score
        var divergenceAbility: Double? // Divergence ability score
        var accommodationAbility: Double? // Accommodation ability score
        var stereopsisScore: Double? // Stereopsis score
        var coordinationScore: Double? // Eye coordination score
    }
    
    struct VisionTrends: Codable { // Nested struct for vision trends
        var overallTrend: EyeAnalysis.TrendDirection // Overall vision trend
        var acuityTrend: EyeAnalysis.TrendDirection // Visual acuity trend
        var strainTrend: EyeAnalysis.TrendDirection // Eye strain trend
        var improvementAreas: [String] // Areas showing improvement
        var concernAreas: [String] // Areas of concern
    }
    
    struct RiskFactor: Codable, Identifiable { // Nested struct for risk factors
        let id: UUID // Unique identifier for risk factor
        var factor: String // Risk factor description
        var severity: SeverityLevel // Severity level of risk factor
        var recommendation: String // Recommendation for risk factor
        
        enum SeverityLevel: String, Codable { // Enum for severity levels
            case low = "Low" // Low severity
            case medium = "Medium" // Medium severity
            case high = "High" // High severity
            case critical = "Critical" // Critical severity
        }
        
        init(id: UUID = UUID(), factor: String, severity: SeverityLevel, recommendation: String) {
            self.id = id // Initialize unique identifier
            self.factor = factor // Initialize risk factor
            self.severity = severity // Initialize severity level
            self.recommendation = recommendation // Initialize recommendation
        }
    }
    
        init(analysisDate: Date = Date(), timeRange: DateInterval, checkCount: Int = 0, rightEyeAnalysis: EyeAnalysis? = nil, leftEyeAnalysis: EyeAnalysis? = nil, bothEyesAnalysis: BothEyesAnalysis? = nil, trends: VisionTrends = VisionTrends(overallTrend: EyeAnalysis.TrendDirection.stable, acuityTrend: EyeAnalysis.TrendDirection.stable, strainTrend: EyeAnalysis.TrendDirection.stable, improvementAreas: [], concernAreas: []), recommendations: [String] = [], riskFactors: [RiskFactor] = [], improvements: [String] = []) {
        self.analysisDate = analysisDate // Initialize analysis date
        self.timeRange = timeRange // Initialize time range
        self.checkCount = checkCount // Initialize check count
        self.rightEyeAnalysis = rightEyeAnalysis // Initialize right eye analysis
        self.leftEyeAnalysis = leftEyeAnalysis // Initialize left eye analysis
        self.bothEyesAnalysis = bothEyesAnalysis // Initialize both eyes analysis
        self.trends = trends // Initialize trends
        self.recommendations = recommendations // Initialize recommendations
        self.riskFactors = riskFactors // Initialize risk factors
        self.improvements = improvements // Initialize improvements
    }
}

// MARK: - Vision Analyzer
class VisionAnalyzer { // Define VisionAnalyzer class for analyzing vision health
    func analyze(checks: [DailyVisionCheck], prescription: VisionPrescription? = nil) -> VisionAnalysisReport { // Function to analyze vision checks
        guard !checks.isEmpty else { // Check if checks exist
            return VisionAnalysisReport( // Return empty report
                timeRange: DateInterval(start: Date(), end: Date()), // Set empty time range
                trends: VisionAnalysisReport.VisionTrends(overallTrend: .stable, acuityTrend: .stable, strainTrend: .stable, improvementAreas: [], concernAreas: []) // Set stable trends
            )
        }
        
        let sortedChecks = checks.sorted { $0.date < $1.date } // Sort checks by date
        let startDate = sortedChecks.first!.date // Get start date
        let endDate = sortedChecks.last!.date // Get end date
        let timeRange = DateInterval(start: startDate, end: endDate) // Create time range
        
        let rightEyeAnalysis = analyzeEye(checks: sortedChecks, eye: \.rightEye) // Analyze right eye
        let leftEyeAnalysis = analyzeEye(checks: sortedChecks, eye: \.leftEye) // Analyze left eye
        let bothEyesAnalysis = analyzeBothEyes(checks: sortedChecks) // Analyze both eyes
        let trends = analyzeTrends(checks: sortedChecks) // Analyze trends
        let recommendations = generateRecommendations(checks: sortedChecks, prescription: prescription, rightEye: rightEyeAnalysis, leftEye: leftEyeAnalysis) // Generate recommendations
        let riskFactors = identifyRiskFactors(checks: sortedChecks, prescription: prescription) // Identify risk factors
        let improvements = identifyImprovements(checks: sortedChecks) // Identify improvements
        
        return VisionAnalysisReport( // Return analysis report
            analysisDate: Date(), // Set analysis date
            timeRange: timeRange, // Set time range
            checkCount: sortedChecks.count, // Set check count
            rightEyeAnalysis: rightEyeAnalysis, // Set right eye analysis
            leftEyeAnalysis: leftEyeAnalysis, // Set left eye analysis
            bothEyesAnalysis: bothEyesAnalysis, // Set both eyes analysis
            trends: trends, // Set trends
            recommendations: recommendations, // Set recommendations
            riskFactors: riskFactors, // Set risk factors
            improvements: improvements // Set improvements
        )
    }
    
    private func analyzeEye(checks: [DailyVisionCheck], eye: KeyPath<DailyVisionCheck, DailyVisionCheck.EyeCheck>) -> VisionAnalysisReport.EyeAnalysis? { // Private function to analyze individual eye
        let eyeChecks = checks.map { $0[keyPath: eye] } // Get eye checks
        guard !eyeChecks.isEmpty else { return nil } // Check if checks exist
        
        // Analyze visual acuity
        let acuityValues = eyeChecks.compactMap { check -> Double? in // Map to acuity values
            guard let acuity = check.visualAcuity else { return nil } // Check if acuity exists
            switch acuity { // Switch on acuity level
            case .perfect: return 1.0 // Perfect score
            case .excellent: return 0.9 // Excellent score
            case .good: return 0.8 // Good score
            case .fair: return 0.6 // Fair score
            case .poor: return 0.4 // Poor score
            case .veryPoor: return 0.2 // Very poor score
            case .legallyBlind: return 0.0 // Legally blind score
            }
        }
        let averageAcuity = acuityValues.isEmpty ? nil : acuityValues.reduce(0, +) / Double(acuityValues.count) // Calculate average acuity
        let acuityTrend = calculateTrend(values: acuityValues) // Calculate acuity trend
        
        // Analyze contrast sensitivity
        let contrastValues = eyeChecks.compactMap { $0.contrastSensitivity } // Get contrast values
        let averageContrast = contrastValues.isEmpty ? nil : contrastValues.reduce(0, +) / Double(contrastValues.count) // Calculate average contrast
        let contrastTrend = calculateTrend(values: contrastValues) // Calculate contrast trend
        
        // Analyze eye strain
        let strainLevels = eyeChecks.compactMap { $0.eyeStrain } // Get strain levels
        let averageStrain = calculateAverageStrain(levels: strainLevels) // Calculate average strain
        let strainTrend = calculateStrainTrend(levels: strainLevels) // Calculate strain trend
        
        // Analyze dryness
        let drynessLevels = eyeChecks.compactMap { $0.dryness } // Get dryness levels
        let averageDryness = calculateAverageDryness(levels: drynessLevels) // Calculate average dryness
        let drynessTrend = calculateDrynessTrend(levels: drynessLevels) // Calculate dryness trend
        
        // Analyze color vision
        let colorVisionStatus = analyzeColorVision(checks: eyeChecks) // Analyze color vision
        
        // Analyze peripheral vision
        let peripheralScores = eyeChecks.compactMap { $0.peripheralVision?.overallScore } // Get peripheral scores
        let peripheralScore = peripheralScores.isEmpty ? nil : peripheralScores.reduce(0, +) / Double(peripheralScores.count) // Calculate average peripheral score
        
        return VisionAnalysisReport.EyeAnalysis( // Return eye analysis
            averageAcuity: averageAcuity, // Set average acuity
            acuityTrend: acuityTrend, // Set acuity trend
            averageContrast: averageContrast, // Set average contrast
            contrastTrend: contrastTrend, // Set contrast trend
            averageStrain: averageStrain, // Set average strain
            strainTrend: strainTrend, // Set strain trend
            averageDryness: averageDryness, // Set average dryness
            drynessTrend: drynessTrend, // Set dryness trend
            colorVisionStatus: colorVisionStatus, // Set color vision status
            peripheralVisionScore: peripheralScore // Set peripheral vision score
        )
    }
    
    private func analyzeBothEyes(checks: [DailyVisionCheck]) -> VisionAnalysisReport.BothEyesAnalysis? { // Private function to analyze both eyes
        let bothEyesChecks = checks.map { $0.bothEyes } // Get both eyes checks
        guard !bothEyesChecks.isEmpty else { return nil } // Check if checks exist
        
        let binocularScores = bothEyesChecks.compactMap { $0.binocularVision } // Get binocular scores
        let convergenceScores = bothEyesChecks.compactMap { $0.convergence } // Get convergence scores
        let divergenceScores = bothEyesChecks.compactMap { $0.divergence } // Get divergence scores
        let accommodationScores = bothEyesChecks.compactMap { $0.accommodation } // Get accommodation scores
        let stereopsisScores = bothEyesChecks.compactMap { $0.stereopsis } // Get stereopsis scores
        
        let binocularScore = binocularScores.isEmpty ? nil : binocularScores.reduce(0, +) / Double(binocularScores.count) // Calculate average binocular score
        let convergenceScore = convergenceScores.isEmpty ? nil : convergenceScores.reduce(0, +) / Double(convergenceScores.count) // Calculate average convergence score
        let divergenceScore = divergenceScores.isEmpty ? nil : divergenceScores.reduce(0, +) / Double(divergenceScores.count) // Calculate average divergence score
        let accommodationScore = accommodationScores.isEmpty ? nil : accommodationScores.reduce(0, +) / Double(accommodationScores.count) // Calculate average accommodation score
        let stereopsisScore = stereopsisScores.isEmpty ? nil : stereopsisScores.reduce(0, +) / Double(stereopsisScores.count) // Calculate average stereopsis score
        
        let coordinationScore = calculateCoordinationScore(binocular: binocularScore, convergence: convergenceScore, divergence: divergenceScore) // Calculate coordination score
        
        return VisionAnalysisReport.BothEyesAnalysis( // Return both eyes analysis
            binocularVisionScore: binocularScore, // Set binocular vision score
            convergenceAbility: convergenceScore, // Set convergence ability
            divergenceAbility: divergenceScore, // Set divergence ability
            accommodationAbility: accommodationScore, // Set accommodation ability
            stereopsisScore: stereopsisScore, // Set stereopsis score
            coordinationScore: coordinationScore // Set coordination score
        )
    }
    
    private func analyzeTrends(checks: [DailyVisionCheck]) -> VisionAnalysisReport.VisionTrends { // Private function to analyze trends
        let firstHalf = checks.prefix(checks.count / 2) // Get first half of checks
        let secondHalf = checks.suffix(checks.count / 2) // Get second half of checks
        
        let firstAcuity = firstHalf.compactMap { check -> Double? in // Get first half acuity
            guard let acuity = check.rightEye.visualAcuity else { return nil } // Check if acuity exists
            switch acuity { // Switch on acuity
            case .perfect: return 1.0 // Perfect score
            case .excellent: return 0.9 // Excellent score
            case .good: return 0.8 // Good score
            case .fair: return 0.6 // Fair score
            case .poor: return 0.4 // Poor score
            case .veryPoor: return 0.2 // Very poor score
            case .legallyBlind: return 0.0 // Legally blind score
            }
        }
        let secondAcuity = secondHalf.compactMap { check -> Double? in // Get second half acuity
            guard let acuity = check.rightEye.visualAcuity else { return nil } // Check if acuity exists
            switch acuity { // Switch on acuity
            case .perfect: return 1.0 // Perfect score
            case .excellent: return 0.9 // Excellent score
            case .good: return 0.8 // Good score
            case .fair: return 0.6 // Fair score
            case .poor: return 0.4 // Poor score
            case .veryPoor: return 0.2 // Very poor score
            case .legallyBlind: return 0.0 // Legally blind score
            }
        }
        
        let acuityTrend = calculateTrendDirection(first: firstAcuity, second: secondAcuity) // Calculate acuity trend
        
        let firstStrain = firstHalf.compactMap { $0.rightEye.eyeStrain } // Get first half strain
        let secondStrain = secondHalf.compactMap { $0.rightEye.eyeStrain } // Get second half strain
        let strainTrend = calculateStrainTrendDirection(first: firstStrain, second: secondStrain) // Calculate strain trend
        
        let overallTrend = determineOverallTrend(acuity: acuityTrend, strain: strainTrend) // Determine overall trend
        
        var improvementAreas: [String] = [] // Initialize improvement areas
        var concernAreas: [String] = [] // Initialize concern areas
        
        if acuityTrend == .improving { // Check if acuity improving
            improvementAreas.append("Visual Acuity") // Add to improvements
        } else if acuityTrend == .declining { // Check if acuity declining
            concernAreas.append("Visual Acuity") // Add to concerns
        }
        
        if strainTrend == .improving { // Check if strain improving
            improvementAreas.append("Eye Strain") // Add to improvements
        } else if strainTrend == .declining { // Check if strain declining
            concernAreas.append("Eye Strain") // Add to concerns
        }
        
        return VisionAnalysisReport.VisionTrends( // Return vision trends
            overallTrend: overallTrend, // Set overall trend
            acuityTrend: acuityTrend, // Set acuity trend
            strainTrend: strainTrend, // Set strain trend
            improvementAreas: improvementAreas, // Set improvement areas
            concernAreas: concernAreas // Set concern areas
        )
    }
    
    private func generateRecommendations(checks: [DailyVisionCheck], prescription: VisionPrescription?, rightEye: VisionAnalysisReport.EyeAnalysis?, leftEye: VisionAnalysisReport.EyeAnalysis?) -> [String] { // Private function to generate recommendations
        var recommendations: [String] = [] // Initialize recommendations array
        
        if let rightEye = rightEye, let leftEye = leftEye { // Check if eye analyses exist
            if rightEye.averageStrain == .severe || leftEye.averageStrain == .severe { // Check if severe strain
                recommendations.append("Consider reducing screen time and taking regular breaks") // Add strain recommendation
            }
            if rightEye.averageDryness == .severe || leftEye.averageDryness == .severe { // Check if severe dryness
                recommendations.append("Use artificial tears and consider humidifier for dry environments") // Add dryness recommendation
            }
            if rightEye.acuityTrend == .declining || leftEye.acuityTrend == .declining { // Check if acuity declining
                recommendations.append("Schedule an eye examination with an optometrist") // Add acuity recommendation
            }
        }
        
        if prescription == nil { // Check if prescription missing
            recommendations.append("Consider getting a comprehensive eye examination for baseline prescription") // Add prescription recommendation
        }
        
        return recommendations // Return recommendations
    }
    
    private func identifyRiskFactors(checks: [DailyVisionCheck], prescription: VisionPrescription?) -> [VisionAnalysisReport.RiskFactor] { // Private function to identify risk factors
        var riskFactors: [VisionAnalysisReport.RiskFactor] = [] // Initialize risk factors array
        
        let recentChecks = checks.suffix(7) // Get last 7 checks
        let highStrainCount = recentChecks.filter { $0.rightEye.eyeStrain == .severe || $0.leftEye.eyeStrain == .severe }.count // Count high strain checks
        
        if highStrainCount >= 3 { // Check if frequent high strain
            riskFactors.append(VisionAnalysisReport.RiskFactor( // Add risk factor
                factor: "Frequent severe eye strain detected", // Set factor
                severity: .high, // Set high severity
                recommendation: "Reduce screen time and implement 20-20-20 rule (every 20 minutes, look at something 20 feet away for 20 seconds)" // Set recommendation
            ))
        }
        
        return riskFactors // Return risk factors
    }
    
    private func identifyImprovements(checks: [DailyVisionCheck]) -> [String] { // Private function to identify improvements
        var improvements: [String] = [] // Initialize improvements array
        
        let recentChecks = checks.suffix(7) // Get last 7 checks
        let lowStrainCount = recentChecks.filter { $0.rightEye.eyeStrain == .none || $0.leftEye.eyeStrain == .none }.count // Count low strain checks
        
        if lowStrainCount >= 5 { // Check if frequent low strain
            improvements.append("Eye strain management is effective") // Add improvement
        }
        
        return improvements // Return improvements
    }
    
    private func calculateTrend(values: [Double]) -> VisionAnalysisReport.EyeAnalysis.TrendDirection { // Private function to calculate trend
        guard values.count >= 2 else { return .stable } // Check if enough values
        let firstHalf = values.prefix(values.count / 2) // Get first half
        let secondHalf = values.suffix(values.count / 2) // Get second half
        let firstAverage = firstHalf.reduce(0, +) / Double(firstHalf.count) // Calculate first average
        let secondAverage = secondHalf.reduce(0, +) / Double(secondHalf.count) // Calculate second average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.05 { // Check if difference is small
            return .stable // Return stable
        } else if difference > 0 { // Check if improving
            return .improving // Return improving
        } else { // If declining
            return .declining // Return declining
        }
    }
    
    private func calculateAverageStrain(levels: [DailyVisionCheck.EyeCheck.EyeStrainLevel]) -> VisionAnalysisReport.EyeAnalysis.EyeStrainLevel? { // Private function to calculate average strain
        guard !levels.isEmpty else { return nil } // Check if levels exist
        let counts = Dictionary(grouping: levels, by: { $0 }) // Group by level
        let mostCommon = counts.max(by: { $0.value.count < $1.value.count })?.key // Get most common
        return mostCommon // Return most common level
    }
    
    private func calculateStrainTrend(levels: [DailyVisionCheck.EyeCheck.EyeStrainLevel]) -> VisionAnalysisReport.EyeAnalysis.TrendDirection { // Private function to calculate strain trend
        guard levels.count >= 2 else { return .stable } // Check if enough levels
        let firstHalf = levels.prefix(levels.count / 2) // Get first half
        let secondHalf = levels.suffix(levels.count / 2) // Get second half
        return calculateStrainTrendDirection(first: Array(firstHalf), second: Array(secondHalf)) // Calculate trend direction
    }
    
    private func calculateStrainTrendDirection(first: [DailyVisionCheck.EyeCheck.EyeStrainLevel], second: [DailyVisionCheck.EyeCheck.EyeStrainLevel]) -> VisionAnalysisReport.EyeAnalysis.TrendDirection { // Private function to calculate strain trend direction
        let firstValues = first.map { level -> Double in // Map to values
            switch level { // Switch on level
            case .none: return 0.0 // No strain value
            case .mild: return 1.0 // Mild strain value
            case .moderate: return 2.0 // Moderate strain value
            case .severe: return 3.0 // Severe strain value
            }
        }
        let secondValues = second.map { level -> Double in // Map to values
            switch level { // Switch on level
            case .none: return 0.0 // No strain value
            case .mild: return 1.0 // Mild strain value
            case .moderate: return 2.0 // Moderate strain value
            case .severe: return 3.0 // Severe strain value
            }
        }
        let firstAverage = firstValues.reduce(0, +) / Double(firstValues.count) // Calculate first average
        let secondAverage = secondValues.reduce(0, +) / Double(secondValues.count) // Calculate second average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.2 { // Check if difference is small
            return .stable // Return stable
        } else if difference < 0 { // Check if improving (lower strain)
            return .improving // Return improving
        } else { // If declining (higher strain)
            return .declining // Return declining
        }
    }
    
    private func calculateAverageDryness(levels: [DailyVisionCheck.EyeCheck.DrynessLevel]) -> VisionAnalysisReport.EyeAnalysis.DrynessLevel? { // Private function to calculate average dryness
        guard !levels.isEmpty else { return nil } // Check if levels exist
        let counts = Dictionary(grouping: levels, by: { $0 }) // Group by level
        let mostCommon = counts.max(by: { $0.value.count < $1.value.count })?.key // Get most common
        return mostCommon // Return most common level
    }
    
    private func calculateDrynessTrend(levels: [DailyVisionCheck.EyeCheck.DrynessLevel]) -> VisionAnalysisReport.EyeAnalysis.TrendDirection { // Private function to calculate dryness trend
        guard levels.count >= 2 else { return .stable } // Check if enough levels
        let firstHalf = levels.prefix(levels.count / 2) // Get first half
        let secondHalf = levels.suffix(levels.count / 2) // Get second half
        let firstValues = firstHalf.map { level -> Double in // Map to values
            switch level { // Switch on level
            case .none: return 0.0 // No dryness value
            case .mild: return 1.0 // Mild dryness value
            case .moderate: return 2.0 // Moderate dryness value
            case .severe: return 3.0 // Severe dryness value
            }
        }
        let secondValues = secondHalf.map { level -> Double in // Map to values
            switch level { // Switch on level
            case .none: return 0.0 // No dryness value
            case .mild: return 1.0 // Mild dryness value
            case .moderate: return 2.0 // Moderate dryness value
            case .severe: return 3.0 // Severe dryness value
            }
        }
        let firstAverage = firstValues.reduce(0, +) / Double(firstValues.count) // Calculate first average
        let secondAverage = secondValues.reduce(0, +) / Double(secondValues.count) // Calculate second average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.2 { // Check if difference is small
            return .stable // Return stable
        } else if difference < 0 { // Check if improving (lower dryness)
            return .improving // Return improving
        } else { // If declining (higher dryness)
            return .declining // Return declining
        }
    }
    
    private func analyzeColorVision(checks: [DailyVisionCheck.EyeCheck]) -> VisionAnalysisReport.EyeAnalysis.ColorVisionStatus { // Private function to analyze color vision
        let colorTests = checks.compactMap { $0.colorVision } // Get color vision tests
        guard !colorTests.isEmpty else { return .unknown } // Check if tests exist
        let deficiencies = colorTests.filter { $0 != .normal } // Filter deficiencies
        return deficiencies.count > colorTests.count / 2 ? .deficiency : .normal // Return status based on deficiencies
    }
    
    private func calculateCoordinationScore(binocular: Double?, convergence: Double?, divergence: Double?) -> Double? { // Private function to calculate coordination score
        var scores: [Double] = [] // Initialize scores array
        if let binocular = binocular { scores.append(binocular) } // Add binocular score
        if let convergence = convergence { scores.append(convergence) } // Add convergence score
        if let divergence = divergence { scores.append(divergence) } // Add divergence score
        return scores.isEmpty ? nil : scores.reduce(0, +) / Double(scores.count) // Calculate average score
    }
    
    private func calculateTrendDirection(first: [Double], second: [Double]) -> VisionAnalysisReport.EyeAnalysis.TrendDirection { // Private function to calculate trend direction
        guard !first.isEmpty && !second.isEmpty else { return .stable } // Check if arrays exist
        let firstAverage = first.reduce(0, +) / Double(first.count) // Calculate first average
        let secondAverage = second.reduce(0, +) / Double(second.count) // Calculate second average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.05 { // Check if difference is small
            return .stable // Return stable
        } else if difference > 0 { // Check if improving
            return .improving // Return improving
        } else { // If declining
            return .declining // Return declining
        }
    }
    
    private func determineOverallTrend(acuity: VisionAnalysisReport.EyeAnalysis.TrendDirection, strain: VisionAnalysisReport.EyeAnalysis.TrendDirection) -> VisionAnalysisReport.EyeAnalysis.TrendDirection { // Private function to determine overall trend
        if acuity == .improving && strain == .improving { // Check if both improving
            return .improving // Return improving
        } else if acuity == .declining || strain == .declining { // Check if either declining
            return .declining // Return declining
        } else { // Otherwise
            return .stable // Return stable
        }
    }
}
