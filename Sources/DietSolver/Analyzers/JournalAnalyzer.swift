//
//  JournalAnalyzer.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Journal Analysis Report
struct JournalAnalysisReport: Codable { // Define JournalAnalysisReport struct for journal analysis results
    var analysisDate: Date // Date of analysis
    var timeRange: DateInterval // Time range of analyzed entries
    var entryCount: Int // Total number of entries analyzed
    var structuredEntryCount: Int // Number of structured entries
    var unstructuredEntryCount: Int // Number of unstructured entries
    var mixedEntryCount: Int // Number of mixed entries
    var moodTrend: MoodTrend // Mood trend analysis
    var gratitudeThemes: [String] // Common gratitude themes
    var achievementThemes: [String] // Common achievement themes
    var challengeThemes: [String] // Common challenge themes
    var lessonThemes: [String] // Common lesson themes
    var healthMetricsTrend: HealthMetricsTrend? // Optional health metrics trend
    var energyLevelTrend: EnergyLevelTrend? // Optional energy level trend
    var stressLevelTrend: StressLevelTrend? // Optional stress level trend
    var relationshipInsights: [RelationshipInsight] // Relationship insights from entries
    var workLifeInsights: WorkLifeInsights? // Optional work-life balance insights
    var goalProgressSummary: [GoalProgressSummary] // Summary of goal progress
    var keyInsights: [String] // Key insights from analysis
    var recommendations: [String] // Recommendations based on analysis
    
    struct MoodTrend: Codable { // Nested struct for mood trend
        var averageMood: Double // Average mood rating (1-5 scale)
        var moodDistribution: [String: Int] // Distribution of mood ratings
        var trendDirection: TrendDirection // Direction of mood trend
        var mostCommonMood: JournalEntry.MoodRating? // Most common mood rating
        
        enum TrendDirection: String, Codable { // Enum for trend direction
            case improving = "Improving" // Mood is improving
            case declining = "Declining" // Mood is declining
            case stable = "Stable" // Mood is stable
            case fluctuating = "Fluctuating" // Mood is fluctuating
        }
    }
    
    struct HealthMetricsTrend: Codable { // Nested struct for health metrics trend
        var weightEntries: [WeightEntry] // Array of weight entries over time
        var energyLevelEntries: [EnergyEntry] // Array of energy level entries
        var painLevelEntries: [PainEntry] // Array of pain level entries
        var commonSymptoms: [String] // Common symptoms reported
        var medicationFrequency: [String: Int] // Frequency of medication mentions
        
        struct WeightEntry: Codable { // Nested struct for weight entry
            var date: Date // Date of weight entry
            var weight: Double // Weight value
        }
        
        struct EnergyEntry: Codable { // Nested struct for energy entry
            var date: Date // Date of energy entry
            var level: Double // Energy level (0-10)
        }
        
        struct PainEntry: Codable { // Nested struct for pain entry
            var date: Date // Date of pain entry
            var level: Double // Pain level (0-10)
        }
    }
    
    struct EnergyLevelTrend: Codable { // Nested struct for energy level trend
        var averageLevel: Double // Average energy level
        var levelDistribution: [String: Int] // Distribution of energy levels
        var trendDirection: TrendDirection // Direction of energy trend
        var mostCommonLevel: JournalEntry.StructuredJournalData.EnergyLevel? // Most common level
        
        enum TrendDirection: String, Codable { // Enum for trend direction
            case improving = "Improving" // Energy is improving
            case declining = "Declining" // Energy is declining
            case stable = "Stable" // Energy is stable
            case fluctuating = "Fluctuating" // Energy is fluctuating
        }
    }
    
    struct StressLevelTrend: Codable { // Nested struct for stress level trend
        var averageLevel: Double // Average stress level
        var levelDistribution: [String: Int] // Distribution of stress levels
        var trendDirection: TrendDirection // Direction of stress trend
        var mostCommonLevel: JournalEntry.StructuredJournalData.StressLevel? // Most common level
        
        enum TrendDirection: String, Codable { // Enum for trend direction
            case improving = "Improving" // Stress is improving
            case declining = "Declining" // Stress is declining
            case stable = "Stable" // Stress is stable
            case fluctuating = "Fluctuating" // Stress is fluctuating
        }
    }
    
