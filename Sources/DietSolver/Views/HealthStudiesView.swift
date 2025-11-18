//
//  HealthStudiesView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax
#if canImport(ResearchKit)
import ResearchKit // Import ResearchKit framework for health research studies
#endif

// MARK: - Health Studies View
struct HealthStudiesView: View { // Define HealthStudiesView struct conforming to View protocol
    @StateObject private var researchKitManager = ResearchKitManager() // State object for ResearchKit manager
    @State private var selectedStudy: HealthStudyConfig? // State for selected study
    @State private var showConsent = false // State for showing consent
    
    var body: some View { // Define body property returning view hierarchy
        VStack(spacing: 0) { // Create vertical stack
            // Custom Header
            HStack { // Create horizontal stack for header
                Text("Health Studies")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                
                Spacer() // Add spacer
            }
            .padding(.vertical, AppDesign.Spacing.md)
            .background(AppDesign.Colors.background)
            
            ScrollView { // Create scrollable view
                VStack(spacing: AppDesign.Spacing.lg) { // Create vertical stack
                    // Header
                    VStack(spacing: AppDesign.Spacing.sm) { // Create vertical stack
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppDesign.Colors.primary)
                        
                        Text("Health Research Studies")
                            .font(AppDesign.Typography.title)
                            .fontWeight(.bold)
                        
                        Text("Contribute to anonymized health research while maintaining complete privacy")
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, AppDesign.Spacing.md)
                    
                    // Privacy Notice
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack { // Create horizontal stack
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(AppDesign.Colors.primary)
                                Text("Privacy Guarantee")
                                    .font(AppDesign.Typography.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("• All data is anonymized before any analysis")
                                .font(AppDesign.Typography.body)
                            Text("• No personally identifiable information is collected")
                                .font(AppDesign.Typography.body)
                            Text("• Data never leaves your device unless you explicitly consent")
                                .font(AppDesign.Typography.body)
                            Text("• You can withdraw from studies at any time")
                                .font(AppDesign.Typography.body)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Available Studies
                    if !researchKitManager.activeStudies.isEmpty { // Check if studies available
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
                            Text("Available Studies")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, AppDesign.Spacing.md)
                            
                            ForEach(researchKitManager.activeStudies, id: \.studyId) { study in // Iterate through studies
                                StudyCard(
                                    study: study,
                                    isParticipating: researchKitManager.participations.contains { $0.studyId == study.studyId && $0.isActive },
                                    onJoin: {
                                        selectedStudy = study // Set selected study
                                        showConsent = true // Show consent
                                    },
                                    onWithdraw: {
                                        researchKitManager.withdrawFromStudy(study.studyId) // Withdraw from study
                                    },
                                    researchKitManager: researchKitManager // Pass ResearchKit manager
                                )
                            }
                        }
                    } else { // If no studies
                        ModernCard {
                            VStack(spacing: AppDesign.Spacing.md) { // Create vertical stack
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                Text("No studies available at this time")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            .padding()
                        }
                        .padding(.horizontal, AppDesign.Spacing.md)
                    }
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
            .onAppear {
                // Delay initialization to avoid lifecycle issues
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    researchKitManager.initializeStudies() // Initialize studies
                }
            }
            #if canImport(ResearchKit)
            .sheet(isPresented: $showConsent) {
                if let study = selectedStudy { // Check if study selected
                    ConsentView(study: study, researchKitManager: researchKitManager) // Show consent view
                }
            }
            #endif
        }
    }
}

// MARK: - Study Card
struct StudyCard: View { // Define StudyCard struct for individual study display
    let study: HealthStudyConfig // Study configuration
    let isParticipating: Bool // Whether user is participating
    let onJoin: () -> Void // Join action
    let onWithdraw: () -> Void // Withdraw action
    @ObservedObject var researchKitManager: ResearchKitManager // Observed ResearchKit manager
    
    var body: some View { // Define body property returning view hierarchy
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
                HStack { // Create horizontal stack
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                        Text(study.studyName)
                            .font(AppDesign.Typography.headline)
                            .fontWeight(.bold)
                        
                        Text(study.studyDescription)
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if isParticipating { // Check if participating
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppDesign.Colors.success)
                            .font(.system(size: 24))
                    }
                }
                
