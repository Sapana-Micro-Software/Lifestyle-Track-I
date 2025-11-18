//
//  TimeBasedPlanner.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Time-Based Planning Session
struct TimeBasedPlanningSession: Codable, Identifiable { // Define TimeBasedPlanningSession struct for planning sessions
    let id: UUID // Unique identifier for planning session
    var date: Date // Date of planning session
    var sessionType: SessionType // Type of planning session
    var tasks: [PlanningTask] // Array of planning tasks
    var reflections: [Reflection] // Array of reflections or insights
    var goals: [Goal] // Array of goals for the period
    var priorities: [Priority] // Array of priorities for the period
    var notes: String? // Optional notes for planning session
    
    enum SessionType: String, Codable { // Enum for session types
        case dayStart = "Day Start" // Beginning of day planning session
        case dayEnd = "Day End" // End of day planning session
        case weekStart = "Week Start" // Beginning of week planning session
        case weekEnd = "Week End" // End of week planning session
        case monthStart = "Month Start" // Beginning of month planning session
        case monthEnd = "Month End" // End of month planning session
    }
    
    struct PlanningTask: Codable, Identifiable { // Nested struct for planning tasks
        let id: UUID // Unique identifier for task
        var title: String // Title of task
        var description: String? // Optional description of task
        var category: TaskCategory // Category of task
        var priority: TaskPriority // Priority of task
        var estimatedDuration: Double? // Optional estimated duration in minutes
        var isCompleted: Bool // Whether task is completed
        var dueDate: Date? // Optional due date for task
        
        enum TaskCategory: String, Codable, CaseIterable { // Enum for task categories
            case health = "Health" // Health-related task
            case exercise = "Exercise" // Exercise-related task
            case nutrition = "Nutrition" // Nutrition-related task
            case work = "Work" // Work-related task
            case personal = "Personal" // Personal task
            case relationships = "Relationships" // Relationship-related task
            case learning = "Learning" // Learning or education task
            case creative = "Creative" // Creative activity task
            case rest = "Rest" // Rest or relaxation task
            case other = "Other" // Other category task
        }
        
        enum TaskPriority: String, Codable, CaseIterable { // Enum for task priorities
            case low = "Low" // Low priority task
            case medium = "Medium" // Medium priority task
            case high = "High" // High priority task
            case urgent = "Urgent" // Urgent priority task
        }
        
        init(id: UUID = UUID(), title: String, description: String? = nil, category: TaskCategory = .other, priority: TaskPriority = .medium, estimatedDuration: Double? = nil, isCompleted: Bool = false, dueDate: Date? = nil) {
            self.id = id // Initialize unique identifier
            self.title = title // Initialize task title
            self.description = description // Initialize optional description
            self.category = category // Initialize category
            self.priority = priority // Initialize priority
            self.estimatedDuration = estimatedDuration // Initialize optional duration
            self.isCompleted = isCompleted // Initialize completion status
            self.dueDate = dueDate // Initialize optional due date
        }
    }
    
    struct Reflection: Codable, Identifiable { // Nested struct for reflections
        let id: UUID // Unique identifier for reflection
        var content: String // Content of reflection
        var category: ReflectionCategory // Category of reflection
        var insights: [String] // Array of insights from reflection
        var actionItems: [String] // Array of action items from reflection
        
        enum ReflectionCategory: String, Codable, CaseIterable { // Enum for reflection categories
            case gratitude = "Gratitude" // Gratitude reflection
            case achievement = "Achievement" // Achievement reflection
            case challenge = "Challenge" // Challenge reflection
            case learning = "Learning" // Learning reflection
            case growth = "Growth" // Growth reflection
            case relationship = "Relationship" // Relationship reflection
            case health = "Health" // Health reflection
            case general = "General" // General reflection
        }
        
        init(id: UUID = UUID(), content: String, category: ReflectionCategory = .general, insights: [String] = [], actionItems: [String] = []) {
            self.id = id // Initialize unique identifier
            self.content = content // Initialize reflection content
            self.category = category // Initialize category
            self.insights = insights // Initialize insights array
            self.actionItems = actionItems // Initialize action items array
        }
    }
    
    struct Goal: Codable, Identifiable { // Nested struct for goals
        let id: UUID // Unique identifier for goal
        var title: String // Title of goal
        var description: String? // Optional description of goal
        var targetDate: Date? // Optional target date for goal
        var progress: Double // Progress percentage (0-100)
        var milestones: [Milestone] // Array of goal milestones
        
