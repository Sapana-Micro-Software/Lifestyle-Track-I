import Foundation

// MARK: - Recipe Generator
class RecipeGenerator {
    static func generateRecipe(for meal: Meal) -> String {
        var recipe = "## \(meal.name)\n\n"
        recipe += "### Ingredients:\n\n"
        
        for item in meal.items {
            let amount = formatAmount(item.amount)
            recipe += "- \(amount) \(item.food.name)\n"
        }
        
        recipe += "\n### Instructions:\n\n"
        recipe += generateInstructions(for: meal)
        
        return recipe
    }
    
    private static func formatAmount(_ grams: Double) -> String {
        if grams < 1 {
            return String(format: "%.1f g", grams)
        } else if grams < 1000 {
            return String(format: "%.0f g", grams)
        } else {
            return String(format: "%.2f kg", grams / 1000.0)
        }
    }
    
    private static func generateInstructions(for meal: Meal) -> String {
        var instructions = ""
        
        // Group by category
        let vegetables = meal.items.filter { $0.food.category == .vegetable }
        let proteins = meal.items.filter { $0.food.category == .protein }
        let grains = meal.items.filter { $0.food.category == .grain }
        let herbs = meal.items.filter { $0.food.category == .herb }
        let spices = meal.items.filter { $0.food.category == .spice }
        let fruits = meal.items.filter { $0.food.category == .fruit }
        
        var step = 1
        
        if !vegetables.isEmpty {
            instructions += "\(step). Prepare vegetables: "
            instructions += vegetables.map { $0.food.name.lowercased() }.joined(separator: ", ")
            instructions += ". Wash and chop as needed.\n\n"
            step += 1
        }
        
        if !grains.isEmpty {
            instructions += "\(step). Cook grains: "
            instructions += grains.map { $0.food.name.lowercased() }.joined(separator: ", ")
            instructions += " according to package instructions.\n\n"
            step += 1
        }
        
        if !proteins.isEmpty {
            instructions += "\(step). Prepare proteins: "
            instructions += proteins.map { $0.food.name.lowercased() }.joined(separator: ", ")
            instructions += ". Season and cook to your preference.\n\n"
            step += 1
        }
        
        if !herbs.isEmpty || !spices.isEmpty {
            instructions += "\(step). Add herbs and spices: "
            let allSeasonings = (herbs + spices).map { $0.food.name.lowercased() }
            instructions += allSeasonings.joined(separator: ", ")
            instructions += " for flavor and health benefits.\n\n"
            step += 1
        }
        
        if !fruits.isEmpty && meal.mealType == .breakfast {
            instructions += "\(step). Add fresh fruits: "
            instructions += fruits.map { $0.food.name.lowercased() }.joined(separator: ", ")
            instructions += " as a refreshing addition.\n\n"
            step += 1
        }
        
        instructions += "\(step). Combine all ingredients, mix well, and serve warm.\n"
        
        return instructions
    }
}
