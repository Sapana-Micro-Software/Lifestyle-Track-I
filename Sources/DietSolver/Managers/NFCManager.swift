//
//  NFCManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
#if canImport(CoreNFC)
import CoreNFC // Import Core NFC framework for NFC reading capabilities
#endif

// MARK: - NFC Driver's License Data
struct NFCLicenseData { // Define NFCLicenseData struct for NFC-read license information
    var dateOfBirth: Date? // Optional date of birth from license
    var age: Int? // Optional calculated age
    var expirationDate: Date? // Optional expiration date
    var licenseNumber: String? // Optional license number (for verification only)
    var fullName: String? // Optional full name (for verification only, not stored)
    var address: String? // Optional address (for verification only, not stored)
    
    // MARK: - Calculate Age
    func calculateAge() -> Int? { // Calculate age from date of birth
        guard let dob = dateOfBirth else { return nil } // Check if date of birth available
        let calendar = Calendar.current // Get calendar instance
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date()) // Calculate age components
        return ageComponents.year // Return calculated age
    }
}

// MARK: - NFC Manager
#if canImport(CoreNFC)
@available(iOS 11.0, macOS 12.0, *) // Require iOS 11+ or macOS 12+ for Core NFC
class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate { // Define NFCManager class conforming to NFC reader session delegate
    @Published var isScanning: Bool = false // Published property for scanning status
    @Published var licenseData: NFCLicenseData? // Published property for extracted license data
    @Published var errorMessage: String? // Published property for error messages
    @Published var scanProgress: String = "" // Published property for scan progress
    
    private var readerSession: NFCNDEFReaderSession? // Private reader session instance
    private var completionHandler: ((NFCLicenseData?) -> Void)? // Completion handler for scan results
    
