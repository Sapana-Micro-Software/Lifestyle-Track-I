//
//  EnhancedPlanGenerator.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
import NaturalLanguage // Import Natural Language framework for on-device text processing

// MARK: - Data Anonymizer
class DataAnonymizer { // Define DataAnonymizer class for privacy-preserving data processing
    static let shared = DataAnonymizer() // Shared singleton instance
    
    private init() {} // Private initializer for singleton pattern
    
    // MARK: - Anonymize Health Data
    func anonymize(_ healthData: HealthData) -> AnonymizedHealthProfile { // Anonymize health data to remove PII
        // Convert all personal identifiers to normalized ranges
        let ageRange = categorizeAge(healthData.age) // Categorize age into range
        let weightRange = categorizeWeight(healthData.weight) // Categorize weight into range
        let heightRange = categorizeHeight(healthData.height) // Categorize height into range
        let bmiRange = categorizeBMI(weight: healthData.weight, height: healthData.height) // Calculate and categorize BMI
        
        // Extract only health metrics without personal identifiers
        var medicalMetrics: [String: Double] = [:] // Initialize medical metrics dictionary
        if let glucose = healthData.glucose { medicalMetrics["glucose"] = glucose } // Add glucose if available
        if let hemoglobin = healthData.hemoglobin { medicalMetrics["hemoglobin"] = hemoglobin } // Add hemoglobin if available
        if let cholesterol = healthData.cholesterol { medicalMetrics["cholesterol"] = cholesterol } // Add cholesterol if available
        if let bp = healthData.bloodPressure { // Check if blood pressure available
            medicalMetrics["systolicBP"] = Double(bp.systolic) // Add systolic BP
            medicalMetrics["diastolicBP"] = Double(bp.diastolic) // Add diastolic BP
        }
        
        // Extract activity and fitness metrics (convert to String for consistency)
        var fitnessMetrics: [String: String] = [:] // Initialize fitness metrics dictionary
        fitnessMetrics["activityLevel"] = healthData.activityLevel.rawValue // Add activity level
        if let muscle = healthData.muscleMass { fitnessMetrics["muscleMass"] = String(format: "%.1f", muscle) } // Add muscle mass if available
        if let bodyFat = healthData.bodyFatPercentage { fitnessMetrics["bodyFatPercentage"] = String(format: "%.1f", bodyFat) } // Add body fat if available
        
        // Extract mental health indicators (anonymized)
        var mentalHealthIndicators: [String: String] = [:] // Initialize mental health indicators
        if let mental = healthData.mentalHealth { // Check if mental health data available
            mentalHealthIndicators["stressLevel"] = mental.stressLevel.rawValue // Add stress level
            mentalHealthIndicators["anxietyLevel"] = mental.anxietyLevel.rawValue // Add anxiety level
            mentalHealthIndicators["sleepQuality"] = mental.sleepQuality.rawValue // Add sleep quality
        }
        
        // Extract dental fitness (anonymized)
        var dentalMetrics: [String: Int] = [:] // Initialize dental metrics
        if let dental = healthData.dentalFitness { // Check if dental fitness data available
            dentalMetrics["dailyTeethScrubs"] = dental.dailyTeethScrubs // Add teeth brushing count
            dentalMetrics["dailyFlossingCount"] = dental.dailyFlossingCount // Add flossing count
            dentalMetrics["dailyMouthwashCleans"] = dental.dailyMouthwashCleans // Add mouthwash count
            dentalMetrics["dailyTongueScrapes"] = dental.dailyTongueScrapes // Add tongue scraping count
        }
        
        return AnonymizedHealthProfile( // Return anonymized profile
            ageRange: ageRange, // Set age range
            gender: healthData.gender.rawValue, // Set gender (already anonymized)
            weightRange: weightRange, // Set weight range
            heightRange: heightRange, // Set height range
            bmiRange: bmiRange, // Set BMI range
            medicalMetrics: medicalMetrics, // Set medical metrics
            fitnessMetrics: fitnessMetrics, // Set fitness metrics
            mentalHealthIndicators: mentalHealthIndicators, // Set mental health indicators
            dentalMetrics: dentalMetrics, // Set dental metrics
            activityLevel: healthData.activityLevel.rawValue // Set activity level
        )
    }
    
    // MARK: - Categorization Helpers
    private func categorizeAge(_ age: Int) -> String { // Categorize age into range
        switch age { // Switch on age value
        case 0..<18: return "teen" // Return teen category
        case 18..<30: return "young_adult" // Return young adult category
        case 30..<45: return "adult" // Return adult category
        case 45..<60: return "middle_age" // Return middle age category
        case 60..<75: return "senior" // Return senior category
        default: return "elderly" // Return elderly category
        }
    }
    
