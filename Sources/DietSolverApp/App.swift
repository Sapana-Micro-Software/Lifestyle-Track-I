//
//  App.swift
//  HealthAndWellnessLifestyleSolverApp
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax
import DietSolver // Import DietSolver module containing core health and wellness lifestyle optimization functionality
#if os(macOS)
import AppKit // Import AppKit framework for macOS window management
#endif

@main // Mark this struct as the entry point for the application executable
struct HealthAndWellnessLifestyleSolverAppMain: App { // Define main app struct conforming to App protocol for SwiftUI lifecycle
    var body: some Scene { // Define body property returning Scene for app window management
        WindowGroup { // Create window group scene for main application window
            ContentView() // Instantiate and display main content view as root view
                .frame(minWidth: 800, minHeight: 600) // Set minimum window size for macOS
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full window coverage
                .background(Color(red: 0.98, green: 0.98, blue: 0.99)) // Set background color
                .onAppear {
                    #if os(macOS)
                    // Bring window to front on macOS
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApplication.shared.setActivationPolicy(.regular)
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        // Get all windows and bring them forward
                        for window in NSApplication.shared.windows {
                            window.makeKeyAndOrderFront(nil)
                            window.center()
                        }
                        // If no windows exist yet, create one
                        if NSApplication.shared.windows.isEmpty {
                            NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
                        }
                    }
                    #endif
                }
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 700) // Set default window size for macOS
        .windowStyle(.automatic) // Use automatic window style
        .windowResizability(.contentSize) // Allow window resizing
        #endif
    }
}
