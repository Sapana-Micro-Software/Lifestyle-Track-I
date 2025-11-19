//
//  NotificationManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif
#if os(macOS)
import AppKit
#endif

// MARK: - Notification Manager
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled: Bool = false
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Request Authorization
    func requestAuthorization() async -> Bool {
        #if os(iOS) || os(watchOS) || os(tvOS)
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.notificationsEnabled = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
        #elseif os(macOS)
        // macOS doesn't support UNUserNotificationCenter in the same way
        // For now, we'll use a simple approach that doesn't require authorization
        await MainActor.run {
            self.notificationsEnabled = true
        }
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Check Authorization Status
    private func checkAuthorizationStatus() {
        #if os(iOS) || os(watchOS) || os(tvOS)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
        #elseif os(macOS)
        // On macOS, assume notifications are available
        DispatchQueue.main.async {
            self.notificationsEnabled = true
        }
        #endif
    }
    
    // MARK: - Schedule Meal Reminder
    func scheduleMealReminder(mealName: String, date: Date, minutesBefore: Int = 15) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Meal Time!"
        content.body = "\(mealName) in \(minutesBefore) minutes"
        content.sound = .default
        content.categoryIdentifier = "MEAL_REMINDER"
        content.userInfo = ["mealName": mealName, "type": "meal"]
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: date) ?? date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "meal-\(mealName)-\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling meal reminder: \(error)")
            }
        }
        #elseif os(macOS)
        // On macOS, use NSUserNotification (deprecated but functional)
        // For now, just log - can be enhanced with NSUserNotification if needed
        print("Meal reminder scheduled: \(mealName) at \(date)")
        #endif
    }
    
    // MARK: - Schedule Exercise Reminder
    func scheduleExerciseReminder(activityName: String, date: Date, minutesBefore: Int = 30) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Exercise Time!"
        content.body = "Time for \(activityName)"
        content.sound = .default
        content.categoryIdentifier = "EXERCISE_REMINDER"
        content.userInfo = ["activityName": activityName, "type": "exercise"]
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: date) ?? date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "exercise-\(activityName)-\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling exercise reminder: \(error)")
            }
        }
        #elseif os(macOS)
        print("Exercise reminder scheduled: \(activityName) at \(date)")
        #endif
    }
    
    // MARK: - Schedule Water Reminder
    func scheduleWaterReminder(date: Date, intervalMinutes: Int = 120) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "Time to drink some water"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"
        content.userInfo = ["type": "water"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(intervalMinutes * 60), repeats: true)
        
        let request = UNNotificationRequest(identifier: "water-reminder-\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling water reminder: \(error)")
            }
        }
        #elseif os(macOS)
        print("Water reminder scheduled: every \(intervalMinutes) minutes")
        #endif
    }
    
    // MARK: - Schedule Sleep Reminder
    func scheduleSleepReminder(targetBedtime: Date) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Time to Wind Down"
        content.body = "Your target bedtime is approaching. Start your evening routine."
        content.sound = .default
        content.categoryIdentifier = "SLEEP_REMINDER"
        content.userInfo = ["type": "sleep"]
        
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: targetBedtime) ?? targetBedtime
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate), repeats: true)
        
        let request = UNNotificationRequest(identifier: "sleep-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling sleep reminder: \(error)")
            }
        }
        #elseif os(macOS)
        print("Sleep reminder scheduled for: \(targetBedtime)")
        #endif
    }
    
    // MARK: - Schedule Medication Reminder
    func scheduleMedicationReminder(medicationName: String, time: Date, repeats: Bool = true) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medicationName)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = ["medicationName": medicationName, "type": "medication"]
        
        let trigger: UNNotificationTrigger
        if repeats {
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: time), repeats: true)
        } else {
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time), repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: "medication-\(medicationName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling medication reminder: \(error)")
            }
        }
        #elseif os(macOS)
        print("Medication reminder scheduled: \(medicationName) at \(time), repeats: \(repeats)")
        #endif
    }
    
    // MARK: - Schedule Health Check-in
    func scheduleHealthCheckIn(date: Date, frequency: HealthCheckInFrequency = .weekly) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Health Check-in"
        content.body = "How are you feeling today? Log your health metrics."
        content.sound = .default
        content.categoryIdentifier = "HEALTH_CHECKIN"
        content.userInfo = ["type": "checkin"]
        
        let trigger: UNNotificationTrigger
        switch frequency {
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date), repeats: true)
        case .weekly:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute], from: date), repeats: true)
        case .monthly:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .hour, .minute], from: date), repeats: true)
        }
        
        let request = UNNotificationRequest(identifier: "health-checkin-\(frequency.rawValue)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling health check-in: \(error)")
            }
        }
        #elseif os(macOS)
        print("Health check-in scheduled: \(frequency.rawValue) at \(date)")
        #endif
    }
    
    // MARK: - Schedule Plan Milestone Notification
    func scheduleMilestoneNotification(milestoneName: String, date: Date) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Milestone Achieved! 🎉"
        content.body = "Congratulations! You've reached: \(milestoneName)"
        content.sound = .default
        content.categoryIdentifier = "MILESTONE"
        content.userInfo = ["milestoneName": milestoneName, "type": "milestone"]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        
        let request = UNNotificationRequest(identifier: "milestone-\(milestoneName)-\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling milestone notification: \(error)")
            }
        }
        #elseif os(macOS)
        print("Milestone notification scheduled: \(milestoneName) at \(date)")
        #endif
    }
    
    // MARK: - Schedule Badge Achievement Notification
    func scheduleBadgeNotification(badgeName: String) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = "Badge Earned! 🏆"
        content.body = "You've earned the \(badgeName) badge!"
        content.sound = .default
        content.categoryIdentifier = "BADGE"
        content.userInfo = ["badgeName": badgeName, "type": "badge"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "badge-\(badgeName)-\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling badge notification: \(error)")
            }
        }
        #elseif os(macOS)
        print("Badge notification: \(badgeName)")
        #endif
    }
    
    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        #if os(iOS) || os(watchOS) || os(tvOS)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        #elseif os(macOS)
        print("Notifications cancelled (macOS)")
        #endif
    }
    
    // MARK: - Cancel Specific Notification
    // MARK: - Schedule Generic Notification
    func scheduleNotification(identifier: String, title: String, body: String, date: Date) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["identifier": identifier]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
        #elseif os(macOS)
        print("Notification scheduled: \(title) at \(date)")
        #endif
    }
    
    // MARK: - Schedule Daily Reminder
    func scheduleDailyReminder(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["identifier": identifier, "type": "daily_reminder"]
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
        #elseif os(macOS)
        print("Daily reminder scheduled: \(title) at \(hour):\(minute)")
        #endif
    }
    
    // MARK: - Schedule Weekly Reminder
    func scheduleWeeklyReminder(identifier: String, title: String, body: String, weekday: Int, hour: Int, minute: Int) {
        guard notificationsEnabled else { return }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["identifier": identifier, "type": "weekly_reminder"]
        
        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly reminder: \(error)")
            }
        }
        #elseif os(macOS)
        print("Weekly reminder scheduled: \(title) on weekday \(weekday) at \(hour):\(minute)")
        #endif
    }
    
    func cancelNotification(identifier: String) {
        #if os(iOS) || os(watchOS) || os(tvOS)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        #elseif os(macOS)
        print("Notification cancelled: \(identifier)")
        #endif
    }
    
    // MARK: - Get Pending Notifications
    #if os(iOS) || os(watchOS) || os(tvOS)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    #else
    func getPendingNotifications() async -> [Any] {
        return []
    }
    #endif
}

// MARK: - Health Check-in Frequency
enum HealthCheckInFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}
