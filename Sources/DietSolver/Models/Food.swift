import Foundation

// MARK: - Food Categories
enum FoodCategory: String, Codable, CaseIterable {
    case vegetable = "Vegetable"
    case fruit = "Fruit"
    case grain = "Grain"
    case herb = "Herb"
    case spice = "Spice"
    case legume = "Legume"
    case nut = "Nut"
    case seed = "Seed"
    case protein = "Protein"
    case dairy = "Dairy"
}

// MARK: - Season
enum Season: String, Codable, CaseIterable {
    case spring, summer, fall, winter
}

// MARK: - Food Properties
struct FoodProperties: Codable {
    var tasteScore: Double // 0-10
    var digestionScore: Double // 0-10 (higher = easier to digest)
    var pros: [String]
    var cons: [String]
    var seasonalAvailability: [Season]
}

// MARK: - Nutrient Content
struct NutrientContent: Codable {
    var calories: Double = 0
    var protein: Double = 0 // grams
    var carbohydrates: Double = 0 // grams
    var fats: Double = 0 // grams
    var fiber: Double = 0 // grams
    
    // Vitamins (per 100g)
    var vitaminA: Double = 0 // mcg
    var vitaminC: Double = 0 // mg
    var vitaminD: Double = 0 // mcg
    var vitaminE: Double = 0 // mg
    var vitaminK: Double = 0 // mcg
    var thiamin: Double = 0 // mg
    var riboflavin: Double = 0 // mg
    var niacin: Double = 0 // mg
    var vitaminB6: Double = 0 // mg
    var folate: Double = 0 // mcg
    var vitaminB12: Double = 0 // mcg
    
    // Minerals (per 100g)
    var calcium: Double = 0 // mg
    var iron: Double = 0 // mg
    var magnesium: Double = 0 // mg
    var phosphorus: Double = 0 // mg
    var potassium: Double = 0 // mg
    var sodium: Double = 0 // mg
    var zinc: Double = 0 // mg
    var copper: Double = 0 // mg
    var manganese: Double = 0 // mg
    var selenium: Double = 0 // mcg
    
    // Micronutrients
    var omega3: Double = 0 // g
    var omega6: Double = 0 // g
    var choline: Double = 0 // mg
    var betaine: Double = 0 // mg
    
    func scaled(by amount: Double) -> NutrientContent {
        var scaled = self
        scaled.calories *= amount / 100.0
        scaled.protein *= amount / 100.0
        scaled.carbohydrates *= amount / 100.0
        scaled.fats *= amount / 100.0
        scaled.fiber *= amount / 100.0
        scaled.vitaminA *= amount / 100.0
        scaled.vitaminC *= amount / 100.0
        scaled.vitaminD *= amount / 100.0
        scaled.vitaminE *= amount / 100.0
        scaled.vitaminK *= amount / 100.0
        scaled.thiamin *= amount / 100.0
        scaled.riboflavin *= amount / 100.0
        scaled.niacin *= amount / 100.0
        scaled.vitaminB6 *= amount / 100.0
        scaled.folate *= amount / 100.0
        scaled.vitaminB12 *= amount / 100.0
        scaled.calcium *= amount / 100.0
        scaled.iron *= amount / 100.0
        scaled.magnesium *= amount / 100.0
        scaled.phosphorus *= amount / 100.0
        scaled.potassium *= amount / 100.0
        scaled.sodium *= amount / 100.0
        scaled.zinc *= amount / 100.0
        scaled.copper *= amount / 100.0
        scaled.manganese *= amount / 100.0
        scaled.selenium *= amount / 100.0
        scaled.omega3 *= amount / 100.0
        scaled.omega6 *= amount / 100.0
        scaled.choline *= amount / 100.0
        scaled.betaine *= amount / 100.0
        return scaled
    }
    
