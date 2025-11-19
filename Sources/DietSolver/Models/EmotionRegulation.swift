//
//  EmotionRegulation.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Emotion Regulation Technique
enum EmotionRegulationTechnique: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case tipp = "TIPP"
    case stop = "STOP"
    case grounding54321 = "5-4-3-2-1 Grounding"
    case rain = "RAIN"
    case boxBreathing = "Box Breathing"
    case progressiveMuscleRelaxation = "Progressive Muscle Relaxation"
    
    var title: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .tipp:
            return "Temperature, Intense exercise, Paced breathing, Paired muscle relaxation"
        case .stop:
            return "Stop, Take a breath, Observe, Proceed"
        case .grounding54321:
            return "5 things you see, 4 things you touch, 3 things you hear, 2 things you smell, 1 thing you taste"
        case .rain:
            return "Recognize, Allow, Investigate, Nurture"
        case .boxBreathing:
            return "Breathe in for 4, hold for 4, out for 4, hold for 4"
        case .progressiveMuscleRelaxation:
            return "Tense and release muscle groups progressively"
        }
    }
    
    var steps: [String] {
        switch self {
        case .tipp:
            return [
                "Temperature: Hold ice cubes or splash cold water on your face",
                "Intense exercise: Do jumping jacks or run in place for 1 minute",
                "Paced breathing: Breathe out longer than you breathe in",
                "Paired muscle relaxation: Tense muscles while breathing in, relax while breathing out"
            ]
        case .stop:
            return [
                "Stop: Pause what you're doing",
                "Take a breath: Take 3 deep breaths",
                "Observe: Notice what's happening in your body and mind",
                "Proceed: Choose how to respond mindfully"
            ]
        case .grounding54321:
            return [
                "5 things you can SEE around you",
                "4 things you can TOUCH or feel",
                "3 things you can HEAR",
                "2 things you can SMELL",
                "1 thing you can TASTE"
            ]
        case .rain:
            return [
                "Recognize: Acknowledge what you're feeling",
                "Allow: Let the feeling be there without judgment",
                "Investigate: Explore the feeling with curiosity",
                "Nurture: Offer yourself compassion and kindness"
            ]
        case .boxBreathing:
            return [
                "Breathe in through your nose for 4 counts",
                "Hold your breath for 4 counts",
                "Breathe out through your mouth for 4 counts",
                "Hold your breath for 4 counts",
                "Repeat 4-8 times"
            ]
        case .progressiveMuscleRelaxation:
            return [
                "Start with your feet: Tense for 5 seconds, then release",
                "Move to your calves: Tense and release",
                "Move to your thighs: Tense and release",
                "Move to your hands: Tense and release",
                "Move to your arms: Tense and release",
                "Move to your shoulders: Tense and release",
                "Move to your face: Tense and release",
                "Take a deep breath and relax your entire body"
            ]
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .tipp: return 300 // 5 minutes
        case .stop: return 120 // 2 minutes
        case .grounding54321: return 180 // 3 minutes
        case .rain: return 600 // 10 minutes
        case .boxBreathing: return 240 // 4 minutes
        case .progressiveMuscleRelaxation: return 900 // 15 minutes
        }
    }
    
    var bestFor: [String] {
        switch self {
        case .tipp:
            return ["Intense emotions", "Crisis situations", "Panic attacks"]
        case .stop:
            return ["Impulsive reactions", "Anger", "Anxiety"]
        case .grounding54321:
            return ["Dissociation", "Anxiety", "Panic"]
        case .rain:
            return ["Difficult emotions", "Self-criticism", "Shame"]
        case .boxBreathing:
            return ["Anxiety", "Stress", "Before sleep"]
        case .progressiveMuscleRelaxation:
            return ["Stress", "Anxiety", "Tension", "Before sleep"]
        }
    }
}

// MARK: - Emotion Regulation Session
struct EmotionRegulationSession: Codable, Identifiable {
    let id: UUID
    var date: Date
    var technique: EmotionRegulationTechnique
    var emotionBefore: String
    var intensityBefore: Double // 0.0 to 1.0
    var emotionAfter: String?
    var intensityAfter: Double? // 0.0 to 1.0
    var effectiveness: Double? // 0.0 to 1.0
    var notes: String?
    
    init(id: UUID = UUID(), date: Date = Date(), technique: EmotionRegulationTechnique, emotionBefore: String, intensityBefore: Double, emotionAfter: String? = nil, intensityAfter: Double? = nil, effectiveness: Double? = nil, notes: String? = nil) {
        self.id = id
        self.date = date
        self.technique = technique
        self.emotionBefore = emotionBefore
        self.intensityBefore = intensityBefore
        self.emotionAfter = emotionAfter
        self.intensityAfter = intensityAfter
        self.effectiveness = effectiveness
        self.notes = notes
    }
    
    var improvement: Double? {
        guard let after = intensityAfter else { return nil }
        return intensityBefore - after
    }
}
