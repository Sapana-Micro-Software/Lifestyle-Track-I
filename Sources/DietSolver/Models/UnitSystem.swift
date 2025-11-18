//
//  UnitSystem.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Unit System
enum UnitSystem: String, Codable, CaseIterable { // Define UnitSystem enum conforming to Codable and CaseIterable
    case metric = "Metric" // Metric system (kg, cm, liters, Celsius)
    case imperial = "Imperial" // Imperial system (lbs, ft/in, gallons, Fahrenheit)
    
    // MARK: - Weight Units
    var weightUnit: String { // Computed property for weight unit label
        switch self { // Switch on unit system
        case .metric: return "kg" // Return kilograms for metric
        case .imperial: return "lbs" // Return pounds for imperial
        }
    }
    
    // MARK: - Height Units
    var heightUnit: String { // Computed property for height unit label
        switch self { // Switch on unit system
        case .metric: return "cm" // Return centimeters for metric
        case .imperial: return "ft/in" // Return feet/inches for imperial
        }
    }
    
    // MARK: - Volume Units
    var volumeUnit: String { // Computed property for volume unit label
        switch self { // Switch on unit system
        case .metric: return "liters" // Return liters for metric
        case .imperial: return "gallons" // Return gallons for imperial
        }
    }
    
    // MARK: - Temperature Units
    var temperatureUnit: String { // Computed property for temperature unit label
        switch self { // Switch on unit system
        case .metric: return "°C" // Return Celsius for metric
        case .imperial: return "°F" // Return Fahrenheit for imperial
        }
    }
    
    // MARK: - Distance Units
    var distanceUnit: String { // Computed property for distance unit label
        switch self { // Switch on unit system
        case .metric: return "km" // Return kilometers for metric
        case .imperial: return "miles" // Return miles for imperial
        }
    }
}

// MARK: - Unit Converter
class UnitConverter { // Define UnitConverter class for unit conversions
    static let shared = UnitConverter() // Shared singleton instance
    
    private init() {} // Private initializer for singleton pattern
    
    // MARK: - Weight Conversions
    func convertWeight(_ value: Double, from: UnitSystem, to: UnitSystem) -> Double { // Convert weight between systems
        guard from != to else { return value } // Return original value if systems match
        switch (from, to) { // Switch on source and target systems
        case (.metric, .imperial): return value * 2.20462 // Convert kg to lbs
        case (.imperial, .metric): return value / 2.20462 // Convert lbs to kg
        default: return value // Return original value for same system
        }
    }
    
    // MARK: - Height Conversions
    func convertHeight(_ value: Double, from: UnitSystem, to: UnitSystem) -> Double { // Convert height between systems
        guard from != to else { return value } // Return original value if systems match
        switch (from, to) { // Switch on source and target systems
        case (.metric, .imperial): return value / 2.54 // Convert cm to inches
        case (.imperial, .metric): return value * 2.54 // Convert inches to cm
        default: return value // Return original value for same system
        }
    }
    
    // MARK: - Height to Feet/Inches
    func heightToFeetInches(_ inches: Double) -> (feet: Int, inches: Double) { // Convert total inches to feet and inches
        let feet = Int(inches / 12) // Calculate whole feet
        let remainingInches = inches.truncatingRemainder(dividingBy: 12) // Calculate remaining inches
        return (feet, remainingInches) // Return tuple of feet and inches
    }
    
    // MARK: - Feet/Inches to Height
    func feetInchesToHeight(feet: Int, inches: Double) -> Double { // Convert feet and inches to total inches
        return Double(feet) * 12 + inches // Calculate total inches
    }
    
    // MARK: - Volume Conversions
    func convertVolume(_ value: Double, from: UnitSystem, to: UnitSystem) -> Double { // Convert volume between systems
        guard from != to else { return value } // Return original value if systems match
        switch (from, to) { // Switch on source and target systems
        case (.metric, .imperial): return value * 0.264172 // Convert liters to gallons
        case (.imperial, .metric): return value / 0.264172 // Convert gallons to liters
        default: return value // Return original value for same system
        }
    }
    
    // MARK: - Temperature Conversions
    func convertTemperature(_ value: Double, from: UnitSystem, to: UnitSystem) -> Double { // Convert temperature between systems
        guard from != to else { return value } // Return original value if systems match
        switch (from, to) { // Switch on source and target systems
        case (.metric, .imperial): return (value * 9/5) + 32 // Convert Celsius to Fahrenheit
        case (.imperial, .metric): return (value - 32) * 5/9 // Convert Fahrenheit to Celsius
        default: return value // Return original value for same system
        }
    }
    
    // MARK: - Distance Conversions
    func convertDistance(_ value: Double, from: UnitSystem, to: UnitSystem) -> Double { // Convert distance between systems
        guard from != to else { return value } // Return original value if systems match
        switch (from, to) { // Switch on source and target systems
        case (.metric, .imperial): return value * 0.621371 // Convert km to miles
        case (.imperial, .metric): return value / 0.621371 // Convert miles to km
        default: return value // Return original value for same system
        }
    }
    
    // MARK: - Format Weight
    func formatWeight(_ value: Double, system: UnitSystem) -> String { // Format weight for display
        switch system { // Switch on unit system
        case .metric: return String(format: "%.1f kg", value) // Format as kg
        case .imperial: return String(format: "%.1f lbs", value) // Format as lbs
        }
    }
    
    // MARK: - Format Height
    func formatHeight(_ value: Double, system: UnitSystem) -> String { // Format height for display
        switch system { // Switch on unit system
        case .metric: return String(format: "%.1f cm", value) // Format as cm
        case .imperial: // Format as feet and inches
            let (feet, inches) = heightToFeetInches(value) // Convert to feet and inches
            return String(format: "%d' %.1f\"", feet, inches) // Format as feet and inches
        }
    }
    
    // MARK: - Format Volume
    func formatVolume(_ value: Double, system: UnitSystem) -> String { // Format volume for display
        switch system { // Switch on unit system
        case .metric: return String(format: "%.2f L", value) // Format as liters
        case .imperial: return String(format: "%.2f gal", value) // Format as gallons
        }
    }
}