        struct Milestone: Codable, Identifiable { // Nested struct for milestones
            let id: UUID // Unique identifier for milestone
            var title: String // Title of milestone
            var targetDate: Date? // Optional target date for milestone
            var isCompleted: Bool // Whether milestone is completed
            
            init(id: UUID = UUID(), title: String, targetDate: Date? = nil, isCompleted: Bool = false) {
                self.id = id // Initialize unique identifier
                self.title = title // Initialize milestone title
                self.targetDate = targetDate // Initialize optional target date
                self.isCompleted = isCompleted // Initialize completion status
            }
        }
        
        init(id: UUID = UUID(), title: String, description: String? = nil, targetDate: Date? = nil, progress: Double = 0, milestones: [Milestone] = []) {
            self.id = id // Initialize unique identifier
            self.title = title // Initialize goal title
            self.description = description // Initialize optional description
            self.targetDate = targetDate // Initialize optional target date
            self.progress = progress // Initialize progress percentage
            self.milestones = milestones // Initialize milestones array
        }
    }
    
    struct Priority: Codable, Identifiable { // Nested struct for priorities
        let id: UUID // Unique identifier for priority
        var title: String // Title of priority
        var description: String? // Optional description of priority
        var importance: ImportanceLevel // Importance level of priority
        
        enum ImportanceLevel: String, Codable, CaseIterable { // Enum for importance levels
            case low = "Low" // Low importance priority
            case medium = "Medium" // Medium importance priority
            case high = "High" // High importance priority
            case critical = "Critical" // Critical importance priority
        }
        
        init(id: UUID = UUID(), title: String, description: String? = nil, importance: ImportanceLevel = .medium) {
            self.id = id // Initialize unique identifier
            self.title = title // Initialize priority title
            self.description = description // Initialize optional description
            self.importance = importance // Initialize importance level
        }
    }
    
    init(id: UUID = UUID(), date: Date, sessionType: SessionType, tasks: [PlanningTask] = [], reflections: [Reflection] = [], goals: [Goal] = [], priorities: [Priority] = [], notes: String? = nil) {
        self.id = id // Initialize unique identifier
        self.date = date // Initialize session date
        self.sessionType = sessionType // Initialize session type
        self.tasks = tasks // Initialize tasks array
        self.reflections = reflections // Initialize reflections array
        self.goals = goals // Initialize goals array
        self.priorities = priorities // Initialize priorities array
        self.notes = notes // Initialize optional notes
    }
}

// MARK: - Time-Based Planner
class TimeBasedPlanner { // Define TimeBasedPlanner class for generating planning sessions
    func generateDayStartPlan(for date: Date, healthData: HealthData?, journalEntries: [JournalEntry], previousDayPlan: TimeBasedPlanningSession?) -> TimeBasedPlanningSession { // Function to generate day start plan
        var tasks: [TimeBasedPlanningSession.PlanningTask] = [] // Initialize tasks array
        var reflections: [TimeBasedPlanningSession.Reflection] = [] // Initialize reflections array
        var priorities: [TimeBasedPlanningSession.Priority] = [] // Initialize priorities array
        
        // Analyze previous day's journal entries for insights
        let previousDayEntries = journalEntries.filter { // Filter journal entries from previous day
            Calendar.current.isDate($0.date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date) // Check if entry is from previous day
        }
        
        if !previousDayEntries.isEmpty { // Check if previous day entries exist
            let reflection = analyzeJournalEntries(previousDayEntries) // Analyze journal entries
            reflections.append(reflection) // Add reflection to array
        }
        
        // Generate morning tasks based on health data
        if let healthData = healthData { // Check if health data exists
            if healthData.exerciseGoals != nil { // Check if exercise goals exist
                tasks.append(TimeBasedPlanningSession.PlanningTask( // Add exercise task
                    title: "Morning Exercise", // Set task title
                    description: "Complete morning exercise routine", // Set task description
                    category: .exercise, // Set exercise category
                    priority: .high, // Set high priority
                    estimatedDuration: 30 // Set 30 minute duration
                ))
            }
            
            if healthData.mentalHealth?.stressLevel == .high || healthData.mentalHealth?.stressLevel == .veryHigh { // Check if high stress
                tasks.append(TimeBasedPlanningSession.PlanningTask( // Add meditation task
                    title: "Morning Meditation", // Set task title
                    description: "Practice meditation for stress relief", // Set task description
                    category: .health, // Set health category
                    priority: .high, // Set high priority
                    estimatedDuration: 15 // Set 15 minute duration
                ))
            }
        }
        
        // Add journal entry task
        tasks.append(TimeBasedPlanningSession.PlanningTask( // Add journal task
            title: "Morning Journal Entry", // Set task title
            description: "Write morning journal entry", // Set task description
            category: .personal, // Set personal category
            priority: .medium, // Set medium priority
            estimatedDuration: 10 // Set 10 minute duration
        ))
        
        // Set priorities
        priorities.append(TimeBasedPlanningSession.Priority( // Add health priority
            title: "Health & Wellness", // Set priority title
            description: "Focus on physical and mental health", // Set priority description
            importance: .high // Set high importance
        ))
        
        return TimeBasedPlanningSession( // Return day start planning session
            date: date, // Set session date
            sessionType: .dayStart, // Set day start type
            tasks: tasks, // Set tasks array
            reflections: reflections, // Set reflections array
            priorities: priorities, // Set priorities array
            notes: "Plan your day with intention and focus on wellness" // Set planning notes
        )
    }
    
