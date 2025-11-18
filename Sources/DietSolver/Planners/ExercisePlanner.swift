import Foundation

// MARK: - Exercise Planner
class ExercisePlanner {
    private let exerciseDatabase = ExerciseDatabase.shared
    
    func generateWeeklyPlan(for healthData: HealthData, goals: ExerciseGoals) -> ExercisePlan {
        var weeklyPlan: [ExercisePlan.DayPlan] = []
        
        // Create plan for each day of the week
        for dayIndex in 0..<7 {
            var activities: [ExercisePlan.DayPlan.PlannedActivity] = []
            
            // Distribute activities across the week
            switch dayIndex {
            case 0: // Sunday - Rest or light activity
                activities.append(contentsOf: [
                    createActivity("Meditation", duration: 20, timeOfDay: .morning),
                    createActivity("Yoga", duration: 30, timeOfDay: .morning),
                    createActivity("Walking", duration: 30, timeOfDay: .evening),
                    createActivity("Music Listening Session", duration: 30, timeOfDay: .afternoon),
                    createActivity("Hearing Exercise", duration: 10, timeOfDay: .morning),
                ])
                
            case 1: // Monday - Strength + Cardio
                activities.append(contentsOf: [
                    createActivity("Sun Salutations", duration: 15, timeOfDay: .morning),
                    createActivity("Weight Training", duration: 45, timeOfDay: .morning),
                    createActivity("Pranayama", duration: 10, timeOfDay: .evening),
                    createActivity("Hearing Exercise", duration: 10, timeOfDay: .morning),
                ])
                
            case 2: // Tuesday - High Intensity Cardio
                activities.append(contentsOf: [
                    createActivity("Running", duration: 30, timeOfDay: .morning),
                    createActivity("Kickboxing", duration: 45, timeOfDay: .afternoon),
                    createActivity("Anulom Vilom", duration: 10, timeOfDay: .evening),
                    createActivity("Active Music Listening", duration: 20, timeOfDay: .afternoon),
                ])
                
            case 3: // Wednesday - Strength + Flexibility
                activities.append(contentsOf: [
                    createActivity("Weight Training", duration: 45, timeOfDay: .morning),
                    createActivity("Pilates", duration: 30, timeOfDay: .afternoon),
                    createActivity("Body Scanning", duration: 15, timeOfDay: .evening),
                    createActivity("Tactile Stimulation", duration: 15, timeOfDay: .evening),
                ])
                
            case 4: // Thursday - Dance/Cardio
                activities.append(contentsOf: [
                    createActivity("Zumba", duration: 45, timeOfDay: .morning),
                    createActivity("Bhastrika", duration: 10, timeOfDay: .afternoon),
                    createActivity("Walking", duration: 30, timeOfDay: .evening),
                    createActivity("Music Listening Session", duration: 30, timeOfDay: .evening),
                ])
                
            case 5: // Friday - Mixed
                activities.append(contentsOf: [
                    createActivity("Spinning", duration: 45, timeOfDay: .morning),
                    createActivity("Tai Chi", duration: 30, timeOfDay: .afternoon),
                    createActivity("Kriya", duration: 15, timeOfDay: .evening),
                    createActivity("Binaural Beats Session", duration: 20, timeOfDay: .evening),
                ])
                
            case 6: // Saturday - Active Recovery
                activities.append(contentsOf: [
                    createActivity("Yoga", duration: 45, timeOfDay: .morning),
                    createActivity("Rowing", duration: 30, timeOfDay: .afternoon),
                    createActivity("Laughing Exercise", duration: 10, timeOfDay: .evening),
                    createActivity("Nature Sounds Therapy", duration: 30, timeOfDay: .afternoon),
                    createActivity("Massage Therapy", duration: 20, timeOfDay: .evening),
                    createActivity("Tongue Exercises", duration: 10, timeOfDay: .morning),
                ])
                
            default:
                break
            }
            
            weeklyPlan.append(ExercisePlan.DayPlan(
                id: UUID(),
                dayOfWeek: dayIndex,
                activities: activities
            ))
        }
        
        // Determine focus areas based on health data
        var focusAreas: [String] = []
        
        if healthData.muscleMass == nil || (healthData.muscleMass! / healthData.weight) < 0.35 {
            focusAreas.append("Muscle Building")
        }
        
        if let mentalHealth = healthData.mentalHealth {
            if mentalHealth.stressLevel == .high || mentalHealth.stressLevel == .veryHigh {
                focusAreas.append("Stress Reduction")
            }
            if mentalHealth.anxietyLevel == .moderate || mentalHealth.anxietyLevel == .severe {
                focusAreas.append("Anxiety Management")
            }
            if mentalHealth.sleepQuality == .poor || mentalHealth.sleepQuality == .fair {
                focusAreas.append("Sleep Quality")
            }
        }
        
        if let sexualHealth = healthData.sexualHealth {
            if sexualHealth.libidoLevel == .low {
                focusAreas.append("Hormonal Balance")
            }
        }
        
        if healthData.exerciseLogs.isEmpty {
            focusAreas.append("Building Exercise Habit")
        }
        
        // Add hearing health focus areas
        if healthData.dailyAudioHearingTests.isEmpty {
            focusAreas.append("Hearing Health Monitoring")
        }
        
        if healthData.musicHearingSessions.isEmpty {
            focusAreas.append("Music Listening Habit")
        } else {
            let recentSessions = healthData.musicHearingSessions.filter { session in
                Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
            }
            if recentSessions.count < 3 {
                focusAreas.append("Regular Music Listening")
            }
        }
        
        // Check hearing test frequency
        let recentTests = healthData.dailyAudioHearingTests.filter { test in
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(test.date) ?? false
        }
        if recentTests.count < 3 {
            focusAreas.append("Daily Hearing Tests")
        }
        
        // Add tactile health focus areas
        if healthData.dailyTactileTests.isEmpty {
            focusAreas.append("Tactile Health Monitoring")
        }
        
        if healthData.tactileVitalitySessions.isEmpty {
            focusAreas.append("Tactile Vitality Sessions")
        } else {
            let recentSessions = healthData.tactileVitalitySessions.filter { session in
                Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
            }
            if recentSessions.count < 2 {
                focusAreas.append("Regular Tactile Therapy")
            }
        }
        
        // Add tongue health focus areas
        if healthData.dailyTongueTests.isEmpty {
            focusAreas.append("Tongue Health Monitoring")
        }
        
        if healthData.tongueVitalitySessions.isEmpty {
            focusAreas.append("Tongue Vitality Sessions")
        } else {
            let recentSessions = healthData.tongueVitalitySessions.filter { session in
                Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
            }
            if recentSessions.count < 3 {
                focusAreas.append("Regular Tongue Exercises")
            }
        }
        
        return ExercisePlan(weeklyPlan: weeklyPlan, goals: goals, focusAreas: focusAreas)
    }
    
