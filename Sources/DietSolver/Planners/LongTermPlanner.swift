//
//  LongTermPlanner.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Long-Term Planner
class LongTermPlanner {
    
    // MARK: - Generate Long-Term Plan
    func generatePlan(for healthData: HealthData, duration: PlanDuration, urgency: UrgencyLevel) -> LongTermPlan {
        let difficulty = urgency.recommendedDifficulty() // Determine difficulty based on urgency level
        let startDate = Date() // Set start date to current date
        let calendar = Calendar.current // Get calendar instance for date calculations
        let endDate = calendar.date(byAdding: .day, value: duration.days, to: startDate) ?? startDate // Calculate end date from duration
        
        var goals: [TransformationGoal] = [] // Initialize empty goals array
        goals.append(contentsOf: generateGoals(from: healthData, urgency: urgency)) // Generate goals from health data
        
        var phases: [LongTermPlan.PlanPhase] = [] // Initialize empty phases array
        phases.append(contentsOf: generatePhases(duration: duration, difficulty: difficulty, goals: goals)) // Generate plan phases
        
        var milestones: [LongTermPlan.Milestone] = [] // Initialize empty milestones array
        milestones.append(contentsOf: generateMilestones(duration: duration, startDate: startDate, goals: goals)) // Generate milestones
        
        return LongTermPlan( // Create and return long-term plan object
            duration: duration, // Set plan duration
            difficulty: difficulty, // Set difficulty level
            urgency: urgency, // Set urgency level
            startDate: startDate, // Set start date
            endDate: endDate, // Set end date
            goals: goals, // Set goals array
            phases: phases, // Set phases array
            milestones: milestones // Set milestones array
        )
    }
    
    // MARK: - Generate Daily Plans
    func generateDailyPlans(for longTermPlan: LongTermPlan, healthData: HealthData, season: Season) -> [DailyPlanEntry] {
        var dailyPlans: [DailyPlanEntry] = [] // Initialize empty daily plans array
        let calendar = Calendar.current // Get calendar instance for date operations
        let solver = DietSolver() // Create diet solver instance
        let exercisePlanner = ExercisePlanner() // Create exercise planner instance
        
        for day in 0..<longTermPlan.duration.days { // Iterate through each day in plan duration
            guard let currentDate = calendar.date(byAdding: .day, value: day, to: longTermPlan.startDate) else { continue } // Calculate current date for iteration
            let dayNumber = day + 1 // Calculate day number (1-indexed)
            
            let currentPhase = getPhase(for: dayNumber, in: longTermPlan) // Get current phase for this day
            let adjustedHealthData = adjustHealthData(healthData, for: dayNumber, phase: currentPhase, plan: longTermPlan) // Adjust health data for current phase
            
            let dietPlan = solver.solve(healthData: adjustedHealthData, season: season) // Solve diet plan for adjusted health data
            let exerciseGoals = adjustedHealthData.exerciseGoals ?? ExerciseGoals() // Get exercise goals or create default
            let exercisePlan = exercisePlanner.generateWeeklyPlan(for: adjustedHealthData, goals: exerciseGoals) // Generate exercise plan
            
            let supplements = generateSupplements(for: dayNumber, phase: currentPhase, healthData: adjustedHealthData) // Generate supplement recommendations
            let meditationMinutes = calculateMeditationMinutes(dayNumber: dayNumber, phase: currentPhase, difficulty: longTermPlan.difficulty) // Calculate meditation time
            let breathingMinutes = calculateBreathingMinutes(dayNumber: dayNumber, phase: currentPhase, difficulty: longTermPlan.difficulty) // Calculate breathing practice time
            let sleepTarget = calculateSleepTarget(dayNumber: dayNumber, phase: currentPhase, difficulty: longTermPlan.difficulty) // Calculate sleep target
            let waterIntake = calculateWaterIntake(dayNumber: dayNumber, phase: currentPhase, healthData: adjustedHealthData) // Calculate water intake
            
            let dailyEntry = DailyPlanEntry( // Create daily plan entry object
                date: currentDate, // Set entry date
                dayNumber: dayNumber, // Set day number
                dietPlan: dietPlan, // Set diet plan
                exercisePlan: exercisePlan, // Set exercise plan
                supplements: supplements, // Set supplements array
                meditationMinutes: meditationMinutes, // Set meditation minutes
                breathingPracticeMinutes: breathingMinutes, // Set breathing practice minutes
                sleepTarget: sleepTarget, // Set sleep target hours
                waterIntake: waterIntake, // Set water intake liters
                notes: generateDailyNotes(dayNumber: dayNumber, phase: currentPhase) // Generate daily notes
            )
            
            dailyPlans.append(dailyEntry) // Append entry to daily plans array
        }
        
        return dailyPlans // Return complete daily plans array
    }
    
