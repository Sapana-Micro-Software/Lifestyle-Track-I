//
//  ExternalHealthAnalyzer.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
#if canImport(Vision)
import Vision // Import Vision framework for image analysis
#endif
#if canImport(UIKit)
import UIKit // Import UIKit for UIImage on iOS
#endif
#if canImport(AppKit)
import AppKit // Import AppKit for NSImage on macOS
#endif

// MARK: - External Health Analyzer
#if canImport(Vision)
@available(iOS 13.0, macOS 10.15, *) // Require iOS 13+ and macOS 10.15+ for Vision framework
class ExternalHealthAnalyzer: ObservableObject { // Define ExternalHealthAnalyzer class for analyzing external body parts
    
    // MARK: - Analyze Skin
    func analyzeSkin(from image: PlatformImage, completion: @escaping (Result<ExternalSkinAnalysis, Error>) -> Void) { // Analyze skin from image
        guard let cgImage = image.cgImage else { // Check if CGImage is available
            completion(.failure(ExternalHealthError.invalidImage)) // Return error
            return // Return early
        }
        
        let request = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create Vision request handler
        
        // Use multiple Vision requests for comprehensive analysis
        var detectedConditions: [ExternalSkinAnalysis.ExternalSkinCondition] = [] // Initialize detected conditions array
        var texture: ExternalSkinAnalysis.ExternalSkinTexture? = nil // Initialize texture
        var color: ExternalSkinAnalysis.ExternalSkinColor? = nil // Initialize color
        let hydration: ExternalSkinAnalysis.ExternalSkinHydration? = nil // Initialize hydration
        var confidence: Double = 0.0 // Initialize confidence
        
        let group = DispatchGroup() // Create dispatch group for async operations
        
        // Analyze for skin conditions
        group.enter() // Enter dispatch group
        let conditionRequest = VNClassifyImageRequest { request, error in // Create classification request
            defer { group.leave() } // Leave dispatch group
            if error != nil { return } // Return if error
            
            guard let observations = request.results as? [VNClassificationObservation] else { return } // Get observations
            
            // Analyze classifications for skin conditions
            for observation in observations.prefix(10) { // Iterate through top 10 observations
                let identifier = observation.identifier.lowercased() // Get identifier
                
                // Map Vision classifications to skin conditions
                if identifier.contains("acne") || identifier.contains("pimple") { // Check for acne
                    detectedConditions.append(.acne) // Add acne
                } else if identifier.contains("eczema") || identifier.contains("rash") { // Check for eczema
                    detectedConditions.append(.eczema) // Add eczema
                } else if identifier.contains("psoriasis") { // Check for psoriasis
                    detectedConditions.append(.psoriasis) // Add psoriasis
                } else if identifier.contains("red") || identifier.contains("rosacea") { // Check for rosacea
                    detectedConditions.append(.rosacea) // Add rosacea
                } else if identifier.contains("mole") || identifier.contains("spot") { // Check for moles
                    detectedConditions.append(.moles) // Add moles
                } else if identifier.contains("wrinkle") || identifier.contains("line") { // Check for wrinkles
                    detectedConditions.append(.wrinkles) // Add wrinkles
                }
                
                confidence = max(confidence, Double(observation.confidence)) // Update confidence
            }
        }
        
        // Analyze texture
        group.enter() // Enter dispatch group
        let textureRequest = VNDetectFaceLandmarksRequest { request, error in // Create face landmarks request for texture analysis
            defer { group.leave() } // Leave dispatch group
            if error != nil { return } // Return if error
            
            // Texture analysis based on image characteristics
            // This is a simplified approach - in production, use more sophisticated analysis
            texture = .normal // Set default texture
        }
        
        // Analyze color
        group.enter() // Enter dispatch group
        analyzeSkinColor(from: cgImage) { colorResult in // Analyze skin color
            defer { group.leave() } // Leave dispatch group
            color = colorResult // Set color
        }
        
        // Execute requests
        do { // Try to perform requests
            try request.perform([conditionRequest, textureRequest]) // Perform requests
        } catch { // Catch errors
            completion(.failure(error)) // Return error
            return // Return early
        }
        
        // Wait for all analyses to complete
        group.notify(queue: .main) { // Notify on main queue
            // If no conditions detected, mark as normal
            if detectedConditions.isEmpty { // Check if no conditions
                detectedConditions.append(.normal) // Add normal condition
            }
            
            let analysis = ExternalSkinAnalysis( // Create skin analysis
                conditions: Array(Set(detectedConditions)), // Remove duplicates
                texture: texture ?? .normal, // Use texture or default
                color: color, // Use color
                hydration: hydration ?? .moderatelyHydrated, // Use hydration or default
                images: [], // Images will be stored separately
                analysisDate: Date(), // Set analysis date
                confidence: confidence // Set confidence
            )
            
            completion(.success(analysis)) // Return success
        }
    }
    
