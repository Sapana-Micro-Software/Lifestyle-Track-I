//
//  SleepAnalyzer.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Sleep Analyzer
class SleepAnalyzer { // Define SleepAnalyzer class for analyzing sleep data
    
    // MARK: - Analyze Sleep Records
    func analyze(records: [SleepRecord], period: SleepAnalysis.AnalysisPeriod = .week) -> SleepAnalysis { // Function to analyze sleep records and return analysis
        var analysis = SleepAnalysis(records: records, analysisPeriod: period) // Create sleep analysis with records
        analysis.calculateAverages() // Calculate average values from records
        analysis.recommendations = generateRecommendations(from: analysis) // Generate recommendations based on analysis
        return analysis // Return complete sleep analysis
    }
    
    // MARK: - Generate Recommendations
    private func generateRecommendations(from analysis: SleepAnalysis) -> [SleepAnalysis.SleepRecommendation] { // Private function to generate sleep recommendations
        var recommendations: [SleepAnalysis.SleepRecommendation] = [] // Initialize empty recommendations array
        
        // Sleep duration recommendations
        if let avgHours = analysis.averageSleepHours { // Check if average hours available
            if avgHours < 6.0 { // Check if sleep duration is too short
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add critical duration recommendation
                    category: .duration, // Set category to sleep duration
                    priority: .critical, // Set priority to critical
                    title: "Insufficient Sleep Duration", // Set recommendation title
                    description: "Average sleep of \(String(format: "%.1f", avgHours)) hours is below recommended 7-9 hours", // Set description
                    actions: ["Aim for 7-9 hours of sleep per night", "Establish consistent bedtime routine", "Avoid screens 1 hour before bed"] // Set action items
                ))
            } else if avgHours < 7.0 { // Check if sleep duration is below optimal
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add high priority duration recommendation
                    category: .duration, // Set category to sleep duration
                    priority: .high, // Set priority to high
                    title: "Below Optimal Sleep Duration", // Set recommendation title
                    description: "Average sleep of \(String(format: "%.1f", avgHours)) hours is below optimal range", // Set description
                    actions: ["Increase sleep time by 30-60 minutes", "Go to bed 30 minutes earlier", "Create relaxing pre-sleep routine"] // Set action items
                ))
            } else if avgHours > 9.5 { // Check if sleep duration is excessive
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add medium priority duration recommendation
                    category: .duration, // Set category to sleep duration
                    priority: .medium, // Set priority to medium
                    title: "Excessive Sleep Duration", // Set recommendation title
                    description: "Average sleep of \(String(format: "%.1f", avgHours)) hours may indicate underlying health issues", // Set description
                    actions: ["Consult healthcare provider if persistent", "Check for sleep quality issues", "Review medication side effects"] // Set action items
                ))
            }
        }
        
        // Sleep quality recommendations
        if let quality = analysis.averageQuality { // Check if average quality available
            if quality == .poor || quality == .veryPoor { // Check if quality is poor
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add high priority quality recommendation
                    category: .quality, // Set category to sleep quality
                    priority: .high, // Set priority to high
                    title: "Poor Sleep Quality", // Set recommendation title
                    description: "Sleep quality is rated as \(quality.rawValue), affecting recovery and health", // Set description
                    actions: ["Improve sleep environment (dark, cool, quiet)", "Establish consistent sleep schedule", "Practice relaxation techniques before bed"] // Set action items
                ))
            }
        }
        
        // REM sleep recommendations
        if let avgRem = analysis.averageRem { // Check if average REM available
            let remHours = avgRem / 60.0 // Convert minutes to hours
            if remHours < 1.5 { // Check if REM sleep is insufficient
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add high priority REM recommendation
                    category: .stages, // Set category to sleep stages
                    priority: .high, // Set priority to high
                    title: "Insufficient REM Sleep", // Set recommendation title
                    description: "Average REM sleep of \(String(format: "%.1f", remHours)) hours is below recommended 1.5-2 hours", // Set description
                    actions: ["Ensure adequate total sleep duration", "Avoid alcohol before bed", "Maintain consistent sleep schedule"] // Set action items
                ))
            }
        }
        
        // Deep sleep recommendations
        if let avgDeep = analysis.averageDeepSleep { // Check if average deep sleep available
            let deepHours = avgDeep / 60.0 // Convert minutes to hours
            if deepHours < 1.0 { // Check if deep sleep is insufficient
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add high priority deep sleep recommendation
                    category: .stages, // Set category to sleep stages
                    priority: .high, // Set priority to high
                    title: "Insufficient Deep Sleep", // Set recommendation title
                    description: "Average deep sleep of \(String(format: "%.1f", deepHours)) hours may affect physical recovery", // Set description
                    actions: ["Exercise regularly but not too close to bedtime", "Maintain cool bedroom temperature", "Reduce stress and anxiety"] // Set action items
                ))
            }
        }
        
        // Snoring recommendations
        if let snoringFreq = analysis.snoringFrequency { // Check if snoring frequency available
            if snoringFreq > 50.0 { // Check if snoring occurs frequently
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add high priority snoring recommendation
                    category: .snoring, // Set category to snoring
                    priority: .high, // Set priority to high
                    title: "Frequent Snoring Detected", // Set recommendation title
                    description: "Snoring detected on \(String(format: "%.0f", snoringFreq))% of nights, may indicate sleep apnea", // Set description
                    actions: ["Sleep on side instead of back", "Maintain healthy weight", "Consult sleep specialist if persistent", "Consider CPAP if recommended"] // Set action items
                ))
            } else if snoringFreq > 25.0 { // Check if snoring occurs occasionally
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add medium priority snoring recommendation
                    category: .snoring, // Set category to snoring
                    priority: .medium, // Set priority to medium
                    title: "Occasional Snoring", // Set recommendation title
                    description: "Snoring detected on \(String(format: "%.0f", snoringFreq))% of nights", // Set description
                    actions: ["Try sleeping on side", "Elevate head with extra pillow", "Avoid alcohol before bed"] // Set action items
                ))
            }
        }
        
        // Sleep efficiency recommendations
        if let efficiency = analysis.sleepEfficiency { // Check if sleep efficiency available
            if efficiency < 85.0 { // Check if efficiency is low
                recommendations.append(SleepAnalysis.SleepRecommendation( // Add high priority efficiency recommendation
                    category: .quality, // Set category to sleep quality
                    priority: .high, // Set priority to high
                    title: "Low Sleep Efficiency", // Set recommendation title
                    description: "Sleep efficiency of \(String(format: "%.1f", efficiency))% indicates significant time awake in bed", // Set description
                    actions: ["Only go to bed when sleepy", "Get out of bed if unable to sleep", "Avoid napping during day", "Establish consistent wake time"] // Set action items
                ))
            }
        }
        
        return recommendations // Return generated recommendations array
    }
    
    // MARK: - Integrate with Diet Recommendations
    func adjustDietForSleep(sleepAnalysis: SleepAnalysis, currentRequirements: [String: NutrientRequirement]) -> [String: NutrientRequirement] { // Function to adjust diet based on sleep
        var adjusted = currentRequirements // Create mutable copy of requirements
        
        // Increase magnesium for poor sleep quality
        if let quality = sleepAnalysis.averageQuality { // Check if quality available
            if quality == .poor || quality == .veryPoor { // Check if quality is poor
                if var magnesium = adjusted["magnesium"] { // Check if magnesium requirement exists
                    magnesium.dailyValue *= 1.3 // Increase magnesium by 30%
                    adjusted["magnesium"] = magnesium // Update requirement
                }
            }
        }
        
        // Increase tryptophan-rich foods for insufficient REM
        if let avgRem = sleepAnalysis.averageRem { // Check if average REM available
            if avgRem < 90.0 { // Check if REM is below 90 minutes
                if var protein = adjusted["protein"] { // Check if protein requirement exists
                    protein.dailyValue *= 1.1 // Increase protein slightly for tryptophan
                    adjusted["protein"] = protein // Update requirement
                }
            }
        }
        
        // Adjust calories for sleep duration
        if let avgHours = sleepAnalysis.averageSleepHours { // Check if average hours available
            if avgHours < 6.0 { // Check if sleep is insufficient
                // Insufficient sleep may increase cortisol and affect metabolism
                if var calories = adjusted["calories"] { // Check if calories requirement exists
                    calories.dailyValue *= 0.95 // Slightly reduce calories to account for metabolic changes
                    adjusted["calories"] = calories // Update requirement
                }
            }
        }
        
        return adjusted // Return adjusted requirements
    }
    
    // MARK: - Integrate with Exercise Recommendations
    func adjustExerciseForSleep(sleepAnalysis: SleepAnalysis, currentPlan: ExercisePlan) -> ExercisePlan { // Function to adjust exercise based on sleep
        var adjustedPlan = currentPlan // Create mutable copy of plan
        
        // Reduce intensity if sleep quality is poor
        if let quality = sleepAnalysis.averageQuality { // Check if quality available
            if quality == .poor || quality == .veryPoor { // Check if quality is poor
                // Modify exercise plan to be less intense
                for i in 0..<adjustedPlan.weeklyPlan.count { // Iterate through weekly plan
                    adjustedPlan.weeklyPlan[i].activities = adjustedPlan.weeklyPlan[i].activities.map { activity in // Map activities
                        if activity.activity.intensity == .high { // Check if activity is high intensity
                            // Replace with moderate intensity alternative
                            let moderateActivity = ExerciseDatabase.shared.activities.first { // Find moderate alternative
                                $0.name == activity.activity.name && $0.intensity == .moderate // Match name and moderate intensity
                            }
                            if let moderate = moderateActivity { // Check if alternative found
                                // Create new PlannedActivity with moderate activity
                                return ExercisePlan.DayPlan.PlannedActivity(
                                    id: activity.id,
                                    activity: moderate,
                                    duration: activity.duration,
                                    timeOfDay: activity.timeOfDay
                                )
                            }
                        }
                        return activity // Return original activity
                    }
                }
            }
        }
        
        return adjustedPlan // Return adjusted exercise plan
    }
}
