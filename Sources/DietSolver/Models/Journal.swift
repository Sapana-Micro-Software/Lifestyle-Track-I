//
//  Journal.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Journal Entry
struct JournalEntry: Codable, Identifiable { // Define JournalEntry struct for individual journal entries
    let id: UUID // Unique identifier for journal entry
    var date: Date // Date of journal entry
    var entryType: EntryType // Type of journal entry (structured or unstructured)
    var structuredData: StructuredJournalData? // Optional structured journal data
    var unstructuredText: String? // Optional unstructured free-form text
    var mood: MoodRating? // Optional mood rating for entry
    var tags: [String] // Array of tags for categorizing entries
    var attachments: [JournalAttachment] // Array of attachments (photos, files, etc.)
    
    enum EntryType: String, Codable { // Enum for journal entry types
        case structured = "Structured" // Structured entry with predefined fields
        case unstructured = "Unstructured" // Unstructured free-form entry
        case mixed = "Mixed" // Mixed entry with both structured and unstructured content
    }
    
    enum MoodRating: String, Codable, CaseIterable { // Enum for mood ratings
        case excellent = "Excellent" // Excellent mood rating
        case good = "Good" // Good mood rating
        case neutral = "Neutral" // Neutral mood rating
        case poor = "Poor" // Poor mood rating
        case veryPoor = "Very Poor" // Very poor mood rating
    }
    
    struct StructuredJournalData: Codable { // Nested struct for structured journal data
        var gratitude: [String] // List of things user is grateful for
        var achievements: [String] // List of achievements for the day
        var challenges: [String] // List of challenges faced
        var lessons: [String] // List of lessons learned
        var goalsProgress: [GoalProgress] // Array of goal progress updates
        var healthMetrics: HealthMetricsEntry? // Optional health metrics entry
        var energyLevel: EnergyLevel? // Optional energy level rating
        var stressLevel: StressLevel? // Optional stress level rating
        var relationships: [RelationshipNote] // Array of relationship notes
        var workLife: WorkLifeEntry? // Optional work-life balance entry
        
        struct GoalProgress: Codable, Identifiable { // Nested struct for goal progress
            let id: UUID // Unique identifier for goal progress
            var goalName: String // Name of the goal
            var progress: Double // Progress percentage (0-100)
            var notes: String? // Optional notes about progress
            var obstacles: [String] // List of obstacles encountered
            
            init(id: UUID = UUID(), goalName: String, progress: Double, notes: String? = nil, obstacles: [String] = []) {
                self.id = id // Initialize unique identifier
                self.goalName = goalName // Initialize goal name
                self.progress = progress // Initialize progress percentage
                self.notes = notes // Initialize optional notes
                self.obstacles = obstacles // Initialize obstacles array
            }
        }
        
        struct HealthMetricsEntry: Codable { // Nested struct for health metrics
            var weight: Double? // Optional weight measurement
            var energyLevel: Double? // Optional energy level (0-10)
            var painLevel: Double? // Optional pain level (0-10)
            var symptoms: [String] // List of symptoms experienced
            var medications: [MedicationEntry] // Array of medication entries
            
            struct MedicationEntry: Codable { // Nested struct for medication
                var name: String // Name of medication
                var dosage: String // Dosage information
                var time: Date // Time medication was taken
                var sideEffects: [String] // List of side effects experienced
            }
        }
        
        enum EnergyLevel: String, Codable, CaseIterable { // Enum for energy levels
            case veryHigh = "Very High" // Very high energy level
            case high = "High" // High energy level
            case moderate = "Moderate" // Moderate energy level
            case low = "Low" // Low energy level
            case veryLow = "Very Low" // Very low energy level
        }
        
        enum StressLevel: String, Codable, CaseIterable { // Enum for stress levels
            case none = "None" // No stress
            case low = "Low" // Low stress level
            case moderate = "Moderate" // Moderate stress level
            case high = "High" // High stress level
            case veryHigh = "Very High" // Very high stress level
        }
        
        struct RelationshipNote: Codable, Identifiable { // Nested struct for relationship notes
            let id: UUID // Unique identifier for relationship note
            var person: String // Name of person
            var interaction: String // Description of interaction
            var quality: InteractionQuality // Quality of interaction
            var notes: String? // Optional additional notes
            
            enum InteractionQuality: String, Codable { // Enum for interaction quality
                case positive = "Positive" // Positive interaction
                case neutral = "Neutral" // Neutral interaction
                case negative = "Negative" // Negative interaction
                case mixed = "Mixed" // Mixed interaction
            }
            
