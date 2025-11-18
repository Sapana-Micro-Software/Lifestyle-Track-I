//
//  NotificationManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
import UserNotifications

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
    }
    
    // MARK: - Check Authorization Status
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Meal Reminder
    func scheduleMealReminder(mealName: String, date: Date, minutesBefore: Int = 15) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Exercise Reminder
    func scheduleExerciseReminder(activityName: String, date: Date, minutesBefore: Int = 30) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Water Reminder
    func scheduleWaterReminder(date: Date, intervalMinutes: Int = 120) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Sleep Reminder
    func scheduleSleepReminder(targetBedtime: Date) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Medication Reminder
    func scheduleMedicationReminder(medicationName: String, time: Date, repeats: Bool = true) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Health Check-in
    func scheduleHealthCheckIn(date: Date, frequency: HealthCheckInFrequency = .weekly) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Plan Milestone Notification
    func scheduleMilestoneNotification(milestoneName: String, date: Date) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Schedule Badge Achievement Notification
    func scheduleBadgeNotification(badgeName: String) {
        guard notificationsEnabled else { return }
        
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
    }
    
    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Cancel Specific Notification
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}

// MARK: - Health Check-in Frequency
enum HealthCheckInFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}
