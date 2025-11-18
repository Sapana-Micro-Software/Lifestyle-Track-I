//
//  VisionGames.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Vision Game
struct VisionGame: Codable, Identifiable { // Define VisionGame struct for vision exercise games
    let id: UUID // Unique identifier for vision game
    var gameType: GameType // Type of vision game
    var name: String // Name of the game
    var description: String // Description of the game
    var duration: TimeInterval // Duration of game session in seconds
    var difficulty: DifficultyLevel // Difficulty level of game
    var targetSkill: VisionSkill // Vision skill targeted by game
    var instructions: [String] // Array of game instructions
    var benefits: [String] // Array of vision benefits from game
    
    enum GameType: String, Codable, CaseIterable { // Enum for game types
        case eyeTracking = "Eye Tracking" // Eye tracking game
        case focusTraining = "Focus Training" // Focus training game
        case peripheralAwareness = "Peripheral Awareness" // Peripheral awareness game
        case depthPerception = "Depth Perception" // Depth perception game
        case colorDiscrimination = "Color Discrimination" // Color discrimination game
        case contrastSensitivity = "Contrast Sensitivity" // Contrast sensitivity game
        case convergence = "Convergence" // Convergence training game
        case accommodation = "Accommodation" // Accommodation training game
        case saccades = "Saccades" // Saccadic eye movement game
        case pursuit = "Pursuit" // Smooth pursuit eye movement game
    }
    
    enum DifficultyLevel: String, Codable, CaseIterable { // Enum for difficulty levels
        case beginner = "Beginner" // Beginner difficulty level
        case intermediate = "Intermediate" // Intermediate difficulty level
        case advanced = "Advanced" // Advanced difficulty level
        case expert = "Expert" // Expert difficulty level
    }
    
    enum VisionSkill: String, Codable, CaseIterable { // Enum for vision skills
        case acuity = "Visual Acuity" // Visual acuity skill
        case focus = "Focus" // Focus skill
        case tracking = "Eye Tracking" // Eye tracking skill
        case peripheral = "Peripheral Vision" // Peripheral vision skill
        case depth = "Depth Perception" // Depth perception skill
        case color = "Color Vision" // Color vision skill
        case contrast = "Contrast Sensitivity" // Contrast sensitivity skill
        case convergence = "Convergence" // Convergence skill
        case accommodation = "Accommodation" // Accommodation skill
        case coordination = "Eye Coordination" // Eye coordination skill
    }
    
    init(id: UUID = UUID(), gameType: GameType, name: String, description: String, duration: TimeInterval = 300, difficulty: DifficultyLevel = .beginner, targetSkill: VisionSkill, instructions: [String] = [], benefits: [String] = []) {
        self.id = id // Initialize unique identifier
        self.gameType = gameType // Initialize game type
        self.name = name // Initialize game name
        self.description = description // Initialize game description
        self.duration = duration // Initialize game duration
        self.difficulty = difficulty // Initialize difficulty level
        self.targetSkill = targetSkill // Initialize target skill
        self.instructions = instructions // Initialize instructions array
        self.benefits = benefits // Initialize benefits array
    }
}

// MARK: - Vision Game Session
struct VisionGameSession: Codable, Identifiable { // Define VisionGameSession struct for game play sessions
    let id: UUID // Unique identifier for game session
    var gameId: UUID // ID of game played
    var startTime: Date // Start time of session
    var endTime: Date? // Optional end time of session
    var duration: TimeInterval // Actual duration of session
    var score: Double? // Optional game score (0-100)
    var accuracy: Double? // Optional accuracy percentage (0-100)
    var reactionTime: Double? // Optional average reaction time in milliseconds
    var eye: EyeSide? // Optional eye side used for single-eye games
    var results: GameResults // Game results data
    var notes: String? // Optional notes about session
    
    enum EyeSide: String, Codable { // Enum for eye sides
        case left = "Left" // Left eye
        case right = "Right" // Right eye
        case both = "Both" // Both eyes
    }
    
    struct GameResults: Codable { // Nested struct for game results
        var correctAnswers: Int // Number of correct answers
        var totalQuestions: Int // Total number of questions
        var averageResponseTime: Double? // Average response time in milliseconds
        var difficultyCompleted: VisionGame.DifficultyLevel? // Highest difficulty completed
        var improvements: [String] // Array of improvement areas
        var strengths: [String] // Array of strength areas
        
