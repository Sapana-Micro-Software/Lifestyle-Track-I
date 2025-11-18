//
//  GroceryListGenerator.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Grocery List Generator
class GroceryListGenerator {
    static let shared = GroceryListGenerator()
    
    private init() {}
    
    // MARK: - Generate Grocery List from Daily Plans
    func generateGroceryList(from dailyPlans: [DailyPlanEntry], days: Int = 7) -> GroceryList {
        var items: [GroceryItem] = []
        let plansToUse = Array(dailyPlans.prefix(days))
        
        // Extract all foods from meal plans
        for plan in plansToUse {
            if let dietPlan = plan.dietPlan {
                for meal in dietPlan.meals {
                    for mealItem in meal.items {
                        let food = mealItem.food
                        let amount = mealItem.amount // in grams
                        
                        // Find or create grocery item
                        if let existingIndex = items.firstIndex(where: { $0.name.lowercased() == food.name.lowercased() }) {
                            items[existingIndex].quantity += amount
                            if !items[existingIndex].meals.contains(meal.name) {
                                items[existingIndex].meals.append(meal.name)
                            }
                        } else {
                            let category = categorizeFood(food.name)
                            items.append(GroceryItem(
                                name: food.name,
                                quantity: amount,
                                unit: "g",
                                category: category,
                                meals: [meal.name],
                                estimatedCost: estimateCost(food: food, amount: amount)
                            ))
                        }
                    }
                }
            }
        }
        
        // Sort by category and name
        items.sort { first, second in
            if first.category == second.category {
                return first.name < second.name
            }
            return first.category.rawValue < second.category.rawValue
        }
        
        let totalCost = items.reduce(0.0) { $0 + $1.estimatedCost }
        
        return GroceryList(
            items: items,
            totalEstimatedCost: totalCost,
            daysCovered: days,
            generatedDate: Date()
        )
    }
    
    // MARK: - Generate Grocery List from Single Plan
    func generateGroceryList(from plan: DailyDietPlan) -> GroceryList {
        var items: [GroceryItem] = []
        
        for meal in plan.meals {
            for mealItem in meal.items {
                let food = mealItem.food
                let amount = mealItem.amount // in grams
                
                if let existingIndex = items.firstIndex(where: { $0.name.lowercased() == food.name.lowercased() }) {
                    items[existingIndex].quantity += amount
                    if !items[existingIndex].meals.contains(meal.name) {
                        items[existingIndex].meals.append(meal.name)
                    }
                } else {
                    let category = categorizeFood(food.name)
                    items.append(GroceryItem(
                        name: food.name,
                        quantity: amount,
                        unit: "g",
                        category: category,
                        meals: [meal.name],
                        estimatedCost: estimateCost(food: food, amount: amount)
                    ))
                }
            }
        }
        
        items.sort { first, second in
            if first.category == second.category {
                return first.name < second.name
            }
            return first.category.rawValue < second.category.rawValue
        }
        
        let totalCost = items.reduce(0.0) { $0 + $1.estimatedCost }
        
        return GroceryList(
            items: items,
            totalEstimatedCost: totalCost,
            daysCovered: 1,
            generatedDate: Date()
        )
    }
    
    // MARK: - Categorize Food
    private func categorizeFood(_ foodName: String) -> GroceryCategory {
        let lowercased = foodName.lowercased()
        
        // Produce
        if lowercased.contains("apple") || lowercased.contains("banana") || lowercased.contains("orange") ||
           lowercased.contains("berry") || lowercased.contains("grape") || lowercased.contains("mango") ||
           lowercased.contains("lettuce") || lowercased.contains("spinach") || lowercased.contains("broccoli") ||
           lowercased.contains("carrot") || lowercased.contains("tomato") || lowercased.contains("pepper") ||
           lowercased.contains("onion") || lowercased.contains("garlic") || lowercased.contains("potato") {
            return .produce
        }
        
        // Meat & Seafood
        if lowercased.contains("chicken") || lowercased.contains("beef") || lowercased.contains("pork") ||
           lowercased.contains("turkey") || lowercased.contains("fish") || lowercased.contains("salmon") ||
           lowercased.contains("tuna") || lowercased.contains("shrimp") || lowercased.contains("lamb") {
            return .meatSeafood
        }
        
        // Dairy
        if lowercased.contains("milk") || lowercased.contains("cheese") || lowercased.contains("yogurt") ||
           lowercased.contains("butter") || lowercased.contains("cream") || lowercased.contains("egg") {
            return .dairy
        }
        
        // Grains & Bread
        if lowercased.contains("rice") || lowercased.contains("pasta") || lowercased.contains("bread") ||
           lowercased.contains("wheat") || lowercased.contains("quinoa") || lowercased.contains("oats") ||
           lowercased.contains("barley") || lowercased.contains("flour") {
            return .grainsBread
        }
        
        // Pantry
        if lowercased.contains("oil") || lowercased.contains("vinegar") || lowercased.contains("spice") ||
           lowercased.contains("salt") || lowercased.contains("pepper") || lowercased.contains("herb") ||
           lowercased.contains("sauce") || lowercased.contains("seasoning") {
            return .pantry
        }
        
        // Frozen
        if lowercased.contains("frozen") {
            return .frozen
        }
        
        // Beverages
        if lowercased.contains("juice") || lowercased.contains("water") || lowercased.contains("tea") ||
           lowercased.contains("coffee") {
            return .beverages
        }
        
        // Snacks
        if lowercased.contains("nut") || lowercased.contains("seed") || lowercased.contains("cracker") {
            return .snacks
        }
        
        return .other
    }
    