    private func categorizeWeight(_ weight: Double) -> String { // Categorize weight into range
        switch weight { // Switch on weight value
        case 0..<50: return "underweight" // Return underweight category
        case 50..<70: return "normal_low" // Return normal low category
        case 70..<90: return "normal_high" // Return normal high category
        case 90..<110: return "overweight" // Return overweight category
        default: return "obese" // Return obese category
        }
    }
    
    private func categorizeHeight(_ height: Double) -> String { // Categorize height into range
        switch height { // Switch on height value
        case 0..<150: return "short" // Return short category
        case 150..<170: return "average" // Return average category
        case 170..<190: return "tall" // Return tall category
        default: return "very_tall" // Return very tall category
        }
    }
    
    private func categorizeBMI(weight: Double, height: Double) -> String { // Calculate and categorize BMI
        let bmi = weight / pow(height / 100, 2) // Calculate BMI
        switch bmi { // Switch on BMI value
        case 0..<18.5: return "underweight" // Return underweight category
        case 18.5..<25: return "normal" // Return normal category
        case 25..<30: return "overweight" // Return overweight category
        default: return "obese" // Return obese category
        }
    }
}

// MARK: - Anonymized Health Profile
struct AnonymizedHealthProfile { // Define AnonymizedHealthProfile struct for privacy-preserving data (not Codable due to Any type)
    let ageRange: String // Age range category
    let gender: String // Gender (already anonymized)
    let weightRange: String // Weight range category
    let heightRange: String // Height range category
    let bmiRange: String // BMI range category
    let medicalMetrics: [String: Double] // Medical metrics dictionary
    let fitnessMetrics: [String: String] // Fitness metrics dictionary (converted to String for Codable)
    let mentalHealthIndicators: [String: String] // Mental health indicators
    let dentalMetrics: [String: Int] // Dental fitness metrics
    let activityLevel: String // Activity level
    
    // MARK: - Generate Profile Summary
    func generateSummary() -> String { // Generate human-readable summary from anonymized data
        var summary = "Health Profile: " // Initialize summary string
        summary += "\(ageRange) \(gender), " // Add age range and gender
        summary += "\(bmiRange) BMI, " // Add BMI range
        summary += "\(activityLevel) activity level" // Add activity level
        
        if !medicalMetrics.isEmpty { // Check if medical metrics available
            summary += ". Medical: " // Add medical section
            summary += medicalMetrics.map { "\($0.key): \(String(format: "%.1f", $0.value))" }.joined(separator: ", ") // Add medical metrics
        }
        
        if !mentalHealthIndicators.isEmpty { // Check if mental health indicators available
            summary += ". Mental: " // Add mental health section
            summary += mentalHealthIndicators.map { "\($0.key): \($0.value)" }.joined(separator: ", ") // Add mental health indicators
        }
        
        return summary // Return generated summary
    }
}

// MARK: - Enhanced Plan Generator
class EnhancedPlanGenerator { // Define EnhancedPlanGenerator class for intelligent plan generation
    private let anonymizer = DataAnonymizer.shared // Data anonymizer instance
    private let longTermPlanner = LongTermPlanner() // Long-term planner instance
    
    // MARK: - Generate Plan with Natural Language Processing
    func generatePlan(for healthData: HealthData, duration: PlanDuration, urgency: UrgencyLevel) -> LongTermPlan {
        // Step 1: Anonymize data (ensures privacy)
        let anonymizedProfile = anonymizer.anonymize(healthData) // Anonymize health data
        
        // Step 2: Generate base plan using existing planner
        let basePlan = longTermPlanner.generatePlan(for: healthData, duration: duration, urgency: urgency) // Generate base plan
        
        // Step 3: Enhance plan with Natural Language insights
        let enhancedPlan = enhancePlanWithNLP(basePlan: basePlan, profile: anonymizedProfile, urgency: urgency) // Enhance plan with NLP
        
        return enhancedPlan // Return enhanced plan
    }
    