        init(correctAnswers: Int = 0, totalQuestions: Int = 0, averageResponseTime: Double? = nil, difficultyCompleted: VisionGame.DifficultyLevel? = nil, improvements: [String] = [], strengths: [String] = []) {
            self.correctAnswers = correctAnswers // Initialize correct answers count
            self.totalQuestions = totalQuestions // Initialize total questions count
            self.averageResponseTime = averageResponseTime // Initialize average response time
            self.difficultyCompleted = difficultyCompleted // Initialize difficulty completed
            self.improvements = improvements // Initialize improvements array
            self.strengths = strengths // Initialize strengths array
        }
    }
    
    init(id: UUID = UUID(), gameId: UUID, startTime: Date = Date(), endTime: Date? = nil, duration: TimeInterval = 0, score: Double? = nil, accuracy: Double? = nil, reactionTime: Double? = nil, eye: EyeSide? = nil, results: GameResults = GameResults(), notes: String? = nil) {
        self.id = id // Initialize unique identifier
        self.gameId = gameId // Initialize game ID
        self.startTime = startTime // Initialize start time
        self.endTime = endTime // Initialize optional end time
        self.duration = duration // Initialize duration
        self.score = score // Initialize optional score
        self.accuracy = accuracy // Initialize optional accuracy
        self.reactionTime = reactionTime // Initialize optional reaction time
        self.eye = eye // Initialize optional eye side
        self.results = results // Initialize game results
        self.notes = notes // Initialize optional notes
    }
}

// MARK: - Vision Game Database
class VisionGameDatabase { // Define VisionGameDatabase class for managing vision games
    static let shared = VisionGameDatabase() // Shared singleton instance
    
    private init() {} // Private initializer for singleton
    
