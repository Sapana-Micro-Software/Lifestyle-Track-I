import Foundation

// MARK: - Cognitive Assessment
struct CognitiveAssessment: Codable, Identifiable {
    let id: UUID
    let date: Date
    
    // Intelligence Quotients
    var iq: IQAssessment?
    var eq: EQAssessment?
    var cq: CQAssessment?
    
    // Reasoning Assessments
    var spatialReasoning: SpatialReasoningAssessment?
    var temporalReasoning: TemporalReasoningAssessment?
    
    // Problem-Solving
    var tacticalProblemSolving: TacticalProblemSolvingAssessment?
    var strategicProblemSolving: StrategicProblemSolvingAssessment?
    
    // Psychic Capabilities
    var psychicCapabilities: PsychicCapabilitiesAssessment?
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - IQ Assessment
struct IQAssessment: Codable {
    var fullScaleIQ: Int?
    var verbalIQ: Int?
    var performanceIQ: Int?
    var workingMemory: Int?
    var processingSpeed: Int?
    var perceptualReasoning: Int?
    var testType: String? // WAIS, WISC, Stanford-Binet, etc.
    var percentile: Int?
    var classification: IQClassification?
    
    enum IQClassification: String, Codable {
        case extremelyLow = "Extremely Low"
        case borderline = "Borderline"
        case lowAverage = "Low Average"
        case average = "Average"
        case highAverage = "High Average"
        case superior = "Superior"
        case verySuperior = "Very Superior"
    }
}

// MARK: - EQ Assessment (Emotional Intelligence)
struct EQAssessment: Codable {
    var totalScore: Int?
    var selfAwareness: Int?
    var selfRegulation: Int?
    var motivation: Int?
    var empathy: Int?
    var socialSkills: Int?
    var percentile: Int?
    var classification: EQClassification?
    
    enum EQClassification: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
    }
}

// MARK: - CQ Assessment (Creative Intelligence)
struct CQAssessment: Codable {
    var totalScore: Int?
    var fluency: Int? // Number of ideas generated
    var flexibility: Int? // Variety of ideas
    var originality: Int? // Uniqueness of ideas
    var elaboration: Int? // Detail in ideas
    var percentile: Int?
    var classification: CQClassification?
    
    enum CQClassification: String, Codable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case veryHigh = "Very High"
    }
}

// MARK: - Spatial Reasoning Assessment
struct SpatialReasoningAssessment: Codable {
    var score: Int?
    var percentile: Int?
    var testComponents: [SpatialTestComponent]?
    
    struct SpatialTestComponent: Codable {
        var name: String
        var score: Int
        var maxScore: Int
        var description: String
    }
    
    var abilities: [SpatialAbility]?
    
    enum SpatialAbility: String, Codable {
        case mentalRotation = "Mental Rotation"
        case spatialVisualization = "Spatial Visualization"
        case spatialPerception = "Spatial Perception"
        case spatialWorkingMemory = "Spatial Working Memory"
        case navigation = "Navigation"
        case objectLocationMemory = "Object Location Memory"
    }
}

// MARK: - Temporal Reasoning Assessment
struct TemporalReasoningAssessment: Codable {
    var score: Int?
    var percentile: Int?
    var testComponents: [TemporalTestComponent]?
    
    struct TemporalTestComponent: Codable {
        var name: String
        var score: Int
        var maxScore: Int
        var description: String
    }
    
    var abilities: [TemporalAbility]?
    
    enum TemporalAbility: String, Codable {
        case timeEstimation = "Time Estimation"
        case temporalSequencing = "Temporal Sequencing"
        case temporalMemory = "Temporal Memory"
        case temporalPatternRecognition = "Temporal Pattern Recognition"
        case futurePlanning = "Future Planning"
        case temporalAwareness = "Temporal Awareness"
    }
}

// MARK: - Tactical Problem-Solving Assessment
struct TacticalProblemSolvingAssessment: Codable {
    var score: Int?
    var percentile: Int?
    var responseTime: Double? // seconds
    var accuracy: Double? // percentage
    var scenarios: [TacticalScenario]?
    
    struct TacticalScenario: Codable {
        var name: String
        var score: Int
        var timeToSolve: Double // seconds
        var optimalSolution: Bool
        var efficiency: Double // percentage
    }
    
    var strengths: [TacticalStrength]?
    
    enum TacticalStrength: String, Codable {
        case quickDecisionMaking = "Quick Decision Making"
        case immediateProblemSolving = "Immediate Problem Solving"
        case shortTermStrategy = "Short-Term Strategy"
        case adaptiveThinking = "Adaptive Thinking"
        case resourceManagement = "Resource Management"
    }
}

// MARK: - Strategic Problem-Solving Assessment
struct StrategicProblemSolvingAssessment: Codable {
    var score: Int?
    var percentile: Int?
    var planningQuality: Double? // 0-100
    var longTermVision: Double? // 0-100
    var scenarios: [StrategicScenario]?
    
    struct StrategicScenario: Codable {
        var name: String
        var score: Int
        var planningDepth: Double // 0-100
        var outcomePrediction: Double // 0-100
        var contingencyPlanning: Double // 0-100
    }
    
    var strengths: [StrategicStrength]?
    
    enum StrategicStrength: String, Codable {
        case longTermPlanning = "Long-Term Planning"
        case systemsThinking = "Systems Thinking"
        case riskAssessment = "Risk Assessment"
        case scenarioAnalysis = "Scenario Analysis"
        case goalOrientation = "Goal Orientation"
    }
}

// MARK: - Psychic Capabilities Assessment
struct PsychicCapabilitiesAssessment: Codable {
    var remoteViewing: RemoteViewingAssessment?
    var clairvoyance: ClairvoyanceAssessment?
    var telepathy: TelepathyAssessment?
    var precognition: PrecognitionAssessment?
    var psychokinesis: PsychokinesisAssessment?
    
    var overallScore: Int?
    var percentile: Int?
    var classification: PsychicClassification?
    
    enum PsychicClassification: String, Codable {
        case none = "None Detected"
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case exceptional = "Exceptional"
    }
}

// MARK: - Remote Viewing Assessment
struct RemoteViewingAssessment: Codable {
    var score: Int?
    var accuracy: Double? // percentage
    var sessions: [RemoteViewingSession]?
    
    struct RemoteViewingSession: Codable {
        var date: Date
        var target: String
        var accuracy: Double // percentage
        var details: [String]
        var verification: String?
    }
    
    var abilities: [RemoteViewingAbility]?
    
    enum RemoteViewingAbility: String, Codable {
        case targetIdentification = "Target Identification"
        case spatialAccuracy = "Spatial Accuracy"
        case detailRetrieval = "Detail Retrieval"
        case temporalAccuracy = "Temporal Accuracy"
        case emotionalResonance = "Emotional Resonance"
    }
}

// MARK: - Other Psychic Assessments
struct ClairvoyanceAssessment: Codable {
    var score: Int?
    var accuracy: Double?
    var testResults: [String: Double]?
}

struct TelepathyAssessment: Codable {
    var score: Int?
    var accuracy: Double?
    var testResults: [String: Double]?
}

struct PrecognitionAssessment: Codable {
    var score: Int?
    var accuracy: Double?
    var testResults: [String: Double]?
}

struct PsychokinesisAssessment: Codable {
    var score: Int?
    var accuracy: Double?
    var testResults: [String: Double]?
}
