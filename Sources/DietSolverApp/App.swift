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
            ModernContentView() // Instantiate and display main content view as root view
                .frame(minWidth: 800, minHeight: 600) // Set minimum window size for macOS
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full window coverage
                .background(Color(red: 0.98, green: 0.98, blue: 0.99)) // Set background color
                .preferredColorScheme(.light) // Force light mode for consistent black text
                .onAppear {
                    #if os(macOS)
                    // Bring window to front on macOS (with proper error handling)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // Set activation policy first
                        NSApplication.shared.setActivationPolicy(.regular)
                        
                        // Activate application
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                        // Safely get and activate windows with error handling
                        let windows = NSApplication.shared.windows
                        if !windows.isEmpty {
                            for window in windows {
                                // Check if window is valid and visible before manipulating
                                guard window.isVisible || window.canBecomeKey else { continue }
                                
                                // Use try-catch equivalent pattern for safety
                                autoreleasepool {
                                    window.makeKeyAndOrderFront(nil)
                                    // Only center if window is resizable
                                    if window.styleMask.contains(.resizable) {
                                        window.center()
                                    }
                                }
                            }
                        }
                    }
                    #endif
                }
                .onDisappear {
                    #if os(macOS)
                    // Clean up when view disappears to prevent ViewBridge errors
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Allow SwiftUI to properly clean up view hierarchy
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
