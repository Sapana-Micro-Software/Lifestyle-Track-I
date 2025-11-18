//
//  MealPrepPlanner.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Meal Prep Planner
class MealPrepPlanner {
    static let shared = MealPrepPlanner()
    
    private init() {}
    
    // MARK: - Generate Meal Prep Schedule
    func generateMealPrepSchedule(from dailyPlans: [DailyPlanEntry], days: Int = 7) -> MealPrepSchedule {
        var tasks: [MealPrepTask] = []
        let plansToUse = Array(dailyPlans.prefix(days))
        
        // Group meals by type and identify prep opportunities
        var breakfastItems: [String: Double] = [:]
        var lunchItems: [String: Double] = [:]
        var dinnerItems: [String: Double] = [:]
        var snackItems: [String: Double] = [:]
        
        for plan in plansToUse {
            if let dietPlan = plan.dietPlan {
                for meal in dietPlan.meals {
                    for mealItem in meal.items {
                        let foodName = mealItem.food.name
                        let amount = mealItem.amount
                        
                        switch meal.mealType {
                        case .breakfast:
                            breakfastItems[foodName, default: 0] += amount
                        case .lunch:
                            lunchItems[foodName, default: 0] += amount
                        case .dinner:
                            dinnerItems[foodName, default: 0] += amount
                        case .snack:
                            snackItems[foodName, default: 0] += amount
                        }
                    }
                }
            }
        }
        
        // Create prep tasks
        let prepDay = Calendar.current.startOfDay(for: Date())
        
        // Batch cooking tasks
        if !dinnerItems.isEmpty {
            tasks.append(MealPrepTask(
                type: .batchCooking,
                title: "Batch Cook Proteins",
                description: "Prepare proteins for the week",
                estimatedTime: 60, // minutes
                priority: .high,
                scheduledDate: prepDay,
                items: Array(dinnerItems.keys),
                canBeDoneAhead: true
            ))
        }
        
        if !breakfastItems.isEmpty {
            tasks.append(MealPrepTask(
                type: .prep,
                title: "Prep Breakfast Items",
                description: "Wash, chop, and prepare breakfast ingredients",
                estimatedTime: 30,
                priority: .medium,
                scheduledDate: prepDay,
                items: Array(breakfastItems.keys),
                canBeDoneAhead: true
            ))
        }
        
        if !lunchItems.isEmpty {
            tasks.append(MealPrepTask(
                type: .prep,
                title: "Prep Lunch Items",
                description: "Prepare lunch ingredients and containers",
                estimatedTime: 45,
                priority: .medium,
                scheduledDate: prepDay,
                items: Array(lunchItems.keys),
                canBeDoneAhead: true
            ))
        }
        
        // Daily tasks
        for dayOffset in 0..<days {
            guard let dayDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: prepDay) else { continue }
            
            // Morning prep
            tasks.append(MealPrepTask(
                type: .daily,
                title: "Morning Meal Prep",
                description: "Final prep for today's meals",
                estimatedTime: 15,
                priority: .high,
                scheduledDate: dayDate,
                items: [],
                canBeDoneAhead: false
            ))
        }
        