    struct RelationshipInsight: Codable, Identifiable { // Nested struct for relationship insights
        let id: UUID // Unique identifier for insight
        var person: String // Name of person
        var interactionCount: Int // Number of interactions mentioned
        var positiveCount: Int // Number of positive interactions
        var negativeCount: Int // Number of negative interactions
        var neutralCount: Int // Number of neutral interactions
        var overallQuality: InteractionQuality // Overall interaction quality
        
        enum InteractionQuality: String, Codable { // Enum for interaction quality
            case veryPositive = "Very Positive" // Very positive interactions
            case positive = "Positive" // Positive interactions
            case neutral = "Neutral" // Neutral interactions
            case negative = "Negative" // Negative interactions
            case veryNegative = "Very Negative" // Very negative interactions
        }
        
        init(id: UUID = UUID(), person: String, interactionCount: Int = 0, positiveCount: Int = 0, negativeCount: Int = 0, neutralCount: Int = 0, overallQuality: InteractionQuality = .neutral) {
            self.id = id // Initialize unique identifier
            self.person = person // Initialize person name
            self.interactionCount = interactionCount // Initialize interaction count
            self.positiveCount = positiveCount // Initialize positive count
            self.negativeCount = negativeCount // Initialize negative count
            self.neutralCount = neutralCount // Initialize neutral count
            self.overallQuality = overallQuality // Initialize overall quality
        }
    }
    
    struct WorkLifeInsights: Codable { // Nested struct for work-life insights
        var averageWorkHours: Double? // Average work hours
        var productivityTrend: ProductivityTrend // Productivity trend analysis
        var satisfactionTrend: SatisfactionTrend // Satisfaction trend analysis
        var balanceTrend: BalanceTrend // Work-life balance trend
        var commonAccomplishments: [String] // Common work accomplishments
        var commonChallenges: [String] // Common work challenges
        
        enum ProductivityTrend: String, Codable { // Enum for productivity trend
            case improving = "Improving" // Productivity is improving
            case declining = "Declining" // Productivity is declining
            case stable = "Stable" // Productivity is stable
            case fluctuating = "Fluctuating" // Productivity is fluctuating
        }
        
        enum SatisfactionTrend: String, Codable { // Enum for satisfaction trend
            case improving = "Improving" // Satisfaction is improving
            case declining = "Declining" // Satisfaction is declining
            case stable = "Stable" // Satisfaction is stable
            case fluctuating = "Fluctuating" // Satisfaction is fluctuating
        }
        
        enum BalanceTrend: String, Codable { // Enum for balance trend
            case improving = "Improving" // Balance is improving
            case declining = "Declining" // Balance is declining
            case stable = "Stable" // Balance is stable
            case fluctuating = "Fluctuating" // Balance is fluctuating
        }
    }
    
    struct GoalProgressSummary: Codable, Identifiable { // Nested struct for goal progress summary
        let id: UUID // Unique identifier for summary
        var goalName: String // Name of goal
        var entryCount: Int // Number of entries mentioning goal
        var averageProgress: Double // Average progress percentage
        var progressTrend: ProgressTrend // Progress trend direction
        var commonObstacles: [String] // Common obstacles mentioned
        
        enum ProgressTrend: String, Codable { // Enum for progress trend
            case improving = "Improving" // Progress is improving
            case declining = "Declining" // Progress is declining
            case stable = "Stable" // Progress is stable
            case fluctuating = "Fluctuating" // Progress is fluctuating
        }
        
        init(id: UUID = UUID(), goalName: String, entryCount: Int = 0, averageProgress: Double = 0, progressTrend: ProgressTrend = .stable, commonObstacles: [String] = []) {
            self.id = id // Initialize unique identifier
            self.goalName = goalName // Initialize goal name
            self.entryCount = entryCount // Initialize entry count
            self.averageProgress = averageProgress // Initialize average progress
            self.progressTrend = progressTrend // Initialize progress trend
            self.commonObstacles = commonObstacles // Initialize obstacles array
        }
    }
    
