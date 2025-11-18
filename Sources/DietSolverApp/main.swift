//
//  main.swift
//  HealthAndWellnessLifestyleSolverApp
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax
import DietSolver // Import DietSolver module containing core health and wellness lifestyle optimization functionality

@main // Mark this struct as the entry point for the application executable
struct HealthAndWellnessLifestyleSolverAppMain: App { // Define main app struct conforming to App protocol for SwiftUI lifecycle
    var body: some Scene { // Define body property returning Scene for app window management
        WindowGroup { // Create window group scene for main application window
            ContentView() // Instantiate and display main content view as root view
        }
    }
}