    static func + (lhs: NutrientContent, rhs: NutrientContent) -> NutrientContent {
        var result = NutrientContent()
        result.calories = lhs.calories + rhs.calories
        result.protein = lhs.protein + rhs.protein
        result.carbohydrates = lhs.carbohydrates + rhs.carbohydrates
        result.fats = lhs.fats + rhs.fats
        result.fiber = lhs.fiber + rhs.fiber
        result.vitaminA = lhs.vitaminA + rhs.vitaminA
        result.vitaminC = lhs.vitaminC + rhs.vitaminC
        result.vitaminD = lhs.vitaminD + rhs.vitaminD
        result.vitaminE = lhs.vitaminE + rhs.vitaminE
        result.vitaminK = lhs.vitaminK + rhs.vitaminK
        result.thiamin = lhs.thiamin + rhs.thiamin
        result.riboflavin = lhs.riboflavin + rhs.riboflavin
        result.niacin = lhs.niacin + rhs.niacin
        result.vitaminB6 = lhs.vitaminB6 + rhs.vitaminB6
        result.folate = lhs.folate + rhs.folate
        result.vitaminB12 = lhs.vitaminB12 + rhs.vitaminB12
        result.calcium = lhs.calcium + rhs.calcium
        result.iron = lhs.iron + rhs.iron
        result.magnesium = lhs.magnesium + rhs.magnesium
        result.phosphorus = lhs.phosphorus + rhs.phosphorus
        result.potassium = lhs.potassium + rhs.potassium
        result.sodium = lhs.sodium + rhs.sodium
        result.zinc = lhs.zinc + rhs.zinc
        result.copper = lhs.copper + rhs.copper
        result.manganese = lhs.manganese + rhs.manganese
        result.selenium = lhs.selenium + rhs.selenium
        result.omega3 = lhs.omega3 + rhs.omega3
        result.omega6 = lhs.omega6 + rhs.omega6
        result.choline = lhs.choline + rhs.choline
        result.betaine = lhs.betaine + rhs.betaine
        return result
    }
}

// MARK: - Food Item
struct Food: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: FoodCategory
    let nutrientContent: NutrientContent // per 100g
    let properties: FoodProperties
    let isAncient: Bool // for ancient herbs, etc.
    
    init(id: UUID = UUID(), name: String, category: FoodCategory, nutrientContent: NutrientContent, properties: FoodProperties, isAncient: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.nutrientContent = nutrientContent
        self.properties = properties
        self.isAncient = isAncient
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Food, rhs: Food) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Food Database
class FoodDatabase {
    static let shared = FoodDatabase()
    
    var foods: [Food] = []
    
    private init() {
        loadFoods()
    }
    
