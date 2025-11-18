//
//  HearingData.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Hearing Prescription
struct HearingPrescription: Codable {
    var date: Date
    var expirationDate: Date?
    var rightEar: EarPrescription
    var leftEar: EarPrescription
    var hearingAidSettings: HearingAidSettings?
    var notes: String?
    
    struct EarPrescription: Codable {
        var frequencyResponse: FrequencyResponse?
        var amplificationLevel: Double? // dB
        var hearingLossType: HearingLossType?
        var hearingLossSeverity: HearingLossSeverity?
        
        enum HearingLossType: String, Codable, CaseIterable {
            case conductive = "Conductive"
            case sensorineural = "Sensorineural"
            case mixed = "Mixed"
            case normal = "Normal"
        }
        
        enum HearingLossSeverity: String, Codable, CaseIterable {
            case normal = "Normal"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
            case profound = "Profound"
        }
        
        struct FrequencyResponse: Codable {
            var lowFreq: Double? // Hz
            var midFreq: Double? // Hz
            var highFreq: Double? // Hz
            var responseCurve: [FrequencyPoint]?
            
            struct FrequencyPoint: Codable {
                var frequency: Double // Hz
                var gain: Double // dB
            }
        }
    }
    
    struct HearingAidSettings: Codable {
        var rightEarSettings: [String: Double]?
        var leftEarSettings: [String: Double]?
        var bilateralBalance: Double? // 0-1
    }
    
    init(date: Date = Date(), expirationDate: Date? = nil, rightEar: EarPrescription = EarPrescription(), leftEar: EarPrescription = EarPrescription(), hearingAidSettings: HearingAidSettings? = nil, notes: String? = nil) {
        self.date = date
        self.expirationDate = expirationDate
        self.rightEar = rightEar
        self.leftEar = leftEar
        self.hearingAidSettings = hearingAidSettings
        self.notes = notes
    }
}

// MARK: - Daily Audio Hearing Test
struct DailyAudioHearingTest: Codable, Identifiable {
    let id: UUID
    var date: Date
    var time: Date
    var rightEar: EarTest
    var leftEar: EarTest
    var bothEars: BothEarsTest
    var testType: TestType
    var device: TestDevice
    var environment: TestEnvironment
    var notes: String?
    
    struct EarTest: Codable {
        var pureToneThresholds: [FrequencyThreshold]?
        var speechRecognition: SpeechRecognitionTest?
        var wordRecognition: WordRecognitionTest?
        var tinnitusPresence: Bool?
        var tinnitusSeverity: TinnitusSeverity?
        var earPressure: EarPressure?
        var earPain: EarPainLevel?
        
        struct FrequencyThreshold: Codable {
            var frequency: Double // Hz
            var threshold: Double // dB HL (Hearing Level)
            var ear: EarSide
        }
        
        struct SpeechRecognitionTest: Codable {
            var score: Double // 0-100%
            var noiseLevel: Double? // dB
            var signalToNoiseRatio: Double? // dB
        }
        
        struct WordRecognitionTest: Codable {
            var score: Double // 0-100%
            var wordsCorrect: Int
            var wordsTotal: Int
        }
        
        enum TinnitusSeverity: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
            case verySevere = "Very Severe"
        }
        
        enum EarPressure: String, Codable, CaseIterable {
            case normal = "Normal"
            case low = "Low"
            case high = "High"
            case blocked = "Blocked"
        }
        
        enum EarPainLevel: String, Codable, CaseIterable {
            case none = "None"
            case mild = "Mild"
            case moderate = "Moderate"
            case severe = "Severe"
        }
        
        enum EarSide: String, Codable {
            case left = "Left"
            case right = "Right"
        }
    }
    
    struct BothEarsTest: Codable {
        var binauralHearing: Double? // 0-1 score
        var soundLocalization: Double? // 0-1 score
        var speechInNoise: Double? // 0-1 score
        var spatialHearing: Double? // 0-1 score
    }
    
    enum TestType: String, Codable, CaseIterable {
        case pureTone = "Pure Tone"
        case speech = "Speech Recognition"
        case word = "Word Recognition"
        case comprehensive = "Comprehensive"
        case quick = "Quick Check"
    }
    
    enum TestDevice: String, Codable, CaseIterable {
        case airpods = "AirPods"
        case airpodsPro = "AirPods Pro"
        case airpodsMax = "AirPods Max"
        case iphone = "iPhone"
        case ipad = "iPad"
        case appleWatch = "Apple Watch"
        case audiometer = "Audiometer"
        case manual = "Manual"
        case other = "Other"
    }
    
    struct TestEnvironment: Codable {
        var backgroundNoise: NoiseLevel
        var roomAcoustics: RoomAcoustics
        var distanceFromSource: Double? // meters
        var timeSinceLastTest: TimeInterval?
        
        enum NoiseLevel: String, Codable, CaseIterable {
            case quiet = "Quiet"
            case low = "Low"
            case moderate = "Moderate"
            case high = "High"
            case veryHigh = "Very High"
        }
        
        enum RoomAcoustics: String, Codable, CaseIterable {
            case anechoic = "Anechoic"
            case treated = "Acoustically Treated"
            case normal = "Normal Room"
            case reverberant = "Reverberant"
            case outdoor = "Outdoor"
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), time: Date = Date(), rightEar: EarTest = EarTest(), leftEar: EarTest = EarTest(), bothEars: BothEarsTest = BothEarsTest(), testType: TestType = .quick, device: TestDevice = .iphone, environment: TestEnvironment = TestEnvironment(backgroundNoise: .quiet, roomAcoustics: .normal), notes: String? = nil) {
        self.id = id
        self.date = date
        self.time = time
        self.rightEar = rightEar
        self.leftEar = leftEar
        self.bothEars = bothEars
        self.testType = testType
        self.device = device
        self.environment = environment
        self.notes = notes
    }
}