    init(analysisDate: Date = Date(), timeRange: DateInterval, entryCount: Int = 0, structuredEntryCount: Int = 0, unstructuredEntryCount: Int = 0, mixedEntryCount: Int = 0, moodTrend: MoodTrend = MoodTrend(averageMood: 0, moodDistribution: [:], trendDirection: .stable, mostCommonMood: nil), gratitudeThemes: [String] = [], achievementThemes: [String] = [], challengeThemes: [String] = [], lessonThemes: [String] = [], healthMetricsTrend: HealthMetricsTrend? = nil, energyLevelTrend: EnergyLevelTrend? = nil, stressLevelTrend: StressLevelTrend? = nil, relationshipInsights: [RelationshipInsight] = [], workLifeInsights: WorkLifeInsights? = nil, goalProgressSummary: [GoalProgressSummary] = [], keyInsights: [String] = [], recommendations: [String] = []) {
        self.analysisDate = analysisDate // Initialize analysis date
        self.timeRange = timeRange // Initialize time range
        self.entryCount = entryCount // Initialize entry count
        self.structuredEntryCount = structuredEntryCount // Initialize structured count
        self.unstructuredEntryCount = unstructuredEntryCount // Initialize unstructured count
        self.mixedEntryCount = mixedEntryCount // Initialize mixed count
        self.moodTrend = moodTrend // Initialize mood trend
        self.gratitudeThemes = gratitudeThemes // Initialize gratitude themes
        self.achievementThemes = achievementThemes // Initialize achievement themes
        self.challengeThemes = challengeThemes // Initialize challenge themes
        self.lessonThemes = lessonThemes // Initialize lesson themes
        self.healthMetricsTrend = healthMetricsTrend // Initialize health metrics trend
        self.energyLevelTrend = energyLevelTrend // Initialize energy level trend
        self.stressLevelTrend = stressLevelTrend // Initialize stress level trend
        self.relationshipInsights = relationshipInsights // Initialize relationship insights
        self.workLifeInsights = workLifeInsights // Initialize work-life insights
        self.goalProgressSummary = goalProgressSummary // Initialize goal progress summary
        self.keyInsights = keyInsights // Initialize key insights
        self.recommendations = recommendations // Initialize recommendations
    }
}

// MARK: - Journal Analyzer
class JournalAnalyzer { // Define JournalAnalyzer class for analyzing journal entries
    func analyze(entries: [JournalEntry], timeRange: DateInterval? = nil) -> JournalAnalysisReport { // Function to analyze journal entries
        let effectiveTimeRange = timeRange ?? DateInterval(start: entries.first?.date ?? Date(), end: entries.last?.date ?? Date()) // Determine effective time range
        let sortedEntries = entries.sorted { $0.date < $1.date } // Sort entries by date
        
        var structuredCount = 0 // Initialize structured entry count
        var unstructuredCount = 0 // Initialize unstructured entry count
        var mixedCount = 0 // Initialize mixed entry count
        
        for entry in sortedEntries { // Loop through entries
            switch entry.entryType { // Switch on entry type
            case .structured: // For structured entries
                structuredCount += 1 // Increment structured count
            case .unstructured: // For unstructured entries
                unstructuredCount += 1 // Increment unstructured count
            case .mixed: // For mixed entries
                mixedCount += 1 // Increment mixed count
            }
        }
        
        let moodTrend = analyzeMoodTrend(entries: sortedEntries) // Analyze mood trend
        let gratitudeThemes = extractThemes(from: sortedEntries, field: \.structuredData?.gratitude) // Extract gratitude themes
        let achievementThemes = extractThemes(from: sortedEntries, field: \.structuredData?.achievements) // Extract achievement themes
        let challengeThemes = extractThemes(from: sortedEntries, field: \.structuredData?.challenges) // Extract challenge themes
        let lessonThemes = extractThemes(from: sortedEntries, field: \.structuredData?.lessons) // Extract lesson themes
        let healthMetricsTrend = analyzeHealthMetrics(entries: sortedEntries) // Analyze health metrics
        let energyLevelTrend = analyzeEnergyLevelTrend(entries: sortedEntries) // Analyze energy level trend
        let stressLevelTrend = analyzeStressLevelTrend(entries: sortedEntries) // Analyze stress level trend
        let relationshipInsights = analyzeRelationships(entries: sortedEntries) // Analyze relationships
        let workLifeInsights = analyzeWorkLife(entries: sortedEntries) // Analyze work-life balance
        let goalProgressSummary = analyzeGoalProgress(entries: sortedEntries) // Analyze goal progress
        let keyInsights = generateKeyInsights(entries: sortedEntries, moodTrend: moodTrend, healthMetrics: healthMetricsTrend, energyTrend: energyLevelTrend, stressTrend: stressLevelTrend) // Generate key insights
        let recommendations = generateRecommendations(entries: sortedEntries, moodTrend: moodTrend, healthMetrics: healthMetricsTrend, energyTrend: energyLevelTrend, stressTrend: stressLevelTrend) // Generate recommendations
        
        return JournalAnalysisReport( // Return analysis report
            analysisDate: Date(), // Set analysis date
            timeRange: effectiveTimeRange, // Set time range
            entryCount: sortedEntries.count, // Set entry count
            structuredEntryCount: structuredCount, // Set structured count
            unstructuredEntryCount: unstructuredCount, // Set unstructured count
            mixedEntryCount: mixedCount, // Set mixed count
            moodTrend: moodTrend, // Set mood trend
            gratitudeThemes: gratitudeThemes, // Set gratitude themes
            achievementThemes: achievementThemes, // Set achievement themes
            challengeThemes: challengeThemes, // Set challenge themes
            lessonThemes: lessonThemes, // Set lesson themes
            healthMetricsTrend: healthMetricsTrend, // Set health metrics trend
            energyLevelTrend: energyLevelTrend, // Set energy level trend
            stressLevelTrend: stressLevelTrend, // Set stress level trend
            relationshipInsights: relationshipInsights, // Set relationship insights
            workLifeInsights: workLifeInsights, // Set work-life insights
            goalProgressSummary: goalProgressSummary, // Set goal progress summary
            keyInsights: keyInsights, // Set key insights
            recommendations: recommendations // Set recommendations
        )
    }
    
