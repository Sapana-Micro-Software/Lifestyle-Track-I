//
//  SleepAnalysis.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Sleep Quality
enum SleepQuality: String, Codable, CaseIterable { // Define SleepQuality enum with string raw values and Codable conformance
    case excellent = "Excellent" // Excellent sleep quality rating option
    case good = "Good" // Good sleep quality rating option
    case fair = "Fair" // Fair sleep quality rating option
    case poor = "Poor" // Poor sleep quality rating option
    case veryPoor = "Very Poor" // Very poor sleep quality rating option
    
    var score: Double { // Computed property returning numeric score for quality
        switch self { // Switch statement to map quality to score
        case .excellent: return 5.0 // Return maximum score for excellent quality
        case .good: return 4.0 // Return high score for good quality
        case .fair: return 3.0 // Return medium score for fair quality
        case .poor: return 2.0 // Return low score for poor quality
        case .veryPoor: return 1.0 // Return minimum score for very poor quality
        }
    }
}

// MARK: - Sleep Stage
enum SleepStage: String, Codable, CaseIterable { // Define SleepStage enum for different sleep phases
    case awake = "Awake" // Awake stage during sleep period
    case lightSleep = "Light Sleep" // Light sleep stage (N1, N2)
    case deepSleep = "Deep Sleep" // Deep sleep stage (N3, N4, Slow Wave Sleep)
    case remSleep = "REM Sleep" // Rapid Eye Movement sleep stage
    case deepRem = "Deep REM" // Deep REM sleep variant
    case lightRem = "Light REM" // Light REM sleep variant
    case nonRem = "Non-REM" // Non-REM sleep stage category
}

// MARK: - Sleep Record
struct SleepRecord: Codable, Identifiable { // Define SleepRecord struct for individual sleep sessions
    let id: UUID // Unique identifier for sleep record
    var date: Date // Date of sleep session
    var bedtime: Date? // Time when user went to bed
    var wakeTime: Date? // Time when user woke up
    var totalSleepHours: Double? // Total hours of sleep for the night
    var quality: SleepQuality? // Subjective sleep quality rating
    var snoring: SnoringData? // Snoring information and measurements
    var stages: [SleepStageData] // Array of sleep stage data throughout night
    var interruptions: [SleepInterruption] // Array of sleep interruptions or awakenings
    var environment: SleepEnvironment? // Sleep environment factors affecting quality
    var notes: String? // Optional notes about sleep session
    
    struct SleepStageData: Codable { // Nested struct for individual sleep stage data
        var stage: SleepStage // Type of sleep stage
        var startTime: Date // Start time of this sleep stage
        var duration: Double // Duration of stage in minutes
        var heartRate: Int? // Average heart rate during stage
        var breathingRate: Int? // Average breathing rate during stage
    }
    
    struct SleepInterruption: Codable, Identifiable { // Nested struct for sleep interruptions
        let id: UUID // Unique identifier for interruption
        var time: Date // Time when interruption occurred
        var duration: Double // Duration of interruption in minutes
        var reason: String? // Reason for interruption if known
        var wokeUp: Bool // Whether user fully woke up
    }
    
    struct SnoringData: Codable { // Nested struct for snoring information
        var detected: Bool // Whether snoring was detected during sleep
        var frequency: SnoringFrequency? // Frequency of snoring episodes
        var intensity: SnoringIntensity? // Intensity level of snoring
        var totalDuration: Double? // Total minutes of snoring during night
        var episodes: [SnoringEpisode] // Array of individual snoring episodes
        
        enum SnoringFrequency: String, Codable { // Enum for snoring frequency levels
            case none = "None" // No snoring detected
            case occasional = "Occasional" // Occasional snoring episodes
            case frequent = "Frequent" // Frequent snoring throughout night
            case constant = "Constant" // Constant snoring all night
        }
        
        enum SnoringIntensity: String, Codable { // Enum for snoring intensity levels
            case quiet = "Quiet" // Quiet snoring barely audible
            case moderate = "Moderate" // Moderate snoring clearly audible
            case loud = "Loud" // Loud snoring very noticeable
            case veryLoud = "Very Loud" // Very loud snoring disruptive
        }
        
        struct SnoringEpisode: Codable { // Nested struct for individual snoring episodes
            var startTime: Date // Start time of snoring episode
            var duration: Double // Duration of episode in minutes
            var intensity: SnoringIntensity // Intensity of this episode
            var position: SleepPosition? // Sleep position during episode
        }
    }
    
    struct SleepEnvironment: Codable { // Nested struct for sleep environment factors
        var temperature: Double? // Room temperature in Celsius
        var humidity: Double? // Room humidity percentage
        var lightLevel: LightLevel? // Light level in room
        var noiseLevel: NoiseLevel? // Noise level in environment
        var mattressQuality: String? // Quality or type of mattress
        var pillowType: String? // Type of pillow used
        
        enum LightLevel: String, Codable { // Enum for light level categories
            case pitchBlack = "Pitch Black" // Completely dark room
            case veryDark = "Very Dark" // Very dark with minimal light
            case dim = "Dim" // Dim lighting in room
            case moderate = "Moderate" // Moderate lighting present
            case bright = "Bright" // Bright lighting in room
        }
        
