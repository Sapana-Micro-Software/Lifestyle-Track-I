//
//  FeedbackLearning.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Message Feedback
struct MessageFeedback: Codable, Identifiable {
    let id: UUID
    var messageId: UUID
    var timestamp: Date
    var helpful: Bool
    var rating: Int? // 1-5 stars
    var comment: String?
    var therapyTechnique: TherapyTechnique?
    var preferredStyle: CommunicationStyle?
    
    enum CommunicationStyle: String, Codable {
        case empathetic = "Empathetic"
        case direct = "Direct"
        case supportive = "Supportive"
        case analytical = "Analytical"
        case encouraging = "Encouraging"
    }
    
    init(id: UUID = UUID(), messageId: UUID, timestamp: Date = Date(), helpful: Bool, rating: Int? = nil, comment: String? = nil, therapyTechnique: TherapyTechnique? = nil, preferredStyle: CommunicationStyle? = nil) {
        self.id = id
        self.messageId = messageId
        self.timestamp = timestamp
        self.helpful = helpful
        self.rating = rating
        self.comment = comment
        self.therapyTechnique = therapyTechnique
        self.preferredStyle = preferredStyle
    }
}

// MARK: - Feedback Learning Manager
class FeedbackLearningManager: ObservableObject {
    static let shared = FeedbackLearningManager()
    
    @Published var feedbackHistory: [MessageFeedback] = []
    @Published var preferredCommunicationStyle: MessageFeedback.CommunicationStyle?
    @Published var preferredTherapyTechniques: [TherapyTechnique] = []
    
    private init() {
        loadData()
        analyzePreferences()
    }
    
    func recordFeedback(_ feedback: MessageFeedback) {
        feedbackHistory.append(feedback)
        saveData()
        analyzePreferences()
    }
    
    func getAverageRating() -> Double {
        let ratings = feedbackHistory.compactMap { $0.rating }
        guard !ratings.isEmpty else { return 0.0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
    
    func getHelpfulPercentage() -> Double {
        guard !feedbackHistory.isEmpty else { return 0.0 }
        let helpfulCount = feedbackHistory.filter { $0.helpful }.count
        return Double(helpfulCount) / Double(feedbackHistory.count)
    }
    
    private func analyzePreferences() {
        // Analyze communication style preferences
        let styleCounts = Dictionary(grouping: feedbackHistory.filter { $0.helpful }, by: { $0.preferredStyle })
            .compactMapValues { $0.count }
        
        if let mostPreferred = styleCounts.max(by: { $0.value < $1.value })?.key {
            preferredCommunicationStyle = mostPreferred
        }
        
        // Analyze therapy technique preferences
        let techniqueCounts = Dictionary(grouping: feedbackHistory.filter { $0.helpful }, by: { $0.therapyTechnique })
            .compactMapValues { $0.count }
        
        preferredTherapyTechniques = techniqueCounts.sorted { $0.value > $1.value }
            .prefix(3)
            .compactMap { $0.key }
    }
    
    func shouldUseTechnique(_ technique: TherapyTechnique) -> Bool {
        return preferredTherapyTechniques.contains(technique)
    }
    
    func getRecommendedStyle() -> MessageFeedback.CommunicationStyle {
        return preferredCommunicationStyle ?? .empathetic
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(feedbackHistory) {
            UserDefaults.standard.set(encoded, forKey: "messageFeedbackHistory")
        }
        if let encoded = try? JSONEncoder().encode(preferredCommunicationStyle) {
            UserDefaults.standard.set(encoded, forKey: "preferredCommunicationStyle")
        }
        if let encoded = try? JSONEncoder().encode(preferredTherapyTechniques) {
            UserDefaults.standard.set(encoded, forKey: "preferredTherapyTechniques")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "messageFeedbackHistory"),
           let decoded = try? JSONDecoder().decode([MessageFeedback].self, from: data) {
            feedbackHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "preferredCommunicationStyle"),
           let decoded = try? JSONDecoder().decode(MessageFeedback.CommunicationStyle.self, from: data) {
            preferredCommunicationStyle = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "preferredTherapyTechniques"),
           let decoded = try? JSONDecoder().decode([TherapyTechnique].self, from: data) {
            preferredTherapyTechniques = decoded
        }
    }
}
