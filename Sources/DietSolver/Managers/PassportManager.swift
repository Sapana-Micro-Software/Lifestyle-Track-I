//
//  PassportManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
#if canImport(CoreNFC)
import CoreNFC // Import Core NFC framework for e-passport reading
#endif
#if canImport(Vision)
import Vision // Import Vision framework for MRZ scanning
#endif
#if canImport(UIKit)
import UIKit // Import UIKit for image processing
#endif

// MARK: - Passport Data
struct PassportData { // Define PassportData struct for extracted passport information
    var dateOfBirth: Date? // Optional date of birth from passport
    var age: Int? // Optional calculated age
    var nationality: String? // Optional nationality (for demographic insights)
    var passportNumber: String? // Optional passport number (for verification only, not stored)
    var expirationDate: Date? // Optional expiration date
    var fullName: String? // Optional full name (for verification only, not stored)
    var gender: String? // Optional gender from passport
    
    // MARK: - Calculate Age
    func calculateAge() -> Int? { // Calculate age from date of birth
        guard let dob = dateOfBirth else { return nil } // Check if date of birth available
        let calendar = Calendar.current // Get calendar instance
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date()) // Calculate age components
        return ageComponents.year // Return calculated age
    }
    
    // MARK: - Convert Gender String to HealthData Gender
    func toHealthDataGender() -> HealthData.Gender? { // Convert passport gender to HealthData gender
        guard let genderStr = gender else { return nil } // Check if gender available
        let normalized = genderStr.uppercased() // Normalize to uppercase
        if normalized.contains("M") || normalized.contains("MALE") { // Check if male
            return .male // Return male
        } else if normalized.contains("F") || normalized.contains("FEMALE") { // Check if female
            return .female // Return female
        } else { // Otherwise
            return .other // Return other
        }
    }
}

// MARK: - Passport Manager
#if canImport(CoreNFC)
@available(iOS 11.0, macOS 12.0, *) // Require iOS 11+ or macOS 12+ for Core NFC
class PassportManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate { // Define PassportManager class conforming to NFC reader session delegate
    @Published var isScanning: Bool = false // Published property for scanning status
    @Published var passportData: PassportData? // Published property for extracted passport data
    @Published var errorMessage: String? // Published property for error messages
    @Published var scanProgress: String = "" // Published property for scan progress
    
    private var readerSession: NFCNDEFReaderSession? // Private reader session instance
    private var completionHandler: ((PassportData?) -> Void)? // Completion handler for scan results
    
