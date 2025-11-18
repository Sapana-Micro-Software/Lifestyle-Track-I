import Foundation

// MARK: - Exercise Categories
enum ExerciseCategory: String, Codable, CaseIterable {
    case cardio = "Cardio"
    case strength = "Strength Training"
    case flexibility = "Flexibility"
    case mindBody = "Mind-Body"
    case breathing = "Breathing Techniques"
    case dance = "Dance Fitness"
    case martialArts = "Martial Arts"
    case functional = "Functional Training"
}

// MARK: - Exercise Intensity
enum ExerciseIntensity: String, Codable, CaseIterable {
    case light = "Light"
    case moderate = "Moderate"
    case vigorous = "Vigorous"
    case high = "High Intensity"
    
    var metValue: Double {
        switch self {
        case .light: return 3.0
        case .moderate: return 5.0
        case .vigorous: return 7.0
        case .high: return 9.0
        }
    }
}

// MARK: - Exercise Activity
struct ExerciseActivity: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let intensity: ExerciseIntensity
    let caloriesPerMinute: Double // per kg body weight
    let benefits: [String]
    let muscleGroups: [String]
    let isIndianTechnique: Bool
    
    init(id: UUID = UUID(), name: String, category: ExerciseCategory, intensity: ExerciseIntensity, caloriesPerMinute: Double, benefits: [String], muscleGroups: [String] = [], isIndianTechnique: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.intensity = intensity
        self.caloriesPerMinute = caloriesPerMinute
        self.benefits = benefits
        self.muscleGroups = muscleGroups
        self.isIndianTechnique = isIndianTechnique
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExerciseActivity, rhs: ExerciseActivity) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Exercise Session
struct ExerciseSession: Codable, Identifiable {
    let id: UUID
    let activity: ExerciseActivity
    let duration: Double // minutes
    let date: Date
    let heartRateAverage: Int?
    let heartRateMax: Int?
    let caloriesBurned: Double
    let notes: String?
    
    init(id: UUID = UUID(), activity: ExerciseActivity, duration: Double, date: Date = Date(), heartRateAverage: Int? = nil, heartRateMax: Int? = nil, caloriesBurned: Double, notes: String? = nil) {
        self.id = id
        self.activity = activity
        self.duration = duration
        self.date = date
        self.heartRateAverage = heartRateAverage
        self.heartRateMax = heartRateMax
        self.caloriesBurned = caloriesBurned
        self.notes = notes
    }
}

// MARK: - Daily Exercise Log
struct DailyExerciseLog: Codable {
    var date: Date
    var sessions: [ExerciseSession]
    var steps: Int
    var stairsClimbed: Int
    var heartRateVariation: HeartRateVariation
    var meditationMinutes: Double
    var breathingPracticeMinutes: Double
    
    struct HeartRateVariation: Codable {
        var resting: Int
        var average: Int
        var max: Int
        var min: Int
    }
    
    var totalCaloriesBurned: Double {
        sessions.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var totalDuration: Double {
        sessions.reduce(0) { $0 + $1.duration }
    }
}

// MARK: - Exercise Database
class ExerciseDatabase {
    static let shared = ExerciseDatabase()
    
    var activities: [ExerciseActivity] = []
    
    private init() {
        loadActivities()
    }
    