// MARK: - Music Hearing Session
struct MusicHearingSession: Codable, Identifiable {
    let id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var duration: Double // minutes
    var musicType: MusicType
    var genre: String?
    var volumeLevel: VolumeLevel
    var device: MusicDevice
    var listeningMode: ListeningMode
    var hearingProtection: Bool
    var hearingFatigue: HearingFatigueLevel?
    var enjoyment: EnjoymentLevel
    var notes: String?
    
    enum MusicType: String, Codable, CaseIterable {
        case classical = "Classical"
        case jazz = "Jazz"
        case rock = "Rock"
        case pop = "Pop"
        case electronic = "Electronic"
        case world = "World Music"
        case instrumental = "Instrumental"
        case vocal = "Vocal"
        case therapeutic = "Therapeutic"
        case binaural = "Binaural Beats"
        case nature = "Nature Sounds"
        case meditation = "Meditation Music"
        case other = "Other"
    }
    
    enum VolumeLevel: String, Codable, CaseIterable {
        case veryQuiet = "Very Quiet"
        case quiet = "Quiet"
        case moderate = "Moderate"
        case loud = "Loud"
        case veryLoud = "Very Loud"
    }
    
    enum MusicDevice: String, Codable, CaseIterable {
        case airpods = "AirPods"
        case airpodsPro = "AirPods Pro"
        case airpodsMax = "AirPods Max"
        case headphones = "Headphones"
        case speakers = "Speakers"
        case carAudio = "Car Audio"
        case homeTheater = "Home Theater"
        case other = "Other"
    }
    
    enum ListeningMode: String, Codable, CaseIterable {
        case active = "Active Listening"
        case background = "Background"
        case focused = "Focused"
        case therapeutic = "Therapeutic"
        case exercise = "Exercise"
        case relaxation = "Relaxation"
    }
    
    enum HearingFatigueLevel: String, Codable, CaseIterable {
        case none = "None"
        case mild = "Mild"
        case moderate = "Moderate"
        case severe = "Severe"
    }
    
    enum EnjoymentLevel: String, Codable, CaseIterable {
        case veryLow = "Very Low"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
    }
    
    init(id: UUID = UUID(), date: Date = Date(), startTime: Date = Date(), endTime: Date? = nil, duration: Double = 0, musicType: MusicType = .other, genre: String? = nil, volumeLevel: VolumeLevel = .moderate, device: MusicDevice = .airpods, listeningMode: ListeningMode = .background, hearingProtection: Bool = false, hearingFatigue: HearingFatigueLevel? = nil, enjoyment: EnjoymentLevel = .moderate, notes: String? = nil) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.musicType = musicType
        self.genre = genre
        self.volumeLevel = volumeLevel
        self.device = device
        self.listeningMode = listeningMode
        self.hearingProtection = hearingProtection
        self.hearingFatigue = hearingFatigue
        self.enjoyment = enjoyment
        self.notes = notes
    }
}

// MARK: - Hearing Health Summary
struct HearingHealthSummary: Codable {
    var lastTestDate: Date?
    var averageHearingThreshold: Double? // dB HL
    var trend: HearingTrend
    var recommendations: [String]
    var nextTestDue: Date?
    var musicSessionFrequency: Double? // sessions per week
    var averageSessionDuration: Double? // minutes
    
    enum HearingTrend: String, Codable {
        case improving = "Improving"
        case stable = "Stable"
        case declining = "Declining"
        case fluctuating = "Fluctuating"
    }
    
    init(lastTestDate: Date? = nil, averageHearingThreshold: Double? = nil, trend: HearingTrend = .stable, recommendations: [String] = [], nextTestDue: Date? = nil, musicSessionFrequency: Double? = nil, averageSessionDuration: Double? = nil) {
        self.lastTestDate = lastTestDate
        self.averageHearingThreshold = averageHearingThreshold
        self.trend = trend
        self.recommendations = recommendations
        self.nextTestDue = nextTestDue
        self.musicSessionFrequency = musicSessionFrequency
        self.averageSessionDuration = averageSessionDuration
    }
}

// MARK: - Hearing Analysis Report
struct HearingAnalysisReport: Codable {
    var date: Date
    var summary: HearingHealthSummary
    var testHistory: [DailyAudioHearingTest]
    var musicSessionHistory: [MusicHearingSession]
    var patterns: HearingPatterns
    var recommendations: [HearingRecommendation]
    
    struct HearingPatterns: Codable {
        var hearingLossProgression: String?
        var musicListeningPatterns: String?
        var fatiguePatterns: String?
        var volumePreferenceTrends: String?
    }
    
    struct HearingRecommendation: Codable, Identifiable {
        let id: UUID
        var type: RecommendationType
        var priority: Priority
        var description: String
        var actionItems: [String]
        
        enum RecommendationType: String, Codable {
            case test = "Hearing Test"
            case music = "Music Session"
            case protection = "Hearing Protection"
            case exercise = "Hearing Exercise"
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
    
    init(date: Date = Date(), summary: HearingHealthSummary = HearingHealthSummary(), testHistory: [DailyAudioHearingTest] = [], musicSessionHistory: [MusicHearingSession] = [], patterns: HearingPatterns = HearingPatterns(), recommendations: [HearingRecommendation] = []) {
        self.date = date
        self.summary = summary
        self.testHistory = testHistory
        self.musicSessionHistory = musicSessionHistory
        self.patterns = patterns
        self.recommendations = recommendations
    }
}
