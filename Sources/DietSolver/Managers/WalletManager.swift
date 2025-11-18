//
//  WalletManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
#if os(iOS)
import PassKit // Import PassKit framework for Wallet and identity document access
#endif

// MARK: - Driver's License Data
struct DriversLicenseData { // Define DriversLicenseData struct for extracted license information
    var dateOfBirth: Date? // Optional date of birth from license
    var age: Int? // Optional calculated age
    var fullName: String? // Optional full name (for verification only, not stored)
    var address: String? // Optional address (for verification only, not stored)
    var licenseNumber: String? // Optional license number (for verification only, not stored)
    var expirationDate: Date? // Optional expiration date
    var issuingState: String? // Optional issuing state
    
    // MARK: - Calculate Age
    func calculateAge() -> Int? { // Calculate age from date of birth
        guard let dob = dateOfBirth else { return nil } // Check if date of birth available
        let calendar = Calendar.current // Get calendar instance
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date()) // Calculate age components
        return ageComponents.year // Return calculated age
    }
}

// MARK: - Wallet Manager
#if os(iOS)
@available(iOS 16.0, *) // Require iOS 16+ for identity document support
class WalletManager: NSObject, ObservableObject { // Define WalletManager class conforming to ObservableObject
    @Published var isAuthorized: Bool = false // Published property for authorization status
    @Published var licenseData: DriversLicenseData? // Published property for extracted license data
    @Published var errorMessage: String? // Published property for error messages
    
    // MARK: - Request Authorization
    func requestAuthorization() async -> Bool { // Request authorization for identity document access
        do { // Begin do-catch block for error handling
            let authorizationResult = try await PKIdentityAuthorizationController.requestAuthorization(for: [.driversLicense]) // Request authorization
            
            await MainActor.run { // Switch to main actor
                self.isAuthorized = authorizationResult == .authorized // Update authorization status
            }
            
            return authorizationResult == .authorized // Return authorization result
        } catch { // Catch any errors
            await MainActor.run { // Switch to main actor
                self.errorMessage = "Failed to request authorization: \(error.localizedDescription)" // Set error message
                self.isAuthorized = false // Set authorization to false
            }
            return false // Return false on error
        }
    }
    
    // MARK: - Read Driver's License
    func readDriversLicense() async -> DriversLicenseData? { // Read driver's license from Wallet
        // First check authorization
        guard await requestAuthorization() else { // Check if authorized
            await MainActor.run { // Switch to main actor
                self.errorMessage = "Authorization required to read driver's license" // Set error message
            }
            return nil // Return nil if not authorized
        }
        
        do { // Begin do-catch block for error handling
            // Request identity document - only request date of birth for privacy
            let identityElements: [PKIdentityElement] = [.dateOfBirth] // Only request date of birth
            let request = PKIdentityRequest(requestedElements: identityElements) // Create identity request
            
            // Present identity document request
            let result = try await PKIdentityAuthorizationController.requestIdentity(for: request) // Request identity
            
            guard let identityDocument = result.identityDocument else { // Check if identity document received
                await MainActor.run { // Switch to main actor
                    self.errorMessage = "No identity document found in Wallet" // Set error message
                }
                return nil // Return nil if no document
            }
            
            // Extract data from identity document
            var licenseData = DriversLicenseData() // Initialize license data
            
            // Extract date of birth (only data we need)
            if let dobElement = identityDocument.dateOfBirth { // Check if date of birth element available
                licenseData.dateOfBirth = dobElement.value // Set date of birth
                licenseData.age = licenseData.calculateAge() // Calculate age
            }
            
            await MainActor.run { // Switch to main actor
                self.licenseData = licenseData // Update license data
                self.errorMessage = nil // Clear error message
            }
            
            return licenseData // Return extracted license data
        } catch { // Catch any errors
            await MainActor.run { // Switch to main actor
                self.errorMessage = "Failed to read driver's license: \(error.localizedDescription)" // Set error message
                self.licenseData = nil // Clear license data
            }
            return nil // Return nil on error
        }
    }
    
    // MARK: - Check Availability
    static func isAvailable() -> Bool { // Check if Wallet identity documents are available
        if #available(iOS 16.0, *) { // Check iOS version
            return PKIdentityAuthorizationController.canRequestIdentityElements([.driversLicense]) // Check if can request
        }
        return false // Return false if not available
    }
}
#else
// MARK: - Wallet Manager (Unavailable on macOS)
class WalletManager: ObservableObject { // Define WalletManager class for non-iOS platforms
    @Published var isAuthorized: Bool = false // Published property for authorization status
    @Published var licenseData: DriversLicenseData? // Published property for extracted license data
    @Published var errorMessage: String? // Published property for error messages
    
    func readDriversLicense() async -> DriversLicenseData? { // Unavailable on macOS
        await MainActor.run { // Switch to main actor
            self.errorMessage = "Driver's License reading is only available on iOS 16.0 or later" // Set error message
        }
        return nil // Return nil
    }
    
    static func isAvailable() -> Bool { // Check availability
        return false // Return false on non-iOS
    }
}
#endif

// MARK: - Fallback for Older iOS Versions
class WalletManagerFallback: ObservableObject { // Define fallback manager for older iOS versions
    @Published var isAuthorized: Bool = false // Published property for authorization status
    @Published var licenseData: DriversLicenseData? // Published property for extracted license data
    @Published var errorMessage: String? // Published property for error messages
    
    func readDriversLicense() async -> DriversLicenseData? { // Fallback method
        await MainActor.run { // Switch to main actor
            self.errorMessage = "Driver's License reading requires iOS 16.0 or later" // Set error message
        }
        return nil // Return nil
    }
    
    static func isAvailable() -> Bool { // Check availability
        return false // Return false
    }
}
