//
//  ResearchKitManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality
#if canImport(ResearchKit)
import ResearchKit // Import ResearchKit framework for health research studies
#endif

// MARK: - Health Study Configuration
struct HealthStudyConfig { // Define HealthStudyConfig struct for study configuration
    let studyId: String // Study identifier
    let studyName: String // Study name
    let studyDescription: String // Study description
    let consentRequired: Bool // Whether consent is required
    let dataTypes: [StudyDataType] // Types of data collected
    let duration: StudyDuration // Study duration
    let anonymizationLevel: AnonymizationLevel // Level of data anonymization
    
    enum StudyDataType: String, Codable { // Enum for study data types
        case basicHealth = "basic_health" // Basic health metrics
        case fitness = "fitness" // Fitness data
        case mentalHealth = "mental_health" // Mental health data
        case dentalHealth = "dental_health" // Dental health data
        case lifestyle = "lifestyle" // Lifestyle data
        case exercise = "exercise" // Exercise data
        case sleep = "sleep" // Sleep data
    }
    
    enum StudyDuration: String, Codable { // Enum for study duration
        case shortTerm = "short_term" // Short-term study (1-3 months)
        case mediumTerm = "medium_term" // Medium-term study (3-12 months)
        case longTerm = "long_term" // Long-term study (12+ months)
    }
    
    enum AnonymizationLevel: String, Codable { // Enum for anonymization levels
        case minimal = "minimal" // Minimal anonymization (age ranges, categories)
        case standard = "standard" // Standard anonymization (ranges, no identifiers)
        case maximum = "maximum" // Maximum anonymization (aggregated data only)
    }
}

// MARK: - Study Participation
struct StudyParticipation: Codable { // Define StudyParticipation struct for tracking participation
    let studyId: String // Study identifier
    let participantId: String // Anonymized participant ID
    let consentDate: Date? // Date of consent
    let consentVersion: String? // Consent version
    var isActive: Bool // Whether participation is active
    var dataContributions: [DataContribution] // Data contributions made
    
    struct DataContribution: Codable { // Define DataContribution struct
        let date: Date // Contribution date
        let dataType: HealthStudyConfig.StudyDataType // Type of data contributed
        let anonymized: Bool // Whether data was anonymized
    }
}

// MARK: - ResearchKit Manager
#if canImport(ResearchKit)
@available(iOS 9.0, *) // Require iOS 9+ for ResearchKit
class ResearchKitManager: NSObject, ObservableObject { // Define ResearchKitManager class conforming to ObservableObject
    @Published var activeStudies: [HealthStudyConfig] = [] // Published array of active studies
    @Published var participations: [StudyParticipation] = [] // Published array of study participations
    @Published var consentStatus: [String: Bool] = [:] // Published consent status dictionary
    
    private let anonymizer = DataAnonymizer.shared // Data anonymizer instance
    
    // MARK: - Initialize Studies
    func initializeStudies() { // Initialize available health studies
        // Example study: Long-term Health and Wellness Study
        let wellnessStudy = HealthStudyConfig(
            studyId: "wellness_longterm_2025",
            studyName: "Long-Term Health and Wellness Study",
            studyDescription: "A comprehensive study tracking health metrics, fitness, mental health, and lifestyle factors over extended periods to understand long-term health patterns.",
            consentRequired: true,
            dataTypes: [.basicHealth, .fitness, .mentalHealth, .dentalHealth, .lifestyle, .exercise, .sleep],
            duration: .longTerm,
            anonymizationLevel: .maximum
        )
        
        activeStudies = [wellnessStudy] // Set active studies
    }
    
    // MARK: - Create Consent Document
    func createConsentDocument(for study: HealthStudyConfig) -> ORKConsentDocument { // Create ResearchKit consent document
        let consentDocument = ORKConsentDocument() // Create consent document
        consentDocument.title = study.studyName // Set study title
        consentDocument.signaturePageTitle = "Consent" // Set signature page title
        consentDocument.signaturePageContent = study.studyDescription // Set signature page content
        
        // Add consent sections
        var sections: [ORKConsentSection] = [] // Initialize sections array
        
        // Overview section
        let overviewSection = ORKConsentSection(type: .overview) // Create overview section
        overviewSection.title = "Study Overview" // Set title
        overviewSection.summary = study.studyDescription // Set summary
        overviewSection.content = """
        This study aims to understand long-term health patterns by analyzing anonymized health data.
        
        Your participation is voluntary and you can withdraw at any time.
        All data is anonymized before any analysis.
        Your personal information is never shared.
        """
        sections.append(overviewSection) // Add section
        
        // Data Use section
        let dataUseSection = ORKConsentSection(type: .dataGathering) // Create data use section
        dataUseSection.title = "Data Collection" // Set title
        dataUseSection.summary = "What data we collect" // Set summary
        dataUseSection.content = """
        We collect the following anonymized data:
        - Age ranges (not exact age)
        - Health metrics (anonymized)
        - Fitness patterns (aggregated)
        - Lifestyle factors (categorized)
        
        All data is processed on your device and anonymized before any analysis.
        """
        sections.append(dataUseSection) // Add section
        
        // Privacy section
        let privacySection = ORKConsentSection(type: .privacy) // Create privacy section
        privacySection.title = "Privacy Protection" // Set title
        privacySection.summary = "How we protect your privacy" // Set summary
        privacySection.content = """
        - All data is anonymized before processing
        - No personally identifiable information is collected
        - Data never leaves your device unless you explicitly consent
        - You can withdraw from the study at any time
        - All data contributions are optional
        """
        sections.append(privacySection) // Add section
        
        // Time Commitment section
        let timeSection = ORKConsentSection(type: .timeCommitment) // Create time section
        timeSection.title = "Time Commitment" // Set title
        timeSection.summary = "What participation involves" // Set summary
        timeSection.content = """
        Participation involves:
        - Sharing anonymized health data from your app usage
        - No additional time required beyond normal app use
        - Optional periodic health assessments
        """
        sections.append(timeSection) // Add section
        
        consentDocument.sections = sections // Set sections
        
        // Add signature
        let signature = ORKConsentSignature(forPersonWithTitle: "Participant", dateFormatString: nil, identifier: "participant-signature") // Create signature
        consentDocument.addSignature(signature) // Add signature
        
        return consentDocument // Return consent document
    }
    
