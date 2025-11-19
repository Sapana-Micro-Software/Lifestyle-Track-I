//
//  SmartReminderManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
import UserNotifications

// MARK: - Reminder Pattern
struct ReminderPattern: Codable {
    var preferredTimeOfDay: TimeOfDay
    var frequency: ReminderFrequency
    var lastReminderDate: Date?
    var reminderCount: Int
    var effectivenessScore: Double // 0.0 to 1.0 based on user engagement
    
    enum TimeOfDay: String, Codable, CaseIterable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case flexible = "Flexible"
    }
    
    enum ReminderFrequency: String, Codable {
        case daily = "Daily"
        case everyOtherDay = "Every Other Day"
        case weekly = "Weekly"
        case asNeeded = "As Needed"
    }
}

// MARK: - Smart Reminder Manager
class SmartReminderManager: ObservableObject {
    static let shared = SmartReminderManager()
    
    @Published var reminderPattern: ReminderPattern
    @Published var isEnabled: Bool = true
    
    private let notificationManager = NotificationManager.shared
    private let chatbotManager = PsychologistChatbotManager.shared
    private let reminderPatternKey = "smart_reminder_pattern"
    private let reminderEnabledKey = "smart_reminder_enabled"
    
    private init() {
        self.reminderPattern = ReminderPattern(
            preferredTimeOfDay: .flexible,
            frequency: .daily,
            lastReminderDate: nil,
            reminderCount: 0,
            effectivenessScore: 0.5
        )
        loadSettings()
    }
    
    // MARK: - Pattern Analysis
    
    func analyzeOptimalReminderTime(from sessions: [ConversationSession]) -> ReminderPattern.TimeOfDay {
        guard !sessions.isEmpty else { return .flexible }
        
        var morningCount = 0
        var afternoonCount = 0
        var eveningCount = 0
        
        let calendar = Calendar.current
        
        for session in sessions {
            let hour = calendar.component(.hour, from: session.startDate)
            if hour >= 6 && hour < 12 {
                morningCount += 1
            } else if hour >= 12 && hour < 18 {
                afternoonCount += 1
            } else {
                eveningCount += 1
            }
        }
        
        if morningCount > afternoonCount && morningCount > eveningCount {
            return .morning
        } else if afternoonCount > eveningCount {
            return .afternoon
        } else {
            return .evening
        }
    }
    
    func calculateOptimalFrequency(from sessions: [ConversationSession]) -> ReminderPattern.ReminderFrequency {
        guard sessions.count >= 3 else { return .daily }
        
        let sortedSessions = sessions.sorted { $0.startDate < $1.startDate }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sortedSessions.count {
            let interval = sortedSessions[i].startDate.timeIntervalSince(sortedSessions[i-1].startDate)
            intervals.append(interval)
        }
        
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        let days = averageInterval / (24 * 60 * 60)
        
        if days < 1.5 {
            return .daily
        } else if days < 3.5 {
            return .everyOtherDay
        } else {
            return .weekly
        }
    }
    
    // MARK: - Reminder Scheduling
    
    func scheduleSmartReminders() {
        guard isEnabled else { return }
        
        // Cancel existing reminders
        cancelAllReminders()
        
        // Analyze patterns from conversation history
        let sessions = chatbotManager.userProfile.conversationHistory
        let optimalTime = analyzeOptimalReminderTime(from: sessions)
        let optimalFrequency = calculateOptimalFrequency(from: sessions)
        
        // Update pattern
        reminderPattern.preferredTimeOfDay = optimalTime
        reminderPattern.frequency = optimalFrequency
        
        // Schedule based on pattern
        switch reminderPattern.frequency {
        case .daily:
            scheduleDailyReminder(at: optimalTime)
        case .everyOtherDay:
            scheduleEveryOtherDayReminder(at: optimalTime)
        case .weekly:
            scheduleWeeklyReminder(at: optimalTime)
        case .asNeeded:
            scheduleAsNeededReminders()
        }
        
        saveSettings()
    }
    
    private func scheduleDailyReminder(at timeOfDay: ReminderPattern.TimeOfDay) {
        let hour = hourForTimeOfDay(timeOfDay)
        let minute = minuteForTimeOfDay(timeOfDay)
        
        notificationManager.scheduleDailyReminder(
            identifier: "smart_checkin_daily",
            title: "Daily Check-in",
            body: "How are you feeling today? I'm here to support you.",
            hour: hour,
            minute: minute
        )
    }
    