    // MARK: - Start NFC Scan
    func startScanning(completion: @escaping (NFCLicenseData?) -> Void) { // Start NFC scanning session
        guard NFCNDEFReaderSession.readingAvailable else { // Check if NFC reading is available
            errorMessage = "NFC reading is not available on this device" // Set error message
            completion(nil) // Call completion with nil
            return // Return early
        }
        
        completionHandler = completion // Store completion handler
        isScanning = true // Set scanning status
        errorMessage = nil // Clear error message
        scanProgress = "Hold your device near the driver's license..." // Set progress message
        
        // Create NFC reader session
        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true) // Create reader session
        readerSession?.alertMessage = "Hold your iPhone near the driver's license to read information" // Set alert message
        readerSession?.begin() // Begin scanning session
    }
    
    // MARK: - Stop Scanning
    func stopScanning() { // Stop NFC scanning session
        readerSession?.invalidate() // Invalidate reader session
        readerSession = nil // Clear reader session
        isScanning = false // Set scanning status to false
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { // Handle detected NDEF messages
        DispatchQueue.main.async { // Switch to main thread
            self.scanProgress = "Reading license data..." // Update progress message
        }
        
        // Parse NDEF messages to extract license data
        var licenseData = NFCLicenseData() // Initialize license data
        
        for message in messages { // Iterate through messages
            for record in message.records { // Iterate through records
                if let payload = String(data: record.payload, encoding: .utf8) { // Convert payload to string
                    // Parse license data from payload
                    // Note: Actual parsing depends on license format (varies by state/country)
                    parseLicensePayload(payload, into: &licenseData) // Parse payload into license data
                }
            }
        }
        
        // Calculate age if date of birth available
        if licenseData.dateOfBirth != nil { // Check if date of birth available
            licenseData.age = licenseData.calculateAge() // Calculate age
        }
        
        DispatchQueue.main.async { // Switch to main thread
            self.licenseData = licenseData // Update license data
            self.isScanning = false // Set scanning status to false
            self.scanProgress = licenseData.age != nil ? "License data read successfully!" : "Partial data read" // Update progress
            self.completionHandler?(licenseData) // Call completion handler
            self.completionHandler = nil // Clear completion handler
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) { // Handle session invalidation
        DispatchQueue.main.async { // Switch to main thread
            self.isScanning = false // Set scanning status to false
            
            if let nfcError = error as? NFCReaderError { // Check if NFC error
                switch nfcError.code { // Switch on error code
                case .readerSessionInvalidationErrorUserCanceled: // User canceled
                    self.errorMessage = nil // Clear error message
                    self.scanProgress = "Scan canceled" // Set progress message
                case .readerSessionInvalidationErrorSessionTimeout: // Session timeout
                    self.errorMessage = "Scan timed out. Please try again." // Set error message
                default: // Other errors
                    self.errorMessage = "NFC scan error: \(error.localizedDescription)" // Set error message
                }
            } else { // Other error types
                self.errorMessage = "NFC scan error: \(error.localizedDescription)" // Set error message
            }
            
            self.completionHandler?(nil) // Call completion handler with nil
            self.completionHandler = nil // Clear completion handler
        }
    }
    
    // MARK: - Parse License Payload
    private func parseLicensePayload(_ payload: String, into licenseData: inout NFCLicenseData) { // Parse license payload data
        // Parse common license data formats
        // Note: This is a simplified parser - actual formats vary by jurisdiction
        
        // Try to extract date of birth (common formats: YYYYMMDD, MM/DD/YYYY, etc.)
        let datePatterns = [
            "\\b(\\d{4})(\\d{2})(\\d{2})\\b", // YYYYMMDD
            "\\b(\\d{2})/(\\d{2})/(\\d{4})\\b", // MM/DD/YYYY
            "\\b(\\d{4})-(\\d{2})-(\\d{2})\\b" // YYYY-MM-DD
        ]
        
        for pattern in datePatterns { // Iterate through date patterns
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) { // Create regex
                let range = NSRange(payload.startIndex..., in: payload) // Define search range
                if let match = regex.firstMatch(in: payload, options: [], range: range) { // Find match
                    var year: Int? = nil // Initialize year
                    var month: Int? = nil // Initialize month
                    var day: Int? = nil // Initialize day
                    
                    if match.numberOfRanges >= 4 { // Check if enough ranges
                        // Extract date components based on pattern
                        if pattern.contains("YYYYMMDD") { // YYYYMMDD format
                            if let yearRange = Range(match.range(at: 1), in: payload),
                               let monthRange = Range(match.range(at: 2), in: payload),
                               let dayRange = Range(match.range(at: 3), in: payload) {
                                year = Int(payload[yearRange]) // Extract year
                                month = Int(payload[monthRange]) // Extract month
                                day = Int(payload[dayRange]) // Extract day
                            }
                        } else { // MM/DD/YYYY or YYYY-MM-DD format
                            if let firstRange = Range(match.range(at: 1), in: payload),
                               let secondRange = Range(match.range(at: 2), in: payload),
                               let thirdRange = Range(match.range(at: 3), in: payload) {
                                if pattern.contains("/") { // MM/DD/YYYY
                                    month = Int(payload[firstRange]) // Extract month
                                    day = Int(payload[secondRange]) // Extract day
                                    year = Int(payload[thirdRange]) // Extract year
                                } else { // YYYY-MM-DD
                                    year = Int(payload[firstRange]) // Extract year
                                    month = Int(payload[secondRange]) // Extract month
                                    day = Int(payload[thirdRange]) // Extract day
                                }
                            }
                        }
                        
                        // Create date from components
                        if let y = year, let m = month, let d = day { // Check if all components available
                            var components = DateComponents() // Create date components
                            components.year = y // Set year
                            components.month = m // Set month
                            components.day = d // Set day
                            
                            if let date = Calendar.current.date(from: components) { // Create date
                                // Only use if date is reasonable (between 1900 and current year)
                                if y >= 1900 && y <= Calendar.current.component(.year, from: Date()) { // Check if reasonable year
                                    licenseData.dateOfBirth = date // Set date of birth
                                    break // Break loop
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - NFC Manager (Unavailable)
#else
class NFCManager: ObservableObject { // Define NFCManager class for platforms without Core NFC
    @Published var isScanning: Bool = false // Published property for scanning status
    @Published var licenseData: NFCLicenseData? // Published property for extracted license data
    @Published var errorMessage: String? // Published property for error messages
    @Published var scanProgress: String = "" // Published property for scan progress
    
    func startScanning(completion: @escaping (NFCLicenseData?) -> Void) { // Unavailable method
        errorMessage = "NFC reading is not available on this platform" // Set error message
        completion(nil) // Call completion with nil
    }
}
#endif

// MARK: - NFC Availability Check
extension NFCManager { // Extension for availability checking
    static func isAvailable() -> Bool { // Check if NFC is available
        #if canImport(CoreNFC)
        if #available(iOS 11.0, macOS 12.0, *) { // Check platform version
            return NFCNDEFReaderSession.readingAvailable // Return NFC reading availability
        }
        #endif
        return false // Return false if not available
    }
}
