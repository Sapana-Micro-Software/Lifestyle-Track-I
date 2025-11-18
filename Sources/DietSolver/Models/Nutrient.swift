import Foundation

// MARK: - Nutrient Types
enum NutrientType: String, Codable, CaseIterable {
    case vitamin = "Vitamin"
    case macronutrient = "Macronutrient"
    case micronutrient = "Micronutrient"
    case mineral = "Mineral"
}

// MARK: - Specific Nutrients
enum Vitamin: String, Codable, CaseIterable {
    case a, b1, b2, b3, b5, b6, b7, b9, b12, c, d, e, k
}

enum Macronutrient: String, Codable, CaseIterable {
    case protein, carbohydrates, fats, fiber
}

enum Micronutrient: String, Codable, CaseIterable {
    case omega3, omega6, choline, betaine
}

enum Mineral: String, Codable, CaseIterable {
    case calcium, iron, magnesium, phosphorus, potassium, sodium, zinc, copper, manganese, selenium
}

// MARK: - Nutrient Requirements
struct NutrientRequirement: Codable {
    let name: String
    var dailyValue: Double // in appropriate units (mg, g, mcg, etc.)
    let unit: String
    let category: NutrientType
}

// MARK: - USDA Nutrient Guidelines
struct USDANutrientGuidelines {
    static let adultMale: [String: NutrientRequirement] = [
        "calories": NutrientRequirement(name: "Calories", dailyValue: 2500, unit: "kcal", category: .macronutrient),
        "protein": NutrientRequirement(name: "Protein", dailyValue: 56, unit: "g", category: .macronutrient),
        "carbs": NutrientRequirement(name: "Carbohydrates", dailyValue: 300, unit: "g", category: .macronutrient),
        "fats": NutrientRequirement(name: "Fats", dailyValue: 65, unit: "g", category: .macronutrient),
        "fiber": NutrientRequirement(name: "Fiber", dailyValue: 38, unit: "g", category: .macronutrient),
        "vitamin_a": NutrientRequirement(name: "Vitamin A", dailyValue: 900, unit: "mcg", category: .vitamin),
        "vitamin_c": NutrientRequirement(name: "Vitamin C", dailyValue: 90, unit: "mg", category: .vitamin),
        "vitamin_d": NutrientRequirement(name: "Vitamin D", dailyValue: 20, unit: "mcg", category: .vitamin),
        "vitamin_e": NutrientRequirement(name: "Vitamin E", dailyValue: 15, unit: "mg", category: .vitamin),
        "vitamin_k": NutrientRequirement(name: "Vitamin K", dailyValue: 120, unit: "mcg", category: .vitamin),
        "thiamin": NutrientRequirement(name: "Thiamin (B1)", dailyValue: 1.2, unit: "mg", category: .vitamin),
        "riboflavin": NutrientRequirement(name: "Riboflavin (B2)", dailyValue: 1.3, unit: "mg", category: .vitamin),
        "niacin": NutrientRequirement(name: "Niacin (B3)", dailyValue: 16, unit: "mg", category: .vitamin),
        "vitamin_b6": NutrientRequirement(name: "Vitamin B6", dailyValue: 1.3, unit: "mg", category: .vitamin),
        "folate": NutrientRequirement(name: "Folate (B9)", dailyValue: 400, unit: "mcg", category: .vitamin),
        "vitamin_b12": NutrientRequirement(name: "Vitamin B12", dailyValue: 2.4, unit: "mcg", category: .vitamin),
        "calcium": NutrientRequirement(name: "Calcium", dailyValue: 1000, unit: "mg", category: .mineral),
        "iron": NutrientRequirement(name: "Iron", dailyValue: 8, unit: "mg", category: .mineral),
        "magnesium": NutrientRequirement(name: "Magnesium", dailyValue: 400, unit: "mg", category: .mineral),
        "phosphorus": NutrientRequirement(name: "Phosphorus", dailyValue: 700, unit: "mg", category: .mineral),
        "potassium": NutrientRequirement(name: "Potassium", dailyValue: 3400, unit: "mg", category: .mineral),
        "sodium": NutrientRequirement(name: "Sodium", dailyValue: 2300, unit: "mg", category: .mineral),
        "zinc": NutrientRequirement(name: "Zinc", dailyValue: 11, unit: "mg", category: .mineral),
        "copper": NutrientRequirement(name: "Copper", dailyValue: 0.9, unit: "mg", category: .mineral),
        "manganese": NutrientRequirement(name: "Manganese", dailyValue: 2.3, unit: "mg", category: .mineral),
        "selenium": NutrientRequirement(name: "Selenium", dailyValue: 55, unit: "mcg", category: .mineral),
    ]
    
