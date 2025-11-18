//
//  EatingMetrics.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Eating Metrics
struct EatingMetrics: Codable, Identifiable {
    let id: UUID
    var date: Date
    var mealType: MealType
    var duration: Double // Total meal duration in minutes
    var totalBites: Int
    var totalChews: Int
    var averageBitesPerChew: Double {
        guard totalChews > 0 else { return 0 }
        return Double(totalBites) / Double(totalChews)
    }
    var averageChewsPerBite: Double {
        guard totalBites > 0 else { return 0 }
        return Double(totalChews) / Double(totalBites)
    }
    var eatingSpeed: Double { // bites per minute
        guard duration > 0 else { return 0 }
        return Double(totalBites) / duration
    }
    var chewingSpeed: Double { // chews per minute
        guard duration > 0 else { return 0 }
        return Double(totalChews) / duration
    }
    var foodPieces: [FoodPiece] = []
    var averagePieceSize: Double { // cm³
        guard !foodPieces.isEmpty else { return 0 }
        return foodPieces.reduce(0.0) { $0 + $1.volume } / Double(foodPieces.count)
    }
    var notes: String?
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
    
    struct FoodPiece: Codable, Identifiable {
        let id: UUID
        var name: String
        var length: Double // cm
        var width: Double // cm
        var height: Double // cm
        var volume: Double { // cm³
            return length * width * height
        }
        var weight: Double? // grams
        var bites: Int
        var chews: Int
        
        init(id: UUID = UUID(), name: String, length: Double, width: Double, height: Double, weight: Double? = nil, bites: Int, chews: Int) {
            self.id = id
            self.name = name
            self.length = length
            self.width = width
            self.height = height
            self.weight = weight
            self.bites = bites
            self.chews = chews
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), mealType: MealType, duration: Double, totalBites: Int, totalChews: Int, foodPieces: [FoodPiece] = [], notes: String? = nil) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.duration = duration
        self.totalBites = totalBites
        self.totalChews = totalChews
        self.foodPieces = foodPieces
        self.notes = notes
    }
}

// MARK: - Eating Metrics Summary
struct EatingMetricsSummary: Codable {
    var totalMeals: Int
    var averageDuration: Double // minutes
    var averageEatingSpeed: Double // bites per minute
    var averageChewingSpeed: Double // chews per minute
    var averageBitesPerChew: Double
    var averageChewsPerBite: Double
    var averagePieceSize: Double // cm³
    var optimalEatingScore: Double { // 0-100, higher is better
        var score = 50.0
        
        // Optimal eating speed: 15-25 bites per minute
        if averageEatingSpeed >= 15 && averageEatingSpeed <= 25 {
            score += 20.0
        } else if averageEatingSpeed < 15 {
            score += 10.0 - (15 - averageEatingSpeed) * 0.5
        } else {
            score -= (averageEatingSpeed - 25) * 0.5
        }
        
        // Optimal chews per bite: 20-30
        if averageChewsPerBite >= 20 && averageChewsPerBite <= 30 {
            score += 20.0
        } else if averageChewsPerBite < 20 {
            score += 10.0 - (20 - averageChewsPerBite) * 0.5
        } else {
            score -= (averageChewsPerBite - 30) * 0.3
        }
        
        // Optimal meal duration: 20-30 minutes
        if averageDuration >= 20 && averageDuration <= 30 {
            score += 10.0
        } else if averageDuration < 20 {
            score -= (20 - averageDuration) * 0.5
        } else {
            score -= (averageDuration - 30) * 0.3
        }
        
        return min(max(score, 0.0), 100.0)
    }
    
    init(metrics: [EatingMetrics]) {
        self.totalMeals = metrics.count
        guard !metrics.isEmpty else {
            self.averageDuration = 0
            self.averageEatingSpeed = 0
            self.averageChewingSpeed = 0
            self.averageBitesPerChew = 0
            self.averageChewsPerBite = 0
            self.averagePieceSize = 0
            return
        }
        
        self.averageDuration = metrics.reduce(0.0) { $0 + $1.duration } / Double(metrics.count)
        self.averageEatingSpeed = metrics.reduce(0.0) { $0 + $1.eatingSpeed } / Double(metrics.count)
        self.averageChewingSpeed = metrics.reduce(0.0) { $0 + $1.chewingSpeed } / Double(metrics.count)
        self.averageBitesPerChew = metrics.reduce(0.0) { $0 + $1.averageBitesPerChew } / Double(metrics.count)
        self.averageChewsPerBite = metrics.reduce(0.0) { $0 + $1.averageChewsPerBite } / Double(metrics.count)
        self.averagePieceSize = metrics.reduce(0.0) { $0 + $1.averagePieceSize } / Double(metrics.count)
    }
}