    // MARK: - Start Passport Scan
    func startScanning(completion: @escaping (PassportData?) -> Void) { // Start passport scanning session
        guard NFCNDEFReaderSession.readingAvailable else { // Check if NFC reading is available
            errorMessage = "NFC reading is not available on this device" // Set error message
            completion(nil) // Call completion with nil
            return // Return early
        }
        
        completionHandler = completion // Store completion handler
        isScanning = true // Set scanning status
        errorMessage = nil // Clear error message
        scanProgress = "Hold your device near the passport..." // Set progress message
        
        // Create NFC reader session for e-passport
        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true) // Create reader session
        readerSession?.alertMessage = "Hold your device near the passport to read information" // Set alert message
        readerSession?.begin() // Begin scanning session
    }
    
    // MARK: - Stop Scanning
    func stopScanning() { // Stop passport scanning session
        readerSession?.invalidate() // Invalidate reader session
        readerSession = nil // Clear reader session
        isScanning = false // Set scanning status to false
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { // Handle detected NDEF messages
        DispatchQueue.main.async { // Switch to main thread
            self.scanProgress = "Reading passport data..." // Update progress message
        }
        
        // Parse NDEF messages to extract passport data
        var passportData = PassportData() // Initialize passport data
        
        for message in messages { // Iterate through messages
            for record in message.records { // Iterate through records
                if let payload = String(data: record.payload, encoding: .utf8) { // Convert payload to string
                    // Parse passport data from payload
                    parsePassportPayload(payload, into: &passportData) // Parse payload into passport data
                }
            }
        }
        
        // Calculate age if date of birth available
        if passportData.dateOfBirth != nil { // Check if date of birth available
            passportData.age = passportData.calculateAge() // Calculate age
        }
        
        DispatchQueue.main.async { // Switch to main thread
            self.passportData = passportData // Update passport data
            self.isScanning = false // Set scanning status to false
            self.scanProgress = passportData.age != nil ? "Passport data read successfully!" : "Partial data read" // Update progress
            self.completionHandler?(passportData) // Call completion handler
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
                    self.errorMessage = "Passport scan error: \(error.localizedDescription)" // Set error message
                }
            } else { // Other error types
                self.errorMessage = "Passport scan error: \(error.localizedDescription)" // Set error message
            }
            
            self.completionHandler?(nil) // Call completion handler with nil
            self.completionHandler = nil // Clear completion handler
        }
    }
    
    // MARK: - Parse Passport Payload
    private func parsePassportPayload(_ payload: String, into passportData: inout PassportData) { // Parse passport payload data
        // Parse common passport data formats
        // Note: This is a simplified parser - actual e-passport formats follow ICAO 9303 standard
        
        // Try to extract date of birth (common formats: YYMMDD, YYYYMMDD)
        let datePatterns = [
            "\\b(\\d{2})(\\d{2})(\\d{2})\\b", // YYMMDD (passport format)
            "\\b(\\d{4})(\\d{2})(\\d{2})\\b", // YYYYMMDD
            "\\b(\\d{2})/(\\d{2})/(\\d{4})\\b" // MM/DD/YYYY
        ]
        
        for pattern in datePatterns { // Iterate through date patterns
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) { // Create regex
                let range = NSRange(payload.startIndex..., in: payload) // Define search range
                if let match = regex.firstMatch(in: payload, options: [], range: range) { // Find match
                    var year: Int? = nil // Initialize year
                    var month: Int? = nil // Initialize month
                    var day: Int? = nil // Initialize day
                    
                    if match.numberOfRanges >= 4 { // Check if enough ranges
                        if let firstRange = Range(match.range(at: 1), in: payload),
                           let secondRange = Range(match.range(at: 2), in: payload),
                           let thirdRange = Range(match.range(at: 3), in: payload) {
                            
                            if pattern.contains("YYMMDD") && !pattern.contains("YYYY") { // YYMMDD format
                                let yearStr = String(payload[firstRange]) // Extract year string
                                let monthStr = String(payload[secondRange]) // Extract month string
                                let dayStr = String(payload[thirdRange]) // Extract day string
                                
                                year = Int(yearStr) // Extract year
                                month = Int(monthStr) // Extract month
                                day = Int(dayStr) // Extract day
                                
                                // Convert 2-digit year to 4-digit (assume 1900s for years > 50, 2000s for years <= 50)
                                if let y = year { // Check if year available
                                    year = y > 50 ? 1900 + y : 2000 + y // Convert to 4-digit year
                                }
                            } else if pattern.contains("YYYYMMDD") { // YYYYMMDD format
                                year = Int(payload[firstRange]) // Extract year
                                month = Int(payload[secondRange]) // Extract month
                                day = Int(payload[thirdRange]) // Extract day
                            } else if pattern.contains("/") { // MM/DD/YYYY format
                                month = Int(payload[firstRange]) // Extract month
                                day = Int(payload[secondRange]) // Extract day
                                year = Int(payload[thirdRange]) // Extract year
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
                                        passportData.dateOfBirth = date // Set date of birth
                                        break // Break loop
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Try to extract gender (M, F, or gender codes)
        let genderPattern = "\\b([MF]|MALE|FEMALE)\\b" // Gender pattern
        if let regex = try? NSRegularExpression(pattern: genderPattern, options: .caseInsensitive) { // Create regex
            let range = NSRange(payload.startIndex..., in: payload) // Define search range
            if let match = regex.firstMatch(in: payload, options: [], range: range) { // Find match
                if let genderRange = Range(match.range(at: 1), in: payload) { // Get gender range
                    passportData.gender = String(payload[genderRange]).uppercased() // Set gender
                }
            }
        }
        
        // Try to extract nationality (3-letter country codes)
        let nationalityPattern = "\\b([A-Z]{3})\\b" // Nationality pattern (3 uppercase letters)
        if let regex = try? NSRegularExpression(pattern: nationalityPattern, options: []) { // Create regex
            let range = NSRange(payload.startIndex..., in: payload) // Define search range
            let matches = regex.matches(in: payload, options: [], range: range) // Find all matches
            // Use first match as potential nationality code
            if let firstMatch = matches.first, let nationalityRange = Range(firstMatch.range(at: 1), in: payload) { // Get first match
                let code = String(payload[nationalityRange]) // Extract code
                // Common country codes (simplified check)
                if ["USA", "GBR", "CAN", "AUS", "FRA", "DEU", "JPN", "CHN", "IND"].contains(code) { // Check if known country code
                    passportData.nationality = code // Set nationality
                }
            }
        }
    }
}

// MARK: - MRZ Scanner (Machine Readable Zone)
#if canImport(Vision) && canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *) // Require iOS 13+ or macOS 10.15+ for Vision framework
extension PassportManager { // Extension for MRZ scanning
    // Make scanMRZFromImage available on PassportManager
    // MARK: - Scan MRZ from Image
    func scanMRZFromImage(_ image: UIImage, completion: @escaping (PassportData?) -> Void) { // Scan MRZ from passport image
        guard let cgImage = image.cgImage else { // Check if CGImage available
            completion(nil) // Call completion with nil
            return // Return early
        }
        
        let request = VNRecognizeTextRequest { request, error in // Create text recognition request
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { // Check if observations available
                DispatchQueue.main.async { // Switch to main thread
                    completion(nil) // Call completion with nil
                }
                return // Return early
            }
            
            var passportData = PassportData() // Initialize passport data
            var mrzText = "" // Initialize MRZ text
            
            // Extract text from observations
            for observation in observations { // Iterate through observations
                guard let topCandidate = observation.topCandidates(1).first else { continue } // Get top candidate
                mrzText += topCandidate.string + "\n" // Append text
            }
            
            // Parse MRZ format (typically 2-3 lines)
            self.parseMRZText(mrzText, into: &passportData) // Parse MRZ text
            
            DispatchQueue.main.async { // Switch to main thread
                if passportData.dateOfBirth != nil { // Check if date of birth available
                    passportData.age = passportData.calculateAge() // Calculate age
                }
                completion(passportData) // Call completion with passport data
            }
        }
        
        request.recognitionLevel = .accurate // Set recognition level to accurate
        request.usesLanguageCorrection = false // Disable language correction for MRZ
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create image request handler
        do { // Begin do-catch block
            try handler.perform([request]) // Perform request
        } catch { // Catch errors
            DispatchQueue.main.async { // Switch to main thread
                completion(nil) // Call completion with nil
            }
        }
    }
    
    // MARK: - Parse MRZ Text
    private func parseMRZText(_ mrzText: String, into passportData: inout PassportData) { // Parse MRZ text format
        let lines = mrzText.components(separatedBy: "\n").filter { !$0.isEmpty } // Split into lines
        
        for line in lines { // Iterate through lines
            // MRZ format: P<USO... (passport type and country code)
            // Date of birth: YYMMDD format
            // Gender: M or F
            
            // Extract date of birth (YYMMDD format, typically in second line)
            let dobPattern = "\\b(\\d{2})(\\d{2})(\\d{2})\\b" // Date of birth pattern
            if let regex = try? NSRegularExpression(pattern: dobPattern, options: []) { // Create regex
                let range = NSRange(line.startIndex..., in: line) // Define search range
                if let match = regex.firstMatch(in: line, options: [], range: range) { // Find match
                    if match.numberOfRanges >= 4 { // Check if enough ranges
                        if let yearRange = Range(match.range(at: 1), in: line),
                           let monthRange = Range(match.range(at: 2), in: line),
                           let dayRange = Range(match.range(at: 3), in: line) {
                            
                            if let year = Int(line[yearRange]),
                               let month = Int(line[monthRange]),
                               let day = Int(line[dayRange]) {
                                
                                // Convert 2-digit year to 4-digit
                                let fullYear = year > 50 ? 1900 + year : 2000 + year // Convert year
                                
                                var components = DateComponents() // Create date components
                                components.year = fullYear // Set year
                                components.month = month // Set month
                                components.day = day // Set day
                                
                                if let date = Calendar.current.date(from: components) { // Create date
                                    passportData.dateOfBirth = date // Set date of birth
                                }
                            }
                        }
                    }
                }
            }
            
            // Extract gender (M or F, typically after date of birth)
            let genderPattern = "\\b([MF])\\b" // Gender pattern
            if let regex = try? NSRegularExpression(pattern: genderPattern, options: []) { // Create regex
                let range = NSRange(line.startIndex..., in: line) // Define search range
                if let match = regex.firstMatch(in: line, options: [], range: range) { // Find match
                    if let genderRange = Range(match.range(at: 1), in: line) { // Get gender range
                        passportData.gender = String(line[genderRange]) // Set gender
                    }
                }
            }
            
            // Extract nationality (3-letter code, typically at start of line)
            if line.hasPrefix("P<") && line.count >= 5 { // Check if passport line
                let startIndex = line.index(line.startIndex, offsetBy: 2) // Get start index
                let endIndex = line.index(startIndex, offsetBy: 3) // Get end index
                let nationality = String(line[startIndex..<endIndex]) // Extract nationality
                passportData.nationality = nationality // Set nationality
            }
        }
    }
}
#endif

// MARK: - Passport Manager (Unavailable)
#else
class PassportManager: ObservableObject { // Define PassportManager class for platforms without Core NFC
    @Published var isScanning: Bool = false // Published property for scanning status
    @Published var passportData: PassportData? // Published property for extracted passport data
    @Published var errorMessage: String? // Published property for error messages
    @Published var scanProgress: String = "" // Published property for scan progress
    
    func startScanning(completion: @escaping (PassportData?) -> Void) { // Unavailable method
        errorMessage = "Passport reading is not available on this platform" // Set error message
        completion(nil) // Call completion with nil
    }
}
#endif

// MARK: - Passport Availability Check
extension PassportManager { // Extension for availability checking
    static func isAvailable() -> Bool { // Check if passport reading is available
        #if canImport(CoreNFC)
        if #available(iOS 11.0, macOS 12.0, *) { // Check platform version
            return NFCNDEFReaderSession.readingAvailable // Return NFC reading availability
        }
        #endif
        return false // Return false if not available
    }
    
    static func isMRZScanningAvailable() -> Bool { // Check if MRZ scanning is available
        #if canImport(Vision) && canImport(UIKit)
        if #available(iOS 13.0, macOS 10.15, *) { // Check platform version
            return true // Return true if Vision framework available
        }
        #endif
        return false // Return false if not available
    }
}