                // Study Details
                VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) { // Create vertical stack
                    HStack { // Create horizontal stack
                        Image(systemName: "clock.fill")
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .frame(width: 20)
                        Text("Duration: \(study.duration.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)")
                            .font(AppDesign.Typography.caption)
                    }
                    
                    HStack { // Create horizontal stack
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .frame(width: 20)
                        Text("Anonymization: \(study.anonymizationLevel.rawValue.capitalized)")
                            .font(AppDesign.Typography.caption)
                    }
                }
                .padding(.top, AppDesign.Spacing.xs)
                
                // Action Button
                if isParticipating { // Check if participating
                    Button(action: onWithdraw) { // Withdraw button
                        Text("Withdraw from Study")
                            .font(AppDesign.Typography.headline)
                            .foregroundColor(AppDesign.Colors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppDesign.Spacing.sm)
                            .background(AppDesign.Colors.error.opacity(0.1))
                            .cornerRadius(AppDesign.Radius.medium)
                    }
                } else { // If not participating
                    Button(action: onJoin) { // Join button
                        Text("Join Study")
                            .font(AppDesign.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppDesign.Spacing.sm)
                            .background(
                                LinearGradient(
                                    colors: [AppDesign.Colors.primary, AppDesign.Colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(AppDesign.Radius.medium)
                    }
                }
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
}

// MARK: - Consent View
#if canImport(ResearchKit)
@available(iOS 9.0, *) // Require iOS 9+ for ResearchKit
struct ConsentView: UIViewControllerRepresentable { // Define ConsentView struct for ResearchKit integration
    let study: HealthStudyConfig // Study configuration
    @ObservedObject var researchKitManager: ResearchKitManager // Observed ResearchKit manager
    @Environment(\.dismiss) var dismiss // Dismiss environment value
    
    func makeUIViewController(context: Context) -> ORKTaskViewController { // Create task view controller
        // Create consent task - ensure it's created safely
        let consentTask: ORKOrderedTask
        if let task = researchKitManager.createConsentTask(for: study) { // Create consent task (now returns optional)
            consentTask = task // Use created task
        } else {
            // Fallback if task creation fails - create minimal valid task
            let emptyStep = ORKInstructionStep(identifier: "empty-step") // Create empty instruction step
            emptyStep.title = "Consent" // Set title
            emptyStep.text = "Unable to load consent document." // Set text
            consentTask = ORKOrderedTask(identifier: "empty", steps: [emptyStep]) // Create task with empty step
        }
        
        let taskViewController = ORKTaskViewController(task: consentTask, taskRun: nil) // Create task view controller
        taskViewController.delegate = context.coordinator // Set delegate
        return taskViewController // Return task view controller
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) { // Update view controller
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator { // Create coordinator
        Coordinator(self) // Return coordinator
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate { // Define coordinator class
        let parent: ConsentView // Parent consent view
        
        init(_ parent: ConsentView) { // Initialize coordinator
            self.parent = parent // Set parent
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) { // Handle task completion
            // Handle on main thread to avoid threading issues
            DispatchQueue.main.async { [weak self] in // Use weak self to avoid retain cycles
                guard let self = self else { return } // Check if self exists
                
                if reason == .completed { // Check if completed
                    // Extract consent signature
                    if let results = taskViewController.result.results, // Get results
                       let consentResult = results.first(where: { $0.identifier == "consent-signature" }) as? ORKConsentSignatureResult { // Find consent signature result
                        // Record consent
                        self.parent.researchKitManager.recordConsent(for: self.parent.study.studyId, consentVersion: "1.0") // Record consent
                        
                        // Join study
                        self.parent.researchKitManager.joinStudy(self.parent.study) { success in // Join study
                            if success { // Check if successful
                                // Study joined successfully
                            }
                        }
                    }
                }
                
                // Dismiss with delay to ensure UI updates complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent.dismiss() // Dismiss view
                }
            }
        }
    }
}
#else
// MARK: - Consent View (Unavailable)
struct ConsentView: View { // Define fallback consent view
    let study: HealthStudyConfig // Study configuration
    @ObservedObject var researchKitManager: ResearchKitManager // Observed ResearchKit manager
    @Environment(\.dismiss) var dismiss // Dismiss environment value
    
    var body: some View { // Define body property
        Text("ResearchKit is not available on this platform")
            .padding()
    }
}
#endif