    // MARK: - Generate Goals
    private func generateGoals(from healthData: HealthData, urgency: UrgencyLevel) -> [TransformationGoal] {
        var goals: [TransformationGoal] = [] // Initialize empty goals array
        
        // Weight goal
        if let currentWeight = Optional(healthData.weight) { // Check if current weight is available
            let targetWeight = calculateTargetWeight(current: currentWeight, healthData: healthData) // Calculate target weight
            goals.append(TransformationGoal( // Add weight transformation goal
                category: .weight, // Set goal category to weight
                targetValue: targetWeight, // Set target weight value
                targetDescription: "Achieve optimal weight of \(String(format: "%.1f", targetWeight)) kg", // Set goal description
                currentValue: currentWeight, // Set current weight value
                priority: urgency == .critical ? 10 : 7 // Set priority based on urgency
            ))
        }
        
        // Muscle mass goal
        if let currentMuscle = healthData.muscleMass { // Check if current muscle mass is available
            let targetMuscle = currentMuscle * 1.2 // Calculate target muscle mass (20% increase)
            goals.append(TransformationGoal( // Add muscle mass transformation goal
                category: .muscleMass, // Set goal category to muscle mass
                targetValue: targetMuscle, // Set target muscle mass value
                targetDescription: "Increase muscle mass to \(String(format: "%.1f", targetMuscle)) kg", // Set goal description
                currentValue: currentMuscle, // Set current muscle mass value
                priority: 8 // Set priority to 8
            ))
        } else { // If muscle mass not available
            let estimatedMuscle = healthData.weight * 0.4 // Estimate muscle mass as 40% of weight
            let targetMuscle = estimatedMuscle * 1.3 // Calculate target muscle mass (30% increase)
            goals.append(TransformationGoal( // Add estimated muscle mass goal
                category: .muscleMass, // Set goal category to muscle mass
                targetValue: targetMuscle, // Set target muscle mass value
                targetDescription: "Build muscle mass to \(String(format: "%.1f", targetMuscle)) kg", // Set goal description
                currentValue: estimatedMuscle, // Set estimated current muscle mass
                priority: 6 // Set priority to 6
            ))
        }
        
        // Cardiovascular health goal
        if let bloodTest = healthData.medicalTests.bloodTests.last { // Check if blood test available
            if let cholesterol = bloodTest.totalCholesterol, cholesterol > 200 { // Check if cholesterol is high
                goals.append(TransformationGoal( // Add cardiovascular health goal
                    category: .cardiovascular, // Set goal category to cardiovascular
                    targetDescription: "Improve cardiovascular health and reduce cholesterol", // Set goal description
                    priority: urgency == .critical ? 10 : 8 // Set priority based on urgency
                ))
            }
        }
        
        // Mental health goal
        if let mentalHealth = healthData.mentalHealth { // Check if mental health data available
            if mentalHealth.stressLevel == .high || mentalHealth.stressLevel == .veryHigh { // Check if high stress
                goals.append(TransformationGoal( // Add mental health transformation goal
                    category: .mentalHealth, // Set goal category to mental health
                    targetDescription: "Reduce stress and improve mental well-being", // Set goal description
                    priority: 9 // Set priority to 9
                ))
            }
        }
        
        return goals // Return generated goals array
    }
    
    // MARK: - Generate Phases
    private func generatePhases(duration: PlanDuration, difficulty: DifficultyLevel, goals: [TransformationGoal]) -> [LongTermPlan.PlanPhase] {
        var phases: [LongTermPlan.PlanPhase] = [] // Initialize empty phases array
        let totalDays = duration.days // Get total days in duration
        let phaseCount = min(6, max(3, duration.months / 2)) // Calculate number of phases (3-6)
        let daysPerPhase = totalDays / phaseCount // Calculate days per phase
        
        for i in 0..<phaseCount { // Iterate through each phase
            let startDay = i * daysPerPhase + 1 // Calculate phase start day
            let endDay = min((i + 1) * daysPerPhase, totalDays) // Calculate phase end day
            let phaseName = getPhaseName(index: i, total: phaseCount) // Get phase name
            let focus = getPhaseFocus(index: i, total: phaseCount, goals: goals) // Get phase focus
            let dietAdjustments = getDietAdjustments(index: i, difficulty: difficulty) // Get diet adjustments
            let exerciseAdjustments = getExerciseAdjustments(index: i, difficulty: difficulty) // Get exercise adjustments
            let supplements = getSupplementRecommendations(index: i, difficulty: difficulty) // Get supplement recommendations
            
            phases.append(LongTermPlan.PlanPhase( // Add phase to phases array
                name: phaseName, // Set phase name
                startDay: startDay, // Set phase start day
                endDay: endDay, // Set phase end day
                focus: focus, // Set phase focus
                dietAdjustments: dietAdjustments, // Set diet adjustments
                exerciseAdjustments: exerciseAdjustments, // Set exercise adjustments
                supplementRecommendations: supplements // Set supplement recommendations
            ))
        }
        
        return phases // Return generated phases array
    }
    