    private func loadFoods() {
        // Vegetables
        foods.append(contentsOf: [
            Food(name: "Spinach", category: .vegetable,
                 nutrientContent: NutrientContent(calories: 23, protein: 2.9, carbohydrates: 3.6, fats: 0.4, fiber: 2.2,
                                                 vitaminA: 469, vitaminC: 28.1, vitaminK: 482.9, folate: 194,
                                                 calcium: 99, iron: 2.7, magnesium: 79, potassium: 558),
                 properties: FoodProperties(tasteScore: 7.0, digestionScore: 8.0,
                                          pros: ["High in iron", "Rich in antioxidants", "Low calorie"],
                                          cons: ["Oxalates may interfere with calcium"],
                                          seasonalAvailability: [.spring, .summer, .fall])),
            
            Food(name: "Broccoli", category: .vegetable,
                 nutrientContent: NutrientContent(calories: 34, protein: 2.8, carbohydrates: 7, fats: 0.4, fiber: 2.6,
                                                 vitaminA: 31, vitaminC: 89.2, vitaminK: 101.6, folate: 63,
                                                 calcium: 47, iron: 0.7, magnesium: 21, potassium: 316),
                 properties: FoodProperties(tasteScore: 6.5, digestionScore: 7.0,
                                          pros: ["High in vitamin C", "Cancer-fighting compounds"],
                                          cons: ["May cause gas"],
                                          seasonalAvailability: [.fall, .winter, .spring])),
            
            Food(name: "Sweet Potato", category: .vegetable,
                 nutrientContent: NutrientContent(calories: 86, protein: 1.6, carbohydrates: 20, fats: 0.1, fiber: 3,
                                                 vitaminA: 709, vitaminC: 2.4, potassium: 337),
                 properties: FoodProperties(tasteScore: 9.0, digestionScore: 8.5,
                                          pros: ["High in beta-carotene", "Complex carbs"],
                                          cons: ["Higher in carbs"],
                                          seasonalAvailability: [.fall, .winter])),
        ])
        
        // Fruits
        foods.append(contentsOf: [
            Food(name: "Blueberries", category: .fruit,
                 nutrientContent: NutrientContent(calories: 57, protein: 0.7, carbohydrates: 14, fats: 0.3, fiber: 2.4,
                                                 vitaminC: 9.7, vitaminK: 19.3, manganese: 0.3),
                 properties: FoodProperties(tasteScore: 9.5, digestionScore: 9.0,
                                          pros: ["High in antioxidants", "Low calorie"],
                                          cons: ["Can be expensive"],
                                          seasonalAvailability: [.summer])),
            
            Food(name: "Banana", category: .fruit,
                 nutrientContent: NutrientContent(calories: 89, protein: 1.1, carbohydrates: 23, fats: 0.3, fiber: 2.6,
                                                 vitaminC: 8.7, vitaminB6: 0.4, potassium: 358),
                 properties: FoodProperties(tasteScore: 8.5, digestionScore: 9.5,
                                          pros: ["High in potassium", "Easy to digest"],
                                          cons: ["Higher in sugar"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
        ])
        
        // Grains
        foods.append(contentsOf: [
            Food(name: "Quinoa", category: .grain,
                 nutrientContent: NutrientContent(calories: 368, protein: 14, carbohydrates: 64, fats: 6, fiber: 7,
                                                 vitaminB6: 0.5, folate: 184, magnesium: 197, phosphorus: 457, potassium: 563),
                 properties: FoodProperties(tasteScore: 7.5, digestionScore: 8.0,
                                          pros: ["Complete protein", "Gluten-free"],
                                          cons: ["Higher in calories"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
            
            Food(name: "Brown Rice", category: .grain,
                 nutrientContent: NutrientContent(calories: 111, protein: 2.6, carbohydrates: 23, fats: 0.9, fiber: 1.8,
                                                 vitaminB6: 0.2, magnesium: 43, phosphorus: 83),
                 properties: FoodProperties(tasteScore: 7.0, digestionScore: 7.5,
                                          pros: ["Whole grain", "Filling"],
                                          cons: ["Lower in protein"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
        ])
        
        // Ancient Herbs
        foods.append(contentsOf: [
            Food(name: "Turmeric", category: .herb,
                 nutrientContent: NutrientContent(calories: 354, protein: 7.8, carbohydrates: 65, fats: 9.9, fiber: 21,
                                                 vitaminC: 0.7, vitaminE: 4.4, vitaminK: 13.4,
                                                 calcium: 183, iron: 41.4, magnesium: 193, phosphorus: 268, potassium: 2525),
                 properties: FoodProperties(tasteScore: 6.0, digestionScore: 8.5,
                                          pros: ["Anti-inflammatory", "Curcumin benefits"],
                                          cons: ["Strong flavor"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter]),
                 isAncient: true),
            
            Food(name: "Ginger", category: .herb,
                 nutrientContent: NutrientContent(calories: 80, protein: 1.8, carbohydrates: 18, fats: 0.8, fiber: 2,
                                                 vitaminC: 5, vitaminB6: 0.2,
                                                 calcium: 16, iron: 0.6, magnesium: 43, phosphorus: 34, potassium: 415),
                 properties: FoodProperties(tasteScore: 7.0, digestionScore: 9.0,
                                          pros: ["Aids digestion", "Anti-nausea"],
                                          cons: ["Spicy"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter]),
                 isAncient: true),
            
            Food(name: "Ashwagandha", category: .herb,
                 nutrientContent: NutrientContent(calories: 245, protein: 3.9, carbohydrates: 50, fats: 0.9, fiber: 32,
                                                 calcium: 23, iron: 3.3),
                 properties: FoodProperties(tasteScore: 4.0, digestionScore: 7.0,
                                          pros: ["Adaptogen", "Stress reduction"],
                                          cons: ["Bitter taste"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter]),
                 isAncient: true),
        ])
        
        // Spices
        foods.append(contentsOf: [
            Food(name: "Cinnamon", category: .spice,
                 nutrientContent: NutrientContent(calories: 247, protein: 4, carbohydrates: 81, fats: 1.2, fiber: 53,
                                                 calcium: 1002, iron: 8.3, magnesium: 60, manganese: 17.5),
                 properties: FoodProperties(tasteScore: 9.0, digestionScore: 8.0,
                                          pros: ["Blood sugar regulation", "Antioxidants"],
                                          cons: ["High in coumarin if overused"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
            
            Food(name: "Garlic", category: .spice,
                 nutrientContent: NutrientContent(calories: 149, protein: 6.4, carbohydrates: 33, fats: 0.5, fiber: 2.1,
                                                 vitaminC: 31.2, vitaminB6: 1.2,
                                                 calcium: 181, iron: 1.7, magnesium: 25, phosphorus: 153, potassium: 401, manganese: 1.7, selenium: 14.2),
                 properties: FoodProperties(tasteScore: 7.5, digestionScore: 6.5,
                                          pros: ["Immune support", "Cardiovascular health"],
                                          cons: ["Strong odor", "May cause heartburn"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
        ])
        
        // Legumes
        foods.append(contentsOf: [
            Food(name: "Lentils", category: .legume,
                 nutrientContent: NutrientContent(calories: 116, protein: 9, carbohydrates: 20, fats: 0.4, fiber: 7.9,
                                                 folate: 181, iron: 3.3, magnesium: 36, phosphorus: 180, potassium: 369),
                 properties: FoodProperties(tasteScore: 7.0, digestionScore: 7.5,
                                          pros: ["High protein", "High fiber"],
                                          cons: ["May cause gas"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
            
            Food(name: "Chickpeas", category: .legume,
                 nutrientContent: NutrientContent(calories: 164, protein: 8.9, carbohydrates: 27, fats: 2.6, fiber: 7.6,
                                                 folate: 172, iron: 2.9, magnesium: 48, phosphorus: 168, potassium: 291),
                 properties: FoodProperties(tasteScore: 8.0, digestionScore: 7.0,
                                          pros: ["High protein", "Versatile"],
                                          cons: ["May cause bloating"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
        ])
        
        // Nuts
        foods.append(contentsOf: [
            Food(name: "Almonds", category: .nut,
                 nutrientContent: NutrientContent(calories: 579, protein: 21, carbohydrates: 22, fats: 50, fiber: 12,
                                                 vitaminE: 25.6, calcium: 269, iron: 3.7, magnesium: 270, phosphorus: 481, potassium: 733),
                 properties: FoodProperties(tasteScore: 8.5, digestionScore: 7.0,
                                          pros: ["High in healthy fats", "Rich in vitamin E"],
                                          cons: ["High calorie", "May cause allergies"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
            
            Food(name: "Walnuts", category: .nut,
                 nutrientContent: NutrientContent(calories: 654, protein: 15, carbohydrates: 14, fats: 65, fiber: 6.7,
                                                 vitaminB6: 0.5, folate: 98,
                                                 calcium: 98, iron: 2.9, magnesium: 158, phosphorus: 346, potassium: 441, omega3: 9.1),
                 properties: FoodProperties(tasteScore: 8.0, digestionScore: 6.5,
                                          pros: ["High in omega-3", "Brain health"],
                                          cons: ["High calorie"],
                                          seasonalAvailability: [.fall, .winter])),
        ])
        
        // Protein sources
        foods.append(contentsOf: [
            Food(name: "Salmon", category: .protein,
                 nutrientContent: NutrientContent(calories: 208, protein: 20, carbohydrates: 0, fats: 12, fiber: 0,
                                                 vitaminD: 13, niacin: 8.5, vitaminB6: 0.6, vitaminB12: 3.2,
                                                 phosphorus: 200, potassium: 363, selenium: 36.5, omega3: 2.3),
                 properties: FoodProperties(tasteScore: 9.0, digestionScore: 9.0,
                                          pros: ["High in omega-3", "Complete protein"],
                                          cons: ["Mercury concerns if farmed"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
            
            Food(name: "Chicken Breast", category: .protein,
                 nutrientContent: NutrientContent(calories: 165, protein: 31, carbohydrates: 0, fats: 3.6, fiber: 0,
                                                 niacin: 14.8, vitaminB6: 0.6, phosphorus: 220, selenium: 24.3),
                 properties: FoodProperties(tasteScore: 8.5, digestionScore: 9.0,
                                          pros: ["Lean protein", "Versatile"],
                                          cons: ["Lower in omega-3"],
                                          seasonalAvailability: [.spring, .summer, .fall, .winter])),
        ])
    }
    
    func foodsForSeason(_ season: Season) -> [Food] {
        foods.filter { $0.properties.seasonalAvailability.contains(season) }
    }
}