        enum NoiseLevel: String, Codable { // Enum for noise level categories
            case silent = "Silent" // Completely silent environment
            case quiet = "Quiet" // Very quiet minimal noise
            case moderate = "Moderate" // Moderate background noise
            case loud = "Loud" // Loud disruptive noise
            case veryLoud = "Very Loud" // Very loud constant noise
        }
    }
    
    enum SleepPosition: String, Codable { // Enum for sleep position types
        case back = "Back" // Sleeping on back supine position
        case stomach = "Stomach" // Sleeping on stomach prone position
        case leftSide = "Left Side" // Sleeping on left side
        case rightSide = "Right Side" // Sleeping on right side
        case multiple = "Multiple" // Multiple positions throughout night
    }
    
    init(id: UUID = UUID(), date: Date = Date(), bedtime: Date? = nil, wakeTime: Date? = nil, totalSleepHours: Double? = nil, quality: SleepQuality? = nil, snoring: SnoringData? = nil, stages: [SleepStageData] = [], interruptions: [SleepInterruption] = [], environment: SleepEnvironment? = nil, notes: String? = nil) {
        self.id = id // Initialize unique identifier
        self.date = date // Initialize sleep date
        self.bedtime = bedtime // Initialize bedtime optional value
        self.wakeTime = wakeTime // Initialize wake time optional value
        self.totalSleepHours = totalSleepHours // Initialize total sleep hours optional value
        self.quality = quality // Initialize sleep quality optional value
        self.snoring = snoring // Initialize snoring data optional value
        self.stages = stages // Initialize sleep stages array
        self.interruptions = interruptions // Initialize interruptions array
        self.environment = environment // Initialize environment data optional value
        self.notes = notes // Initialize notes optional string
    }
    
    // MARK: - Computed Properties
    var totalDeepRemMinutes: Double { // Computed property calculating total deep REM sleep
        return stages.filter { $0.stage == .deepRem }.reduce(0) { $0 + $1.duration } // Sum duration of all deep REM stages
    }
    
    var totalLightRemMinutes: Double { // Computed property calculating total light REM sleep
        return stages.filter { $0.stage == .lightRem }.reduce(0) { $0 + $1.duration } // Sum duration of all light REM stages
    }
    
    var totalRemMinutes: Double { // Computed property calculating total REM sleep
        return stages.filter { $0.stage == .remSleep || $0.stage == .deepRem || $0.stage == .lightRem }.reduce(0) { $0 + $1.duration } // Sum all REM variants
    }
    
    var totalNonRemMinutes: Double { // Computed property calculating total non-REM sleep
        return stages.filter { $0.stage == .nonRem || $0.stage == .lightSleep || $0.stage == .deepSleep }.reduce(0) { $0 + $1.duration } // Sum all non-REM stages
    }
    
    var totalDeepSleepMinutes: Double { // Computed property calculating total deep sleep
        return stages.filter { $0.stage == .deepSleep }.reduce(0) { $0 + $1.duration } // Sum duration of deep sleep stages
    }
    
    var totalLightSleepMinutes: Double { // Computed property calculating total light sleep
        return stages.filter { $0.stage == .lightSleep }.reduce(0) { $0 + $1.duration } // Sum duration of light sleep stages
    }
    
    var sleepEfficiency: Double { // Computed property calculating sleep efficiency percentage
        guard let bedtime = bedtime, let wakeTime = wakeTime else { return 0 } // Check if times available
        let timeInBed = wakeTime.timeIntervalSince(bedtime) / 3600 // Calculate hours in bed
        guard let sleepHours = totalSleepHours, timeInBed > 0 else { return 0 } // Check if sleep hours available
        return (sleepHours / timeInBed) * 100 // Return efficiency as percentage
    }
    
    var snoringDetected: Bool { // Computed property checking if snoring was detected
        return snoring?.detected ?? false // Return snoring detection status
    }
    
    var snoringDuration: Double { // Computed property getting total snoring duration
        return snoring?.totalDuration ?? 0 // Return total snoring duration in minutes
    }
}

// MARK: - Sleep Analysis
struct SleepAnalysis: Codable { // Define SleepAnalysis struct for aggregated sleep data
    var records: [SleepRecord] // Array of sleep records for analysis period
    var analysisPeriod: AnalysisPeriod // Time period for analysis
    var averageSleepHours: Double? // Average hours of sleep per night
    var averageQuality: SleepQuality? // Average sleep quality rating
    var averageDeepRem: Double? // Average deep REM minutes per night
    var averageLightRem: Double? // Average light REM minutes per night
    var averageRem: Double? // Average total REM minutes per night
    var averageNonRem: Double? // Average non-REM minutes per night
    var averageDeepSleep: Double? // Average deep sleep minutes per night
    var averageLightSleep: Double? // Average light sleep minutes per night
    var snoringFrequency: Double? // Percentage of nights with snoring
    var averageSnoringDuration: Double? // Average snoring duration per night
    var sleepEfficiency: Double? // Average sleep efficiency percentage
    var recommendations: [SleepRecommendation] // Array of sleep improvement recommendations
    
