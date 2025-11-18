//
//  DietSolverViewModel.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax
import Foundation // Import Foundation framework for basic Swift types and functionality
import EventKit // Import EventKit framework for calendar and event management

class DietSolverViewModel: ObservableObject { // Define view model class conforming to ObservableObject for reactive updates
    @Published var healthData: HealthData? // Published property for health data with automatic view updates
    @Published var dietPlan: DailyDietPlan? // Published property for daily diet plan with automatic view updates
    @Published var exercisePlan: ExercisePlan? // Published property for exercise plan with automatic view updates
    @Published var longTermPlan: LongTermPlan? // Published property for long-term transformation plan
    @Published var dailyPlans: [DailyPlanEntry] = [] // Published array of daily plan entries for entire duration
    @Published var currentPlanningSession: TimeBasedPlanningSession? // Published property for current planning session
    @Published var calendarScheduleItems: [CalendarScheduleItem] = [] // Published array of calendar schedule items
    @Published var journalAnalysis: JournalAnalysisReport? // Published property for journal analysis report
    @Published var calendarAccessGranted: Bool = false // Published property for calendar access status
    
    private let solver = DietSolver() // Private diet solver instance for optimization calculations
    private let exercisePlanner = ExercisePlanner() // Private exercise planner instance for workout generation
    private let medicalAnalyzer = MedicalAnalyzer() // Private medical analyzer instance for test interpretation
    private let cognitiveAnalyzer = CognitiveAnalyzer() // Private cognitive analyzer instance for assessment analysis
    private let longTermPlanner = LongTermPlanner() // Private long-term planner instance for transformation planning
    private let sleepAnalyzer = SleepAnalyzer() // Private sleep analyzer instance for sleep pattern analysis
    private let timeBasedPlanner = TimeBasedPlanner() // Private time-based planner instance for planning sessions
    private let calendarScheduler = CalendarScheduler() // Private calendar scheduler instance for event creation
    private let journalAnalyzer = JournalAnalyzer() // Private journal analyzer instance for journal analysis
    private let healthKitManager = HealthKitManager() // Private HealthKit manager instance for health data access
    private let visionAnalyzer = VisionAnalyzer() // Private vision analyzer instance for vision health analysis
    
    func setHealthData(_ data: HealthData) {
        healthData = data
        dietPlan = nil
        generateExercisePlan()
    }
    
    func updateHealthData(_ data: HealthData) {
        healthData = data
        generateExercisePlan()
        analyzeMedicalTests()
    }
    
    private func analyzeMedicalTests() {
        guard var healthData = healthData else { return } // Check if health data exists
        
        // Analyze medical tests
        let medicalReport = medicalAnalyzer.analyze( // Analyze medical test collection
            collection: healthData.medicalTests, // Pass medical tests collection
            gender: healthData.gender // Pass gender for analysis
        )
        healthData.medicalAnalysis = medicalReport // Store medical analysis report
        
        // Analyze cognitive assessments
        if let latestCognitive = healthData.cognitiveAssessments.last { // Check if cognitive assessment exists
            let cognitiveReport = cognitiveAnalyzer.analyze(latestCognitive) // Analyze latest cognitive assessment
            // Could store this in healthData if needed
        }
        
        // Analyze sleep records
        if !healthData.sleepRecords.isEmpty { // Check if sleep records exist
            let sleepReport = sleepAnalyzer.analyze(records: healthData.sleepRecords) // Analyze sleep records
            healthData.sleepAnalysis = sleepReport // Store sleep analysis report
        }
        
        self.healthData = healthData // Update health data with analysis results
    }
    
    private func generateExercisePlan() {
        guard let healthData = healthData else { return }
        let goals = healthData.exerciseGoals ?? ExerciseGoals()
        exercisePlan = exercisePlanner.generateWeeklyPlan(for: healthData, goals: goals)
    }
    
