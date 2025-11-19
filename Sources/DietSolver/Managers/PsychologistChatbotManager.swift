//
//  PsychologistChatbotManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
import NaturalLanguage
import Vision
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Psychologist Chatbot Manager
class PsychologistChatbotManager: ObservableObject {
    static let shared = PsychologistChatbotManager()
    
    @Published var currentSession: ConversationSession?
    @Published var userProfile: PsychologistUserProfile
    @Published var isProcessing: Bool = false
    @Published var crisisDetected: Bool = false
    @Published var crisisLevel: SentimentAnalysis.RiskLevel?
    
    private let languageRecognizer = NLLanguageRecognizer()
    private let tokenizer = NLTokenizer(unit: .word)
    private var tagger: NLTagger {
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .sentimentScore])
        tagger.string = ""
        return tagger
    }
    
    // Reference to health data for personalization
    private var healthData: HealthData?
    private var emotionalHealthHistory: [EmotionalHealth] = []
    private var journalEntries: [JournalEntry] = []
    
    // Therapy approach selection
    private var activeTherapyApproach: TherapyTechnique = .personCentered
    
    private init() {
        self.userProfile = PsychologistUserProfile()
        setupNaturalLanguage()
    }
    
    // MARK: - Setup
    func setupNaturalLanguage() {
        // Configure language recognizer
        languageRecognizer.languageConstraints = [.english]
        
        // Configure tokenizer
        tokenizer.setLanguage(.english)
        
        // Configure tagger
        tagger.string = ""
    }
    
    // MARK: - Session Management
    func startNewSession() {
        currentSession = ConversationSession(
            startDate: Date(),
            messages: [createWelcomeMessage()],
            therapyApproach: selectTherapyApproach()
        )
    }
    
    func endCurrentSession() {
        guard var session = currentSession else { return }
        session.endDate = Date()
        generateSessionSummary(for: &session)
        userProfile.conversationHistory.append(session)
        saveUserProfile()
        currentSession = nil
    }
    
    // MARK: - Message Processing
    func processUserMessage(_ text: String, image: Any? = nil) async {
        isProcessing = true
        defer { isProcessing = false }
        
        guard var session = currentSession else { return }
        
        // Analyze text
        let sentiment = analyzeSentiment(text)
        let entities = extractEntities(text)
        let intent = classifyIntent(text)
        
        // Analyze image if provided
        var imageAnalysis: ImageEmotionalAnalysis? = nil
        if let image = image {
            imageAnalysis = await analyzeImage(image)
        }
        
        // Create user message
        let userMessage = ChatMessage(
            role: .user,
            content: text,
            sentiment: sentiment,
            entities: entities,
            intent: intent,
            imageAnalysis: imageAnalysis
        )
        
        session.messages.append(userMessage)
        
        // Check for crisis
        checkForCrisis(in: userMessage, session: &session)
        
        // Generate personalized response
        let response = await generateResponse(
            to: userMessage,
            in: session,
            sentiment: sentiment,
            entities: entities,
            intent: intent,
            imageAnalysis: imageAnalysis
        )
        
        session.messages.append(response)
        session.personalizedInsights.append(contentsOf: extractInsights(from: userMessage, in: session))
        
        currentSession = session
        updateUserProfile(with: userMessage)
    }
    
    // MARK: - Natural Language Analysis
    
    private func analyzeSentiment(_ text: String) -> SentimentAnalysis {
        var sentiment = SentimentAnalysis(
            score: 0.0,
            magnitude: 0.0,
            dominantEmotion: .neutral,
            emotionScores: [:]
        )
        
        // Use NLTagger for sentiment
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .sentimentScore])
        tagger.string = text
        let range = text.startIndex..<text.endIndex
        
        var emotionScores: [SentimentAnalysis.Emotion: Double] = [:]
        var totalScore: Double = 0.0
        var count: Int = 0
        
        tagger.enumerateTags(in: range, unit: .sentence, scheme: .sentimentScore) { tag, tokenRange in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
                
                // Map sentiment score to emotions
                if score > 0.5 {
                    emotionScores[.joy, default: 0.0] += score
                } else if score < -0.5 {
                    emotionScores[.sadness, default: 0.0] += abs(score)
                } else {
                    emotionScores[.neutral, default: 0.0] += 1.0 - abs(score)
                }
            }
            return true
        }
        
        if count > 0 {
            sentiment.score = totalScore / Double(count)
            sentiment.magnitude = min(abs(sentiment.score), 1.0)
        }
        
        // Detect specific emotions using keywords
        let lowerText = text.lowercased()
        detectEmotions(in: lowerText, scores: &emotionScores)
        
        // Find dominant emotion
        if let dominant = emotionScores.max(by: { $0.value < $1.value }) {
            sentiment.dominantEmotion = dominant.key
        }
        
        sentiment.emotionScores = emotionScores
        
        return sentiment
    }
    
    private func detectEmotions(in text: String, scores: inout [SentimentAnalysis.Emotion: Double]) {
        let emotionKeywords: [SentimentAnalysis.Emotion: [String]] = [
            .anxiety: ["anxious", "worried", "nervous", "panic", "fear", "scared"],
            .stress: ["stressed", "overwhelmed", "pressure", "tension", "strain"],
            .sadness: ["sad", "depressed", "down", "unhappy", "melancholy", "grief"],
            .anger: ["angry", "mad", "furious", "irritated", "frustrated", "annoyed"],
            .fear: ["afraid", "terrified", "frightened", "worried", "concerned"],
            .joy: ["happy", "joyful", "glad", "pleased", "delighted", "cheerful"],
            .gratitude: ["grateful", "thankful", "appreciate", "blessed"],
            .hope: ["hopeful", "optimistic", "positive", "confident"]
        ]
        
        for (emotion, keywords) in emotionKeywords {
            for keyword in keywords {
                if text.contains(keyword) {
                    scores[emotion, default: 0.0] += 0.3
                }
            }
        }
    }
    
    private func extractEntities(_ text: String) -> [NamedEntity] {
        var entities: [NamedEntity] = []
        
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .sentimentScore])
        tagger.string = text
        let range = text.startIndex..<text.endIndex
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag {
                let entityText = String(text[tokenRange])
                let category = mapNameTypeToCategory(tag)
                entities.append(NamedEntity(text: entityText, category: category, confidence: 0.8))
            }
            return true
        }
        
        // Extract additional entities using patterns
        extractPatternEntities(from: text, entities: &entities)
        
        return entities
    }
    
    private func mapNameTypeToCategory(_ tag: NLTag) -> NamedEntity.EntityCategory {
        switch tag {
        case .personalName: return .person
        case .placeName: return .location
        case .organizationName: return .organization
        default: return .emotion
        }
    }
    
    private func extractPatternEntities(from text: String, entities: inout [NamedEntity]) {
        // Extract dates
        let datePattern = #"\d{1,2}[/-]\d{1,2}[/-]\d{2,4}"#
        if let regex = try? NSRegularExpression(pattern: datePattern) {
            let range = NSRange(text.startIndex..., in: text)
            regex.enumerateMatches(in: text, range: range) { match, _, _ in
                if let match = match, let range = Range(match.range, in: text) {
                    entities.append(NamedEntity(text: String(text[range]), category: .date, confidence: 0.9))
                }
            }
        }
        
        // Extract emotions and triggers
        let triggerKeywords = ["trigger", "makes me", "causes", "because of", "due to"]
        for keyword in triggerKeywords {
            if text.lowercased().contains(keyword) {
                // Extract surrounding context as potential trigger
                if let range = text.range(of: keyword, options: .caseInsensitive) {
                    let start = text.index(range.upperBound, offsetBy: 0)
                    let end = text.index(start, offsetBy: 50, limitedBy: text.endIndex) ?? text.endIndex
                    let triggerText = String(text[start..<end]).trimmingCharacters(in: .whitespaces)
                    if !triggerText.isEmpty {
                        entities.append(NamedEntity(text: triggerText, category: .trigger, confidence: 0.7))
                    }
                }
            }
        }
    }
    
    private func classifyIntent(_ text: String) -> ChatMessage.MessageIntent {
        let lowerText = text.lowercased()
        
        // Crisis detection keywords
        let crisisKeywords = ["suicide", "kill myself", "end it all", "want to die", "no point", "hopeless"]
        for keyword in crisisKeywords {
            if lowerText.contains(keyword) {
                return .crisis
            }
        }
        
        // Question detection
        if text.hasSuffix("?") || lowerText.contains("what") || lowerText.contains("how") || lowerText.contains("why") || lowerText.contains("when") || lowerText.contains("where") {
            return .question
        }
        
        // Request detection
        if lowerText.contains("help") || lowerText.contains("advice") || lowerText.contains("suggest") || lowerText.contains("recommend") {
            return .request
        }
        
        // Gratitude detection
        if lowerText.contains("thank") || lowerText.contains("grateful") || lowerText.contains("appreciate") {
            return .gratitude
        }
        
        // Progress detection
        if lowerText.contains("better") || lowerText.contains("improved") || lowerText.contains("progress") || lowerText.contains("achieved") {
            return .progress
        }
        
        // Concern detection
        if lowerText.contains("worried") || lowerText.contains("concerned") || lowerText.contains("anxious") || lowerText.contains("stressed") {
            return .concern
        }
        
        return .statement
    }
    
    // MARK: - Vision Framework Integration
    
    @MainActor
    private func analyzeImage(_ image: Any) async -> ImageEmotionalAnalysis? {
        #if canImport(UIKit)
        guard let uiImage = image as? UIImage else { return nil }
        guard let cgImage = uiImage.cgImage else { return nil }
        
        return await withCheckedContinuation { continuation in
            let request = VNDetectFaceLandmarksRequest { request, error in
                guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }
                
                var facialExpressions: [ImageEmotionalAnalysis.FacialExpression] = []
                var dominantEmotion: SentimentAnalysis.Emotion = .neutral
                var maxConfidence: Double = 0.0
                
                for observation in observations {
                    // Analyze facial landmarks for emotion
                    let confidence = Double(observation.confidence)
                    
                    // Use facial landmarks to infer emotion
                    // This is a simplified version - in production, you'd use more sophisticated models
                    let emotion = inferEmotionFromFace(observation)
                    let intensity = calculateEmotionIntensity(observation)
                    
                    facialExpressions.append(ImageEmotionalAnalysis.FacialExpression(
                        emotion: emotion,
                        confidence: confidence,
                        intensity: intensity
                    ))
                    
                    if confidence > maxConfidence {
                        maxConfidence = confidence
                        dominantEmotion = emotion
                    }
                }
                
                let emotionalState: ImageEmotionalAnalysis.EmotionalState = {
                    let positiveCount = facialExpressions.filter { $0.emotion == .joy || $0.emotion == .gratitude || $0.emotion == .hope }.count
                    let negativeCount = facialExpressions.filter { $0.emotion == .sadness || $0.emotion == .anger || $0.emotion == .fear || $0.emotion == .anxiety }.count
                    
                    if positiveCount > negativeCount { return .positive }
                    if negativeCount > positiveCount { return .negative }
                    if positiveCount == negativeCount && positiveCount > 0 { return .mixed }
                    return .neutral
                }()
                
                let analysis = ImageEmotionalAnalysis(
                    facialExpressions: facialExpressions,
                    emotionalState: emotionalState,
                    bodyLanguage: nil, // Would require full body detection
                    environment: nil
                )
                
                continuation.resume(returning: analysis)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
        #else
        return nil
        #endif
    }
    
    #if canImport(UIKit)
    private func inferEmotionFromFace(_ observation: VNFaceObservation) -> SentimentAnalysis.Emotion {
        // Simplified emotion inference based on facial landmarks
        // In production, use a trained emotion recognition model
        
        guard let landmarks = observation.landmarks else {
            return .neutral
        }
        
        // Analyze mouth (smile detection)
        if let outerLips = landmarks.outerLips {
            let mouthPoints = outerLips.normalizedPoints
            if mouthPoints.count >= 2 {
                let mouthHeight = abs(mouthPoints[2].y - mouthPoints[6].y)
                if mouthHeight > 0.1 {
                    return .joy
                }
            }
        }
        
        // Analyze eyebrows (frown detection)
        if let leftEyebrow = landmarks.leftEyebrow, let rightEyebrow = landmarks.rightEyebrow {
            let leftPoints = leftEyebrow.normalizedPoints
            let rightPoints = rightEyebrow.normalizedPoints
            if !leftPoints.isEmpty && !rightPoints.isEmpty {
                let eyebrowAngle = calculateEyebrowAngle(leftPoints, rightPoints)
                if eyebrowAngle < -0.1 {
                    return .sadness
                } else if eyebrowAngle > 0.1 {
                    return .anger
                }
            }
        }
        
        return .neutral
    }
    
    private func calculateEmotionIntensity(_ observation: VNFaceObservation) -> Double {
        // Calculate intensity based on facial expression strength
        return Double(observation.confidence)
    }
    
    private func calculateEyebrowAngle(_ leftPoints: [CGPoint], _ rightPoints: [CGPoint]) -> Double {
        // Simplified eyebrow angle calculation
        guard !leftPoints.isEmpty && !rightPoints.isEmpty else { return 0.0 }
        let leftAvg = leftPoints.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        let rightAvg = rightPoints.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        let leftAvgPoint = CGPoint(x: leftAvg.x / CGFloat(leftPoints.count), y: leftAvg.y / CGFloat(leftPoints.count))
        let rightAvgPoint = CGPoint(x: rightAvg.x / CGFloat(rightPoints.count), y: rightAvg.y / CGFloat(rightPoints.count))
        return Double(rightAvgPoint.y - leftAvgPoint.y)
    }
    #endif
    
    // MARK: - Response Generation
    
    private func generateResponse(
        to message: ChatMessage,
        in session: ConversationSession,
        sentiment: SentimentAnalysis,
        entities: [NamedEntity],
        intent: ChatMessage.MessageIntent,
        imageAnalysis: ImageEmotionalAnalysis?
    ) async -> ChatMessage {
        // Select appropriate therapy technique
        let technique = selectTherapyTechnique(for: message, sentiment: sentiment, intent: intent)
        
        // Generate personalized response based on therapy approach
        let responseText = await generateTherapyResponse(
            to: message,
            using: technique,
            sentiment: sentiment,
            entities: entities,
            intent: intent,
            imageAnalysis: imageAnalysis,
            session: session
        )
        
        return ChatMessage(
            role: .psychologist,
            content: responseText,
            therapyTechnique: technique
        )
    }
    
    private func selectTherapyTechnique(
        for message: ChatMessage,
        sentiment: SentimentAnalysis,
        intent: ChatMessage.MessageIntent
    ) -> TherapyTechnique {
        // Select technique based on context
        switch intent {
        case .crisis:
            return .dbt // DBT is good for crisis situations
        case .question:
            return .solutionFocused
        case .gratitude:
            return .mindfulness
        case .progress:
            return .cbt
        case .concern:
            return .personCentered
        default:
            // Use user's preferred approach or adapt based on sentiment
            if sentiment.score < -0.5 {
                return .cbt // CBT for negative emotions
            } else if sentiment.dominantEmotion == .anxiety || sentiment.dominantEmotion == .stress {
                return .mindfulness
            } else {
                return userProfile.preferredTherapyApproach ?? activeTherapyApproach
            }
        }
    }
    
    private func generateTherapyResponse(
        to message: ChatMessage,
        using technique: TherapyTechnique,
        sentiment: SentimentAnalysis,
        entities: [NamedEntity],
        intent: ChatMessage.MessageIntent,
        imageAnalysis: ImageEmotionalAnalysis?,
        session: ConversationSession
    ) async -> String {
        // This is a sophisticated response generation system
        // In production, this would use a language model or rule-based system
        
        var responseComponents: [String] = []
        
        // Handle crisis first
        if intent == .crisis {
            return generateCrisisResponse()
        }
        
        // Generate response based on therapy technique
        switch technique {
        case .cbt:
            responseComponents.append(generateCBTResponse(to: message, sentiment: sentiment))
        case .personCentered:
            responseComponents.append(generatePersonCenteredResponse(to: message, sentiment: sentiment))
        case .solutionFocused:
            responseComponents.append(generateSolutionFocusedResponse(to: message, intent: intent))
        case .mindfulness:
            responseComponents.append(generateMindfulnessResponse(to: message, sentiment: sentiment))
        case .dbt:
            responseComponents.append(generateDBTResponse(to: message, sentiment: sentiment))
        case .gestalt:
            responseComponents.append(generateGestaltResponse(to: message))
        case .psychodynamic:
            responseComponents.append(generatePsychodynamicResponse(to: message))
        case .existential:
            responseComponents.append(generateExistentialResponse(to: message))
        case .narrative:
            responseComponents.append(generateNarrativeResponse(to: message))
        case .acceptance:
            responseComponents.append(generateAcceptanceResponse(to: message, sentiment: sentiment))
        }
        
        // Add personalized insights
        if let insight = generatePersonalizedInsight(from: message, entities: entities, imageAnalysis: imageAnalysis) {
            responseComponents.append(insight)
        }
        
        // Add follow-up question
        if shouldAskFollowUp(session: session) {
            responseComponents.append(generateFollowUpQuestion(basedOn: message, sentiment: sentiment, intent: intent))
        }
        
        return responseComponents.joined(separator: " ")
    }
    
    // MARK: - Therapy-Specific Response Generators
    
    private func generateCBTResponse(to message: ChatMessage, sentiment: SentimentAnalysis) -> String {
        var response = "I hear you. "
        
        if sentiment.score < -0.3 {
            response += "It sounds like you're experiencing some difficult thoughts or feelings. "
            response += "Can you help me understand what thoughts are going through your mind right now? "
            response += "Sometimes our thoughts can influence how we feel, and exploring them together might be helpful."
        } else {
            response += "Thank you for sharing that with me. "
            response += "I'm curious - what do you think might be contributing to how you're feeling about this?"
        }
        
        return response
    }
    
    private func generatePersonCenteredResponse(to message: ChatMessage, sentiment: SentimentAnalysis) -> String {
        var response = "Thank you for trusting me with that. "
        
        if sentiment.score < 0 {
            response += "It sounds like this is really important to you, and I want you to know that your feelings are valid. "
            response += "Can you tell me more about what this experience has been like for you?"
        } else {
            response += "I'm glad you're sharing this with me. "
            response += "What stands out to you most about this situation?"
        }
        
        return response
    }
    
    private func generateSolutionFocusedResponse(to message: ChatMessage, intent: ChatMessage.MessageIntent) -> String {
        var response = "I appreciate you sharing that. "
        
        if intent == .question {
            response += "That's a thoughtful question. "
            response += "What do you think might work for you in this situation? "
            response += "Sometimes we already have the answers within us."
        } else {
            response += "I'm curious - what would it look like if things were going better? "
            response += "What small step could you take toward that?"
        }
        
        return response
    }
    
    private func generateMindfulnessResponse(to message: ChatMessage, sentiment: SentimentAnalysis) -> String {
        var response = "Thank you for being present with me in this moment. "
        
        if sentiment.dominantEmotion == .anxiety || sentiment.dominantEmotion == .stress {
            response += "I notice you might be experiencing some anxiety or stress. "
            response += "Can we take a moment together? "
            response += "Try taking three deep breaths - in through your nose, out through your mouth. "
            response += "What do you notice in your body right now?"
        } else {
            response += "What are you noticing in this moment? "
            response += "How does it feel to share this with me?"
        }
        
        return response
    }
    
    private func generateDBTResponse(to message: ChatMessage, sentiment: SentimentAnalysis) -> String {
        var response = "I'm here with you. "
        
        if sentiment.score < -0.5 {
            response += "It sounds like you're in a lot of distress right now. "
            response += "Let's work together to help you through this. "
            response += "What skills or strategies have helped you in the past when you've felt this way?"
        } else {
            response += "Thank you for sharing. "
            response += "How are you managing your emotions around this? "
            response += "What's one thing you could do right now that might help you feel a bit more balanced?"
        }
        
        return response
    }
    
    private func generateGestaltResponse(to message: ChatMessage) -> String {
        return "I'm present with you. " +
               "What are you experiencing right now, in this moment? " +
               "How does it feel to say that out loud?"
    }
    
    private func generatePsychodynamicResponse(to message: ChatMessage) -> String {
        return "Thank you for sharing that. " +
               "I'm curious - does this remind you of anything from your past? " +
               "Sometimes patterns from earlier experiences can influence how we feel in the present."
    }
    
    private func generateExistentialResponse(to message: ChatMessage) -> String {
        return "That's a meaningful thing to share. " +
               "What does this experience mean to you? " +
               "How does it connect to what matters most in your life?"
    }
    
    private func generateNarrativeResponse(to message: ChatMessage) -> String {
        return "Thank you for telling me that story. " +
               "I'm wondering - is this the only way to tell this story? " +
               "What would it look like if you were the hero of your own story in this situation?"
    }
    
    private func generateAcceptanceResponse(to message: ChatMessage, sentiment: SentimentAnalysis) -> String {
        var response = "I appreciate your openness. "
        
        if sentiment.score < 0 {
            response += "It sounds like you're experiencing some difficult feelings. "
            response += "Sometimes the first step is simply acknowledging what we're feeling without judgment. "
            response += "What values are important to you that might guide you through this?"
        } else {
            response += "What matters most to you in this situation? "
            response += "How can you move forward in a way that aligns with your values?"
        }
        
        return response
    }
    
    // MARK: - Crisis Detection and Response
    
    private func checkForCrisis(in message: ChatMessage, session: inout ConversationSession) {
        let riskLevel = message.sentiment?.riskLevel ?? .low
        
        if message.intent == .crisis || riskLevel == .high || riskLevel == .critical {
            session.crisisDetected = true
            session.crisisLevel = riskLevel
            crisisDetected = true
            crisisLevel = riskLevel
            
            // Trigger immediate response
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .crisisDetected, object: nil)
            }
        }
    }
    
    private func generateCrisisResponse() -> String {
        return "I'm very concerned about what you've shared. " +
               "Your safety is the most important thing right now. " +
               "Please reach out to a crisis helpline immediately: " +
               "National Suicide Prevention Lifeline: 988 (US) or your local emergency services. " +
               "You don't have to go through this alone - there are people who want to help you right now."
    }
    
    // MARK: - Personalization
    
    private func generatePersonalizedInsight(
        from message: ChatMessage,
        entities: [NamedEntity],
        imageAnalysis: ImageEmotionalAnalysis?
    ) -> String? {
        var insights: [String] = []
        
        // Insight from health data
        if let healthData = healthData {
            if let mentalHealth = healthData.mentalHealth {
                if mentalHealth.stressLevel == .high || mentalHealth.stressLevel == .veryHigh {
                    insights.append("I notice from your health data that you've been experiencing high stress levels. " +
                                   "This might be connected to what you're sharing with me today.")
                }
            }
            
            // Check emotional health patterns
            if let latestEmotional = healthData.emotionalHealth.last {
                if latestEmotional.stressLevel == .high && message.sentiment?.dominantEmotion == .stress {
                    insights.append("I see you've been tracking high stress levels in your emotional health data. " +
                                   "It seems like this is an ongoing concern for you.")
                }
            }
        }
        
        // Insight from triggers
        let triggerEntities = entities.filter { $0.category == .trigger }
        if !triggerEntities.isEmpty {
            let triggers = triggerEntities.map { $0.text }.joined(separator: ", ")
            insights.append("I'm noticing you mentioned some triggers: \(triggers). " +
                           "These seem important to explore further.")
        }
        
        // Insight from image analysis
        if let imageAnalysis = imageAnalysis {
            if imageAnalysis.emotionalState == .negative {
                insights.append("I can see from the image you shared that you might be experiencing some difficult emotions. " +
                               "Your facial expression suggests you're going through something challenging right now.")
            }
        }
        
        // Insight from conversation history
        if let pattern = detectPattern(in: message) {
            insights.append("I'm noticing a pattern here that we've discussed before. " +
                           "\(pattern) This might be worth exploring more deeply.")
        }
        
        return insights.isEmpty ? nil : insights.joined(separator: " ")
    }
    
    private func detectPattern(in message: ChatMessage) -> String? {
        // Check if similar topics have come up before
        let currentTopics = extractTopics(from: message.content)
        
        for session in userProfile.conversationHistory {
            for pastMessage in session.messages where pastMessage.role == .user {
                let pastTopics = extractTopics(from: pastMessage.content)
                let commonTopics = Set(currentTopics).intersection(Set(pastTopics))
                if !commonTopics.isEmpty {
                    return "You've mentioned \(commonTopics.joined(separator: ", ")) before."
                }
            }
        }
        
        return nil
    }
    
    private func extractTopics(from text: String) -> [String] {
        // Simple topic extraction - in production, use more sophisticated NLP
        let keywords = ["work", "family", "relationship", "health", "anxiety", "stress", "depression", "sleep", "exercise", "diet"]
        var topics: [String] = []
        
        let lowerText = text.lowercased()
        for keyword in keywords {
            if lowerText.contains(keyword) {
                topics.append(keyword)
            }
        }
        
        return topics
    }
    
    private func generateFollowUpQuestion(
        basedOn message: ChatMessage,
        sentiment: SentimentAnalysis,
        intent: ChatMessage.MessageIntent
    ) -> String {
        var questions: [String] = []
        
        switch intent {
        case .statement:
            if sentiment.score < 0 {
                questions.append("What would help you feel better about this?")
            } else {
                questions.append("What made this experience positive for you?")
            }
        case .concern:
            questions.append("What's the worst-case scenario you're worried about?")
            questions.append("What would help you feel less worried?")
        case .progress:
            questions.append("What do you think contributed to this improvement?")
            questions.append("How can you build on this progress?")
        default:
            questions.append("Can you tell me more about that?")
            questions.append("What does that mean to you?")
        }
        
        return questions.randomElement() ?? "Can you tell me more about that?"
    }
    
    private func shouldAskFollowUp(session: ConversationSession) -> Bool {
        // Ask follow-up if it's been a while or if the last message was short
        guard let lastMessage = session.messages.last(where: { $0.role == .user }) else {
            return true
        }
        
        if lastMessage.content.count < 50 {
            return true
        }
        
        // Ask follow-up every 2-3 user messages
        let userMessageCount = session.messages.filter { $0.role == .user }.count
        return userMessageCount % 3 == 0
    }
    
    // MARK: - Session Summary
    
    private func generateSessionSummary(for session: inout ConversationSession) {
        let userMessages = session.messages.filter { $0.role == .user }
        let keyTopics = extractKeyTopics(from: userMessages)
        let emotionalPatterns = extractEmotionalPatterns(from: userMessages)
        let progressNotes = generateProgressNotes(from: userMessages)
        let recommendations = generateRecommendations(from: session)
        
        session.sessionSummary = ConversationSession.SessionSummary(
            keyTopics: keyTopics,
            emotionalPatterns: emotionalPatterns,
            progressNotes: progressNotes,
            recommendations: recommendations,
            nextSessionFocus: generateNextSessionFocus(from: session)
        )
    }
    
    private func extractKeyTopics(from messages: [ChatMessage]) -> [String] {
        var topics: Set<String> = []
        
        for message in messages {
            let messageTopics = extractTopics(from: message.content)
            topics.formUnion(messageTopics)
            
            if let entities = message.entities {
                for entity in entities {
                    if entity.category == .trigger || entity.category == .emotion {
                        topics.insert(entity.text)
                    }
                }
            }
        }
        
        return Array(topics)
    }
    
    private func extractEmotionalPatterns(from messages: [ChatMessage]) -> [String] {
        var patterns: [String] = []
        
        let sentiments = messages.compactMap { $0.sentiment?.score }
        if !sentiments.isEmpty {
            let average = sentiments.reduce(0, +) / Double(sentiments.count)
            if average < -0.3 {
                patterns.append("Overall negative sentiment throughout session")
            } else if average > 0.3 {
                patterns.append("Overall positive sentiment throughout session")
            } else {
                patterns.append("Mixed emotional state")
            }
        }
        
        let emotions = messages.compactMap { $0.sentiment?.dominantEmotion }
        let emotionCounts = Dictionary(grouping: emotions, by: { $0 }).mapValues { $0.count }
        if let mostCommon = emotionCounts.max(by: { $0.value < $1.value }) {
            patterns.append("Dominant emotion: \(mostCommon.key.rawValue)")
        }
        
        return patterns
    }
    
    private func generateProgressNotes(from messages: [ChatMessage]) -> [String] {
        var notes: [String] = []
        
        for message in messages {
            if message.intent == .progress {
                notes.append("User reported progress: \(message.content.prefix(100))")
            }
            
            if let sentiment = message.sentiment, sentiment.score > 0.5 {
                notes.append("Positive moment identified")
            }
        }
        
        return notes
    }
    
    private func generateRecommendations(from session: ConversationSession) -> [String] {
        var recommendations: [String] = []
        
        // Recommendations based on sentiment
        if let avgSentiment = session.averageSentiment {
            if avgSentiment < -0.3 {
                recommendations.append("Consider practicing daily mindfulness exercises")
                recommendations.append("Explore stress management techniques")
            }
        }
        
        // Recommendations based on therapy approach
        if let approach = session.therapyApproach {
            switch approach {
            case .cbt:
                recommendations.append("Practice identifying and challenging negative thought patterns")
            case .mindfulness:
                recommendations.append("Try daily meditation or breathing exercises")
            case .solutionFocused:
                recommendations.append("Focus on small, achievable steps toward your goals")
            default:
                break
            }
        }
        
        // Recommendations based on health data
        if let healthData = healthData {
            if let mentalHealth = healthData.mentalHealth {
                if mentalHealth.sleepQuality == .poor {
                    recommendations.append("Improving sleep quality may help with emotional well-being")
                }
            }
        }
        
        return recommendations
    }
    
    private func generateNextSessionFocus(from session: ConversationSession) -> String? {
        guard let lastUserMessage = session.messages.last(where: { $0.role == .user }) else {
            return nil
        }
        
        if let entities = lastUserMessage.entities, !entities.isEmpty {
            let triggers = entities.filter { $0.category == .trigger }
            if !triggers.isEmpty {
                return "Explore triggers: \(triggers.map { $0.text }.joined(separator: ", "))"
            }
        }
        
        if let sentiment = lastUserMessage.sentiment, sentiment.score < -0.3 {
            return "Continue working on managing difficult emotions"
        }
        
        return "Build on the progress discussed today"
    }
    
    // MARK: - User Profile Management
    
    func updateHealthData(_ healthData: HealthData) {
        self.healthData = healthData
        self.emotionalHealthHistory = healthData.emotionalHealth
        // Extract journal entries
        self.journalEntries = healthData.journalCollection.entries
    }
    
    private func updateUserProfile(with message: ChatMessage) {
        // Update triggers
        if let entities = message.entities {
            for entity in entities where entity.category == .trigger {
                userProfile.triggers[entity.text, default: 0] += 1
            }
        }
        
        // Update emotional patterns
        if message.sentiment != nil {
            // Track emotional patterns over time
            // Patterns are tracked in updateUserProfile and session summaries
        }
        
        saveUserProfile()
    }
    
    private func extractInsights(from message: ChatMessage, in session: ConversationSession) -> [ConversationSession.PersonalizedInsight] {
        var insights: [ConversationSession.PersonalizedInsight] = []
        
        // Insight from health data
        if let healthData = healthData, let mentalHealth = healthData.mentalHealth {
            if mentalHealth.stressLevel == .high && message.sentiment?.dominantEmotion == .stress {
                insights.append(ConversationSession.PersonalizedInsight(
                    insight: "High stress levels detected in health data correlate with current conversation",
                    basedOn: .healthData,
                    confidence: 0.8
                ))
            }
        }
        
        // Insight from conversation history
        if let pattern = detectPattern(in: message) {
            insights.append(ConversationSession.PersonalizedInsight(
                insight: "Pattern detected: \(pattern)",
                basedOn: .historical,
                confidence: 0.7
            ))
        }
        
        // Insight from image analysis
        if let imageAnalysis = message.imageAnalysis {
            insights.append(ConversationSession.PersonalizedInsight(
                insight: "Facial expression analysis indicates \(imageAnalysis.emotionalState.rawValue) emotional state",
                basedOn: .imageAnalysis,
                confidence: 0.75
            ))
        }
        
        return insights
    }
    
    private func selectTherapyApproach() -> TherapyTechnique {
        return userProfile.preferredTherapyApproach ?? .personCentered
    }
    
    private func createWelcomeMessage() -> ChatMessage {
        let welcomeText = "Hello, I'm here to support you today. " +
                         "You can share anything that's on your mind - your thoughts, feelings, concerns, or questions. " +
                         "I'm listening, and I'm here to help you explore and understand what you're experiencing. " +
                         "What would you like to talk about today?"
        
        return ChatMessage(
            role: .psychologist,
            content: welcomeText
        )
    }
    
    // MARK: - Persistence
    
    private func saveUserProfile() {
        // Save to UserDefaults or secure storage
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "psychologistUserProfile")
        }
    }
    
    func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: "psychologistUserProfile"),
           let decoded = try? JSONDecoder().decode(PsychologistUserProfile.self, from: data) {
            self.userProfile = decoded
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let crisisDetected = Notification.Name("crisisDetected")
}
