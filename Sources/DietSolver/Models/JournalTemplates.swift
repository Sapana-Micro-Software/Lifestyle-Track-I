//
//  JournalTemplates.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Journal Template
enum JournalTemplate: String, Codable, CaseIterable {
    case cbtThoughtRecord = "CBT Thought Record"
    case gratitude = "Gratitude Journal"
    case dailyReflection = "Daily Reflection"
    case moodTracking = "Mood Tracking"
    case goalProgress = "Goal Progress"
    case morningPages = "Morning Pages"
    case eveningReview = "Evening Review"
    case stressLog = "Stress Log"
    
    var title: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .cbtThoughtRecord:
            return "Challenge negative thoughts using CBT techniques"
        case .gratitude:
            return "Write about things you're grateful for"
        case .dailyReflection:
            return "Reflect on your day and experiences"
        case .moodTracking:
            return "Track your mood and emotional patterns"
        case .goalProgress:
            return "Review progress on your therapy goals"
        case .morningPages:
            return "Free-form morning journaling"
        case .eveningReview:
            return "Review and reflect on your day"
        case .stressLog:
            return "Log stressful events and your responses"
        }
    }
    
    var prompts: [String] {
        switch self {
        case .cbtThoughtRecord:
            return [
                "What situation triggered this thought?",
                "What automatic thought came to mind?",
                "What emotions did you feel?",
                "What evidence supports this thought?",
                "What evidence contradicts this thought?",
                "What cognitive distortions might be present?",
                "What's a more balanced thought?",
                "How do you feel now?"
            ]
        case .gratitude:
            return [
                "What are 3 things you're grateful for today?",
                "Who are you grateful for and why?",
                "What experiences made you feel grateful?",
                "What small moments brought you joy?"
            ]
        case .dailyReflection:
            return [
                "How was your day overall?",
                "What went well today?",
                "What challenges did you face?",
                "What did you learn about yourself?",
                "What would you do differently?"
            ]
        case .moodTracking:
            return [
                "How are you feeling right now?",
                "What's your mood on a scale of 1-10?",
                "What factors influenced your mood today?",
                "What patterns do you notice?"
            ]
        case .goalProgress:
            return [
                "What goals are you working on?",
                "What progress have you made?",
                "What obstacles are you facing?",
                "What's your next step?",
                "What support do you need?"
            ]
        case .morningPages:
            return [
                "Write freely about whatever comes to mind...",
                "What's on your mind this morning?",
                "What are you looking forward to today?",
                "What concerns do you have?"
            ]
        case .eveningReview:
            return [
                "How did your day go?",
                "What were the highlights?",
                "What were the low points?",
                "What are you grateful for?",
                "What will you do differently tomorrow?"
            ]
        case .stressLog:
            return [
                "What stressful event occurred?",
                "When did it happen?",
                "How did you respond?",
                "What coping strategies did you use?",
                "What would help next time?"
            ]
        }
    }
    
    func createJournalEntry(date: Date = Date(), responses: [String: String]) -> JournalEntry {
        var structuredData = JournalEntry.StructuredJournalData(
            gratitude: [],
            achievements: [],
            challenges: [],
            lessons: [],
            goalsProgress: [],
            healthMetrics: nil,
            energyLevel: nil,
            stressLevel: nil,
            relationships: [],
            workLife: nil
        )
        var unstructuredText = ""
        
        switch self {
        case .cbtThoughtRecord:
            unstructuredText = "CBT Thought Record:\n"
            for (key, value) in responses {
                unstructuredText += "\(key): \(value)\n"
            }
        case .gratitude:
            if let gratitudeItems = responses["gratitude_items"] {
                structuredData.gratitude = gratitudeItems.components(separatedBy: CharacterSet.newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
        case .dailyReflection:
            if let reflection = responses["reflection"] {
                unstructuredText = reflection
            }
        case .moodTracking:
            if let mood = responses["mood"] {
                unstructuredText = "Mood: \(mood)\n"
                if let factors = responses["factors"] {
                    unstructuredText += "Factors: \(factors)\n"
                }
            }
        case .goalProgress:
            if let goals = responses["goals"] {
                unstructuredText = "Goal Progress:\n\(goals)"
            }
        case .morningPages, .eveningReview:
            if let pages = responses["content"] {
                unstructuredText = pages
            }
        case .stressLog:
            if let stress = responses["stress_event"] {
                unstructuredText = "Stress Log:\n\(stress)"
            }
        }
        
        return JournalEntry(
            id: UUID(),
            date: date,
            entryType: unstructuredText.isEmpty ? .structured : .mixed,
            structuredData: structuredData.gratitude.isEmpty ? nil : structuredData,
            unstructuredText: unstructuredText.isEmpty ? nil : unstructuredText,
            tags: [rawValue.lowercased().replacingOccurrences(of: " ", with: "_")]
        )
    }
}