    // MARK: - Create Consent Task
    @available(iOS 9.0, *) // Require iOS 9+ for ResearchKit
    func createConsentTask(for study: HealthStudyConfig) -> ORKOrderedTask? { // Create ResearchKit consent task (returns optional for safety)
        // Ensure we're on main thread for UI-related operations
        guard Thread.isMainThread else { // Check if on main thread
            var task: ORKOrderedTask? = nil // Initialize task
            DispatchQueue.main.sync { // Switch to main thread
                task = createConsentTask(for: study) // Recursive call on main thread
            }
            return task // Return task
        }
        
        let consentDocument = createConsentDocument(for: study) // Create consent document
        let consentStep = ORKVisualConsentStep(identifier: "consent-visual", document: consentDocument) // Create visual consent step
        
        let reviewStep = ORKConsentReviewStep(identifier: "consent-review") // Create review step
        reviewStep.consentDocument = consentDocument // Set consent document
        reviewStep.reasonForConsent = "By signing below, I confirm that I have read and understood the consent document and agree to participate in this study." // Set reason
        
        let signatureStep = ORKConsentSignatureStep(identifier: "consent-signature") // Create signature step
        signatureStep.requiresScrollToBottom = true // Require scrolling to bottom
        
        return ORKOrderedTask(identifier: "consent-task", steps: [consentStep, reviewStep, signatureStep]) // Return ordered task
    }
    
    // MARK: - Anonymize Health Data for Study
    func anonymizeHealthDataForStudy(_ healthData: HealthData, study: HealthStudyConfig) -> [String: Any] { // Anonymize health data for study participation
        let anonymizedProfile = anonymizer.anonymize(healthData) // Anonymize health data
        
        var studyData: [String: Any] = [:] // Initialize study data dictionary
        
        // Add basic anonymized data based on study requirements
        studyData["age_range"] = anonymizedProfile.ageRange // Add age range
        studyData["gender"] = anonymizedProfile.gender // Add gender (already anonymized)
        studyData["bmi_range"] = anonymizedProfile.bmiRange // Add BMI range
        studyData["activity_level"] = anonymizedProfile.activityLevel // Add activity level
        
        // Add data types based on study configuration
        if study.dataTypes.contains(.basicHealth) { // Check if basic health requested
            studyData["medical_metrics"] = anonymizedProfile.medicalMetrics // Add medical metrics
        }
        
        if study.dataTypes.contains(.fitness) { // Check if fitness requested
            studyData["fitness_metrics"] = anonymizedProfile.fitnessMetrics // Add fitness metrics
        }
        
        if study.dataTypes.contains(.mentalHealth) { // Check if mental health requested
            studyData["mental_health_indicators"] = anonymizedProfile.mentalHealthIndicators // Add mental health indicators
        }
        
        if study.dataTypes.contains(.dentalHealth) { // Check if dental health requested
            studyData["dental_metrics"] = anonymizedProfile.dentalMetrics // Add dental metrics
        }
        
        // Apply additional anonymization based on level
        switch study.anonymizationLevel { // Switch on anonymization level
        case .maximum: // Maximum anonymization
            // Further aggregate data
            if let medicalMetrics = studyData["medical_metrics"] as? [String: Double] { // Check if medical metrics available
                var aggregated: [String: String] = [:] // Initialize aggregated dictionary
                for (key, value) in medicalMetrics { // Iterate through metrics
                    // Convert to ranges
                    if value < 100 { // Check value range
                        aggregated[key] = "low" // Set to low
                    } else if value < 200 { // Check value range
                        aggregated[key] = "normal" // Set to normal
                    } else { // Otherwise
                        aggregated[key] = "high" // Set to high
                    }
                }
                studyData["medical_metrics"] = aggregated // Replace with aggregated data
            }
        case .standard, .minimal: // Standard or minimal anonymization
            // Already anonymized by DataAnonymizer
            break // No additional processing needed
        }
        
        return studyData // Return study data
    }
    
