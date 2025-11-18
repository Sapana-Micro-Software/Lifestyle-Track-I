//
//  SiriKitHandler.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
import Intents

#if canImport(Intents) && os(iOS)
// MARK: - SiriKit Intent Handler
class SiriKitHandler: NSObject {
    static let shared = SiriKitHandler()
    private let controller = DietSolverController()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Intent Handlers
    
    func handleHealthStatusIntent(_ intent: INHealthStatusIntent) -> INHealthStatusIntentResponse {
        let response = INHealthStatusIntentResponse(code: .success, userActivity: nil)
        
        if let healthData = controller.healthData {
            let status = "Your health status: Age \(healthData.age), Weight \(String(format: "%.1f", healthData.weight)) kg"
            response.healthStatus = status
        } else {
            response.healthStatus = "No health data available"
        }
        
        return response
    }
    
    func handleBadgeStatusIntent(_ intent: INBadgeStatusIntent) -> INBadgeStatusIntentResponse {
        let response = INBadgeStatusIntentResponse(code: .success, userActivity: nil)
        let earnedBadges = controller.getEarnedBadges()
        
        if earnedBadges.isEmpty {
            response.badgeStatus = "You have no badges yet. Keep working on your health goals!"
        } else {
            response.badgeStatus = "You have earned \(earnedBadges.count) badge\(earnedBadges.count == 1 ? "" : "s")"
        }
        
        return response
    }
    
    func handleDietPlanIntent(_ intent: INDietPlanIntent) -> INDietPlanIntentResponse {
        let response = INDietPlanIntentResponse(code: .success, userActivity: nil)
        
        if let plan = controller.dietPlan {
            let mealCount = plan.meals.count
            let calories = Int(plan.totalNutrients.calories)
            response.dietPlan = "You have \(mealCount) meals planned today with \(calories) calories"
        } else {
            response.dietPlan = "No diet plan available. Please generate a plan first."
        }
        
        return response
    }
}

// MARK: - Intent Handler Protocol Conformance
extension SiriKitHandler: INHealthStatusIntentHandling {
    func handle(intent: INHealthStatusIntent, completion: @escaping (INHealthStatusIntentResponse) -> Void) {
        let response = handleHealthStatusIntent(intent)
        completion(response)
    }
}

extension SiriKitHandler: INBadgeStatusIntentHandling {
    func handle(intent: INBadgeStatusIntent, completion: @escaping (INBadgeStatusIntentResponse) -> Void) {
        let response = handleBadgeStatusIntent(intent)
        completion(response)
    }
}

extension SiriKitHandler: INDietPlanIntentHandling {
    func handle(intent: INDietPlanIntent, completion: @escaping (INDietPlanIntentResponse) -> Void) {
        let response = handleDietPlanIntent(intent)
        completion(response)
    }
}

// MARK: - Intent Definitions (would be in separate .intentdefinition file in Xcode)
// These are placeholder structs representing the intent definitions
// In a real project, these would be generated from an .intentdefinition file

struct INHealthStatusIntent {
    // Intent properties would be defined here
}

struct INHealthStatusIntentResponse {
    let code: INHealthStatusIntentResponseCode
    let userActivity: NSUserActivity?
    var healthStatus: String?
    
    enum INHealthStatusIntentResponseCode {
        case success
        case failure
        case unspecified
    }
}

struct INBadgeStatusIntent {
    // Intent properties would be defined here
}

struct INBadgeStatusIntentResponse {
    let code: INBadgeStatusIntentResponseCode
    let userActivity: NSUserActivity?
    var badgeStatus: String?
    
    enum INBadgeStatusIntentResponseCode {
        case success
        case failure
        case unspecified
    }
}

struct INDietPlanIntent {
    // Intent properties would be defined here
}

struct INDietPlanIntentResponse {
    let code: INDietPlanIntentResponseCode
    let userActivity: NSUserActivity?
    var dietPlan: String?
    
    enum INDietPlanIntentResponseCode {
        case success
        case failure
        case unspecified
    }
}

protocol INHealthStatusIntentHandling {
    func handle(intent: INHealthStatusIntent, completion: @escaping (INHealthStatusIntentResponse) -> Void)
}

protocol INBadgeStatusIntentHandling {
    func handle(intent: INBadgeStatusIntent, completion: @escaping (INBadgeStatusIntentResponse) -> Void)
}

protocol INDietPlanIntentHandling {
    func handle(intent: INDietPlanIntent, completion: @escaping (INDietPlanIntentResponse) -> Void)
}
#else
// SiriKit not available on this platform
#endif
