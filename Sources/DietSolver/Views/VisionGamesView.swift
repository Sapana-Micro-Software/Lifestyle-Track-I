//
//  VisionGamesView.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

struct VisionGamesView: View { // Define VisionGamesView struct conforming to View protocol
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    @State private var selectedGame: VisionGame? // State for selected game
    @State private var games: [VisionGame] = VisionGameDatabase.shared.loadGames() // State for games list
    
    var body: some View { // Define body property returning view hierarchy
        NavigationView { // Create navigation view container
            List { // Create list container
                ForEach(games) { game in // Loop through games
                    NavigationLink(destination: VisionGameDetailView(game: game, viewModel: viewModel)) { // Create navigation link
                        VStack(alignment: .leading, spacing: 8) { // Create vertical stack
                            Text(game.name) // Display game name
                                .font(.headline) // Set headline font
                            Text(game.description) // Display game description
                                .font(.caption) // Set caption font
                                .foregroundColor(.secondary) // Set secondary color
                            HStack { // Create horizontal stack
                                Text(game.targetSkill.rawValue) // Display target skill
                                    .font(.caption) // Set caption font
                                    .padding(.horizontal, 8) // Add horizontal padding
                                    .padding(.vertical, 4) // Add vertical padding
                                    .background(Color.blue.opacity(0.2)) // Set background color
                                    .cornerRadius(8) // Set corner radius
                                Text(game.difficulty.rawValue) // Display difficulty
                                    .font(.caption) // Set caption font
                                    .padding(.horizontal, 8) // Add horizontal padding
                                    .padding(.vertical, 4) // Add vertical padding
                                    .background(Color.gray.opacity(0.2)) // Set background color
                                    .cornerRadius(8) // Set corner radius
                                Spacer() // Add spacer
                                Text("\(Int(game.duration / 60)) min") // Display duration
                                    .font(.caption) // Set caption font
                                    .foregroundColor(.secondary) // Set secondary color
                            }
                        }
                        .padding(.vertical, 4) // Add vertical padding
                    }
                }
            }
            .navigationTitle("Vision Games") // Set navigation title
        }
    }
}

struct VisionGameDetailView: View { // Define VisionGameDetailView struct for game details
    let game: VisionGame // Game to display
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    @State private var isPlaying = false // State for playing status
    @State private var score: Double = 0 // State for game score
    @State private var startTime: Date? // State for start time
    
    var body: some View { // Define body property returning view hierarchy
        ScrollView { // Create scrollable view
            VStack(alignment: .leading, spacing: 20) { // Create vertical stack
                // Game Info
                VStack(alignment: .leading, spacing: 8) { // Create vertical stack for info
                    Text(game.name) // Display game name
                        .font(.title) // Set title font
                        .bold() // Make text bold
                    Text(game.description) // Display description
                        .font(.body) // Set body font
                }
                .padding() // Add padding
                
                // Instructions
                if !game.instructions.isEmpty { // Check if instructions exist
                    VStack(alignment: .leading, spacing: 8) { // Create vertical stack for instructions
                        Text("Instructions") // Display instructions label
                            .font(.headline) // Set headline font
                        ForEach(game.instructions, id: \.self) { instruction in // Loop through instructions
                            Text("• \(instruction)") // Display instruction
                                .font(.body) // Set body font
                        }
                    }
                    .padding() // Add padding
                    .background(Color.gray.opacity(0.1)) // Set background color
                    .cornerRadius(10) // Set corner radius
                }
                
                // Benefits
                if !game.benefits.isEmpty { // Check if benefits exist
                    VStack(alignment: .leading, spacing: 8) { // Create vertical stack for benefits
                        Text("Benefits") // Display benefits label
                            .font(.headline) // Set headline font
                        ForEach(game.benefits, id: \.self) { benefit in // Loop through benefits
                            Text("• \(benefit)") // Display benefit
                                .font(.body) // Set body font
                        }
                    }
                    .padding() // Add padding
                    .background(Color.gray.opacity(0.1)) // Set background color
                    .cornerRadius(10) // Set corner radius
                }
                
                // Game Stats
                if score > 0 { // Check if score exists
                    VStack(alignment: .leading, spacing: 8) { // Create vertical stack for stats
                        Text("Last Score: \(Int(score))") // Display score
                            .font(.headline) // Set headline font
                    }
                    .padding() // Add padding
                }
                
                // Play Button
                Button(action: { // Create button action
                    startGame() // Call start game function
                }) { // Button label
                    HStack { // Create horizontal stack
                        Image(systemName: "play.fill") // Display play icon
                        Text(isPlaying ? "Playing..." : "Start Game") // Display button text
                    }
                    .frame(maxWidth: .infinity) // Set frame to fill width
                    .padding() // Add padding
                    .background(isPlaying ? Color.gray : Color.blue) // Set background color
                    .foregroundColor(.white) // Set white text color
                    .cornerRadius(10) // Set corner radius
                }
                .padding() // Add padding
                .disabled(isPlaying) // Disable when playing
            }
            .padding() // Add padding around content
        }
        .navigationTitle(game.name) // Set navigation title
    }
    
    private func startGame() { // Private function to start game
        isPlaying = true // Set playing status
        startTime = Date() // Set start time
        score = Double.random(in: 60...100) // Generate random score (simulated)
        
        // Simulate game completion after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + game.duration) { // Schedule completion
            endGame() // Call end game function
        }
    }
    
    private func endGame() { // Private function to end game
        guard let startTime = startTime else { return } // Check if start time exists
        isPlaying = false // Set playing status
        
        let session = VisionGameSession( // Create game session
            gameId: game.id, // Set game ID
            startTime: startTime, // Set start time
            endTime: Date(), // Set end time
            duration: game.duration, // Set duration
            score: score, // Set score
            accuracy: score, // Set accuracy
            results: VisionGameSession.GameResults( // Create results
                correctAnswers: Int(score / 10), // Set correct answers
                totalQuestions: 10, // Set total questions
                averageResponseTime: 500, // Set average response time
                difficultyCompleted: game.difficulty, // Set difficulty completed
                improvements: [], // Set improvements
                strengths: [] // Set strengths
            )
        )
        
        guard var healthData = viewModel.healthData else { return } // Check if health data exists
        healthData.visionGameSessions.append(session) // Add session to health data
        viewModel.updateHealthData(healthData) // Update health data
    }
}