    private func loadActivities() {
        // Cardio Activities
        activities.append(contentsOf: [
            ExerciseActivity(name: "Walking", category: .cardio, intensity: .light, caloriesPerMinute: 0.04,
                           benefits: ["Improves cardiovascular health", "Low impact", "Accessible"],
                           muscleGroups: ["Legs", "Core"]),
            
            ExerciseActivity(name: "Jogging", category: .cardio, intensity: .moderate, caloriesPerMinute: 0.08,
                           benefits: ["Cardiovascular fitness", "Bone density", "Mental health"],
                           muscleGroups: ["Legs", "Core", "Glutes"]),
            
            ExerciseActivity(name: "Running", category: .cardio, intensity: .vigorous, caloriesPerMinute: 0.12,
                           benefits: ["High calorie burn", "Endurance", "Cardiovascular health"],
                           muscleGroups: ["Legs", "Core", "Glutes", "Arms"]),
            
            ExerciseActivity(name: "Sprinting", category: .cardio, intensity: .high, caloriesPerMinute: 0.20,
                           benefits: ["Explosive power", "Anaerobic fitness", "Muscle building"],
                           muscleGroups: ["Legs", "Glutes", "Core"]),
            
            ExerciseActivity(name: "Rowing", category: .cardio, intensity: .vigorous, caloriesPerMinute: 0.14,
                           benefits: ["Full body workout", "Low impact", "Cardiovascular"],
                           muscleGroups: ["Back", "Legs", "Arms", "Core"]),
            
            ExerciseActivity(name: "Stair Climbing", category: .cardio, intensity: .vigorous, caloriesPerMinute: 0.15,
                           benefits: ["Leg strength", "Cardiovascular", "Glute activation"],
                           muscleGroups: ["Legs", "Glutes", "Core"]),
            
            ExerciseActivity(name: "Elliptical", category: .cardio, intensity: .moderate, caloriesPerMinute: 0.10,
                           benefits: ["Low impact", "Full body", "Cardiovascular"],
                           muscleGroups: ["Legs", "Arms", "Core"]),
            
            ExerciseActivity(name: "Spinning", category: .cardio, intensity: .high, caloriesPerMinute: 0.18,
                           benefits: ["High intensity", "Leg strength", "Cardiovascular"],
                           muscleGroups: ["Legs", "Glutes", "Core"]),
        ])
        
        // Strength Training
        activities.append(contentsOf: [
            ExerciseActivity(name: "Weight Training", category: .strength, intensity: .vigorous, caloriesPerMinute: 0.08,
                           benefits: ["Muscle building", "Bone density", "Metabolism boost"],
                           muscleGroups: ["Full body"]),
        ])
        
        // Dance Fitness
        activities.append(contentsOf: [
            ExerciseActivity(name: "Zumba", category: .dance, intensity: .high, caloriesPerMinute: 0.12,
                           benefits: ["Fun cardio", "Coordination", "Full body"],
                           muscleGroups: ["Legs", "Core", "Arms"]),
            
            ExerciseActivity(name: "U-Jam", category: .dance, intensity: .high, caloriesPerMinute: 0.13,
                           benefits: ["Urban dance fitness", "Cardiovascular", "Coordination"],
                           muscleGroups: ["Full body"]),
            
            ExerciseActivity(name: "Jane Fonda's Workout", category: .dance, intensity: .moderate, caloriesPerMinute: 0.09,
                           benefits: ["Classic aerobics", "Cardiovascular", "Flexibility"],
                           muscleGroups: ["Full body"]),
        ])
        
        // Martial Arts & Combat
        activities.append(contentsOf: [
            ExerciseActivity(name: "Kickboxing", category: .martialArts, intensity: .high, caloriesPerMinute: 0.16,
                           benefits: ["Self-defense", "Full body", "Stress relief"],
                           muscleGroups: ["Legs", "Arms", "Core", "Back"]),
        ])
        
        // Mind-Body Practices
        activities.append(contentsOf: [
            ExerciseActivity(name: "Yoga", category: .mindBody, intensity: .light, caloriesPerMinute: 0.03,
                           benefits: ["Flexibility", "Strength", "Mental clarity", "Stress reduction"],
                           muscleGroups: ["Full body"]),
            
            ExerciseActivity(name: "Sun Salutations", category: .mindBody, intensity: .moderate, caloriesPerMinute: 0.05,
                           benefits: ["Full body flow", "Flexibility", "Energy", "Spiritual practice"],
                           muscleGroups: ["Full body"]),
            
            ExerciseActivity(name: "Tai Chi", category: .mindBody, intensity: .light, caloriesPerMinute: 0.03,
                           benefits: ["Balance", "Flexibility", "Mental calm", "Low impact"],
                           muscleGroups: ["Full body"]),
            
            ExerciseActivity(name: "Pilates", category: .mindBody, intensity: .moderate, caloriesPerMinute: 0.05,
                           benefits: ["Core strength", "Flexibility", "Posture", "Body awareness"],
                           muscleGroups: ["Core", "Back", "Legs"]),
            
            ExerciseActivity(name: "Meditation", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Stress reduction", "Mental clarity", "Emotional regulation", "Focus"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Body Scanning", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Body awareness", "Stress reduction", "Mindfulness", "Relaxation"],
                           muscleGroups: []),
        ])
        
        // Indian Breathing Techniques
        activities.append(contentsOf: [
            ExerciseActivity(name: "Pranayama", category: .breathing, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Lung capacity", "Stress reduction", "Energy regulation", "Mental clarity"],
                           muscleGroups: ["Respiratory system"],
                           isIndianTechnique: true),
            
            ExerciseActivity(name: "Bhastrika", category: .breathing, intensity: .moderate, caloriesPerMinute: 0.02,
                           benefits: ["Lung strength", "Energy boost", "Detoxification", "Mental alertness"],
                           muscleGroups: ["Respiratory system", "Core"],
                           isIndianTechnique: true),
            
            ExerciseActivity(name: "Anulom Vilom", category: .breathing, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Balance", "Stress reduction", "Respiratory health", "Mental calm"],
                           muscleGroups: ["Respiratory system"],
                           isIndianTechnique: true),
            
            ExerciseActivity(name: "Kriya", category: .breathing, intensity: .moderate, caloriesPerMinute: 0.02,
                           benefits: ["Spiritual practice", "Energy flow", "Mental clarity", "Inner transformation"],
                           muscleGroups: ["Respiratory system", "Core"],
                           isIndianTechnique: true),
        ])
        
        // Special Activities
        activities.append(contentsOf: [
            ExerciseActivity(name: "Laughing Exercise", category: .cardio, intensity: .light, caloriesPerMinute: 0.03,
                           benefits: ["Stress relief", "Mood boost", "Cardiovascular", "Social connection"],
                           muscleGroups: ["Core", "Face"]),
        ])
        
        // Hearing & Audio Activities
        activities.append(contentsOf: [
            ExerciseActivity(name: "Music Listening Session", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Hearing health", "Stress reduction", "Cognitive stimulation", "Mood enhancement"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Active Music Listening", category: .mindBody, intensity: .light, caloriesPerMinute: 0.02,
                           benefits: ["Hearing acuity", "Focus", "Cognitive function", "Emotional regulation"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Hearing Exercise", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Hearing health", "Auditory processing", "Sound discrimination", "Cognitive health"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Nature Sounds Therapy", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Hearing health", "Relaxation", "Stress reduction", "Mindfulness"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Binaural Beats Session", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Hearing health", "Focus", "Meditation", "Brainwave entrainment"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Audio Book Listening", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Hearing health", "Learning", "Cognitive stimulation", "Entertainment"],
                           muscleGroups: []),
        ])
        
        // Tactile & Touch Activities
        activities.append(contentsOf: [
            ExerciseActivity(name: "Tactile Stimulation", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Tactile health", "Sensory awareness", "Stress reduction", "Body awareness"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Massage Therapy", category: .mindBody, intensity: .light, caloriesPerMinute: 0.02,
                           benefits: ["Tactile health", "Muscle relaxation", "Circulation", "Pain relief"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Texture Exploration", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Tactile sensitivity", "Sensory integration", "Mindfulness", "Cognitive stimulation"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Temperature Therapy", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Tactile health", "Circulation", "Pain relief", "Relaxation"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Reflexology", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Tactile health", "Energy flow", "Relaxation", "Therapeutic"],
                           muscleGroups: []),
        ])
        
        // Tongue & Oral Health Activities
        activities.append(contentsOf: [
            ExerciseActivity(name: "Tongue Exercises", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Tongue health", "Speech clarity", "Oral strength", "Swallowing"],
                           muscleGroups: ["Tongue", "Oral muscles"]),
            
            ExerciseActivity(name: "Taste Training", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Taste sensitivity", "Nutrition awareness", "Mindful eating", "Sensory health"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Tongue Scraping", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Oral hygiene", "Tongue health", "Taste improvement", "Freshness"],
                           muscleGroups: []),
            
            ExerciseActivity(name: "Oil Pulling", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Oral health", "Tongue vitality", "Detoxification", "Freshness"],
                           muscleGroups: ["Oral muscles"]),
            
            ExerciseActivity(name: "Speech Practice", category: .mindBody, intensity: .light, caloriesPerMinute: 0.01,
                           benefits: ["Tongue mobility", "Speech clarity", "Oral coordination", "Communication"],
                           muscleGroups: ["Tongue", "Oral muscles"]),
        ])
    }
    