    // MARK: - Analyze Eyes
    func analyzeEyes(from image: PlatformImage, completion: @escaping (Result<ExternalEyeAnalysis, Error>) -> Void) { // Analyze eyes from image
        guard let cgImage = image.cgImage else { // Check if CGImage is available
            completion(.failure(ExternalHealthError.invalidImage)) // Return error
            return // Return early
        }
        
        let request = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create Vision request handler
        
        var detectedConditions: [ExternalEyeAnalysis.EyeCondition] = [] // Initialize detected conditions
        var redness: ExternalEyeAnalysis.RednessLevel? = nil // Initialize redness
        var clarity: ExternalEyeAnalysis.ClarityLevel? = nil // Initialize clarity
        var confidence: Double = 0.0 // Initialize confidence
        
        let eyeRequest = VNDetectFaceLandmarksRequest { request, error in // Create face landmarks request
            if let error = error { // Check for error
                completion(.failure(error)) // Return error
                return // Return early
            }
            
            guard let observations = request.results as? [VNFaceObservation] else { // Get face observations
                completion(.failure(ExternalHealthError.noFaceDetected)) // Return error
                return // Return early
            }
            
            // Analyze eye region
            for observation in observations { // Iterate through observations
                if let leftEye = observation.landmarks?.leftEye, // Get left eye
                   let rightEye = observation.landmarks?.rightEye { // Get right eye
                    
                    // Analyze eye characteristics (simplified)
                    // In production, use more sophisticated eye region analysis
                    self.analyzeEyeRegion(leftEye: leftEye, rightEye: rightEye, cgImage: cgImage) { eyeResult in // Analyze eye region
                        detectedConditions = eyeResult.conditions // Set conditions
                        redness = eyeResult.redness // Set redness
                        clarity = eyeResult.clarity // Set clarity
                        confidence = eyeResult.confidence // Set confidence
                        
                        let analysis = ExternalEyeAnalysis( // Create eye analysis
                            conditions: detectedConditions.isEmpty ? [.normal] : detectedConditions, // Use conditions or normal
                            redness: redness, // Use redness
                            clarity: clarity ?? .clear, // Use clarity or default
                            images: [], // Images stored separately
                            analysisDate: Date(), // Set analysis date
                            confidence: confidence // Set confidence
                        )
                        
                        completion(.success(analysis)) // Return success
                    }
                    return // Return early
                }
            }
            
            // No eyes detected
            let analysis = ExternalEyeAnalysis( // Create default analysis
                conditions: [.normal], // Set normal condition
                redness: nil, // No redness data
                clarity: nil, // No clarity data
                images: [], // Images stored separately
                analysisDate: Date(), // Set analysis date
                confidence: 0.5 // Set default confidence
            )
            completion(.success(analysis)) // Return success
        }
        
        do { // Try to perform request
            try request.perform([eyeRequest]) // Perform request
        } catch { // Catch errors
            completion(.failure(error)) // Return error
        }
    }
    