            init(id: UUID = UUID(), person: String, interaction: String, quality: InteractionQuality, notes: String? = nil) {
                self.id = id // Initialize unique identifier
                self.person = person // Initialize person name
                self.interaction = interaction // Initialize interaction description
                self.quality = quality // Initialize interaction quality
                self.notes = notes // Initialize optional notes
            }
        }
        
        struct WorkLifeEntry: Codable { // Nested struct for work-life balance
            var workHours: Double? // Hours worked
            var productivity: ProductivityRating? // Productivity rating
            var workSatisfaction: SatisfactionRating? // Work satisfaction rating
            var workLifeBalance: BalanceRating? // Work-life balance rating
            var accomplishments: [String] // List of work accomplishments
            var challenges: [String] // List of work challenges
            
            enum ProductivityRating: String, Codable, CaseIterable { // Enum for productivity ratings
                case veryHigh = "Very High" // Very high productivity
                case high = "High" // High productivity
                case moderate = "Moderate" // Moderate productivity
                case low = "Low" // Low productivity
                case veryLow = "Very Low" // Very low productivity
            }
            
            enum SatisfactionRating: String, Codable, CaseIterable { // Enum for satisfaction ratings
                case verySatisfied = "Very Satisfied" // Very satisfied
                case satisfied = "Satisfied" // Satisfied
                case neutral = "Neutral" // Neutral
                case dissatisfied = "Dissatisfied" // Dissatisfied
                case veryDissatisfied = "Very Dissatisfied" // Very dissatisfied
            }
            
            enum BalanceRating: String, Codable, CaseIterable { // Enum for balance ratings
                case excellent = "Excellent" // Excellent balance
                case good = "Good" // Good balance
                case fair = "Fair" // Fair balance
                case poor = "Poor" // Poor balance
                case veryPoor = "Very Poor" // Very poor balance
            }
        }
    }
    
    struct JournalAttachment: Codable, Identifiable { // Nested struct for journal attachments
        let id: UUID // Unique identifier for attachment
        var type: AttachmentType // Type of attachment
        var url: String? // URL or path to attachment
        var description: String? // Optional description of attachment
        
        enum AttachmentType: String, Codable { // Enum for attachment types
            case photo = "Photo" // Photo attachment
            case video = "Video" // Video attachment
            case audio = "Audio" // Audio attachment
            case document = "Document" // Document attachment
            case link = "Link" // Web link attachment
        }
        
        init(id: UUID = UUID(), type: AttachmentType, url: String? = nil, description: String? = nil) {
            self.id = id // Initialize unique identifier
            self.type = type // Initialize attachment type
            self.url = url // Initialize optional URL
            self.description = description // Initialize optional description
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), entryType: EntryType = .unstructured, structuredData: StructuredJournalData? = nil, unstructuredText: String? = nil, mood: MoodRating? = nil, tags: [String] = [], attachments: [JournalAttachment] = []) {
        self.id = id // Initialize unique identifier
        self.date = date // Initialize entry date
        self.entryType = entryType // Initialize entry type
        self.structuredData = structuredData // Initialize structured data
        self.unstructuredText = unstructuredText // Initialize unstructured text
        self.mood = mood // Initialize mood rating
        self.tags = tags // Initialize tags array
        self.attachments = attachments // Initialize attachments array
    }
}

// MARK: - Journal Collection
struct JournalCollection: Codable { // Define JournalCollection struct for managing journal entries
    var entries: [JournalEntry] // Array of all journal entries
    var categories: [String] // Array of journal categories
    var tags: [String] // Array of all tags used across entries
    
    init(entries: [JournalEntry] = [], categories: [String] = [], tags: [String] = []) {
        self.entries = entries // Initialize entries array
        self.categories = categories // Initialize categories array
        self.tags = tags // Initialize tags array
    }
    
    func entriesForDate(_ date: Date) -> [JournalEntry] { // Function to get entries for specific date
        let calendar = Calendar.current // Get calendar instance
        return entries.filter { // Filter entries matching date
            calendar.isDate($0.date, inSameDayAs: date) // Check if entry date matches
        }
    }
    
    func entriesForWeek(containing date: Date) -> [JournalEntry] { // Function to get entries for week
        let calendar = Calendar.current // Get calendar instance
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] } // Get week interval
        return entries.filter { // Filter entries in week interval
            weekInterval.contains($0.date) // Check if entry date is in interval
        }
    }
    
    func entriesForMonth(containing date: Date) -> [JournalEntry] { // Function to get entries for month
        let calendar = Calendar.current // Get calendar instance
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] } // Get month interval
        return entries.filter { // Filter entries in month interval
            monthInterval.contains($0.date) // Check if entry date is in interval
        }
    }
}