    // MARK: - Enhance Plan with Natural Language Processing
    private func enhancePlanWithNLP(basePlan: LongTermPlan, profile: AnonymizedHealthProfile, urgency: UrgencyLevel) -> LongTermPlan {
        var enhancedPlan = basePlan // Create mutable copy of base plan
        
        // Use Natural Language framework to analyze and enhance goals
        let nlpAnalyzer = NLPAnalyzer() // Create NLP analyzer instance
        let profileSummary = profile.generateSummary() // Generate profile summary
        
        // Analyze profile to extract key insights
        let insights = nlpAnalyzer.analyzeHealthProfile(profileSummary) // Analyze health profile
        
        // Enhance goals with NLP insights
        enhancedPlan.goals = enhanceGoalsWithInsights(basePlan.goals, insights: insights, urgency: urgency) // Enhance goals
        
        // Enhance phases with personalized recommendations
        enhancedPlan.phases = enhancePhasesWithInsights(basePlan.phases, insights: insights, profile: profile) // Enhance phases
        
        return enhancedPlan // Return enhanced plan
    }
    
    // MARK: - Enhance Goals
    private func enhanceGoalsWithInsights(_ goals: [TransformationGoal], insights: HealthInsights, urgency: UrgencyLevel) -> [TransformationGoal] {
        var enhancedGoals = goals // Create mutable copy of goals
        
        // Add NLP-derived goals based on insights
        if insights.needsCardiovascularFocus { // Check if cardiovascular focus needed
            let cardioGoal = TransformationGoal( // Create cardiovascular goal
                category: .cardiovascular, // Set category
                targetDescription: "Improve cardiovascular health through diet and exercise", // Set description
                priority: urgency == .critical ? 10 : 8 // Set priority
            )
            enhancedGoals.append(cardioGoal) // Add goal to array
        }
        
        if insights.needsMentalHealthFocus { // Check if mental health focus needed
            let mentalGoal = TransformationGoal( // Create mental health goal
                category: .mentalHealth, // Set category
                targetDescription: "Enhance mental well-being through mindfulness and stress management", // Set description
                priority: 9 // Set priority
            )
            enhancedGoals.append(mentalGoal) // Add goal to array
        }
        
        if insights.needsDentalHealthFocus { // Check if dental health focus needed
            let dentalGoal = TransformationGoal( // Create dental health goal
                category: .organHealth, // Set category to organ health (dental is part of overall organ health)
                targetDescription: "Maintain optimal dental hygiene and oral health", // Set description
                priority: 7 // Set priority
            )
            enhancedGoals.append(dentalGoal) // Add goal to array
        }
        
        return enhancedGoals // Return enhanced goals
    }
    
    // MARK: - Enhance Phases
    private func enhancePhasesWithInsights(_ phases: [LongTermPlan.PlanPhase], insights: HealthInsights, profile: AnonymizedHealthProfile) -> [LongTermPlan.PlanPhase] {
        return phases.map { phase in // Map phases to enhanced versions
            var enhancedPhase = phase // Create mutable copy of phase
            
            // Add personalized recommendations based on insights
            if insights.needsCardiovascularFocus { // Check if cardiovascular focus needed
                enhancedPhase.dietAdjustments.append("Increase omega-3 rich foods") // Add diet adjustment
                enhancedPhase.exerciseAdjustments.append("Include cardiovascular training") // Add exercise adjustment
            }
            
            if insights.needsMentalHealthFocus { // Check if mental health focus needed
                enhancedPhase.supplementRecommendations.append("Consider magnesium for stress support") // Add supplement
                enhancedPhase.dietAdjustments.append("Include mood-supporting nutrients") // Add diet adjustment
            }
            
            if profile.dentalMetrics["dailyTeethScrubs"] ?? 0 < 2 { // Check if dental hygiene needs improvement
                enhancedPhase.supplementRecommendations.append("Maintain consistent dental hygiene routine") // Add recommendation
            }
            
            return enhancedPhase // Return enhanced phase
        }
    }
    
    // MARK: - Generate Daily Plans
    func generateDailyPlans(for longTermPlan: LongTermPlan, healthData: HealthData, season: Season) -> [DailyPlanEntry] {
        // Anonymize data before processing
        let anonymizedProfile = anonymizer.anonymize(healthData) // Anonymize health data
        
        // Generate base daily plans
        let basePlans = longTermPlanner.generateDailyPlans(for: longTermPlan, healthData: healthData, season: season) // Generate base plans
        
        // Enhance with NLP-generated personalized notes
        let enhancedPlans = basePlans.map { plan in // Map plans to enhanced versions
            var enhanced = plan // Create mutable copy
            let nlpAnalyzer = NLPAnalyzer() // Create NLP analyzer
            let personalizedNote = nlpAnalyzer.generatePersonalizedNote(for: plan, profile: anonymizedProfile) // Generate personalized note
            if let note = enhanced.notes { // Check if note exists
                if let personalized = personalizedNote { // Check if personalized note exists
                    enhanced.notes = "\(note)\n\(personalized)" // Append personalized note
                } else {
                    enhanced.notes = note // Keep existing note
                }
            } else {
                enhanced.notes = personalizedNote // Set personalized note (may be nil)
            }
            return enhanced // Return enhanced plan
        }
        
        return enhancedPlans // Return enhanced plans
    }
}

