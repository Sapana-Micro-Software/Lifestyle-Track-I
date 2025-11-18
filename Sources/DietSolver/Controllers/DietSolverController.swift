//
//  DietSolverController.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
import Combine

// MARK: - MVC Controller
class DietSolverController: ObservableObject {
    // Model references
    @Published var healthData: HealthData?
    @Published var dietPlan: DailyDietPlan?
    @Published var exercisePlan: ExercisePlan?
    @Published var badges: [HealthBadge] = []
    
    // Business logic components
    private let solver = DietSolver()
    private let exercisePlanner = ExercisePlanner()
    private let badgeManager = BadgeManager.shared
    
    // View Model (for backward compatibility)
    weak var viewModel: DietSolverViewModel?
    
    init(viewModel: DietSolverViewModel? = nil) {
        self.viewModel = viewModel
        syncWithViewModel()
    }
    
    private func syncWithViewModel() {
        guard let viewModel = viewModel else { return }
        healthData = viewModel.healthData
        dietPlan = viewModel.dietPlan
        exercisePlan = viewModel.exercisePlan
    }
    
    // MARK: - Business Logic Methods
    
    func updateHealthData(_ data: HealthData) {
        healthData = data
        viewModel?.updateHealthData(data)
        HealthHistoryManager.shared.updateHistory(healthData: data)
        evaluateBadges()
    }
    
    func solveDiet(season: Season = .spring) {
        guard let healthData = healthData else { return }
        dietPlan = solver.solve(healthData: healthData, season: season)
        viewModel?.dietPlan = dietPlan
        evaluateBadges()
    }
    
    func generateExercisePlan() {
        guard let healthData = healthData else { return }
        let goals = healthData.exerciseGoals ?? ExerciseGoals()
        exercisePlan = exercisePlanner.generateWeeklyPlan(for: healthData, goals: goals)
        viewModel?.exercisePlan = exercisePlan
        evaluateBadges()
    }
    
    func evaluateBadges() {
        badges = badgeManager.evaluateBadges(
            healthData: healthData,
            dietPlan: dietPlan,
            exercisePlan: exercisePlan
        )
    }
    
    func getEarnedBadges() -> [HealthBadge] {
        return badges.filter { $0.isEarned }
    }
    
    func getBadgesByCategory(_ category: HealthBadge.BadgeCategory) -> [HealthBadge] {
        return badges.filter { $0.category == category }
    }
}