    private func analyzeMoodTrend(entries: [JournalEntry]) -> JournalAnalysisReport.MoodTrend { // Private function to analyze mood trend
        let moodsWithRatings = entries.compactMap { entry -> (Date, Int)? in // Map entries to mood ratings
            guard let mood = entry.mood else { return nil } // Check if mood exists
            let rating: Int // Declare rating variable
            switch mood { // Switch on mood rating
            case .excellent: rating = 5 // Set rating 5 for excellent
            case .good: rating = 4 // Set rating 4 for good
            case .neutral: rating = 3 // Set rating 3 for neutral
            case .poor: rating = 2 // Set rating 2 for poor
            case .veryPoor: rating = 1 // Set rating 1 for very poor
            }
            return (entry.date, rating) // Return date and rating tuple
        }
        
        guard !moodsWithRatings.isEmpty else { // Check if moods exist
            return JournalAnalysisReport.MoodTrend(averageMood: 0, moodDistribution: [:], trendDirection: .stable, mostCommonMood: nil) // Return empty trend
        }
        
        let averageMood = Double(moodsWithRatings.map { $0.1 }.reduce(0, +)) / Double(moodsWithRatings.count) // Calculate average mood
        var moodDistribution: [String: Int] = [:] // Initialize mood distribution dictionary
        var moodCounts: [JournalEntry.MoodRating: Int] = [:] // Initialize mood counts dictionary
        
        for entry in entries { // Loop through entries to build mood distribution
            if let mood = entry.mood { // Check if mood exists
                moodDistribution[mood.rawValue, default: 0] += 1 // Increment distribution count
            }
        }
        
        for entry in entries { // Loop through entries
            if let mood = entry.mood { // Check if mood exists
                moodCounts[mood, default: 0] += 1 // Increment mood count
            }
        }
        
        let mostCommonMood = moodCounts.max(by: { $0.value < $1.value })?.key // Get most common mood
        let trendDirection = calculateMoodTrendDirection(moodsWithRatings: moodsWithRatings) // Calculate trend direction
        
        return JournalAnalysisReport.MoodTrend( // Return mood trend
            averageMood: averageMood, // Set average mood
            moodDistribution: moodDistribution, // Set mood distribution
            trendDirection: trendDirection, // Set trend direction
            mostCommonMood: mostCommonMood // Set most common mood
        )
    }
    
