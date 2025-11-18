//
//  CalendarSchedule.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
import EventKit // Import EventKit framework for calendar and event management

// MARK: - Calendar Schedule Item
struct CalendarScheduleItem: Codable, Identifiable { // Define CalendarScheduleItem struct for calendar events
    let id: UUID // Unique identifier for schedule item
    var title: String // Title of calendar event
    var startDate: Date // Start date and time of event
    var endDate: Date // End date and time of event
    var location: String? // Optional location for event
    var notes: String? // Optional notes or description for event
    var category: ScheduleCategory // Category of schedule item
    var priority: Priority // Priority level of schedule item
    var isRecurring: Bool // Whether event repeats
    var recurrenceRule: RecurrenceRule? // Optional recurrence rule for repeating events
    var reminders: [Reminder] // Array of reminders for event
    var isAllDay: Bool // Whether event is all-day event
    
    enum ScheduleCategory: String, Codable, CaseIterable { // Enum for schedule categories
        case meal = "Meal" // Meal-related schedule item
        case exercise = "Exercise" // Exercise-related schedule item
        case meditation = "Meditation" // Meditation-related schedule item
        case sleep = "Sleep" // Sleep-related schedule item
        case work = "Work" // Work-related schedule item
        case personal = "Personal" // Personal activity schedule item
        case health = "Health" // Health checkup or appointment
        case planning = "Planning" // Planning or review session
        case journal = "Journal" // Journal entry time
        case other = "Other" // Other category schedule item
    }
    
    enum Priority: String, Codable, CaseIterable { // Enum for priority levels
        case low = "Low" // Low priority schedule item
        case medium = "Medium" // Medium priority schedule item
        case high = "High" // High priority schedule item
        case critical = "Critical" // Critical priority schedule item
    }
    
    struct RecurrenceRule: Codable { // Nested struct for recurrence rules
        var frequency: Frequency // Frequency of recurrence
        var interval: Int // Interval between recurrences
        var endDate: Date? // Optional end date for recurrence
        var daysOfWeek: [Int]? // Optional days of week (1-7, Sunday=1)
        var dayOfMonth: Int? // Optional day of month for monthly recurrence
        
        enum Frequency: String, Codable { // Enum for recurrence frequency
            case daily = "Daily" // Daily recurrence
            case weekly = "Weekly" // Weekly recurrence
            case monthly = "Monthly" // Monthly recurrence
            case yearly = "Yearly" // Yearly recurrence
        }
    }
    
    struct Reminder: Codable, Identifiable { // Nested struct for reminders
        let id: UUID // Unique identifier for reminder
        var minutesBefore: Int // Minutes before event to remind
        var isEnabled: Bool // Whether reminder is enabled
        
        init(id: UUID = UUID(), minutesBefore: Int, isEnabled: Bool = true) {
            self.id = id // Initialize unique identifier
            self.minutesBefore = minutesBefore // Initialize minutes before event
            self.isEnabled = isEnabled // Initialize enabled status
        }
    }
    
    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, location: String? = nil, notes: String? = nil, category: ScheduleCategory = .other, priority: Priority = .medium, isRecurring: Bool = false, recurrenceRule: RecurrenceRule? = nil, reminders: [Reminder] = [], isAllDay: Bool = false) {
        self.id = id // Initialize unique identifier
        self.title = title // Initialize event title
        self.startDate = startDate // Initialize start date
        self.endDate = endDate // Initialize end date
        self.location = location // Initialize optional location
        self.notes = notes // Initialize optional notes
        self.category = category // Initialize category
        self.priority = priority // Initialize priority
        self.isRecurring = isRecurring // Initialize recurring flag
        self.recurrenceRule = recurrenceRule // Initialize recurrence rule
        self.reminders = reminders // Initialize reminders array
        self.isAllDay = isAllDay // Initialize all-day flag
    }
}

// MARK: - Calendar Scheduler
class CalendarScheduler { // Define CalendarScheduler class for managing calendar events
    private let eventStore = EKEventStore() // Private EventKit event store instance
    
    func requestCalendarAccess() async -> Bool { // Async function to request calendar access permission
        let status = EKEventStore.authorizationStatus(for: .event) // Get current authorization status
        switch status { // Switch on authorization status
        case .authorized: // If already authorized
            return true // Return true for authorized access
        case .notDetermined: // If permission not yet requested
            do { // Try to request access
                return try await eventStore.requestAccess(to: .event) // Request access and return result
            } catch { // Catch errors
                return false // Return false on error
            }
        default: // For denied or restricted cases
            return false // Return false for denied access
        }
    }
    