    private func createActivity(_ name: String, duration: Double, timeOfDay: ExercisePlan.DayPlan.PlannedActivity.TimeOfDay) -> ExercisePlan.DayPlan.PlannedActivity {
        let activity = exerciseDatabase.activities.first { $0.name == name } ?? exerciseDatabase.activities[0]
        return ExercisePlan.DayPlan.PlannedActivity(
            id: UUID(),
            activity: activity,
            duration: duration,
            timeOfDay: timeOfDay
        )
    }
    
    func recommendExercises(for healthData: HealthData, dayOfWeek: Int) -> [ExerciseActivity] {
        var recommendations: [ExerciseActivity] = []
        
        // Based on mental health
        if let mentalHealth = healthData.mentalHealth {
            if mentalHealth.stressLevel == .high || mentalHealth.stressLevel == .veryHigh {
                recommendations.append(contentsOf: [
                    exerciseDatabase.activities.first { $0.name == "Meditation" }!,
                    exerciseDatabase.activities.first { $0.name == "Yoga" }!,
                    exerciseDatabase.activities.first { $0.name == "Pranayama" }!,
                    exerciseDatabase.activities.first { $0.name == "Tai Chi" }!,
                ])
            }
            
            if mentalHealth.anxietyLevel == .moderate || mentalHealth.anxietyLevel == .severe {
                recommendations.append(contentsOf: [
                    exerciseDatabase.activities.first { $0.name == "Anulom Vilom" }!,
                    exerciseDatabase.activities.first { $0.name == "Body Scanning" }!,
                    exerciseDatabase.activities.first { $0.name == "Meditation" }!,
                ])
            }
        }
        
        // Based on muscle mass goals
        if let muscleMass = healthData.muscleMass {
            let musclePercentage = (muscleMass / healthData.weight) * 100
            if musclePercentage < 35 {
                recommendations.append(exerciseDatabase.activities.first { $0.name == "Weight Training" }!)
            }
        } else {
            recommendations.append(exerciseDatabase.activities.first { $0.name == "Weight Training" }!)
        }
        
        // Based on sexual health
        if let sexualHealth = healthData.sexualHealth {
            if sexualHealth.libidoLevel == .low {
                // Cardio and strength training can help
                recommendations.append(contentsOf: [
                    exerciseDatabase.activities.first { $0.name == "Running" }!,
                    exerciseDatabase.activities.first { $0.name == "Weight Training" }!,
                ])
            }
        }
        
        // Always include some cardio
        recommendations.append(exerciseDatabase.activities.first { $0.name == "Walking" }!)
        
        // Add hearing-related activities based on hearing data
        if healthData.dailyAudioHearingTests.isEmpty || healthData.dailyAudioHearingTests.count < 7 {
            // Recommend daily hearing tests
            if let hearingExercise = exerciseDatabase.activities.first(where: { $0.name == "Hearing Exercise" }) {
                recommendations.append(hearingExercise)
            }
        }
        
        if healthData.musicHearingSessions.isEmpty {
            // Recommend music listening if no sessions
            if let musicListening = exerciseDatabase.activities.first(where: { $0.name == "Music Listening Session" }) {
                recommendations.append(musicListening)
            }
        } else {
            // Check recent music sessions
            let recentSessions = healthData.musicHearingSessions.filter { session in
                Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(session.date) ?? false
            }
            if recentSessions.count < 5 {
                // Recommend more music sessions
                if let activeMusic = exerciseDatabase.activities.first(where: { $0.name == "Active Music Listening" }) {
                    recommendations.append(activeMusic)
                }
            }
        }
        
        // Check for hearing issues from tests
        if let latestTest = healthData.dailyAudioHearingTests.last {
            if let rightThreshold = latestTest.rightEar.pureToneThresholds?.first?.threshold,
               rightThreshold > 25 { // Mild hearing loss threshold
                if let hearingExercise = exerciseDatabase.activities.first(where: { $0.name == "Hearing Exercise" }) {
                    recommendations.append(hearingExercise)
                }
            }
            if let leftThreshold = latestTest.leftEar.pureToneThresholds?.first?.threshold,
               leftThreshold > 25 {
                if let hearingExercise = exerciseDatabase.activities.first(where: { $0.name == "Hearing Exercise" }) {
                    recommendations.append(hearingExercise)
                }
            }
            
            // Check for tinnitus
            if latestTest.rightEar.tinnitusPresence == true || latestTest.leftEar.tinnitusPresence == true {
                if let natureSounds = exerciseDatabase.activities.first(where: { $0.name == "Nature Sounds Therapy" }) {
                    recommendations.append(natureSounds)
                }
                if let binaural = exerciseDatabase.activities.first(where: { $0.name == "Binaural Beats Session" }) {
                    recommendations.append(binaural)
                }
            }
        }
        
        // Add tactile-related recommendations
        if healthData.dailyTactileTests.isEmpty || healthData.dailyTactileTests.count < 5 {
            if let tactileStim = exerciseDatabase.activities.first(where: { $0.name == "Tactile Stimulation" }) {
                recommendations.append(tactileStim)
            }
        }
        
        if healthData.tactileVitalitySessions.isEmpty {
            if let massage = exerciseDatabase.activities.first(where: { $0.name == "Massage Therapy" }) {
                recommendations.append(massage)
            }
        }
        
        // Check for tactile issues
        if let latestTactileTest = healthData.dailyTactileTests.last {
            if latestTactileTest.results.numbness == .moderate || latestTactileTest.results.numbness == .severe {
                if let tactileStim = exerciseDatabase.activities.first(where: { $0.name == "Tactile Stimulation" }) {
                    recommendations.append(tactileStim)
                }
                if let texture = exerciseDatabase.activities.first(where: { $0.name == "Texture Exploration" }) {
                    recommendations.append(texture)
                }
            }
            
            if latestTactileTest.results.painSensitivity?.level == .moderate || latestTactileTest.results.painSensitivity?.level == .severe {
                if let tempTherapy = exerciseDatabase.activities.first(where: { $0.name == "Temperature Therapy" }) {
                    recommendations.append(tempTherapy)
                }
            }
        }
        
        // Add tongue-related recommendations
        if healthData.dailyTongueTests.isEmpty || healthData.dailyTongueTests.count < 5 {
            if let tongueExercise = exerciseDatabase.activities.first(where: { $0.name == "Tongue Exercises" }) {
                recommendations.append(tongueExercise)
            }
        }
        
        if healthData.tongueVitalitySessions.isEmpty {
            if let tasteTraining = exerciseDatabase.activities.first(where: { $0.name == "Taste Training" }) {
                recommendations.append(tasteTraining)
            }
        }
        
        // Check for tongue issues
        if let latestTongueTest = healthData.dailyTongueTests.last {
            if latestTongueTest.symptoms.pain == .moderate || latestTongueTest.symptoms.pain == .severe {
                if let tongueExercise = exerciseDatabase.activities.first(where: { $0.name == "Tongue Exercises" }) {
                    recommendations.append(tongueExercise)
                }
            }
            
            if let tasteTest = latestTongueTest.tasteTest, tasteTest.overallScore < 0.5 {
                if let tasteTraining = exerciseDatabase.activities.first(where: { $0.name == "Taste Training" }) {
                    recommendations.append(tasteTraining)
                }
            }
            
            if let mobilityTest = latestTongueTest.mobilityTest, mobilityTest.overallScore < 0.5 {
                if let speechPractice = exerciseDatabase.activities.first(where: { $0.name == "Speech Practice" }) {
                    recommendations.append(speechPractice)
                }
            }
        }
        
        return Array(Set(recommendations)) // Remove duplicates
    }
    
    func calculateCaloriesBurned(activity: ExerciseActivity, duration: Double, weight: Double) -> Double {
        return activity.caloriesPerMinute * duration * weight
    }
}