        return MealPrepSchedule(
            tasks: tasks,
            daysCovered: days,
            totalEstimatedTime: tasks.reduce(0) { $0 + $1.estimatedTime },
            generatedDate: Date()
        )
    }
    
    // MARK: - Get Batch Cooking Recommendations
    func getBatchCookingRecommendations(from dailyPlans: [DailyPlanEntry]) -> [BatchCookingRecommendation] {
        var recommendations: [BatchCookingRecommendation] = []
        let plansToUse = Array(dailyPlans.prefix(7))
        
        // Analyze protein usage
        var proteinUsage: [String: Int] = [:]
        for plan in plansToUse {
            if let dietPlan = plan.dietPlan {
                for meal in dietPlan.meals {
                    for mealItem in meal.items {
                        let foodName = mealItem.food.name
                        if isProtein(foodName) {
                            proteinUsage[foodName, default: 0] += 1
                        }
                    }
                }
            }
        }
        
        // Recommend batch cooking for frequently used proteins
        for (protein, count) in proteinUsage where count >= 3 {
            recommendations.append(BatchCookingRecommendation(
                food: protein,
                frequency: count,
                recommendedBatchSize: estimateBatchSize(for: protein, count: count),
                storageMethod: getStorageMethod(for: protein),
                prepInstructions: getPrepInstructions(for: protein)
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Helper Methods
    private func isProtein(_ foodName: String) -> Bool {
        let lowercased = foodName.lowercased()
        return lowercased.contains("chicken") || lowercased.contains("beef") ||
               lowercased.contains("fish") || lowercased.contains("salmon") ||
               lowercased.contains("turkey") || lowercased.contains("pork") ||
               lowercased.contains("tofu") || lowercased.contains("lentil") ||
               lowercased.contains("bean") || lowercased.contains("chickpea")
    }
    
    private func estimateBatchSize(for food: String, count: Int) -> String {
        // Simple estimation - in production would be more sophisticated
        let lowercased = food.lowercased()
        if lowercased.contains("chicken") || lowercased.contains("beef") {
            return "\(count * 200)g"
        } else if lowercased.contains("fish") {
            return "\(count * 150)g"
        } else {
            return "\(count * 100)g"
        }
    }
    
    private func getStorageMethod(for food: String) -> String {
        let lowercased = food.lowercased()
        if lowercased.contains("chicken") || lowercased.contains("beef") || lowercased.contains("fish") {
            return "Refrigerate in airtight containers for up to 4 days, or freeze for longer storage"
        } else if lowercased.contains("vegetable") {
            return "Store in refrigerator in sealed containers"
        } else {
            return "Store in airtight containers in refrigerator"
        }
    }
    
    private func getPrepInstructions(for food: String) -> String {
        let lowercased = food.lowercased()
        if lowercased.contains("chicken") {
            return "Cook chicken thoroughly, let cool, then portion into containers"
        } else if lowercased.contains("beef") {
            return "Cook beef to desired doneness, let cool, then portion"
        } else if lowercased.contains("fish") {
            return "Cook fish gently, let cool, then portion. Best used within 2-3 days"
        } else {
            return "Prepare according to recipe, let cool, then portion"
        }
    }
}

// MARK: - Meal Prep Schedule
struct MealPrepSchedule: Codable, Identifiable {
    let id: UUID
    var tasks: [MealPrepTask]
    var daysCovered: Int
    var totalEstimatedTime: Int // minutes
    var generatedDate: Date
    
    init(id: UUID = UUID(), tasks: [MealPrepTask], daysCovered: Int, totalEstimatedTime: Int, generatedDate: Date) {
        self.id = id
        self.tasks = tasks
        self.daysCovered = daysCovered
        self.totalEstimatedTime = totalEstimatedTime
        self.generatedDate = generatedDate
    }
}

// MARK: - Meal Prep Task
struct MealPrepTask: Codable, Identifiable {
    let id: UUID
    var type: TaskType
    var title: String
    var description: String
    var estimatedTime: Int // minutes
    var priority: Priority
    var scheduledDate: Date
    var items: [String] // Food items involved
    var canBeDoneAhead: Bool
    var isCompleted: Bool
    
    enum TaskType: String, Codable, CaseIterable {
        case batchCooking = "Batch Cooking"
        case prep = "Prep"
        case daily = "Daily"
    }
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    init(id: UUID = UUID(), type: TaskType, title: String, description: String, estimatedTime: Int, priority: Priority, scheduledDate: Date, items: [String], canBeDoneAhead: Bool, isCompleted: Bool = false) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.estimatedTime = estimatedTime
        self.priority = priority
        self.scheduledDate = scheduledDate
        self.items = items
        self.canBeDoneAhead = canBeDoneAhead
        self.isCompleted = isCompleted
    }
}

// MARK: - Batch Cooking Recommendation
struct BatchCookingRecommendation: Codable, Identifiable {
    let id: UUID
    var food: String
    var frequency: Int // How many times used in the week
    var recommendedBatchSize: String
    var storageMethod: String
    var prepInstructions: String
    
    init(id: UUID = UUID(), food: String, frequency: Int, recommendedBatchSize: String, storageMethod: String, prepInstructions: String) {
        self.id = id
        self.food = food
        self.frequency = frequency
        self.recommendedBatchSize = recommendedBatchSize
        self.storageMethod = storageMethod
        self.prepInstructions = prepInstructions
    }
}
