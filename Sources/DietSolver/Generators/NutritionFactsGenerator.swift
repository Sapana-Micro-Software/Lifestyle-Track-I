import Foundation

// MARK: - Nutrition Facts Generator
class NutritionFactsGenerator {
    static func generateNutritionFacts(for plan: DailyDietPlan, requirements: [String: NutrientRequirement]) -> String {
        let nutrients = plan.totalNutrients
        
        var facts = "# 📊 Daily Nutrition Facts\n\n"
        facts += "## Summary\n\n"
        
        // Check if all requirements are met
        let allMet = checkAllRequirements(nutrients: nutrients, requirements: requirements)
        
        if allMet {
            facts += "✅ **All nutrient requirements met!**\n\n"
            facts += "This diet plan provides optimal nutrition for:\n"
            facts += "- ✨ Healthy skin (Vitamins A, C, E)\n"
            facts += "- 🩸 Healthy blood (Iron, B vitamins)\n"
            facts += "- 🦴 Strong bones (Calcium, Vitamin D, Magnesium)\n"
            facts += "- 💪 Strong muscles (Protein, Potassium)\n\n"
        } else {
            facts += "⚠️ **Some nutrients may need adjustment**\n\n"
        }
        
        facts += "---\n\n"
        
        // Calories
        facts += "## Calories\n\n"
        if let req = requirements["calories"] {
            let percentage = (nutrients.calories / req.dailyValue) * 100
            facts += "**\(String(format: "%.0f", nutrients.calories)) kcal** / \(String(format: "%.0f", req.dailyValue)) kcal (\(String(format: "%.1f", percentage))%)\n\n"
        }
        
        // Macronutrients
        facts += "## Macronutrients\n\n"
        facts += generateNutrientLine("Protein", value: nutrients.protein, requirement: requirements["protein"], unit: "g")
        facts += generateNutrientLine("Carbohydrates", value: nutrients.carbohydrates, requirement: requirements["carbs"], unit: "g")
        facts += generateNutrientLine("Fats", value: nutrients.fats, requirement: requirements["fats"], unit: "g")
        facts += generateNutrientLine("Fiber", value: nutrients.fiber, requirement: requirements["fiber"], unit: "g")
        
        facts += "\n---\n\n"
        
        // Vitamins
        facts += "## Vitamins\n\n"
        facts += generateNutrientLine("Vitamin A", value: nutrients.vitaminA, requirement: requirements["vitamin_a"], unit: "mcg")
        facts += generateNutrientLine("Vitamin C", value: nutrients.vitaminC, requirement: requirements["vitamin_c"], unit: "mg")
        facts += generateNutrientLine("Vitamin D", value: nutrients.vitaminD, requirement: requirements["vitamin_d"], unit: "mcg")
        facts += generateNutrientLine("Vitamin E", value: nutrients.vitaminE, requirement: requirements["vitamin_e"], unit: "mg")
        facts += generateNutrientLine("Vitamin K", value: nutrients.vitaminK, requirement: requirements["vitamin_k"], unit: "mcg")
        facts += generateNutrientLine("Thiamin (B1)", value: nutrients.thiamin, requirement: requirements["thiamin"], unit: "mg")
        facts += generateNutrientLine("Riboflavin (B2)", value: nutrients.riboflavin, requirement: requirements["riboflavin"], unit: "mg")
        facts += generateNutrientLine("Niacin (B3)", value: nutrients.niacin, requirement: requirements["niacin"], unit: "mg")
        facts += generateNutrientLine("Vitamin B6", value: nutrients.vitaminB6, requirement: requirements["vitamin_b6"], unit: "mg")
        facts += generateNutrientLine("Folate (B9)", value: nutrients.folate, requirement: requirements["folate"], unit: "mcg")
        facts += generateNutrientLine("Vitamin B12", value: nutrients.vitaminB12, requirement: requirements["vitamin_b12"], unit: "mcg")
        
        facts += "\n---\n\n"
        
        // Minerals
        facts += "## Minerals\n\n"
        facts += generateNutrientLine("Calcium", value: nutrients.calcium, requirement: requirements["calcium"], unit: "mg")
        facts += generateNutrientLine("Iron", value: nutrients.iron, requirement: requirements["iron"], unit: "mg")
        facts += generateNutrientLine("Magnesium", value: nutrients.magnesium, requirement: requirements["magnesium"], unit: "mg")
        facts += generateNutrientLine("Phosphorus", value: nutrients.phosphorus, requirement: requirements["phosphorus"], unit: "mg")
        facts += generateNutrientLine("Potassium", value: nutrients.potassium, requirement: requirements["potassium"], unit: "mg")
        facts += generateNutrientLine("Sodium", value: nutrients.sodium, requirement: requirements["sodium"], unit: "mg")
        facts += generateNutrientLine("Zinc", value: nutrients.zinc, requirement: requirements["zinc"], unit: "mg")
        facts += generateNutrientLine("Copper", value: nutrients.copper, requirement: requirements["copper"], unit: "mg")
        facts += generateNutrientLine("Manganese", value: nutrients.manganese, requirement: requirements["manganese"], unit: "mg")
        facts += generateNutrientLine("Selenium", value: nutrients.selenium, requirement: requirements["selenium"], unit: "mcg")
        
        facts += "\n---\n\n"
        
        // Health Scores
        facts += "## Meal Quality Scores\n\n"
        facts += "**Taste Score:** \(String(format: "%.1f", plan.overallTasteScore)) / 10.0\n"
        facts += "**Digestion Score:** \(String(format: "%.1f", plan.overallDigestionScore)) / 10.0\n"
        
        return facts
    }
    
    private static func generateNutrientLine(_ name: String, value: Double, requirement: NutrientRequirement?, unit: String) -> String {
        guard let req = requirement else {
            return "**\(name):** \(String(format: "%.2f", value)) \(unit)\n"
        }
        
        let percentage = (value / req.dailyValue) * 100
        let status = percentage >= 90 ? "✅" : percentage >= 70 ? "⚠️" : "❌"
        
        return "\(status) **\(name):** \(String(format: "%.2f", value)) \(unit) / \(String(format: "%.2f", req.dailyValue)) \(unit) (\(String(format: "%.1f", percentage))%)\n"
    }
    
    private static func checkAllRequirements(nutrients: NutrientContent, requirements: [String: NutrientRequirement]) -> Bool {
        let criticalNutrients = [
            "calories", "protein", "vitamin_c", "vitamin_d", "calcium", "iron", "magnesium"
        ]
        
        for key in criticalNutrients {
            if let req = requirements[key] {
                let value: Double
                switch key {
                case "calories": value = nutrients.calories
                case "protein": value = nutrients.protein
                case "vitamin_c": value = nutrients.vitaminC
                case "vitamin_d": value = nutrients.vitaminD
                case "calcium": value = nutrients.calcium
                case "iron": value = nutrients.iron
                case "magnesium": value = nutrients.magnesium
                default: continue
                }
                
                if value < req.dailyValue * 0.8 {
                    return false
                }
            }
        }
        
        return true
    }
}
