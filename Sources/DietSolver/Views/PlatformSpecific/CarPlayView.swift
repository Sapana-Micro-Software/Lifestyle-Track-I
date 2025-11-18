//
//  CarPlayView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

#if canImport(CarPlay) && os(iOS)
import CarPlay

// MARK: - CarPlay Integration
class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        // Create CarPlay UI
        let template = createCarPlayTemplate()
        interfaceController.setRootTemplate(template, animated: true)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        // Cleanup
    }
    
    private func createCarPlayTemplate() -> CPTemplate {
        let controller = DietSolverController()
        let badges = controller.getEarnedBadges()
        
        var items: [CPListItem] = []
        
        // Health Summary
        let healthItem = CPListItem(text: "Health Summary", detailText: "View your health status")
        items.append(healthItem)
        
        // Badges
        if !badges.isEmpty {
            let badgesItem = CPListItem(text: "Badges", detailText: "\(badges.count) badges earned")
            items.append(badgesItem)
        }
        
        // Today's Plan
        if let plan = controller.dietPlan {
            let planItem = CPListItem(text: "Today's Plan", detailText: "\(plan.meals.count) meals planned")
            items.append(planItem)
        }
        
        let listTemplate = CPListTemplate(title: "Lifestyle Track", sections: [CPListSection(items: items)])
        return listTemplate
    }
}
#else
// CarPlay not available on this platform
#endif

// MARK: - CarPlay SwiftUI View (for preview/testing)
struct CarPlayContentView: View {
    @StateObject private var controller = DietSolverController()
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Lifestyle Track")
                .font(.headline)
            
            if let plan = controller.dietPlan {
                VStack(spacing: 8) {
                    Text("Today's Plan")
                        .font(.subheadline)
                    Text("\(plan.meals.count) meals")
                        .font(.title3)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            if !controller.getEarnedBadges().isEmpty {
                VStack(spacing: 8) {
                    Text("Badges")
                        .font(.subheadline)
                    Text("\(controller.getEarnedBadges().count) earned")
                        .font(.title3)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(12)
    }
}