    static let adultFemale: [String: NutrientRequirement] = [
        "calories": NutrientRequirement(name: "Calories", dailyValue: 2000, unit: "kcal", category: .macronutrient),
        "protein": NutrientRequirement(name: "Protein", dailyValue: 46, unit: "g", category: .macronutrient),
        "carbs": NutrientRequirement(name: "Carbohydrates", dailyValue: 250, unit: "g", category: .macronutrient),
        "fats": NutrientRequirement(name: "Fats", dailyValue: 50, unit: "g", category: .macronutrient),
        "fiber": NutrientRequirement(name: "Fiber", dailyValue: 25, unit: "g", category: .macronutrient),
        "vitamin_a": NutrientRequirement(name: "Vitamin A", dailyValue: 700, unit: "mcg", category: .vitamin),
        "vitamin_c": NutrientRequirement(name: "Vitamin C", dailyValue: 75, unit: "mg", category: .vitamin),
        "vitamin_d": NutrientRequirement(name: "Vitamin D", dailyValue: 20, unit: "mcg", category: .vitamin),
        "vitamin_e": NutrientRequirement(name: "Vitamin E", dailyValue: 15, unit: "mg", category: .vitamin),
        "vitamin_k": NutrientRequirement(name: "Vitamin K", dailyValue: 90, unit: "mcg", category: .vitamin),
        "thiamin": NutrientRequirement(name: "Thiamin (B1)", dailyValue: 1.1, unit: "mg", category: .vitamin),
        "riboflavin": NutrientRequirement(name: "Riboflavin (B2)", dailyValue: 1.1, unit: "mg", category: .vitamin),
        "niacin": NutrientRequirement(name: "Niacin (B3)", dailyValue: 14, unit: "mg", category: .vitamin),
        "vitamin_b6": NutrientRequirement(name: "Vitamin B6", dailyValue: 1.3, unit: "mg", category: .vitamin),
        "folate": NutrientRequirement(name: "Folate (B9)", dailyValue: 400, unit: "mcg", category: .vitamin),
        "vitamin_b12": NutrientRequirement(name: "Vitamin B12", dailyValue: 2.4, unit: "mcg", category: .vitamin),
        "calcium": NutrientRequirement(name: "Calcium", dailyValue: 1000, unit: "mg", category: .mineral),
        "iron": NutrientRequirement(name: "Iron", dailyValue: 18, unit: "mg", category: .mineral),
        "magnesium": NutrientRequirement(name: "Magnesium", dailyValue: 310, unit: "mg", category: .mineral),
        "phosphorus": NutrientRequirement(name: "Phosphorus", dailyValue: 700, unit: "mg", category: .mineral),
        "potassium": NutrientRequirement(name: "Potassium", dailyValue: 2600, unit: "mg", category: .mineral),
        "sodium": NutrientRequirement(name: "Sodium", dailyValue: 2300, unit: "mg", category: .mineral),
        "zinc": NutrientRequirement(name: "Zinc", dailyValue: 8, unit: "mg", category: .mineral),
        "copper": NutrientRequirement(name: "Copper", dailyValue: 0.9, unit: "mg", category: .mineral),
        "manganese": NutrientRequirement(name: "Manganese", dailyValue: 1.8, unit: "mg", category: .mineral),
        "selenium": NutrientRequirement(name: "Selenium", dailyValue: 55, unit: "mcg", category: .mineral),
    ]
}
