//
//  ConversationTemplates.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Conversation Template
struct ConversationTemplate: Codable, Identifiable {
    let id: UUID
    var title: String
    var category: TemplateCategory
    var template: String
    var description: String
    
    enum TemplateCategory: String, Codable, CaseIterable {
        case feeling = "I'm Feeling..."
        case needHelp = "I Need Help With..."
        case progress = "Progress Update"
        case crisis = "Crisis Support"
        case question = "I Have a Question"
        case gratitude = "Gratitude"
        case concern = "I'm Concerned About..."
        
        var icon: String {
            switch self {
            case .feeling: return "heart.fill"
            case .needHelp: return "hand.raised.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .crisis: return "exclamationmark.triangle.fill"
            case .question: return "questionmark.circle.fill"
            case .gratitude: return "star.fill"
            case .concern: return "eye.fill"
            }
        }
    }
    
    init(id: UUID = UUID(), title: String, category: TemplateCategory, template: String, description: String) {
        self.id = id
        self.title = title
        self.category = category
        self.template = template
        self.description = description
    }
}

// MARK: - Conversation Template Library
class ConversationTemplateLibrary {
    static let shared = ConversationTemplateLibrary()
    
    let templates: [ConversationTemplate] = [
        // Feeling Templates
        ConversationTemplate(
            title: "I'm Feeling Anxious",
            category: .feeling,
            template: "I'm feeling anxious right now. [Describe what's making you anxious and how it's affecting you]",
            description: "Start a conversation about anxiety"
        ),
        ConversationTemplate(
            title: "I'm Feeling Sad",
            category: .feeling,
            template: "I'm feeling sad today. [Describe what's contributing to your sadness and how long you've been feeling this way]",
            description: "Express feelings of sadness"
        ),
        ConversationTemplate(
            title: "I'm Feeling Stressed",
            category: .feeling,
            template: "I'm feeling really stressed. [Describe what's causing your stress and how it's impacting your daily life]",
            description: "Talk about stress"
        ),
        ConversationTemplate(
            title: "I'm Feeling Overwhelmed",
            category: .feeling,
            template: "I'm feeling overwhelmed by everything. [Describe what feels overwhelming and what you need help with]",
            description: "Express feeling overwhelmed"
        ),
        
        // Need Help Templates
        ConversationTemplate(
            title: "I Need Help Coping",
            category: .needHelp,
            template: "I need help learning how to cope with [describe the situation]. I've been struggling with [describe your struggles] and would like some strategies.",
            description: "Request coping strategies"
        ),
        ConversationTemplate(
            title: "I Need Help Understanding My Emotions",
            category: .needHelp,
            template: "I'm having trouble understanding my emotions. [Describe what emotions you're experiencing and why they're confusing]",
            description: "Get help understanding emotions"
        ),
        ConversationTemplate(
            title: "I Need Help with Relationships",
            category: .needHelp,
            template: "I'm having relationship difficulties. [Describe the relationship issue and how it's affecting you]",
            description: "Get relationship support"
        ),
        
        // Progress Templates
        ConversationTemplate(
            title: "I Made Progress",
            category: .progress,
            template: "I wanted to share some progress I've made. [Describe what progress you've made and how you're feeling about it]",
            description: "Share your progress"
        ),
        ConversationTemplate(
            title: "I'm Struggling with Progress",
            category: .progress,
            template: "I feel like I'm not making the progress I hoped for. [Describe what you're struggling with and what you've tried]",
            description: "Discuss progress challenges"
        ),
        
        // Crisis Templates
        ConversationTemplate(
            title: "I'm in Crisis",
            category: .crisis,
            template: "I'm in crisis and need immediate support. [Describe your situation - this will trigger crisis protocols]",
            description: "Get immediate crisis support"
        ),
        
        // Question Templates
        ConversationTemplate(
            title: "I Have a Question About Therapy",
            category: .question,
            template: "I have a question about [your question]. I'm wondering [elaborate on your question]",
            description: "Ask a therapy question"
        ),
        
        // Gratitude Templates
        ConversationTemplate(
            title: "I'm Grateful",
            category: .gratitude,
            template: "I wanted to share something I'm grateful for. [Describe what you're grateful for and why it matters to you]",
            description: "Express gratitude"
        ),
        
        // Concern Templates
        ConversationTemplate(
            title: "I'm Concerned About My Mental Health",
            category: .concern,
            template: "I'm concerned about my mental health. [Describe your concerns and what you've noticed]",
            description: "Express mental health concerns"
        )
    ]
    
    func templates(for category: ConversationTemplate.TemplateCategory) -> [ConversationTemplate] {
        return templates.filter { $0.category == category }
    }
    
    func customizeTemplate(_ template: ConversationTemplate, with userInput: String) -> String {
        return template.template.replacingOccurrences(of: "[", with: userInput).replacingOccurrences(of: "]", with: "")
    }
}