    // MARK: - Join Study
    func joinStudy(_ study: HealthStudyConfig, completion: @escaping (Bool) -> Void) { // Join a health study
        // Check if already participating
        if participations.contains(where: { $0.studyId == study.studyId && $0.isActive }) { // Check if already participating
            completion(false) // Call completion with false
            return // Return early
        }
        
        // Generate anonymized participant ID
        let participantId = generateAnonymizedParticipantId() // Generate participant ID
        
        // Create participation record
        let participation = StudyParticipation(
            studyId: study.studyId,
            participantId: participantId,
            consentDate: nil,
            consentVersion: nil,
            isActive: false,
            dataContributions: []
        )
        
        DispatchQueue.main.async { // Switch to main thread
            self.participations.append(participation) // Add participation
        }
        
        completion(true) // Call completion with true
    }
    
    // MARK: - Contribute Data to Study
    func contributeDataToStudy(_ healthData: HealthData, studyId: String) { // Contribute anonymized data to study
        guard let study = activeStudies.first(where: { $0.studyId == studyId }) else { return } // Find study
        guard var participation = participations.first(where: { $0.studyId == studyId && $0.isActive }) else { return } // Find active participation
        
        // Anonymize data
        let anonymizedData = anonymizeHealthDataForStudy(healthData, study: study) // Anonymize health data
        
        // Create data contribution
        let contribution = StudyParticipation.DataContribution(
            date: Date(),
            dataType: .basicHealth, // Default to basic health
            anonymized: true
        )
        
        // Update participation
        DispatchQueue.main.async { // Switch to main thread
            if let index = self.participations.firstIndex(where: { $0.studyId == studyId }) { // Find participation index
                self.participations[index].dataContributions.append(contribution) // Add contribution
            }
        }
        
        // Note: In a real implementation, this would send anonymized data to a research server
        // For privacy, we only store locally and user must explicitly opt-in to share
    }
    
    // MARK: - Generate Anonymized Participant ID
    private func generateAnonymizedParticipantId() -> String { // Generate anonymized participant ID
        let uuid = UUID().uuidString // Generate UUID
        let hash = uuid.data(using: .utf8)?.hashValue ?? 0 // Hash UUID
        return "P\(abs(hash))" // Return participant ID
    }
    
    // MARK: - Check Consent Status
    func hasConsent(for studyId: String) -> Bool { // Check if user has consented to study
        return consentStatus[studyId] ?? false // Return consent status
    }
    
    // MARK: - Record Consent
    func recordConsent(for studyId: String, consentVersion: String) { // Record user consent
        DispatchQueue.main.async { // Switch to main thread
            self.consentStatus[studyId] = true // Set consent status
            
            // Update participation
            if let index = self.participations.firstIndex(where: { $0.studyId == studyId }) { // Find participation index
                self.participations[index].consentDate = Date() // Set consent date
                self.participations[index].consentVersion = consentVersion // Set consent version
                self.participations[index].isActive = true // Set active status
            }
        }
    }
    
    // MARK: - Withdraw from Study
    func withdrawFromStudy(_ studyId: String) { // Withdraw from study
        DispatchQueue.main.async { // Switch to main thread
            self.consentStatus[studyId] = false // Set consent status to false
            
            // Update participation
            if let index = self.participations.firstIndex(where: { $0.studyId == studyId }) { // Find participation index
                self.participations[index].isActive = false // Set active status to false
            }
        }
    }
}

// MARK: - ResearchKit Manager (Unavailable)
#else
class ResearchKitManager: ObservableObject { // Define ResearchKitManager class for platforms without ResearchKit
    @Published var activeStudies: [HealthStudyConfig] = [] // Published array of active studies
    @Published var participations: [StudyParticipation] = [] // Published array of study participations
    @Published var consentStatus: [String: Bool] = [:] // Published consent status dictionary
    
    func initializeStudies() { // Unavailable method
        // ResearchKit not available on this platform
    }
    
    func createConsentTask(for study: HealthStudyConfig) -> Any? { // Unavailable method
        return nil // Return nil (ResearchKit not available)
    }
    
    func joinStudy(_ study: HealthStudyConfig, completion: @escaping (Bool) -> Void) { // Unavailable method
        completion(false) // Call completion with false
    }
    
    func contributeDataToStudy(_ healthData: HealthData, studyId: String) { // Unavailable method
        // ResearchKit not available
    }
    
    func withdrawFromStudy(_ studyId: String) { // Unavailable method
        // ResearchKit not available
    }
    
    func recordConsent(for studyId: String, consentVersion: String) { // Unavailable method
        // ResearchKit not available
    }
    
    func hasConsent(for studyId: String) -> Bool { // Unavailable method
        return false // Return false
    }
}
#endif

// MARK: - ResearchKit Availability Check
extension ResearchKitManager { // Extension for availability checking
    static func isAvailable() -> Bool { // Check if ResearchKit is available
        #if canImport(ResearchKit)
        if #available(iOS 9.0, *) { // Check iOS version
            return true // Return true if available
        }
        #endif
        return false // Return false if not available
    }
}