    // MARK: - Analyze Nose
    func analyzeNose(from image: PlatformImage, completion: @escaping (Result<ExternalNoseAnalysis, Error>) -> Void) { // Analyze nose from image
        guard let cgImage = image.cgImage else { // Check if CGImage is available
            completion(.failure(ExternalHealthError.invalidImage)) // Return error
            return // Return early
        }
        
        let request = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create Vision request handler
        
        var detectedConditions: [ExternalNoseAnalysis.NoseCondition] = [] // Initialize detected conditions
        var inflammation: ExternalNoseAnalysis.InflammationLevel? = nil // Initialize inflammation
        var confidence: Double = 0.0 // Initialize confidence
        
        let noseRequest = VNDetectFaceLandmarksRequest { request, error in // Create face landmarks request
            if let error = error { // Check for error
                completion(.failure(error)) // Return error
                return // Return early
            }
            
            guard let observations = request.results as? [VNFaceObservation] else { // Get face observations
                completion(.failure(ExternalHealthError.noFaceDetected)) // Return error
                return // Return early
            }
            
            // Analyze nose region
            for observation in observations { // Iterate through observations
                if observation.landmarks?.nose != nil { // Check if nose landmarks exist
                    // Simplified nose analysis
                    // In production, use more sophisticated analysis
                    detectedConditions.append(.normal) // Add normal condition
                    inflammation = ExternalNoseAnalysis.InflammationLevel.none // Set no inflammation
                    confidence = 0.7 // Set confidence
                    
                    let analysis = ExternalNoseAnalysis( // Create nose analysis
                        conditions: detectedConditions, // Use conditions
                        inflammation: inflammation, // Use inflammation
                        images: [], // Images stored separately
                        analysisDate: Date(), // Set analysis date
                        confidence: confidence // Set confidence
                    )
                    
                    completion(.success(analysis)) // Return success
                    return // Return early
                }
            }
            
            // No nose detected
            let analysis = ExternalNoseAnalysis( // Create default analysis
                conditions: [.normal], // Set normal condition
                inflammation: nil, // No inflammation data
                images: [], // Images stored separately
                analysisDate: Date(), // Set analysis date
                confidence: 0.5 // Set default confidence
            )
            completion(.success(analysis)) // Return success
        }
        
        do { // Try to perform request
            try request.perform([noseRequest]) // Perform request
        } catch { // Catch errors
            completion(.failure(error)) // Return error
        }
    }
    
