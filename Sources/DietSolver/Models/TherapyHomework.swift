//
//  TherapyHomework.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Therapy Assignment
struct TherapyAssignment: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var assignmentType: AssignmentType
    var dueDate: Date?
    var assignedDate: Date
    var completedDate: Date?
    var status: AssignmentStatus
    var instructions: String
    var relatedTechnique: TherapyTechnique?
    var progress: AssignmentProgress?
    var notes: String?
    
    enum AssignmentType: String, Codable, CaseIterable {
        case thoughtRecord = "Thought Record"
        case behavioralExperiment = "Behavioral Experiment"
        case mindfulnessPractice = "Mindfulness Practice"
        case gratitudeExercise = "Gratitude Exercise"
        case emotionRegulation = "Emotion Regulation"
        case goalSetting = "Goal Setting"
        case journaling = "Journaling"
        case breathingExercise = "Breathing Exercise"
        case other = "Other"
    }
    
    enum AssignmentStatus: String, Codable {
        case assigned = "Assigned"
        case inProgress = "In Progress"
        case completed = "Completed"
        case overdue = "Overdue"
        case cancelled = "Cancelled"
    }
    
    struct AssignmentProgress: Codable {
        var completionPercentage: Double // 0.0 to 1.0
        var timeSpent: TimeInterval? // in seconds
        var checkIns: [Date]
        var lastUpdated: Date
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        assignmentType: AssignmentType,
        dueDate: Date? = nil,
        assignedDate: Date = Date(),
        completedDate: Date? = nil,
        status: AssignmentStatus = .assigned,
        instructions: String,
        relatedTechnique: TherapyTechnique? = nil,
        progress: AssignmentProgress? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.assignmentType = assignmentType
        self.dueDate = dueDate
        self.assignedDate = assignedDate
        self.completedDate = completedDate
        self.status = status
        self.instructions = instructions
        self.relatedTechnique = relatedTechnique
        self.progress = progress
        self.notes = notes
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, status != .completed, status != .cancelled else {
            return false
        }
        return Date() > dueDate
    }
    
    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: dueDate).day
    }
}

// MARK: - Therapy Homework Manager
class TherapyHomeworkManager: ObservableObject {
    static let shared = TherapyHomeworkManager()
    
    @Published var assignments: [TherapyAssignment] = []
    
    private let assignmentsKey = "therapy_assignments"
    
    private init() {
        loadAssignments()
    }
    
    // MARK: - Assignment Management
    
    func assignHomework(
        title: String,
        description: String,
        type: TherapyAssignment.AssignmentType,
        dueDate: Date? = nil,
        instructions: String,
        technique: TherapyTechnique? = nil
    ) -> TherapyAssignment {
        let assignment = TherapyAssignment(
            title: title,
            description: description,
            assignmentType: type,
            dueDate: dueDate,
            instructions: instructions,
            relatedTechnique: technique
        )
        
        assignments.append(assignment)
        saveAssignments()
        return assignment
    }
    
    func updateAssignment(_ assignment: TherapyAssignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index] = assignment
            saveAssignments()
        }
    }
    
    func completeAssignment(_ assignmentId: UUID, notes: String? = nil) {
        if let index = assignments.firstIndex(where: { $0.id == assignmentId }) {
            assignments[index].status = .completed
            assignments[index].completedDate = Date()
            assignments[index].notes = notes
            saveAssignments()
        }
    }
    
    func cancelAssignment(_ assignmentId: UUID) {
        if let index = assignments.firstIndex(where: { $0.id == assignmentId }) {
            assignments[index].status = .cancelled
            saveAssignments()
        }
    }
    
    func updateProgress(_ assignmentId: UUID, completionPercentage: Double, timeSpent: TimeInterval? = nil) {
        if let index = assignments.firstIndex(where: { $0.id == assignmentId }) {
            let currentProgress = assignments[index].progress ?? TherapyAssignment.AssignmentProgress(
                completionPercentage: 0.0,
                timeSpent: nil,
                checkIns: [],
                lastUpdated: Date()
            )
            
            var updatedCheckIns = currentProgress.checkIns
            updatedCheckIns.append(Date())
            
            assignments[index].progress = TherapyAssignment.AssignmentProgress(
                completionPercentage: min(1.0, max(0.0, completionPercentage)),
                timeSpent: timeSpent ?? currentProgress.timeSpent,
                checkIns: updatedCheckIns,
                lastUpdated: Date()
            )
            
            if completionPercentage >= 1.0 {
                assignments[index].status = .completed
                assignments[index].completedDate = Date()
            } else if assignments[index].status == .assigned {
                assignments[index].status = .inProgress
            }
            
            // Check for overdue
            if assignments[index].isOverdue && assignments[index].status != .completed {
                assignments[index].status = .overdue
            }
            
            saveAssignments()
        }
    }
    
    // MARK: - Query Methods
    
    func getActiveAssignments() -> [TherapyAssignment] {
        return assignments.filter { $0.status != .completed && $0.status != .cancelled }
    }
    
    func getOverdueAssignments() -> [TherapyAssignment] {
        return assignments.filter { $0.isOverdue && $0.status != .completed && $0.status != .cancelled }
    }
    
    func getAssignmentsByType(_ type: TherapyAssignment.AssignmentType) -> [TherapyAssignment] {
        return assignments.filter { $0.assignmentType == type }
    }
    
    func getCompletedAssignments() -> [TherapyAssignment] {
        return assignments.filter { $0.status == .completed }
    }
    
    func getCompletionRate() -> Double {
        guard !assignments.isEmpty else { return 0.0 }
        let completed = assignments.filter { $0.status == .completed }.count
        return Double(completed) / Double(assignments.count)
    }
    
    // MARK: - Persistence
    
    private func saveAssignments() {
        if let encoded = try? JSONEncoder().encode(assignments) {
            UserDefaults.standard.set(encoded, forKey: assignmentsKey)
        }
    }
    
    private func loadAssignments() {
        if let data = UserDefaults.standard.data(forKey: assignmentsKey),
           let decoded = try? JSONDecoder().decode([TherapyAssignment].self, from: data) {
            assignments = decoded
            // Update overdue status
            for index in assignments.indices {
                if assignments[index].isOverdue && assignments[index].status != .completed && assignments[index].status != .cancelled {
                    assignments[index].status = .overdue
                }
            }
        }
    }
}