    func loadGames() -> [VisionGame] { // Function to load all vision games
        return [ // Return array of vision games
            VisionGame( // Create eye tracking game
                gameType: .eyeTracking, // Set eye tracking type
                name: "Follow the Dot", // Set game name
                description: "Track a moving dot with your eyes to improve eye tracking and coordination", // Set description
                duration: 300, // Set 5 minute duration
                difficulty: .beginner, // Set beginner difficulty
                targetSkill: .tracking, // Set tracking skill
                instructions: [ // Set instructions array
                    "Focus on the moving dot on screen", // Instruction 1
                    "Follow the dot with your eyes only (don't move your head)", // Instruction 2
                    "Try to maintain focus throughout the exercise" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves smooth pursuit eye movements", // Benefit 1
                    "Enhances eye coordination", // Benefit 2
                    "Reduces eye strain" // Benefit 3
                ]
            ),
            VisionGame( // Create focus training game
                gameType: .focusTraining, // Set focus training type
                name: "Focus Shift", // Set game name
                description: "Shift focus between near and far objects to improve accommodation", // Set description
                duration: 240, // Set 4 minute duration
                difficulty: .intermediate, // Set intermediate difficulty
                targetSkill: .accommodation, // Set accommodation skill
                instructions: [ // Set instructions array
                    "Focus on the near object", // Instruction 1
                    "Shift focus to the far object", // Instruction 2
                    "Alternate between near and far focus" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves accommodation ability", // Benefit 1
                    "Reduces eye fatigue", // Benefit 2
                    "Enhances focus flexibility" // Benefit 3
                ]
            ),
            VisionGame( // Create peripheral awareness game
                gameType: .peripheralAwareness, // Set peripheral awareness type
                name: "Peripheral Challenge", // Set game name
                description: "Identify objects in your peripheral vision while maintaining central focus", // Set description
                duration: 180, // Set 3 minute duration
                difficulty: .beginner, // Set beginner difficulty
                targetSkill: .peripheral, // Set peripheral skill
                instructions: [ // Set instructions array
                    "Keep your eyes focused on the center", // Instruction 1
                    "Identify objects appearing in your peripheral vision", // Instruction 2
                    "Respond quickly to peripheral stimuli" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Expands peripheral vision field", // Benefit 1
                    "Improves awareness of surroundings", // Benefit 2
                    "Enhances visual field" // Benefit 3
                ]
            ),
            VisionGame( // Create depth perception game
                gameType: .depthPerception, // Set depth perception type
                name: "Depth Test", // Set game name
                description: "Judge distances and depths of objects to improve stereopsis", // Set description
                duration: 300, // Set 5 minute duration
                difficulty: .intermediate, // Set intermediate difficulty
                targetSkill: .depth, // Set depth skill
                instructions: [ // Set instructions array
                    "Look at objects at different distances", // Instruction 1
                    "Judge which object is closer or farther", // Instruction 2
                    "Use both eyes for depth perception" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves depth perception", // Benefit 1
                    "Enhances stereopsis", // Benefit 2
                    "Better spatial awareness" // Benefit 3
                ]
            ),
            VisionGame( // Create color discrimination game
                gameType: .colorDiscrimination, // Set color discrimination type
                name: "Color Match", // Set game name
                description: "Match and identify colors to improve color vision", // Set description
                duration: 240, // Set 4 minute duration
                difficulty: .beginner, // Set beginner difficulty
                targetSkill: .color, // Set color skill
                instructions: [ // Set instructions array
                    "Identify the color shown", // Instruction 1
                    "Match similar colors", // Instruction 2
                    "Distinguish between subtle color differences" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves color discrimination", // Benefit 1
                    "Enhances color vision", // Benefit 2
                    "Better color perception" // Benefit 3
                ]
            ),
            VisionGame( // Create convergence game
                gameType: .convergence, // Set convergence type
                name: "Convergence Training", // Set game name
                description: "Practice bringing both eyes together to focus on near objects", // Set description
                duration: 180, // Set 3 minute duration
                difficulty: .intermediate, // Set intermediate difficulty
                targetSkill: .convergence, // Set convergence skill
                instructions: [ // Set instructions array
                    "Focus both eyes on the approaching object", // Instruction 1
                    "Maintain single vision as object gets closer", // Instruction 2
                    "Stop when you see double" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves convergence ability", // Benefit 1
                    "Reduces eye strain", // Benefit 2
                    "Better near vision" // Benefit 3
                ]
            ),
            VisionGame( // Create saccades game
                gameType: .saccades, // Set saccades type
                name: "Quick Glance", // Set game name
                description: "Practice rapid eye movements between targets", // Set description
                duration: 180, // Set 3 minute duration
                difficulty: .advanced, // Set advanced difficulty
                targetSkill: .tracking, // Set tracking skill
                instructions: [ // Set instructions array
                    "Quickly shift gaze between targets", // Instruction 1
                    "Maintain accuracy with speed", // Instruction 2
                    "Practice smooth transitions" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves saccadic eye movements", // Benefit 1
                    "Faster eye movements", // Benefit 2
                    "Better reading ability" // Benefit 3
                ]
            ),
            VisionGame( // Create contrast sensitivity game
                gameType: .contrastSensitivity, // Set contrast sensitivity type
                name: "Contrast Challenge", // Set game name
                description: "Identify low-contrast objects to improve contrast sensitivity", // Set description
                duration: 300, // Set 5 minute duration
                difficulty: .intermediate, // Set intermediate difficulty
                targetSkill: .contrast, // Set contrast skill
                instructions: [ // Set instructions array
                    "Identify objects with low contrast", // Instruction 1
                    "Distinguish subtle differences", // Instruction 2
                    "Maintain focus on faint objects" // Instruction 3
                ],
                benefits: [ // Set benefits array
                    "Improves contrast sensitivity", // Benefit 1
                    "Better vision in low light", // Benefit 2
                    "Enhanced visual clarity" // Benefit 3
                ]
            )
        ]
    }
    
    func gamesForSkill(_ skill: VisionGame.VisionSkill) -> [VisionGame] { // Function to get games for specific skill
        return loadGames().filter { $0.targetSkill == skill } // Filter games by target skill
    }
    
    func gamesForDifficulty(_ difficulty: VisionGame.DifficultyLevel) -> [VisionGame] { // Function to get games for specific difficulty
        return loadGames().filter { $0.difficulty == difficulty } // Filter games by difficulty
    }
}
