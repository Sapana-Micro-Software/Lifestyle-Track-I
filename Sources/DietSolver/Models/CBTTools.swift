//
//  CBTTools.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - CBT Thought Record
struct CBTThoughtRecord: Codable, Identifiable {
    let id: UUID
    var date: Date
    var situation: String
    var automaticThought: String
    var emotions: [String]
    var emotionIntensity: Double // 0.0 to 1.0
    var evidenceFor: [String]
    var evidenceAgainst: [String]
    var cognitiveDistortions: [CognitiveDistortion]
    var balancedThought: String?
    var outcome: String?
    var outcomeEmotionIntensity: Double? // 0.0 to 1.0
    
    enum CognitiveDistortion: String, Codable, CaseIterable {
        case allOrNothing = "All-or-Nothing Thinking"
        case overgeneralization = "Overgeneralization"
        case mentalFilter = "Mental Filter"
        case disqualifyingPositive = "Disqualifying the Positive"
        case jumpingToConclusions = "Jumping to Conclusions"
        case magnification = "Magnification (Catastrophizing)"
        case emotionalReasoning = "Emotional Reasoning"
        case shouldStatements = "Should Statements"
        case labeling = "Labeling"
        case personalization = "Personalization"
        
        var description: String {
            switch self {
            case .allOrNothing: return "Viewing situations in black and white categories"
            case .overgeneralization: return "Seeing a single negative event as a never-ending pattern"
            case .mentalFilter: return "Focusing exclusively on negative details"
            case .disqualifyingPositive: return "Rejecting positive experiences"
            case .jumpingToConclusions: return "Making negative interpretations without facts"
            case .magnification: return "Exaggerating the importance of negative events"
            case .emotionalReasoning: return "Assuming negative emotions reflect reality"
            case .shouldStatements: return "Using 'should', 'must', or 'ought' statements"
            case .labeling: return "Attaching negative labels to yourself"
            case .personalization: return "Blaming yourself for events outside your control"
            }
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), situation: String = "", automaticThought: String = "", emotions: [String] = [], emotionIntensity: Double = 0.0, evidenceFor: [String] = [], evidenceAgainst: [String] = [], cognitiveDistortions: [CognitiveDistortion] = [], balancedThought: String? = nil, outcome: String? = nil, outcomeEmotionIntensity: Double? = nil) {
        self.id = id
        self.date = date
        self.situation = situation
        self.automaticThought = automaticThought
        self.emotions = emotions
        self.emotionIntensity = emotionIntensity
        self.evidenceFor = evidenceFor
        self.evidenceAgainst = evidenceAgainst
        self.cognitiveDistortions = cognitiveDistortions
        self.balancedThought = balancedThought
        self.outcome = outcome
        self.outcomeEmotionIntensity = outcomeEmotionIntensity
    }
}

// MARK: - Behavioral Experiment
struct BehavioralExperiment: Codable, Identifiable {
    let id: UUID
    var date: Date
    var prediction: String
    var experiment: String
    var actualOutcome: String?
    var whatLearned: String?
    var completed: Bool
    
    init(id: UUID = UUID(), date: Date = Date(), prediction: String = "", experiment: String = "", actualOutcome: String? = nil, whatLearned: String? = nil, completed: Bool = false) {
        self.id = id
        self.date = date
        self.prediction = prediction
        self.experiment = experiment
        self.actualOutcome = actualOutcome
        self.whatLearned = whatLearned
        self.completed = completed
    }
}

// MARK: - CBT Tools Manager
class CBTToolsManager: ObservableObject {
    static let shared = CBTToolsManager()
    
    @Published var thoughtRecords: [CBTThoughtRecord] = []
    @Published var behavioralExperiments: [BehavioralExperiment] = []
    
    private init() {
        loadData()
    }
    
    func saveThoughtRecord(_ record: CBTThoughtRecord) {
        thoughtRecords.append(record)
        saveData()
    }
    
    func updateThoughtRecord(_ record: CBTThoughtRecord) {
        if let index = thoughtRecords.firstIndex(where: { $0.id == record.id }) {
            thoughtRecords[index] = record
            saveData()
        }
    }
    
    func saveBehavioralExperiment(_ experiment: BehavioralExperiment) {
        behavioralExperiments.append(experiment)
        saveData()
    }
    
    func updateBehavioralExperiment(_ experiment: BehavioralExperiment) {
        if let index = behavioralExperiments.firstIndex(where: { $0.id == experiment.id }) {
            behavioralExperiments[index] = experiment
            saveData()
        }
    }
    
    func detectCognitiveDistortions(in thought: String) -> [CBTThoughtRecord.CognitiveDistortion] {
        var detected: [CBTThoughtRecord.CognitiveDistortion] = []
        let lowerThought = thought.lowercased()
        
        // All-or-nothing
        if lowerThought.contains("always") || lowerThought.contains("never") || lowerThought.contains("everything") || lowerThought.contains("nothing") {
            detected.append(.allOrNothing)
        }
        
        // Overgeneralization
        if lowerThought.contains("everyone") || lowerThought.contains("no one") || lowerThought.contains("every time") {
            detected.append(.overgeneralization)
        }
        
        // Should statements
        if lowerThought.contains("should") || lowerThought.contains("must") || lowerThought.contains("ought") {
            detected.append(.shouldStatements)
        }
        
        // Emotional reasoning
        if lowerThought.contains("feel like") && (lowerThought.contains("bad") || lowerThought.contains("wrong") || lowerThought.contains("terrible")) {
            detected.append(.emotionalReasoning)
        }
        
        // Magnification
        if lowerThought.contains("disaster") || lowerThought.contains("catastrophe") || lowerThought.contains("worst") || lowerThought.contains("terrible") {
            detected.append(.magnification)
        }
        
        // Labeling
        if lowerThought.contains("i am a") || lowerThought.contains("i'm a") || lowerThought.contains("i'm such a") {
            detected.append(.labeling)
        }
        
        return detected
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(thoughtRecords) {
            UserDefaults.standard.set(encoded, forKey: "cbtThoughtRecords")
        }
        if let encoded = try? JSONEncoder().encode(behavioralExperiments) {
            UserDefaults.standard.set(encoded, forKey: "cbtBehavioralExperiments")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "cbtThoughtRecords"),
           let decoded = try? JSONDecoder().decode([CBTThoughtRecord].self, from: data) {
            thoughtRecords = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "cbtBehavioralExperiments"),
           let decoded = try? JSONDecoder().decode([BehavioralExperiment].self, from: data) {
            behavioralExperiments = decoded
        }
    }
}