    enum AnalysisPeriod: String, Codable { // Enum for analysis time periods
        case week = "Week" // One week analysis period
        case month = "Month" // One month analysis period
        case threeMonths = "3 Months" // Three month analysis period
        case sixMonths = "6 Months" // Six month analysis period
        case year = "Year" // One year analysis period
    }
    
    struct SleepRecommendation: Codable, Identifiable { // Nested struct for sleep recommendations
        let id: UUID // Unique identifier for recommendation
        var category: RecommendationCategory // Category of recommendation
        var priority: Priority // Priority level of recommendation
        var title: String // Title of recommendation
        var description: String // Detailed description of recommendation
        var actions: [String] // Specific actions to take
        
        enum RecommendationCategory: String, Codable { // Enum for recommendation categories
            case duration = "Sleep Duration" // Recommendations about sleep duration
            case quality = "Sleep Quality" // Recommendations about sleep quality
            case stages = "Sleep Stages" // Recommendations about sleep stages
            case snoring = "Snoring" // Recommendations about snoring
            case environment = "Environment" // Recommendations about sleep environment
            case routine = "Sleep Routine" // Recommendations about sleep routine
            case diet = "Diet" // Diet-related sleep recommendations
            case exercise = "Exercise" // Exercise-related sleep recommendations
        }
        
        enum Priority: String, Codable { // Enum for recommendation priority
            case low = "Low" // Low priority recommendation
            case medium = "Medium" // Medium priority recommendation
            case high = "High" // High priority recommendation
            case critical = "Critical" // Critical priority recommendation
        }
        
        init(id: UUID = UUID(), category: RecommendationCategory, priority: Priority, title: String, description: String, actions: [String]) {
            self.id = id // Initialize unique identifier
            self.category = category // Initialize recommendation category
            self.priority = priority // Initialize priority level
            self.title = title // Initialize recommendation title
            self.description = description // Initialize recommendation description
            self.actions = actions // Initialize action items array
        }
    }
    
    init(records: [SleepRecord] = [], analysisPeriod: AnalysisPeriod = .week) {
        self.records = records // Initialize sleep records array
        self.analysisPeriod = analysisPeriod // Initialize analysis period
        self.recommendations = [] // Initialize recommendations array
        calculateAverages() // Calculate average values from records
    }
    
    // MARK: - Analysis Methods
    mutating func calculateAverages() { // Mutating function to calculate average sleep metrics
        guard !records.isEmpty else { return } // Check if records exist
        
        let totalHours = records.compactMap { $0.totalSleepHours }.reduce(0, +) // Sum all sleep hours
        averageSleepHours = totalHours / Double(records.count) // Calculate average hours
        
        let qualityScores = records.compactMap { $0.quality?.score } // Extract quality scores
        if !qualityScores.isEmpty { // Check if scores available
            let avgScore = qualityScores.reduce(0, +) / Double(qualityScores.count) // Calculate average score
            averageQuality = SleepQuality.allCases.first { abs($0.score - avgScore) < 0.5 } // Find closest quality match
        }
        
        let deepRemValues = records.map { $0.totalDeepRemMinutes } // Extract deep REM values
        averageDeepRem = deepRemValues.reduce(0, +) / Double(deepRemValues.count) // Calculate average deep REM
        
        let lightRemValues = records.map { $0.totalLightRemMinutes } // Extract light REM values
        averageLightRem = lightRemValues.reduce(0, +) / Double(lightRemValues.count) // Calculate average light REM
        
        let remValues = records.map { $0.totalRemMinutes } // Extract total REM values
        averageRem = remValues.reduce(0, +) / Double(remValues.count) // Calculate average total REM
        
        let nonRemValues = records.map { $0.totalNonRemMinutes } // Extract non-REM values
        averageNonRem = nonRemValues.reduce(0, +) / Double(nonRemValues.count) // Calculate average non-REM
        
        let deepSleepValues = records.map { $0.totalDeepSleepMinutes } // Extract deep sleep values
        averageDeepSleep = deepSleepValues.reduce(0, +) / Double(deepSleepValues.count) // Calculate average deep sleep
        
        let lightSleepValues = records.map { $0.totalLightSleepMinutes } // Extract light sleep values
        averageLightSleep = lightSleepValues.reduce(0, +) / Double(lightSleepValues.count) // Calculate average light sleep
        
        let snoringNights = records.filter { $0.snoringDetected }.count // Count nights with snoring
        snoringFrequency = (Double(snoringNights) / Double(records.count)) * 100 // Calculate snoring frequency percentage
        
        let snoringDurations = records.map { $0.snoringDuration } // Extract snoring durations
        averageSnoringDuration = snoringDurations.reduce(0, +) / Double(snoringDurations.count) // Calculate average snoring duration
        
        let efficiencies = records.map { $0.sleepEfficiency } // Extract sleep efficiencies
        sleepEfficiency = efficiencies.reduce(0, +) / Double(efficiencies.count) // Calculate average efficiency
    }
}