    func createEvent(from scheduleItem: CalendarScheduleItem, in calendar: EKCalendar? = nil) async throws -> EKEvent { // Async function to create calendar event from schedule item
        let hasAccess = await requestCalendarAccess() // Request calendar access
        guard hasAccess else { // Check if access granted
            throw CalendarSchedulerError.accessDenied // Throw access denied error
        }
        
        let event = EKEvent(eventStore: eventStore) // Create new EventKit event
        event.title = scheduleItem.title // Set event title from schedule item
        event.startDate = scheduleItem.startDate // Set event start date
        event.endDate = scheduleItem.endDate // Set event end date
        event.location = scheduleItem.location // Set optional location
        event.notes = scheduleItem.notes // Set optional notes
        event.isAllDay = scheduleItem.isAllDay // Set all-day flag
        
        if let calendar = calendar { // Check if specific calendar provided
            event.calendar = calendar // Set event calendar
        } else { // If no calendar specified
            event.calendar = eventStore.defaultCalendarForNewEvents // Use default calendar
        }
        
        if scheduleItem.isRecurring, let rule = scheduleItem.recurrenceRule { // Check if recurring with rule
            event.recurrenceRules = [createRecurrenceRule(from: rule)] // Create and set recurrence rule
        }
        
        for reminder in scheduleItem.reminders where reminder.isEnabled { // Loop through enabled reminders
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminder.minutesBefore * 60)) // Create alarm
            event.addAlarm(alarm) // Add alarm to event
        }
        
        try eventStore.save(event, span: .thisEvent) // Save event to calendar
        return event // Return created event
    }
    
    func createEvents(from scheduleItems: [CalendarScheduleItem], in calendar: EKCalendar? = nil) async throws -> [EKEvent] { // Async function to create multiple events
        var createdEvents: [EKEvent] = [] // Initialize array for created events
        for item in scheduleItems { // Loop through schedule items
            let event = try await createEvent(from: item, in: calendar) // Create event from item
            createdEvents.append(event) // Add event to array
        }
        return createdEvents // Return array of created events
    }
    
    private func createRecurrenceRule(from rule: CalendarScheduleItem.RecurrenceRule) -> EKRecurrenceRule { // Private function to create EventKit recurrence rule
        var recurrenceEnd: EKRecurrenceEnd? = nil // Initialize optional recurrence end
        if let endDate = rule.endDate { // Check if end date provided
            recurrenceEnd = EKRecurrenceEnd(end: endDate) // Create recurrence end
        }
        
        let frequency: EKRecurrenceFrequency // Declare recurrence frequency
        switch rule.frequency { // Switch on rule frequency
        case .daily: // For daily frequency
            frequency = .daily // Set daily frequency
        case .weekly: // For weekly frequency
            frequency = .weekly // Set weekly frequency
        case .monthly: // For monthly frequency
            frequency = .monthly // Set monthly frequency
        case .yearly: // For yearly frequency
            frequency = .yearly // Set yearly frequency
        }
        
        var daysOfWeek: [EKRecurrenceDayOfWeek]? = nil // Initialize optional days of week
        if let days = rule.daysOfWeek { // Check if days of week provided
            daysOfWeek = days.compactMap { day -> EKRecurrenceDayOfWeek? in // Map to EventKit days
                guard day >= 1 && day <= 7 else { return nil } // Validate day range
                return EKRecurrenceDayOfWeek(EKWeekday(rawValue: day) ?? .monday) // Convert to EventKit weekday
            }
        }
        
        let daysOfMonth: [NSNumber]? = rule.dayOfMonth.map { [NSNumber(value: $0)] } // Convert to NSNumber array
        let ekRule = EKRecurrenceRule( // Create EventKit recurrence rule
            recurrenceWith: frequency, // Set frequency
            interval: rule.interval, // Set interval
            daysOfTheWeek: daysOfWeek, // Set days of week
            daysOfTheMonth: daysOfMonth, // Set day of month
            monthsOfTheYear: nil, // No specific months
            weeksOfTheYear: nil, // No specific weeks
            daysOfTheYear: nil, // No specific days of year
            setPositions: nil, // No set positions
            end: recurrenceEnd // Set recurrence end
        )
        return ekRule // Return EventKit recurrence rule
    }
    
    func getAvailableCalendars() -> [EKCalendar] { // Function to get available calendars
        return eventStore.calendars(for: .event) // Return all event calendars
    }
    
    enum CalendarSchedulerError: Error { // Enum for calendar scheduler errors
        case accessDenied // Access denied error
        case eventCreationFailed // Event creation failed error
        case calendarNotFound // Calendar not found error
    }
}