    func generateDayEndPlan(for date: Date, healthData: HealthData?, journalEntries: [JournalEntry], dayPlan: TimeBasedPlanningSession?) -> TimeBasedPlanningSession { // Function to generate day end plan
        var reflections: [TimeBasedPlanningSession.Reflection] = [] // Initialize reflections array
        var tasks: [TimeBasedPlanningSession.PlanningTask] = [] // Initialize tasks array
        
        // Analyze today's journal entries
        let todayEntries = journalEntries.filter { // Filter journal entries for today
            Calendar.current.isDate($0.date, inSameDayAs: date) // Check if entry is from today
        }
        
        if !todayEntries.isEmpty { // Check if today's entries exist
            let reflection = analyzeJournalEntries(todayEntries) // Analyze journal entries
            reflections.append(reflection) // Add reflection to array
        }
        
        // Add evening reflection task
        tasks.append(TimeBasedPlanningSession.PlanningTask( // Add reflection task
            title: "Evening Reflection", // Set task title
            description: "Reflect on the day's experiences and learnings", // Set task description
            category: .personal, // Set personal category
            priority: .medium, // Set medium priority
            estimatedDuration: 15 // Set 15 minute duration
        ))
        
        // Add journal entry task
        tasks.append(TimeBasedPlanningSession.PlanningTask( // Add journal task
            title: "Evening Journal Entry", // Set task title
            description: "Write evening journal entry", // Set task description
            category: .personal, // Set personal category
            priority: .medium, // Set medium priority
            estimatedDuration: 15 // Set 15 minute duration
        ))
        
        // Add preparation for next day task
        tasks.append(TimeBasedPlanningSession.PlanningTask( // Add preparation task
            title: "Prepare for Tomorrow", // Set task title
            description: "Review tomorrow's schedule and prepare", // Set task description
            category: .personal, // Set personal category
            priority: .medium, // Set medium priority
            estimatedDuration: 10 // Set 10 minute duration
        ))
        
        return TimeBasedPlanningSession( // Return day end planning session
            date: date, // Set session date
            sessionType: .dayEnd, // Set day end type
            tasks: tasks, // Set tasks array
            reflections: reflections, // Set reflections array
            notes: "Reflect on your day and prepare for tomorrow" // Set planning notes
        )
    }
    