    func activitiesForCategory(_ category: ExerciseCategory) -> [ExerciseActivity] {
        activities.filter { $0.category == category }
    }
    
    func indianBreathingTechniques() -> [ExerciseActivity] {
        activities.filter { $0.isIndianTechnique }
    }
}

// MARK: - Exercise Goals
struct ExerciseGoals: Codable {
    var weeklyCardioMinutes: Double = 150 // WHO recommendation
    var weeklyStrengthSessions: Int = 2
    var weeklyFlexibilityMinutes: Double = 60
    var weeklyMindBodyMinutes: Double = 120
    var dailySteps: Int = 10000
    var dailyStairs: Int = 10 // flights
    var weeklyBreathingPractice: Double = 60 // minutes
    var targetMuscleMass: Double? // kg
    var targetHeartRateZone: HeartRateZone?
    
    struct HeartRateZone: Codable {
        var resting: Int
        var targetMin: Int
        var targetMax: Int
    }
}

// MARK: - Exercise Plan
struct ExercisePlan: Codable {
    var weeklyPlan: [DayPlan]
    var goals: ExerciseGoals
    var focusAreas: [String]
    
    struct DayPlan: Codable, Identifiable {
        let id: UUID
        let dayOfWeek: Int // 0 = Sunday, 6 = Saturday
        var activities: [PlannedActivity]
        
        struct PlannedActivity: Codable, Identifiable {
            let id: UUID
            let activity: ExerciseActivity
            let duration: Double // minutes
            let timeOfDay: TimeOfDay
            
            enum TimeOfDay: String, Codable, CaseIterable {
                case morning = "Morning"
                case afternoon = "Afternoon"
                case evening = "Evening"
            }
        }
    }
}