    // MARK: - Helper Methods
    private func calculateTargetWeight(current: Double, healthData: HealthData) -> Double {
        _ = current / pow(healthData.height / 100, 2) // Calculate current BMI (not used but kept for documentation)
        let targetBMI = 22.0 // Set target BMI to 22 (optimal)
        return targetBMI * pow(healthData.height / 100, 2) // Calculate and return target weight
    }
    
    private func getPhase(for dayNumber: Int, in plan: LongTermPlan) -> LongTermPlan.PlanPhase? {
        return plan.phases.first { dayNumber >= $0.startDay && dayNumber <= $0.endDay } // Find phase containing this day
    }
    
    private func adjustHealthData(_ healthData: HealthData, for dayNumber: Int, phase: LongTermPlan.PlanPhase?, plan: LongTermPlan) -> HealthData {
        var adjusted = healthData // Create mutable copy of health data
        let progress = Double(dayNumber) / Double(plan.duration.days) // Calculate progress percentage
        
        // Adjust weight based on progress
        if let weightGoal = plan.goals.first(where: { $0.category == .weight }) { // Find weight goal
            if let current = weightGoal.currentValue, let target = weightGoal.targetValue { // Check if values available
                let weightChange = (target - current) * progress // Calculate weight change based on progress
                adjusted.weight = current + weightChange // Adjust weight
            }
        }
        
        // Adjust muscle mass based on progress
        if let muscleGoal = plan.goals.first(where: { $0.category == .muscleMass }) { // Find muscle mass goal
            if let current = muscleGoal.currentValue, let target = muscleGoal.targetValue { // Check if values available
                let muscleChange = (target - current) * progress // Calculate muscle change based on progress
                adjusted.muscleMass = (adjusted.muscleMass ?? 0) + muscleChange // Adjust muscle mass
            }
        }
        
        return adjusted // Return adjusted health data
    }
    
    private func generateSupplements(for dayNumber: Int, phase: LongTermPlan.PlanPhase?, healthData: HealthData) -> [DailyPlanEntry.SupplementRecommendation] {
        var supplements: [DailyPlanEntry.SupplementRecommendation] = [] // Initialize empty supplements array
        
        // Add vitamin D if deficient
        if let bloodTest = healthData.medicalTests.bloodTests.last { // Check if blood test available
            if let vitD = bloodTest.vitaminD, vitD < 30 { // Check if vitamin D low
                supplements.append(DailyPlanEntry.SupplementRecommendation( // Add vitamin D supplement
                    name: "Vitamin D3", // Set supplement name
                    dosage: "2000-5000 IU", // Set dosage
                    timing: "Morning with food", // Set timing
                    purpose: "Address vitamin D deficiency" // Set purpose
                ))
            }
        }
        
        // Add omega-3 for cardiovascular health
        if let bloodTest = healthData.medicalTests.bloodTests.last { // Check if blood test available
            if let cholesterol = bloodTest.totalCholesterol, cholesterol > 200 { // Check if cholesterol high
                supplements.append(DailyPlanEntry.SupplementRecommendation( // Add omega-3 supplement
                    name: "Omega-3 Fatty Acids", // Set supplement name
                    dosage: "1000-2000 mg", // Set dosage
                    timing: "With meals", // Set timing
                    purpose: "Support cardiovascular health" // Set purpose
                ))
            }
        }
        
        return supplements // Return supplements array
    }
    
    private func calculateMeditationMinutes(dayNumber: Int, phase: LongTermPlan.PlanPhase?, difficulty: DifficultyLevel) -> Double {
        let baseMinutes = 10.0 // Set base meditation minutes
        return baseMinutes * difficulty.intensityMultiplier // Return adjusted minutes based on difficulty
    }
    
    private func calculateBreathingMinutes(dayNumber: Int, phase: LongTermPlan.PlanPhase?, difficulty: DifficultyLevel) -> Double {
        let baseMinutes = 15.0 // Set base breathing practice minutes
        return baseMinutes * difficulty.intensityMultiplier // Return adjusted minutes based on difficulty
    }
    
    private func calculateSleepTarget(dayNumber: Int, phase: LongTermPlan.PlanPhase?, difficulty: DifficultyLevel) -> Double {
        let baseSleep = 8.0 // Set base sleep hours
        return baseSleep - (difficulty.intensityMultiplier - 1.0) * 0.5 // Adjust sleep based on difficulty
    }
    