    func solveDiet() {
        guard let healthData = healthData else { return }
        
        // Determine current season (simplified - could use actual date)
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let season: Season
        switch month {
        case 12, 1, 2: season = .winter
        case 3, 4, 5: season = .spring
        case 6, 7, 8: season = .summer
        default: season = .fall
        }
        
        // Solve on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let plan = self.solver.solve(healthData: healthData, season: season)
            
            DispatchQueue.main.async {
                self.dietPlan = plan
            }
        }
    }
    
    func generateLongTermPlan(duration: PlanDuration, urgency: UrgencyLevel) {
        guard let healthData = healthData else { return } // Check if health data exists before planning
        
        let calendar = Calendar.current // Get calendar instance for date calculations
        let month = calendar.component(.month, from: Date()) // Get current month for season determination
        let season: Season // Declare season variable for food availability
        switch month { // Switch statement to determine season from month
        case 12, 1, 2: season = .winter // Set winter season for December, January, February
        case 3, 4, 5: season = .spring // Set spring season for March, April, May
        case 6, 7, 8: season = .summer // Set summer season for June, July, August
        default: season = .fall // Set fall season for remaining months
        }
        
        let plan = longTermPlanner.generatePlan(for: healthData, duration: duration, urgency: urgency) // Generate long-term plan
        longTermPlan = plan // Store generated plan in published property
        
        DispatchQueue.global(qos: .userInitiated).async { // Execute on background thread for performance
            let dailyPlans = self.longTermPlanner.generateDailyPlans(for: plan, healthData: healthData, season: season) // Generate all daily plans
            
            DispatchQueue.main.async { // Return to main thread for UI updates
                self.dailyPlans = dailyPlans // Update published daily plans array
            }
        }
    }
    
    func requestCalendarAccess() async { // Async function to request calendar access
        let granted = await calendarScheduler.requestCalendarAccess() // Request calendar access
        await MainActor.run { // Switch to main actor
            calendarAccessGranted = granted // Update calendar access status
        }
    }
    
    func generateDayStartPlan(for date: Date = Date()) { // Function to generate day start plan
        guard let healthData = healthData else { return } // Check if health data exists
        let journalEntries = healthData.journalCollection.entries // Get journal entries
        let previousDayPlan = currentPlanningSession?.sessionType == .dayEnd ? currentPlanningSession : nil // Get previous day plan
        let plan = timeBasedPlanner.generateDayStartPlan( // Generate day start plan
            for: date, // Pass date
            healthData: healthData, // Pass health data
            journalEntries: journalEntries, // Pass journal entries
            previousDayPlan: previousDayPlan // Pass previous day plan
        )
        currentPlanningSession = plan // Update current planning session
        generateCalendarSchedule(from: plan) // Generate calendar schedule from plan
    }
    
    func generateDayEndPlan(for date: Date = Date()) { // Function to generate day end plan
        guard let healthData = healthData else { return } // Check if health data exists
        let journalEntries = healthData.journalCollection.entries // Get journal entries
        let dayPlan = currentPlanningSession?.sessionType == .dayStart ? currentPlanningSession : nil // Get day plan
        let plan = timeBasedPlanner.generateDayEndPlan( // Generate day end plan
            for: date, // Pass date
            healthData: healthData, // Pass health data
            journalEntries: journalEntries, // Pass journal entries
            dayPlan: dayPlan // Pass day plan
        )
        currentPlanningSession = plan // Update current planning session
        generateCalendarSchedule(from: plan) // Generate calendar schedule from plan
    }
    
    func generateWeekStartPlan(for date: Date = Date()) { // Function to generate week start plan
        guard let healthData = healthData else { return } // Check if health data exists
        let journalEntries = healthData.journalCollection.entries // Get journal entries
        let previousWeekPlan = currentPlanningSession?.sessionType == .weekEnd ? currentPlanningSession : nil // Get previous week plan
        let plan = timeBasedPlanner.generateWeekStartPlan( // Generate week start plan
            for: date, // Pass date
            healthData: healthData, // Pass health data
            journalEntries: journalEntries, // Pass journal entries
            previousWeekPlan: previousWeekPlan // Pass previous week plan
        )
        currentPlanningSession = plan // Update current planning session
        generateCalendarSchedule(from: plan) // Generate calendar schedule from plan
    }
    
    func generateWeekEndPlan(for date: Date = Date()) { // Function to generate week end plan
        guard let healthData = healthData else { return } // Check if health data exists
        let journalEntries = healthData.journalCollection.entries // Get journal entries
        let weekPlan = currentPlanningSession?.sessionType == .weekStart ? currentPlanningSession : nil // Get week plan
        let plan = timeBasedPlanner.generateWeekEndPlan( // Generate week end plan
            for: date, // Pass date
            healthData: healthData, // Pass health data
            journalEntries: journalEntries, // Pass journal entries
            weekPlan: weekPlan // Pass week plan
        )
        currentPlanningSession = plan // Update current planning session
        generateCalendarSchedule(from: plan) // Generate calendar schedule from plan
    }
    
    func generateMonthStartPlan(for date: Date = Date()) { // Function to generate month start plan
        guard let healthData = healthData else { return } // Check if health data exists
        let journalEntries = healthData.journalCollection.entries // Get journal entries
        let previousMonthPlan = currentPlanningSession?.sessionType == .monthEnd ? currentPlanningSession : nil // Get previous month plan
        let plan = timeBasedPlanner.generateMonthStartPlan( // Generate month start plan
            for: date, // Pass date
            healthData: healthData, // Pass health data
            journalEntries: journalEntries, // Pass journal entries
            previousMonthPlan: previousMonthPlan // Pass previous month plan
        )
        currentPlanningSession = plan // Update current planning session
        generateCalendarSchedule(from: plan) // Generate calendar schedule from plan
    }
    
    func generateMonthEndPlan(for date: Date = Date()) { // Function to generate month end plan
        guard let healthData = healthData else { return } // Check if health data exists
        let journalEntries = healthData.journalCollection.entries // Get journal entries
        let monthPlan = currentPlanningSession?.sessionType == .monthStart ? currentPlanningSession : nil // Get month plan
        let plan = timeBasedPlanner.generateMonthEndPlan( // Generate month end plan
            for: date, // Pass date
            healthData: healthData, // Pass health data
            journalEntries: journalEntries, // Pass journal entries
            monthPlan: monthPlan // Pass month plan
        )
        currentPlanningSession = plan // Update current planning session
        generateCalendarSchedule(from: plan) // Generate calendar schedule from plan
    }
    
    func analyzeJournal() { // Function to analyze journal entries
        guard let healthData = healthData else { return } // Check if health data exists
        let entries = healthData.journalCollection.entries // Get journal entries
        guard !entries.isEmpty else { return } // Check if entries exist
        let calendar = Calendar.current // Get calendar instance
        let startDate = entries.map { $0.date }.min() ?? Date() // Get earliest entry date
        let endDate = entries.map { $0.date }.max() ?? Date() // Get latest entry date
        let timeRange = DateInterval(start: startDate, end: endDate) // Create time range
        let analysis = journalAnalyzer.analyze(entries: entries, timeRange: timeRange) // Analyze journal entries
        journalAnalysis = analysis // Update journal analysis
    }
    
    func scheduleDayInCalendar() async throws { // Async function to schedule day in calendar
        guard calendarAccessGranted else { // Check if calendar access granted
            await requestCalendarAccess() // Request calendar access
            guard calendarAccessGranted else { return } // Check again after request
        }
        let events = try await calendarScheduler.createEvents(from: calendarScheduleItems) // Create calendar events
        // Events are automatically saved to calendar
    }
    
    private func generateCalendarSchedule(from plan: TimeBasedPlanningSession) { // Private function to generate calendar schedule from plan
        var scheduleItems: [CalendarScheduleItem] = [] // Initialize schedule items array
        let calendar = Calendar.current // Get calendar instance
        
        for task in plan.tasks { // Loop through planning tasks
            let startDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: plan.date) ?? plan.date // Set start time
            let duration = task.estimatedDuration ?? 30.0 // Get task duration
            let endDate = calendar.date(byAdding: .minute, value: Int(duration), to: startDate) ?? startDate // Calculate end time
            
            let category: CalendarScheduleItem.ScheduleCategory // Declare category variable
            switch task.category { // Switch on task category
            case .health: category = .health // Set health category
            case .exercise: category = .exercise // Set exercise category
            case .nutrition: category = .meal // Set meal category
            case .work: category = .work // Set work category
            case .personal: category = .personal // Set personal category
            case .relationships: category = .personal // Set personal category
            case .learning: category = .personal // Set personal category
            case .creative: category = .personal // Set personal category
            case .rest: category = .personal // Set personal category
            case .other: category = .other // Set other category
            }
            
            let priority: CalendarScheduleItem.Priority // Declare priority variable
            switch task.priority { // Switch on task priority
            case .low: priority = .low // Set low priority
            case .medium: priority = .medium // Set medium priority
            case .high: priority = .high // Set high priority
            case .urgent: priority = .critical // Set critical priority
            }
            
            let scheduleItem = CalendarScheduleItem( // Create schedule item
                title: task.title, // Set item title
                startDate: startDate, // Set start date
                endDate: endDate, // Set end date
                notes: task.description, // Set notes
                category: category, // Set category
                priority: priority, // Set priority
                reminders: [CalendarScheduleItem.Reminder(minutesBefore: 15)] // Add reminder
            )
            scheduleItems.append(scheduleItem) // Add schedule item to array
        }
        
        calendarScheduleItems = scheduleItems // Update calendar schedule items
    }
    
    func requestHealthKitAccess() async { // Async function to request HealthKit access
        let granted = await healthKitManager.requestAuthorization() // Request HealthKit authorization
        if granted { // Check if access granted
            await loadHealthKitData() // Load HealthKit data
        }
    }
    
    func loadHealthKitData() async { // Async function to load HealthKit data
        guard var healthData = healthData else { return } // Check if health data exists
        let biomarkers = await healthKitManager.readBiomarkers() // Read biomarkers from HealthKit
        if let biomarkers = biomarkers { // Check if biomarkers exist
            healthData.healthKitBiomarkers.append(biomarkers) // Add biomarkers to health data
            await MainActor.run { // Switch to main actor
                self.healthData = healthData // Update health data
            }
        }
    }
    
    func analyzeVision() { // Function to analyze vision health
        guard var healthData = healthData else { return } // Check if health data exists
        let checks = healthData.dailyVisionChecks // Get vision checks
        guard !checks.isEmpty else { return } // Check if checks exist
        let prescription = healthData.visionPrescription // Get prescription
        let analysis = visionAnalyzer.analyze(checks: checks, prescription: prescription) // Analyze vision
        healthData.visionAnalysis = analysis // Store analysis in health data
        self.healthData = healthData // Update health data
    }
    
    func reset() {
        healthData = nil // Clear health data to reset application state
        dietPlan = nil // Clear diet plan to reset application state
        longTermPlan = nil // Clear long-term plan to reset application state
        dailyPlans = [] // Clear daily plans array to reset application state
        currentPlanningSession = nil // Clear current planning session
        calendarScheduleItems = [] // Clear calendar schedule items
        journalAnalysis = nil // Clear journal analysis
    }
}