    // MARK: - Estimate Cost
    private func estimateCost(food: Food, amount: Double) -> Double {
        // Simple cost estimation based on food type and amount (in grams)
        // In production, this would use a food cost database
        let baseCostPer100g: Double
        
        let lowercased = food.name.lowercased()
        
        if lowercased.contains("chicken") || lowercased.contains("beef") || lowercased.contains("salmon") {
            baseCostPer100g = 8.0 // $8 per 100g
        } else if lowercased.contains("fish") || lowercased.contains("seafood") {
            baseCostPer100g = 12.0
        } else if lowercased.contains("cheese") || lowercased.contains("yogurt") {
            baseCostPer100g = 5.0
        } else if lowercased.contains("berry") || lowercased.contains("organic") {
            baseCostPer100g = 6.0
        } else if lowercased.contains("vegetable") || lowercased.contains("fruit") {
            baseCostPer100g = 3.0
        } else if lowercased.contains("rice") || lowercased.contains("pasta") || lowercased.contains("grain") {
            baseCostPer100g = 2.0
        } else {
            baseCostPer100g = 4.0 // Default
        }
        
        return baseCostPer100g * (amount / 100.0)
    }
    
    // MARK: - Format for Sharing
    func formatForSharing(_ list: GroceryList) -> String {
        var text = "Grocery List - \(list.daysCovered) days\n"
        text += "Generated: \(formatDate(list.generatedDate))\n\n"
        
        var currentCategory: GroceryCategory?
        for item in list.items {
            if item.category != currentCategory {
                currentCategory = item.category
                text += "\n\(currentCategory!.rawValue):\n"
            }
            text += "• \(item.name) - \(String(format: "%.1f", item.quantity)) \(item.unit)\n"
        }
        
        text += "\nEstimated Total: $\(String(format: "%.2f", list.totalEstimatedCost))"
        
        return text
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Grocery List
struct GroceryList: Codable, Identifiable {
    let id: UUID
    var items: [GroceryItem]
    var totalEstimatedCost: Double
    var daysCovered: Int
    var generatedDate: Date
    
    init(id: UUID = UUID(), items: [GroceryItem], totalEstimatedCost: Double, daysCovered: Int, generatedDate: Date) {
        self.id = id
        self.items = items
        self.totalEstimatedCost = totalEstimatedCost
        self.daysCovered = daysCovered
        self.generatedDate = generatedDate
    }
}

// MARK: - Grocery Item
struct GroceryItem: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var category: GroceryCategory
    var meals: [String] // Which meals use this item
    var estimatedCost: Double
    var isChecked: Bool
    
    init(id: UUID = UUID(), name: String, quantity: Double, unit: String, category: GroceryCategory, meals: [String], estimatedCost: Double, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.meals = meals
        self.estimatedCost = estimatedCost
        self.isChecked = isChecked
    }
}

// MARK: - Grocery Category
enum GroceryCategory: String, Codable, CaseIterable {
    case produce = "Produce"
    case meatSeafood = "Meat & Seafood"
    case dairy = "Dairy"
    case grainsBread = "Grains & Bread"
    case pantry = "Pantry"
    case frozen = "Frozen"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .produce: return "leaf.fill"
        case .meatSeafood: return "fish.fill"
        case .dairy: return "drop.fill"
        case .grainsBread: return "wheat"
        case .pantry: return "cabinet.fill"
        case .frozen: return "snowflake"
        case .beverages: return "cup.and.saucer.fill"
        case .snacks: return "bag.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}