    private func calculateWaterIntake(dayNumber: Int, phase: LongTermPlan.PlanPhase?, healthData: HealthData) -> Double {
        let baseWater = 2.5 // Set base water intake in liters
        let exerciseAdjustment = healthData.exerciseLogs.isEmpty ? 0.0 : 0.5 // Add water for exercise
        return baseWater + exerciseAdjustment // Return total water intake
    }
    
    private func generateDailyNotes(dayNumber: Int, phase: LongTermPlan.PlanPhase?) -> String? {
        if dayNumber % 7 == 0 { // Check if it's a weekly milestone
            return "Weekly check-in: Assess progress and adjust as needed" // Return weekly note
        }
        return nil // Return nil for non-milestone days
    }
    
    private func getPhaseName(index: Int, total: Int) -> String {
        let names = ["Foundation", "Building", "Optimization", "Refinement", "Mastery", "Transformation"] // Phase names array
        return names[min(index, names.count - 1)] // Return phase name for index
    }
    
    private func getPhaseFocus(index: Int, total: Int, goals: [TransformationGoal]) -> String {
        if index == 0 { // Check if first phase
            return "Establish healthy habits and baseline" // Return foundation focus
        } else if index < total / 2 { // Check if early phase
            return "Build strength and endurance" // Return building focus
        } else { // Otherwise
            return "Optimize and refine performance" // Return optimization focus
        }
    }
    
    private func getDietAdjustments(index: Int, difficulty: DifficultyLevel) -> [String] {
        var adjustments: [String] = [] // Initialize empty adjustments array
        adjustments.append("Gradual calorie adjustment") // Add calorie adjustment
        adjustments.append("Increase protein intake") // Add protein increase
        if difficulty == .aggressive || difficulty == .extreme { // Check if high difficulty
            adjustments.append("Strict macronutrient tracking") // Add strict tracking
        }
        return adjustments // Return adjustments array
    }
    
    private func getExerciseAdjustments(index: Int, difficulty: DifficultyLevel) -> [String] {
        var adjustments: [String] = [] // Initialize empty adjustments array
        adjustments.append("Progressive overload") // Add progressive overload
        adjustments.append("Recovery days") // Add recovery days
        if difficulty == .extreme { // Check if extreme difficulty
            adjustments.append("High-intensity training") // Add high-intensity training
        }
        return adjustments // Return adjustments array
    }
    
    private func getSupplementRecommendations(index: Int, difficulty: DifficultyLevel) -> [String] {
        var supplements: [String] = [] // Initialize empty supplements array
        supplements.append("Multivitamin") // Add multivitamin
        supplements.append("Omega-3") // Add omega-3
        if difficulty == .aggressive || difficulty == .extreme { // Check if high difficulty
            supplements.append("Protein supplement") // Add protein supplement
        }
        return supplements // Return supplements array
    }
    
    private func generateMilestones(duration: PlanDuration, startDate: Date, goals: [TransformationGoal]) -> [LongTermPlan.Milestone] {
        var milestones: [LongTermPlan.Milestone] = [] // Initialize empty milestones array
        let calendar = Calendar.current // Get calendar instance
        let milestoneCount = min(6, duration.months / 2) // Calculate milestone count
        
        for i in 1...milestoneCount { // Iterate through milestones
            let monthsFromStart = i * 2 // Calculate months from start
            guard let milestoneDate = calendar.date(byAdding: .month, value: monthsFromStart, to: startDate) else { continue } // Calculate milestone date
            let progress = Double(monthsFromStart) / Double(duration.months) // Calculate progress percentage
            
            milestones.append(LongTermPlan.Milestone( // Add milestone to array
                name: "\(monthsFromStart)-Month Milestone", // Set milestone name
                targetDate: milestoneDate, // Set target date
                description: "Assess progress at \(Int(progress * 100))% of plan", // Set description
                metrics: generateMilestoneMetrics(progress: progress, goals: goals), // Generate metrics
                achieved: false // Set achieved to false
            ))
        }
        
        return milestones // Return milestones array
    }
    
    private func generateMilestoneMetrics(progress: Double, goals: [TransformationGoal]) -> [String: Double] {
        var metrics: [String: Double] = [:] // Initialize empty metrics dictionary
        for goal in goals { // Iterate through goals
            if let current = goal.currentValue, let target = goal.targetValue { // Check if values available
                let expected = current + (target - current) * progress // Calculate expected value
                metrics[goal.category.rawValue] = expected // Add metric to dictionary
            }
        }
        return metrics // Return metrics dictionary
    }
}