    func generateWeekStartPlan(for date: Date, healthData: HealthData?, journalEntries: [JournalEntry], previousWeekPlan: TimeBasedPlanningSession?) -> TimeBasedPlanningSession { // Function to generate week start plan
        var goals: [TimeBasedPlanningSession.Goal] = [] // Initialize goals array
        let priorities: [TimeBasedPlanningSession.Priority] = [] // Initialize priorities array
        let tasks: [TimeBasedPlanningSession.PlanningTask] = [] // Initialize tasks array
        
        // Analyze previous week's journal entries
        let calendar = Calendar.current // Get calendar instance
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { // Get week start date
            return TimeBasedPlanningSession(date: date, sessionType: .weekStart) // Return empty session if no week start
        }
        let previousWeekStart = calendar.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart // Calculate previous week start
        let previousWeekEntries = journalEntries.filter { // Filter previous week entries
            $0.date >= previousWeekStart && $0.date < weekStart // Check if entry is in previous week
        }
        
        var reflections: [TimeBasedPlanningSession.Reflection] = [] // Initialize reflections array
        if !previousWeekEntries.isEmpty { // Check if previous week entries exist
            let reflection = analyzeJournalEntries(previousWeekEntries) // Analyze journal entries
            reflections.append(reflection) // Add reflection to array
        }
        
        // Set goals based on health data and previous week analysis
        if let healthData = healthData { // Check if health data exists
            if healthData.exerciseGoals != nil { // Check if exercise goals exist
                goals.append(TimeBasedPlanningSession.Goal( // Add exercise goal
                    title: "Weekly Exercise Goal", // Set goal title
                    description: "Complete weekly exercise plan", // Set goal description
                    targetDate: calendar.date(byAdding: .day, value: 7, to: date), // Set target date
                    progress: 0 // Set initial progress
                ))
            }
        }
        
        return TimeBasedPlanningSession( // Return week start planning session
            date: date, // Set session date
            sessionType: .weekStart, // Set week start type
            tasks: tasks, // Set tasks array
            reflections: reflections, // Set reflections array
            goals: goals, // Set goals array
            priorities: priorities, // Set priorities array
            notes: "Set your intentions for the week ahead" // Set planning notes
        )
    }
    
    func generateWeekEndPlan(for date: Date, healthData: HealthData?, journalEntries: [JournalEntry], weekPlan: TimeBasedPlanningSession?) -> TimeBasedPlanningSession { // Function to generate week end plan
        var reflections: [TimeBasedPlanningSession.Reflection] = [] // Initialize reflections array
        var tasks: [TimeBasedPlanningSession.PlanningTask] = [] // Initialize tasks array
        
        // Analyze this week's journal entries
        let calendar = Calendar.current // Get calendar instance
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { // Get week interval
            return TimeBasedPlanningSession(date: date, sessionType: .weekEnd) // Return empty session if no interval
        }
        let weekEntries = journalEntries.filter { // Filter week entries
            weekInterval.contains($0.date) // Check if entry is in week interval
        }
        
        if !weekEntries.isEmpty { // Check if week entries exist
            let reflection = analyzeJournalEntries(weekEntries) // Analyze journal entries
            reflections.append(reflection) // Add reflection to array
        }
        
        // Add weekly review task
        tasks.append(TimeBasedPlanningSession.PlanningTask( // Add review task
            title: "Weekly Review", // Set task title
            description: "Review week's accomplishments and challenges", // Set task description
            category: .personal, // Set personal category
            priority: .high, // Set high priority
            estimatedDuration: 30 // Set 30 minute duration
        ))
        
        return TimeBasedPlanningSession( // Return week end planning session
            date: date, // Set session date
            sessionType: .weekEnd, // Set week end type
            tasks: tasks, // Set tasks array
            reflections: reflections, // Set reflections array
            notes: "Reflect on your week and prepare for the next" // Set planning notes
        )
    }
    
    func generateMonthStartPlan(for date: Date, healthData: HealthData?, journalEntries: [JournalEntry], previousMonthPlan: TimeBasedPlanningSession?) -> TimeBasedPlanningSession { // Function to generate month start plan
        var goals: [TimeBasedPlanningSession.Goal] = [] // Initialize goals array
        let priorities: [TimeBasedPlanningSession.Priority] = [] // Initialize priorities array
        
        // Analyze previous month's journal entries
        let calendar = Calendar.current // Get calendar instance
        guard let monthStart = calendar.dateInterval(of: .month, for: date)?.start else { // Get month start date
            return TimeBasedPlanningSession(date: date, sessionType: .monthStart) // Return empty session if no month start
        }
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart // Calculate previous month start
        let previousMonthEntries = journalEntries.filter { // Filter previous month entries
            $0.date >= previousMonthStart && $0.date < monthStart // Check if entry is in previous month
        }
        
        var reflections: [TimeBasedPlanningSession.Reflection] = [] // Initialize reflections array
        if !previousMonthEntries.isEmpty { // Check if previous month entries exist
            let reflection = analyzeJournalEntries(previousMonthEntries) // Analyze journal entries
            reflections.append(reflection) // Add reflection to array
        }
        
        // Set monthly goals based on health data
        if healthData != nil { // Check if health data exists
            goals.append(TimeBasedPlanningSession.Goal( // Add health goal
                title: "Monthly Health Goal", // Set goal title
                description: "Focus on health and wellness improvements", // Set goal description
                targetDate: calendar.date(byAdding: .month, value: 1, to: date), // Set target date
                progress: 0 // Set initial progress
            ))
        }
        
        return TimeBasedPlanningSession( // Return month start planning session
            date: date, // Set session date
            sessionType: .monthStart, // Set month start type
            reflections: reflections, // Set reflections array
            goals: goals, // Set goals array
            priorities: priorities, // Set priorities array
            notes: "Set your intentions for the month ahead" // Set planning notes
        )
    }
    