    private func calculateMoodTrendDirection(moodsWithRatings: [(Date, Int)]) -> JournalAnalysisReport.MoodTrend.TrendDirection { // Private function to calculate mood trend direction
        guard moodsWithRatings.count >= 2 else { return .stable } // Check if enough data points
        let firstHalf = moodsWithRatings.prefix(moodsWithRatings.count / 2) // Get first half
        let secondHalf = moodsWithRatings.suffix(moodsWithRatings.count / 2) // Get second half
        let firstAverage = Double(firstHalf.map { $0.1 }.reduce(0, +)) / Double(firstHalf.count) // Calculate first half average
        let secondAverage = Double(secondHalf.map { $0.1 }.reduce(0, +)) / Double(secondHalf.count) // Calculate second half average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.2 { // Check if difference is small
            return .stable // Return stable trend
        } else if difference > 0 { // Check if improving
            return .improving // Return improving trend
        } else { // If declining
            return .declining // Return declining trend
        }
    }
    
    private func extractThemes(from entries: [JournalEntry], field: KeyPath<JournalEntry, [String]?>) -> [String] { // Private function to extract themes
        var themes: [String: Int] = [:] // Initialize themes dictionary
        for entry in entries { // Loop through entries
            if let values = entry[keyPath: field] { // Check if field values exist
                for value in values { // Loop through values
                    let words = value.lowercased().components(separatedBy: .whitespacesAndNewlines) // Split into words
                    for word in words where word.count > 3 { // Loop through words longer than 3 characters
                        themes[word, default: 0] += 1 // Increment theme count
                    }
                }
            }
        }
        return Array(themes.sorted { $0.value > $1.value }.prefix(10).map { $0.key }) // Return top 10 themes
    }
    
    private func analyzeHealthMetrics(entries: [JournalEntry]) -> JournalAnalysisReport.HealthMetricsTrend? { // Private function to analyze health metrics
        var weightEntries: [JournalAnalysisReport.HealthMetricsTrend.WeightEntry] = [] // Initialize weight entries array
        var energyEntries: [JournalAnalysisReport.HealthMetricsTrend.EnergyEntry] = [] // Initialize energy entries array
        var painEntries: [JournalAnalysisReport.HealthMetricsTrend.PainEntry] = [] // Initialize pain entries array
        var symptoms: [String: Int] = [:] // Initialize symptoms dictionary
        var medications: [String: Int] = [:] // Initialize medications dictionary
        
        for entry in entries { // Loop through entries
            if let structured = entry.structuredData, let health = structured.healthMetrics { // Check if health metrics exist
                if let weight = health.weight { // Check if weight exists
                    weightEntries.append(JournalAnalysisReport.HealthMetricsTrend.WeightEntry(date: entry.date, weight: weight)) // Add weight entry
                }
                if let energy = health.energyLevel { // Check if energy level exists
                    energyEntries.append(JournalAnalysisReport.HealthMetricsTrend.EnergyEntry(date: entry.date, level: energy)) // Add energy entry
                }
                if let pain = health.painLevel { // Check if pain level exists
                    painEntries.append(JournalAnalysisReport.HealthMetricsTrend.PainEntry(date: entry.date, level: pain)) // Add pain entry
                }
                for symptom in health.symptoms { // Loop through symptoms
                    symptoms[symptom, default: 0] += 1 // Increment symptom count
                }
                for medication in health.medications { // Loop through medications
                    medications[medication.name, default: 0] += 1 // Increment medication count
                }
            }
        }
        
        guard !weightEntries.isEmpty || !energyEntries.isEmpty || !painEntries.isEmpty else { return nil } // Check if any metrics exist
        
        return JournalAnalysisReport.HealthMetricsTrend( // Return health metrics trend
            weightEntries: weightEntries, // Set weight entries
            energyLevelEntries: energyEntries, // Set energy entries
            painLevelEntries: painEntries, // Set pain entries
            commonSymptoms: Array(symptoms.sorted { $0.value > $1.value }.prefix(10).map { $0.key }), // Set common symptoms
            medicationFrequency: medications // Set medication frequency
        )
    }
    
    private func analyzeEnergyLevelTrend(entries: [JournalEntry]) -> JournalAnalysisReport.EnergyLevelTrend? { // Private function to analyze energy level trend
        let energyLevels = entries.compactMap { entry -> JournalEntry.StructuredJournalData.EnergyLevel? in // Map entries to energy levels
            entry.structuredData?.energyLevel // Get energy level
        }
        
        guard !energyLevels.isEmpty else { return nil } // Check if energy levels exist
        
        let levelValues: [JournalEntry.StructuredJournalData.EnergyLevel: Double] = [ // Map energy levels to values
            .veryHigh: 5, .high: 4, .moderate: 3, .low: 2, .veryLow: 1 // Set level values
        ]
        let averageLevel = energyLevels.compactMap { levelValues[$0] }.reduce(0, +) / Double(energyLevels.count) // Calculate average level
        var levelDistribution: [String: Int] = [:] // Initialize level distribution dictionary
        for level in energyLevels { // Loop through energy levels
            levelDistribution[level.rawValue, default: 0] += 1 // Increment distribution count
        }
        let mostCommonLevel = levelDistribution.max(by: { $0.value < $1.value }).map { // Get most common level
            JournalEntry.StructuredJournalData.EnergyLevel(rawValue: $0.key) // Convert to enum
        } ?? nil
        
        let trendDirection = calculateEnergyTrendDirection(levels: energyLevels, values: levelValues) // Calculate trend direction
        
        return JournalAnalysisReport.EnergyLevelTrend( // Return energy level trend
            averageLevel: averageLevel, // Set average level
            levelDistribution: levelDistribution, // Set level distribution
            trendDirection: trendDirection, // Set trend direction
            mostCommonLevel: mostCommonLevel // Set most common level
        )
    }
    
    private func analyzeStressLevelTrend(entries: [JournalEntry]) -> JournalAnalysisReport.StressLevelTrend? { // Private function to analyze stress level trend
        let stressLevels = entries.compactMap { entry -> JournalEntry.StructuredJournalData.StressLevel? in // Map entries to stress levels
            entry.structuredData?.stressLevel // Get stress level
        }
        
        guard !stressLevels.isEmpty else { return nil } // Check if stress levels exist
        
        let levelValues: [JournalEntry.StructuredJournalData.StressLevel: Double] = [ // Map stress levels to values
            .none: 0, .low: 1, .moderate: 2, .high: 3, .veryHigh: 4 // Set level values
        ]
        let averageLevel = stressLevels.compactMap { levelValues[$0] }.reduce(0, +) / Double(stressLevels.count) // Calculate average level
        var levelDistribution: [String: Int] = [:] // Initialize level distribution dictionary
        for level in stressLevels { // Loop through stress levels
            levelDistribution[level.rawValue, default: 0] += 1 // Increment distribution count
        }
        let mostCommonLevel = levelDistribution.max(by: { $0.value < $1.value }).map { // Get most common level
            JournalEntry.StructuredJournalData.StressLevel(rawValue: $0.key) // Convert to enum
        } ?? nil
        
        let trendDirection = calculateStressTrendDirection(levels: stressLevels, values: levelValues) // Calculate trend direction
        
        return JournalAnalysisReport.StressLevelTrend( // Return stress level trend
            averageLevel: averageLevel, // Set average level
            levelDistribution: levelDistribution, // Set level distribution
            trendDirection: trendDirection, // Set trend direction
            mostCommonLevel: mostCommonLevel // Set most common level
        )
    }
    
    private func analyzeRelationships(entries: [JournalEntry]) -> [JournalAnalysisReport.RelationshipInsight] { // Private function to analyze relationships
        var personData: [String: (positive: Int, negative: Int, neutral: Int, total: Int)] = [:] // Initialize person data dictionary
        
        for entry in entries { // Loop through entries
            if let structured = entry.structuredData { // Check if structured data exists
                for relationship in structured.relationships { // Loop through relationships
                    var data = personData[relationship.person] ?? (0, 0, 0, 0) // Get or create person data
                    data.total += 1 // Increment total count
                    switch relationship.quality { // Switch on interaction quality
                    case .positive: data.positive += 1 // Increment positive count
                    case .negative: data.negative += 1 // Increment negative count
                    case .neutral: data.neutral += 1 // Increment neutral count
                    case .mixed: data.positive += 1; data.negative += 1 // Increment both for mixed
                    }
                    personData[relationship.person] = data // Update person data
                }
            }
        }
        
        return personData.map { person, data in // Map person data to insights
            let overallQuality: JournalAnalysisReport.RelationshipInsight.InteractionQuality // Declare overall quality
            if data.positive > data.negative * 2 { // Check if very positive
                overallQuality = .veryPositive // Set very positive
            } else if data.positive > data.negative { // Check if positive
                overallQuality = .positive // Set positive
            } else if data.negative > data.positive * 2 { // Check if very negative
                overallQuality = .veryNegative // Set very negative
            } else if data.negative > data.positive { // Check if negative
                overallQuality = .negative // Set negative
            } else { // If neutral
                overallQuality = .neutral // Set neutral
            }
            return JournalAnalysisReport.RelationshipInsight( // Return relationship insight
                person: person, // Set person name
                interactionCount: data.total, // Set interaction count
                positiveCount: data.positive, // Set positive count
                negativeCount: data.negative, // Set negative count
                neutralCount: data.neutral, // Set neutral count
                overallQuality: overallQuality // Set overall quality
            )
        }
    }
    
    private func analyzeWorkLife(entries: [JournalEntry]) -> JournalAnalysisReport.WorkLifeInsights? { // Private function to analyze work-life balance
        let workLifeEntries = entries.compactMap { $0.structuredData?.workLife } // Get work-life entries
        guard !workLifeEntries.isEmpty else { return nil } // Check if entries exist
        
        let totalHours = workLifeEntries.compactMap { $0.workHours }.reduce(0, +) // Calculate total hours
        let averageHours = totalHours / Double(workLifeEntries.count) // Calculate average hours
        
        var accomplishments: [String: Int] = [:] // Initialize accomplishments dictionary
        var challenges: [String: Int] = [:] // Initialize challenges dictionary
        
        for entry in workLifeEntries { // Loop through work-life entries
            for accomplishment in entry.accomplishments { // Loop through accomplishments
                accomplishments[accomplishment, default: 0] += 1 // Increment accomplishment count
            }
            for challenge in entry.challenges { // Loop through challenges
                challenges[challenge, default: 0] += 1 // Increment challenge count
            }
        }
        
        return JournalAnalysisReport.WorkLifeInsights( // Return work-life insights
            averageWorkHours: averageHours > 0 ? averageHours : nil, // Set average work hours
            productivityTrend: .stable, // Set productivity trend (simplified)
            satisfactionTrend: .stable, // Set satisfaction trend (simplified)
            balanceTrend: .stable, // Set balance trend (simplified)
            commonAccomplishments: Array(accomplishments.sorted { $0.value > $1.value }.prefix(10).map { $0.key }), // Set common accomplishments
            commonChallenges: Array(challenges.sorted { $0.value > $1.value }.prefix(10).map { $0.key }) // Set common challenges
        )
    }
    
    private func analyzeGoalProgress(entries: [JournalEntry]) -> [JournalAnalysisReport.GoalProgressSummary] { // Private function to analyze goal progress
        var goalData: [String: (count: Int, totalProgress: Double, obstacles: [String])] = [:] // Initialize goal data dictionary
        
        for entry in entries { // Loop through entries
            if let structured = entry.structuredData { // Check if structured data exists
                for goalProgress in structured.goalsProgress { // Loop through goal progress
                    var data = goalData[goalProgress.goalName] ?? (0, 0, []) // Get or create goal data
                    data.count += 1 // Increment count
                    data.totalProgress += goalProgress.progress // Add progress
                    data.obstacles.append(contentsOf: goalProgress.obstacles) // Add obstacles
                    goalData[goalProgress.goalName] = data // Update goal data
                }
            }
        }
        
        return goalData.map { goalName, data in // Map goal data to summaries
            let averageProgress = data.totalProgress / Double(data.count) // Calculate average progress
            var obstacleCounts: [String: Int] = [:] // Initialize obstacle counts dictionary
            for obstacle in data.obstacles { // Loop through obstacles
                obstacleCounts[obstacle, default: 0] += 1 // Increment obstacle count
            }
            return JournalAnalysisReport.GoalProgressSummary( // Return goal progress summary
                goalName: goalName, // Set goal name
                entryCount: data.count, // Set entry count
                averageProgress: averageProgress, // Set average progress
                progressTrend: .stable, // Set progress trend (simplified)
                commonObstacles: Array(obstacleCounts.sorted { $0.value > $1.value }.prefix(5).map { $0.key }) // Set common obstacles
            )
        }
    }
    
    private func generateKeyInsights(entries: [JournalEntry], moodTrend: JournalAnalysisReport.MoodTrend, healthMetrics: JournalAnalysisReport.HealthMetricsTrend?, energyTrend: JournalAnalysisReport.EnergyLevelTrend?, stressTrend: JournalAnalysisReport.StressLevelTrend?) -> [String] { // Private function to generate key insights
        var insights: [String] = [] // Initialize insights array
        
        if moodTrend.trendDirection == .improving { // Check if mood improving
            insights.append("Your mood has been improving over time") // Add mood insight
        } else if moodTrend.trendDirection == .declining { // Check if mood declining
            insights.append("Your mood has been declining - consider support") // Add mood insight
        }
        
        if let energy = energyTrend, energy.trendDirection == .declining { // Check if energy declining
            insights.append("Energy levels are declining - review sleep and nutrition") // Add energy insight
        }
        
        if let stress = stressTrend, stress.trendDirection == .declining { // Check if stress declining (improving)
            insights.append("Stress management appears effective") // Add stress insight
        } else if let stress = stressTrend, stress.averageLevel > 2.5 { // Check if high stress
            insights.append("High stress levels detected - prioritize self-care") // Add stress insight
        }
        
        return insights // Return insights array
    }
    
    private func generateRecommendations(entries: [JournalEntry], moodTrend: JournalAnalysisReport.MoodTrend, healthMetrics: JournalAnalysisReport.HealthMetricsTrend?, energyTrend: JournalAnalysisReport.EnergyLevelTrend?, stressTrend: JournalAnalysisReport.StressLevelTrend?) -> [String] { // Private function to generate recommendations
        var recommendations: [String] = [] // Initialize recommendations array
        
        if moodTrend.averageMood < 3.0 { // Check if low average mood
            recommendations.append("Consider activities that boost mood: exercise, social connection, gratitude practice") // Add mood recommendation
        }
        
        if let energy = energyTrend, energy.averageLevel < 3.0 { // Check if low energy
            recommendations.append("Focus on sleep quality, nutrition, and regular exercise to boost energy") // Add energy recommendation
        }
        
        if let stress = stressTrend, stress.averageLevel > 2.5 { // Check if high stress
            recommendations.append("Implement stress reduction techniques: meditation, breathing exercises, time management") // Add stress recommendation
        }
        
        return recommendations // Return recommendations array
    }
    
    private func calculateEnergyTrendDirection(levels: [JournalEntry.StructuredJournalData.EnergyLevel], values: [JournalEntry.StructuredJournalData.EnergyLevel: Double]) -> JournalAnalysisReport.EnergyLevelTrend.TrendDirection { // Private function to calculate energy trend direction
        guard levels.count >= 2 else { return .stable } // Check if enough data points
        let firstHalf = levels.prefix(levels.count / 2) // Get first half
        let secondHalf = levels.suffix(levels.count / 2) // Get second half
        let firstAverage = firstHalf.compactMap { values[$0] }.reduce(0, +) / Double(firstHalf.count) // Calculate first half average
        let secondAverage = secondHalf.compactMap { values[$0] }.reduce(0, +) / Double(secondHalf.count) // Calculate second half average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.2 { // Check if difference is small
            return .stable // Return stable trend
        } else if difference > 0 { // Check if improving
            return .improving // Return improving trend
        } else { // If declining
            return .declining // Return declining trend
        }
    }
    
    private func calculateStressTrendDirection(levels: [JournalEntry.StructuredJournalData.StressLevel], values: [JournalEntry.StructuredJournalData.StressLevel: Double]) -> JournalAnalysisReport.StressLevelTrend.TrendDirection { // Private function to calculate stress trend direction
        guard levels.count >= 2 else { return .stable } // Check if enough data points
        let firstHalf = levels.prefix(levels.count / 2) // Get first half
        let secondHalf = levels.suffix(levels.count / 2) // Get second half
        let firstAverage = firstHalf.compactMap { values[$0] }.reduce(0, +) / Double(firstHalf.count) // Calculate first half average
        let secondAverage = secondHalf.compactMap { values[$0] }.reduce(0, +) / Double(secondHalf.count) // Calculate second half average
        let difference = secondAverage - firstAverage // Calculate difference
        
        if abs(difference) < 0.2 { // Check if difference is small
            return .stable // Return stable trend
        } else if difference < 0 { // Check if improving (lower stress)
            return .improving // Return improving trend
        } else { // If declining (higher stress)
            return .declining // Return declining trend
        }
    }
}