    private func scheduleEveryOtherDayReminder(at timeOfDay: ReminderPattern.TimeOfDay) {
        let hour = hourForTimeOfDay(timeOfDay)
        let minute = minuteForTimeOfDay(timeOfDay)
        
        // Schedule for today and tomorrow, then repeat
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset * 2, to: now) {
                var components = calendar.dateComponents([.year, .month, .day], from: date)
                components.hour = hour
                components.minute = minute
                
                if let scheduledDate = calendar.date(from: components), scheduledDate > now {
                    notificationManager.scheduleNotification(
                        identifier: "smart_checkin_\(dayOffset)",
                        title: "Check-in Reminder",
                        body: "How are you doing? I'm here if you need to talk.",
                        date: scheduledDate
                    )
                }
            }
        }
    }
    
    private func scheduleWeeklyReminder(at timeOfDay: ReminderPattern.TimeOfDay) {
        let hour = hourForTimeOfDay(timeOfDay)
        let minute = minuteForTimeOfDay(timeOfDay)
        
        notificationManager.scheduleWeeklyReminder(
            identifier: "smart_checkin_weekly",
            title: "Weekly Check-in",
            body: "Let's check in on your progress this week.",
            weekday: Calendar.current.component(.weekday, from: Date()),
            hour: hour,
            minute: minute
        )
    }
    
    private func scheduleAsNeededReminders() {
        // Schedule reminders based on inactivity detection
        let sessions = chatbotManager.userProfile.conversationHistory
        guard let lastSession = sessions.last else {
            // No sessions yet - schedule initial reminder
            scheduleInitialReminder()
            return
        }
        
        let daysSinceLastSession = Calendar.current.dateComponents([.day], from: lastSession.startDate, to: Date()).day ?? 0
        
        if daysSinceLastSession >= 3 {
            // User inactive - schedule gentle reminder
            scheduleInactivityReminder(daysInactive: daysSinceLastSession)
        }
    }
    
    private func scheduleInitialReminder() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        notificationManager.scheduleNotification(
            identifier: "smart_checkin_initial",
            title: "Welcome!",
            body: "I'm here to support you. Feel free to start a conversation whenever you're ready.",
            date: tomorrow
        )
    }
    
    private func scheduleInactivityReminder(daysInactive: Int) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let body = daysInactive >= 7 
            ? "It's been a while since we last talked. I'm here if you need support."
            : "Haven't heard from you in \(daysInactive) days. How are you doing?"
        
        notificationManager.scheduleNotification(
            identifier: "smart_checkin_inactivity",
            title: "Check-in Reminder",
            body: body,
            date: tomorrow
        )
    }
    
    // MARK: - Crisis Follow-up
    
    func scheduleCrisisFollowUp() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 10 // 10 AM
        components.minute = 0
        
        if let followUpDate = Calendar.current.date(from: components) {
            notificationManager.scheduleNotification(
                identifier: "crisis_followup",
                title: "Follow-up Check-in",
                body: "I wanted to check in with you. How are you feeling today?",
                date: followUpDate
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func hourForTimeOfDay(_ timeOfDay: ReminderPattern.TimeOfDay) -> Int {
        switch timeOfDay {
        case .morning: return 9
        case .afternoon: return 14
        case .evening: return 19
        case .flexible: return 10
        }
    }
    
    private func minuteForTimeOfDay(_ timeOfDay: ReminderPattern.TimeOfDay) -> Int {
        return 0
    }
    
    func cancelAllReminders() {
        notificationManager.cancelNotification(identifier: "smart_checkin_daily")
        notificationManager.cancelNotification(identifier: "smart_checkin_weekly")
        notificationManager.cancelNotification(identifier: "smart_checkin_initial")
        notificationManager.cancelNotification(identifier: "smart_checkin_inactivity")
        
        // Cancel numbered reminders
        for i in 0..<7 {
            notificationManager.cancelNotification(identifier: "smart_checkin_\(i)")
        }
    }
    
    // MARK: - Settings
    
    func updateEffectiveness(engagement: Bool) {
        if engagement {
            reminderPattern.effectivenessScore = min(1.0, reminderPattern.effectivenessScore + 0.1)
        } else {
            reminderPattern.effectivenessScore = max(0.0, reminderPattern.effectivenessScore - 0.05)
        }
        reminderPattern.reminderCount += 1
        saveSettings()
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            cancelAllReminders()
        } else {
            scheduleSmartReminders()
        }
        saveSettings()
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(reminderPattern) {
            UserDefaults.standard.set(encoded, forKey: reminderPatternKey)
        }
        UserDefaults.standard.set(isEnabled, forKey: reminderEnabledKey)
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: reminderPatternKey),
           let decoded = try? JSONDecoder().decode(ReminderPattern.self, from: data) {
            reminderPattern = decoded
        }
        isEnabled = UserDefaults.standard.bool(forKey: reminderEnabledKey)
    }
}