    func generateMonthEndPlan(for date: Date, healthData: HealthData?, journalEntries: [JournalEntry], monthPlan: TimeBasedPlanningSession?) -> TimeBasedPlanningSession { // Function to generate month end plan
        var reflections: [TimeBasedPlanningSession.Reflection] = [] // Initialize reflections array
        var tasks: [TimeBasedPlanningSession.PlanningTask] = [] // Initialize tasks array
        
        // Analyze this month's journal entries
        let calendar = Calendar.current // Get calendar instance
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { // Get month interval
            return TimeBasedPlanningSession(date: date, sessionType: .monthEnd) // Return empty session if no interval
        }
        let monthEntries = journalEntries.filter { // Filter month entries
            monthInterval.contains($0.date) // Check if entry is in month interval
        }
        
        if !monthEntries.isEmpty { // Check if month entries exist
            let reflection = analyzeJournalEntries(monthEntries) // Analyze journal entries
            reflections.append(reflection) // Add reflection to array
        }
        
        // Add monthly review task
        tasks.append(TimeBasedPlanningSession.PlanningTask( // Add review task
            title: "Monthly Review", // Set task title
            description: "Review month's accomplishments and plan next month", // Set task description
            category: .personal, // Set personal category
            priority: .high, // Set high priority
            estimatedDuration: 60 // Set 60 minute duration
        ))
        
        return TimeBasedPlanningSession( // Return month end planning session
            date: date, // Set session date
            sessionType: .monthEnd, // Set month end type
            tasks: tasks, // Set tasks array
            reflections: reflections, // Set reflections array
            notes: "Reflect on your month and prepare for the next" // Set planning notes
        )
    }
    
    private func analyzeJournalEntries(_ entries: [JournalEntry]) -> TimeBasedPlanningSession.Reflection { // Private function to analyze journal entries
        var gratitudeItems: [String] = [] // Initialize gratitude items array
        var achievements: [String] = [] // Initialize achievements array
        var challenges: [String] = [] // Initialize challenges array
        var insights: [String] = [] // Initialize insights array
        
        for entry in entries { // Loop through journal entries
            if let structured = entry.structuredData { // Check if structured data exists
                gratitudeItems.append(contentsOf: structured.gratitude) // Add gratitude items
                achievements.append(contentsOf: structured.achievements) // Add achievements
                challenges.append(contentsOf: structured.challenges) // Add challenges
                insights.append(contentsOf: structured.lessons) // Add lessons as insights
            }
            if let unstructured = entry.unstructuredText { // Check if unstructured text exists
                insights.append(unstructured) // Add unstructured text as insight
            }
        }
        
        var content = "Journal Analysis:\n" // Initialize reflection content
        if !gratitudeItems.isEmpty { // Check if gratitude items exist
            content += "Gratitude: \(gratitudeItems.joined(separator: ", "))\n" // Add gratitude to content
        }
        if !achievements.isEmpty { // Check if achievements exist
            content += "Achievements: \(achievements.joined(separator: ", "))\n" // Add achievements to content
        }
        if !challenges.isEmpty { // Check if challenges exist
            content += "Challenges: \(challenges.joined(separator: ", "))\n" // Add challenges to content
        }
        
        return TimeBasedPlanningSession.Reflection( // Return reflection
            content: content, // Set reflection content
            category: .general, // Set general category
            insights: insights, // Set insights array
            actionItems: [] // Set empty action items array
        )
    }
}
