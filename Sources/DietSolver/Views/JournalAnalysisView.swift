//
//  JournalAnalysisView.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

struct JournalAnalysisView: View { // Define JournalAnalysisView struct conforming to View protocol
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    
    var body: some View { // Define body property returning view hierarchy
        VStack(spacing: 0) { // Create vertical stack
            // Custom Header
            HStack {
                Text("Journal Analysis")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ScrollView { // Create scrollable view
                VStack(alignment: .leading, spacing: 20) { // Create vertical stack with leading alignment
                    if let analysis = viewModel.journalAnalysis { // Check if analysis exists
                        // Analysis Summary
                        VStack(alignment: .leading, spacing: 8) { // Create vertical stack for summary
                            Text("Analysis Summary") // Display summary title
                                .font(.title) // Set title font
                                .bold() // Make text bold
                            Text("\(analysis.entryCount) entries analyzed") // Display entry count
                                .font(.subheadline) // Set subheadline font
                                .foregroundColor(.secondary) // Set secondary color
                            Text("Structured: \(analysis.structuredEntryCount), Unstructured: \(analysis.unstructuredEntryCount), Mixed: \(analysis.mixedEntryCount)") // Display entry types
                                .font(.caption) // Set caption font
                                .foregroundColor(.secondary) // Set secondary color
                        }
                        .padding() // Add padding around summary
                        
                        // Mood Trend
                        VStack(alignment: .leading, spacing: 8) { // Create vertical stack for mood trend
                            Text("Mood Trend") // Display mood trend title
                                .font(.headline) // Set headline font
                            Text("Average Mood: \(String(format: "%.1f", analysis.moodTrend.averageMood))") // Display average mood
                            Text("Trend: \(analysis.moodTrend.trendDirection.rawValue)") // Display trend direction
                            if let mostCommon = analysis.moodTrend.mostCommonMood { // Check if most common mood exists
                                Text("Most Common: \(mostCommon.rawValue)") // Display most common mood
                            }
                        }
                        .padding() // Add padding
                        .background(Color.gray.opacity(0.1)) // Set background color
                        .cornerRadius(10) // Set corner radius
                        
                        // Key Insights
                        if !analysis.keyInsights.isEmpty { // Check if insights exist
                            VStack(alignment: .leading, spacing: 8) { // Create vertical stack for insights
                                Text("Key Insights") // Display insights title
                                    .font(.headline) // Set headline font
                                ForEach(analysis.keyInsights, id: \.self) { insight in // Loop through insights
                                    Text("• \(insight)") // Display insight
                                        .font(.body) // Set body font
                                }
                            }
                            .padding() // Add padding
                            .background(Color.gray.opacity(0.1)) // Set background color
                            .cornerRadius(10) // Set corner radius
                        }
                        
                        // Recommendations
                        if !analysis.recommendations.isEmpty { // Check if recommendations exist
                            VStack(alignment: .leading, spacing: 8) { // Create vertical stack for recommendations
                                Text("Recommendations") // Display recommendations title
                                    .font(.headline) // Set headline font
                                ForEach(analysis.recommendations, id: \.self) { recommendation in // Loop through recommendations
                                    Text("• \(recommendation)") // Display recommendation
                                        .font(.body) // Set body font
                                }
                            }
                            .padding() // Add padding
                            .background(Color.gray.opacity(0.1)) // Set background color
                            .cornerRadius(10) // Set corner radius
                        }
                        
                        // Gratitude Themes
                        if !analysis.gratitudeThemes.isEmpty { // Check if gratitude themes exist
                            VStack(alignment: .leading, spacing: 8) { // Create vertical stack for themes
                                Text("Gratitude Themes") // Display themes title
                                    .font(.headline) // Set headline font
                                ForEach(analysis.gratitudeThemes, id: \.self) { theme in // Loop through themes
                                    Text("• \(theme)") // Display theme
                                        .font(.body) // Set body font
                                }
                            }
                            .padding() // Add padding
                            .background(Color.gray.opacity(0.1)) // Set background color
                            .cornerRadius(10) // Set corner radius
                        }
                        
                        // Achievement Themes
                        if !analysis.achievementThemes.isEmpty { // Check if achievement themes exist
                            VStack(alignment: .leading, spacing: 8) { // Create vertical stack for themes
                                Text("Achievement Themes") // Display themes title
                                    .font(.headline) // Set headline font
                                ForEach(analysis.achievementThemes, id: \.self) { theme in // Loop through themes
                                    Text("• \(theme)") // Display theme
                                        .font(.body) // Set body font
                                }
                            }
                            .padding() // Add padding
                            .background(Color.gray.opacity(0.1)) // Set background color
                            .cornerRadius(10) // Set corner radius
                        }
                        
                        // Relationship Insights
                        if !analysis.relationshipInsights.isEmpty { // Check if relationship insights exist
                            VStack(alignment: .leading, spacing: 8) { // Create vertical stack for insights
                                Text("Relationship Insights") // Display insights title
                                    .font(.headline) // Set headline font
                                ForEach(analysis.relationshipInsights) { insight in // Loop through insights
                                    VStack(alignment: .leading, spacing: 4) { // Create vertical stack for insight
                                        Text(insight.person) // Display person name
                                            .font(.subheadline) // Set subheadline font
                                            .bold() // Make text bold
                                        Text("Quality: \(insight.overallQuality.rawValue)") // Display quality
                                            .font(.caption) // Set caption font
                                        Text("Interactions: \(insight.interactionCount) (Positive: \(insight.positiveCount), Negative: \(insight.negativeCount))") // Display interaction counts
                                            .font(.caption) // Set caption font
                                            .foregroundColor(.secondary) // Set secondary color
                                    }
                                    .padding(.vertical, 4) // Add vertical padding
                                }
                            }
                            .padding() // Add padding
                            .background(Color.gray.opacity(0.1)) // Set background color
                            .cornerRadius(10) // Set corner radius
                        }
                    } else { // If no analysis
                        VStack(spacing: 16) { // Create vertical stack
                            Text("No journal analysis available") // Display message
                                .foregroundColor(.secondary) // Set secondary color
                            Button("Analyze Journal") { // Create analyze button
                                viewModel.analyzeJournal() // Call analyze function
                            }
                            .padding() // Add padding
                            .background(Color.blue) // Set blue background
                            .foregroundColor(.white) // Set white text color
                            .cornerRadius(10) // Set corner radius
                        }
                        .padding() // Add padding
                    }
                }
                .padding() // Add padding around content
            }
            .navigationTitle("Journal Analysis") // Set navigation title
        }
    }
}