// MARK: - NLP Analyzer
class NLPAnalyzer { // Define NLPAnalyzer class for Natural Language processing
    private let tagger = NLTagger(tagSchemes: [.sentimentScore, .lexicalClass]) // Create NLTagger for text analysis
    
    // MARK: - Analyze Health Profile
    func analyzeHealthProfile(_ profileText: String) -> HealthInsights { // Analyze health profile text
        var insights = HealthInsights() // Initialize insights
        
        // Use Natural Language framework to extract key terms
        tagger.string = profileText // Set text to analyze
        let range = profileText.startIndex..<profileText.endIndex // Define analysis range
        
        // Extract medical terms
        var medicalTerms: [String] = [] // Initialize medical terms array
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass) { tag, tokenRange in // Enumerate tags
            if let tag = tag, tag == .noun { // Check if noun
                let word = String(profileText[tokenRange]).lowercased() // Get word
                if isMedicalTerm(word) { // Check if medical term
                    medicalTerms.append(word) // Add to medical terms
                }
            }
            return true // Continue enumeration
        }
        
        // Analyze for cardiovascular focus
        insights.needsCardiovascularFocus = medicalTerms.contains { term in // Check for cardiovascular terms
            ["cholesterol", "blood", "pressure", "cardio", "heart"].contains(term) // Check for cardiovascular keywords
        } || profileText.lowercased().contains("cholesterol") || profileText.lowercased().contains("blood pressure") // Check for keywords
        
        // Analyze for mental health focus
        insights.needsMentalHealthFocus = medicalTerms.contains { term in // Check for mental health terms
            ["stress", "anxiety", "mental", "depression"].contains(term) // Check for mental health keywords
        } || profileText.lowercased().contains("stress") || profileText.lowercased().contains("anxiety") // Check for keywords
        
        // Analyze for dental health focus
        insights.needsDentalHealthFocus = profileText.lowercased().contains("dental") || // Check for dental keyword
            medicalTerms.contains { term in // Check for dental terms
                ["dental", "teeth", "oral", "hygiene"].contains(term) // Check for dental keywords
            }
        
        return insights // Return insights
    }
    
    // MARK: - Generate Personalized Note
    func generatePersonalizedNote(for plan: DailyPlanEntry, profile: AnonymizedHealthProfile) -> String? { // Generate personalized note
        var note = "" // Initialize note string
        
        // Generate note based on day number and profile
        if plan.dayNumber % 7 == 0 { // Check if weekly milestone
            note += "Weekly milestone: Focus on consistency and track your progress. " // Add weekly note
        }
        
        // Add profile-specific recommendations
        if profile.bmiRange == "overweight" || profile.bmiRange == "obese" { // Check if weight management needed
            note += "Remember to stay hydrated and maintain portion control. " // Add weight management note
        }
        
        if profile.mentalHealthIndicators["stressLevel"] == "High" || profile.mentalHealthIndicators["stressLevel"] == "Very High" { // Check if high stress
            note += "Take time for mindfulness and stress reduction activities. " // Add stress management note
        }
        
        if profile.dentalMetrics["dailyTeethScrubs"] ?? 0 < 2 { // Check if dental hygiene needs improvement
            note += "Don't forget your dental hygiene routine: brush twice daily, floss, and use mouthwash. " // Add dental hygiene note
        }
        
        return note.isEmpty ? nil : note // Return note or nil if empty
    }
    
    // MARK: - Helper Methods
    private func isMedicalTerm(_ word: String) -> Bool { // Check if word is medical term
        let medicalTerms = ["cholesterol", "glucose", "hemoglobin", "blood", "pressure", "stress", "anxiety", "mental", "dental", "teeth", "oral", "hygiene", "cardio", "heart", "weight", "bmi", "muscle", "fat"] // Medical terms list
        return medicalTerms.contains(word) // Return if word is medical term
    }
}

// MARK: - Health Insights
struct HealthInsights { // Define HealthInsights struct for extracted insights
    var needsCardiovascularFocus: Bool = false // Cardiovascular focus flag
    var needsMentalHealthFocus: Bool = false // Mental health focus flag
    var needsDentalHealthFocus: Bool = false // Dental health focus flag
}