    // MARK: - Analyze Nails
    func analyzeNails(from image: PlatformImage, completion: @escaping (Result<ExternalNailAnalysis, Error>) -> Void) { // Analyze nails from image
        guard let cgImage = image.cgImage else { // Check if CGImage is available
            completion(.failure(ExternalHealthError.invalidImage)) // Return error
            return // Return early
        }
        
        let request = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create Vision request handler
        
        var detectedConditions: [ExternalNailAnalysis.NailCondition] = [] // Initialize detected conditions
        var color: ExternalNailAnalysis.NailColor? = nil // Initialize color
        let texture: ExternalNailAnalysis.NailTexture? = nil // Initialize texture
        var confidence: Double = 0.0 // Initialize confidence
        
        let classifyRequest = VNClassifyImageRequest { request, error in // Create classification request
            if let error = error { // Check for error
                completion(.failure(error)) // Return error
                return // Return early
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else { // Get observations
                completion(.failure(ExternalHealthError.analysisFailed)) // Return error
                return // Return early
            }
            
            // Analyze nail characteristics
            for observation in observations.prefix(10) { // Iterate through top 10 observations
                let identifier = observation.identifier.lowercased() // Get identifier
                
                // Map to nail conditions
                if identifier.contains("yellow") || identifier.contains("fungal") { // Check for fungal infection
                    detectedConditions.append(.fungalInfection) // Add fungal infection
                } else if identifier.contains("white") || identifier.contains("spot") { // Check for white spots
                    detectedConditions.append(.whiteSpots) // Add white spots
                } else if identifier.contains("ridge") { // Check for ridges
                    detectedConditions.append(.ridges) // Add ridges
                }
                
                confidence = max(confidence, Double(observation.confidence)) // Update confidence
            }
            
            // Analyze color
            self.analyzeNailColor(from: cgImage) { colorResult in // Analyze nail color
                color = colorResult // Set color
                
                let analysis = ExternalNailAnalysis( // Create nail analysis
                    conditions: detectedConditions.isEmpty ? [.normal] : detectedConditions, // Use conditions or normal
                    color: color ?? .pink, // Use color or default
                    texture: texture ?? .normal, // Use texture or default
                    images: [], // Images stored separately
                    analysisDate: Date(), // Set analysis date
                    confidence: confidence // Set confidence
                )
                
                completion(.success(analysis)) // Return success
            }
        }
        
        do { // Try to perform request
            try request.perform([classifyRequest]) // Perform request
        } catch { // Catch errors
            completion(.failure(error)) // Return error
        }
    }
    
    // MARK: - Analyze Hair
    func analyzeHair(from image: PlatformImage, completion: @escaping (Result<ExternalHairAnalysis, Error>) -> Void) { // Analyze hair from image
        guard let cgImage = image.cgImage else { // Check if CGImage is available
            completion(.failure(ExternalHealthError.invalidImage)) // Return error
            return // Return early
        }
        
        let request = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create Vision request handler
        
        var detectedConditions: [ExternalHairAnalysis.HairCondition] = [] // Initialize detected conditions
        var texture: ExternalHairAnalysis.HairTexture? = nil // Initialize texture
        var thickness: ExternalHairAnalysis.HairThickness? = nil // Initialize thickness
        var health: ExternalHairAnalysis.HairHealth? = nil // Initialize health
        var confidence: Double = 0.0 // Initialize confidence
        
        let classifyRequest = VNClassifyImageRequest { request, error in // Create classification request
            if let error = error { // Check for error
                completion(.failure(error)) // Return error
                return // Return early
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else { // Get observations
                completion(.failure(ExternalHealthError.analysisFailed)) // Return error
                return // Return early
            }
            
            // Analyze hair characteristics
            for observation in observations.prefix(10) { // Iterate through top 10 observations
                let identifier = observation.identifier.lowercased() // Get identifier
                
                // Map to hair conditions
                if identifier.contains("dandruff") || identifier.contains("flake") { // Check for dandruff
                    detectedConditions.append(.dandruff) // Add dandruff
                } else if identifier.contains("thin") || identifier.contains("bald") { // Check for thinning
                    detectedConditions.append(.thinning) // Add thinning
                } else if identifier.contains("dry") { // Check for dryness
                    detectedConditions.append(.dryness) // Add dryness
                }
                
                confidence = max(confidence, Double(observation.confidence)) // Update confidence
            }
            
            // Simplified texture and thickness analysis
            texture = .medium // Set default texture
            thickness = .medium // Set default thickness
            health = detectedConditions.isEmpty ? .healthy : .fair // Set health based on conditions
            
            let analysis = ExternalHairAnalysis( // Create hair analysis
                conditions: detectedConditions.isEmpty ? [.normal] : detectedConditions, // Use conditions or normal
                texture: texture, // Use texture
                thickness: thickness, // Use thickness
                health: health, // Use health
                images: [], // Images stored separately
                analysisDate: Date(), // Set analysis date
                confidence: confidence // Set confidence
            )
            
            completion(.success(analysis)) // Return success
        }
        
        do { // Try to perform request
            try request.perform([classifyRequest]) // Perform request
        } catch { // Catch errors
            completion(.failure(error)) // Return error
        }
    }
    
    // MARK: - Analyze Beard
    func analyzeBeard(from image: PlatformImage, completion: @escaping (Result<ExternalBeardAnalysis, Error>) -> Void) { // Analyze beard from image
        guard let cgImage = image.cgImage else { // Check if CGImage is available
            completion(.failure(ExternalHealthError.invalidImage)) // Return error
            return // Return early
        }
        
        let request = VNImageRequestHandler(cgImage: cgImage, options: [:]) // Create Vision request handler
        
        var detectedConditions: [ExternalBeardAnalysis.BeardCondition] = [] // Initialize detected conditions
        var texture: ExternalBeardAnalysis.BeardTexture? = nil // Initialize texture
        var thickness: ExternalBeardAnalysis.BeardThickness? = nil // Initialize thickness
        var health: ExternalBeardAnalysis.BeardHealth? = nil // Initialize health
        var confidence: Double = 0.0 // Initialize confidence
        
        let classifyRequest = VNClassifyImageRequest { request, error in // Create classification request
            if let error = error { // Check for error
                completion(.failure(error)) // Return error
                return // Return early
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else { // Get observations
                completion(.failure(ExternalHealthError.analysisFailed)) // Return error
                return // Return early
            }
            
            // Analyze beard characteristics
            for observation in observations.prefix(10) { // Iterate through top 10 observations
                let identifier = observation.identifier.lowercased() // Get identifier
                
                // Map to beard conditions
                if identifier.contains("razor") || identifier.contains("burn") { // Check for razor burn
                    detectedConditions.append(.razorBurn) // Add razor burn
                } else if identifier.contains("irritat") || identifier.contains("red") { // Check for irritation
                    detectedConditions.append(.irritation) // Add irritation
                } else if identifier.contains("patch") || identifier.contains("sparse") { // Check for patchiness
                    detectedConditions.append(.patchiness) // Add patchiness
                }
                
                confidence = max(confidence, Double(observation.confidence)) // Update confidence
            }
            
            // Simplified texture and thickness analysis
            texture = .medium // Set default texture
            thickness = .medium // Set default thickness
            health = detectedConditions.isEmpty ? .healthy : .fair // Set health based on conditions
            
            let analysis = ExternalBeardAnalysis( // Create beard analysis
                conditions: detectedConditions.isEmpty ? [.normal] : detectedConditions, // Use conditions or normal
                texture: texture, // Use texture
                thickness: thickness, // Use thickness
                health: health, // Use health
                images: [], // Images stored separately
                analysisDate: Date(), // Set analysis date
                confidence: confidence // Set confidence
            )
            
            completion(.success(analysis)) // Return success
        }
        
        do { // Try to perform request
            try request.perform([classifyRequest]) // Perform request
        } catch { // Catch errors
            completion(.failure(error)) // Return error
        }
    }
    
    // MARK: - Helper Methods
    private func analyzeSkinColor(from cgImage: CGImage, completion: @escaping (ExternalSkinAnalysis.ExternalSkinColor?) -> Void) { // Analyze skin color
        // Simplified color analysis
        // In production, use more sophisticated color analysis
        completion(.medium) // Return default color
    }
    
    private func analyzeNailColor(from cgImage: CGImage, completion: @escaping (ExternalNailAnalysis.NailColor?) -> Void) { // Analyze nail color
        // Simplified color analysis
        completion(.pink) // Return default color
    }
    
    private func analyzeEyeRegion(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D, cgImage: CGImage, completion: @escaping (EyeAnalysisResult) -> Void) { // Analyze eye region
        // Simplified eye analysis
        // In production, extract eye region and analyze for redness, clarity, etc.
        let result = EyeAnalysisResult( // Create result
            conditions: [ExternalEyeAnalysis.EyeCondition.normal], // Set normal conditions
            redness: ExternalEyeAnalysis.RednessLevel.none, // Set no redness
            clarity: ExternalEyeAnalysis.ClarityLevel.clear, // Set clear
            confidence: 0.7 // Set confidence
        )
        completion(result) // Return result
    }
    
    private struct EyeAnalysisResult { // Define result struct
        let conditions: [ExternalEyeAnalysis.EyeCondition] // Conditions
        let redness: ExternalEyeAnalysis.RednessLevel? // Redness
        let clarity: ExternalEyeAnalysis.ClarityLevel? // Clarity
        let confidence: Double // Confidence
    }
}

// MARK: - Platform Image Type
#if canImport(UIKit)
typealias PlatformImage = UIImage // Use UIImage on iOS
#elseif canImport(AppKit)
typealias PlatformImage = NSImage // Use NSImage on macOS
#else
typealias PlatformImage = Any // Fallback type
#endif

// MARK: - Platform Image Extension
#if canImport(UIKit)
extension UIImage { // Extend UIImage
    var cgImage: CGImage? { // CGImage property
        return self.cgImage // Return CGImage
    }
}
#elseif canImport(AppKit)
extension NSImage { // Extend NSImage
    var cgImage: CGImage? { // CGImage property
        guard let tiffData = self.tiffRepresentation, // Get TIFF data
              let bitmapImage = NSBitmapImageRep(data: tiffData) else { // Get bitmap image
            return nil // Return nil
        }
        return bitmapImage.cgImage // Return CGImage
    }
}
#endif

// MARK: - External Health Error
enum ExternalHealthError: LocalizedError { // Define error enum
    case invalidImage // Invalid image
    case noFaceDetected // No face detected
    case analysisFailed // Analysis failed
    
    var errorDescription: String? { // Error description
        switch self { // Switch on error type
        case .invalidImage: // Invalid image
            return "Invalid image provided" // Return description
        case .noFaceDetected: // No face detected
            return "No face detected in image" // Return description
        case .analysisFailed: // Analysis failed
            return "Image analysis failed" // Return description
        }
    }
}

// MARK: - External Health Analyzer (Unavailable)
#else
@available(iOS 13.0, macOS 10.15, *)
class ExternalHealthAnalyzer: ObservableObject { // Define fallback analyzer
    func analyzeSkin(from image: Any, completion: @escaping (Result<ExternalSkinAnalysis, Error>) -> Void) { // Unavailable method
        completion(.failure(ExternalHealthError.analysisFailed)) // Return error
    }
    
    func analyzeEyes(from image: Any, completion: @escaping (Result<ExternalEyeAnalysis, Error>) -> Void) { // Unavailable method
        completion(.failure(ExternalHealthError.analysisFailed)) // Return error
    }
    
    func analyzeNose(from image: Any, completion: @escaping (Result<ExternalNoseAnalysis, Error>) -> Void) { // Unavailable method
        completion(.failure(ExternalHealthError.analysisFailed)) // Return error
    }
    
    func analyzeNails(from image: Any, completion: @escaping (Result<ExternalNailAnalysis, Error>) -> Void) { // Unavailable method
        completion(.failure(ExternalHealthError.analysisFailed)) // Return error
    }
    
    func analyzeHair(from image: Any, completion: @escaping (Result<ExternalHairAnalysis, Error>) -> Void) { // Unavailable method
        completion(.failure(ExternalHealthError.analysisFailed)) // Return error
    }
    
    func analyzeBeard(from image: Any, completion: @escaping (Result<ExternalBeardAnalysis, Error>) -> Void) { // Unavailable method
        completion(.failure(ExternalHealthError.analysisFailed)) // Return error
    }
}

enum ExternalHealthError: LocalizedError { // Define error enum
    case invalidImage // Invalid image
    case noFaceDetected // No face detected
    case analysisFailed // Analysis failed
    
    var errorDescription: String? { // Error description
        return "Vision framework not available" // Return description
    }
}
#endif
