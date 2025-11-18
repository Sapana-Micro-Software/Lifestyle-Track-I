import Foundation

// MARK: - Song/Sonnet Generator
class SongGenerator {
    static func generateSong(for plan: DailyDietPlan) -> String {
        var song = "# 🎵 A Sonnet of Nourishment 🎵\n\n"
        
        // Create a sonnet (14 lines, ABAB CDCD EFEF GG rhyme scheme)
        let foods = plan.meals.flatMap { $0.items.map { $0.food.name } }
        let uniqueFoods = Array(Set(foods)).prefix(14)
        
        song += generateSonnet(foods: Array(uniqueFoods), plan: plan)
        
        song += "\n\n---\n\n"
        song += "# 🎶 The Recipe Song 🎶\n\n"
        
        for meal in plan.meals {
            song += generateMealVerse(meal: meal)
            song += "\n\n"
        }
        
        return song
    }
    
    private static func generateSonnet(foods: [String], plan: DailyDietPlan) -> String {
        var sonnet = ""
        
        // ABAB
        sonnet += "In \(plan.season.rawValue) days, when nature's gifts we find,\n"
        sonnet += "These foods of earth, so pure and so refined,\n"
        sonnet += "With vitamins and minerals combined,\n"
        sonnet += "A balanced diet for body and mind.\n\n"
        
        // CDCD
        if foods.count > 0 {
            sonnet += "The \(foods[0].lowercased()) bright, the \(foods.count > 1 ? foods[1].lowercased() : "grain") so true,\n"
        } else {
            sonnet += "The vegetables green, the grains so true,\n"
        }
        sonnet += "Each nutrient works to make us new,\n"
        if foods.count > 2 {
            sonnet += "With \(foods[2].lowercased()) and herbs, our health renew.\n\n"
        } else {
            sonnet += "With ancient herbs, our health renew.\n\n"
        }
        
        // EFEF
        sonnet += "For breakfast light, for lunch we dine,\n"
        sonnet += "And dinner brings the day's design,\n"
        sonnet += "Each meal a step, a perfect line,\n"
        sonnet += "To make our bodies truly shine.\n\n"
        
        // GG (couplet)
        sonnet += "So eat with joy, with care, with grace,\n"
        sonnet += "And let this meal your health embrace.\n"
        
        return sonnet
    }
    
    private static func generateMealVerse(meal: Meal) -> String {
        var verse = "🎵 \(meal.name.uppercased()) 🎵\n\n"
        
        let foodNames = meal.items.map { $0.food.name }
        let rhymeWords = generateRhymeWords(for: meal.mealType)
        
        verse += "\(meal.name) time, \(meal.name) time, what shall we eat?\n"
        verse += "\(foodNames.joined(separator: ", ")) - a \(rhymeWords.adjective) treat!\n"
        verse += "Mix them together, make it \(rhymeWords.verb),\n"
        verse += "This meal will make you \(rhymeWords.result)!\n"
        
        return verse
    }
    
    private static func generateRhymeWords(for mealType: Meal.MealType) -> (adjective: String, verb: String, result: String) {
        switch mealType {
        case .breakfast:
            return ("sweet", "complete", "energized and fleet")
        case .lunch:
            return ("bold", "unfold", "strong and controlled")
        case .dinner:
            return ("grand", "expand", "healthy and planned")
        case .snack:
            return ("quick", "pick", "refreshed and slick")
        }
    }
}
