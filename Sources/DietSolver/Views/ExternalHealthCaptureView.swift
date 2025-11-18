//
//  ExternalHealthCaptureView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax
#if canImport(UIKit)
import UIKit // Import UIKit for UIImagePickerController
#endif

// MARK: - External Health Capture View
struct ExternalHealthCaptureView: View { // Define ExternalHealthCaptureView struct for capturing body part images
    @Environment(\.dismiss) var dismiss // Dismiss environment value
    @StateObject private var analyzer = ExternalHealthAnalyzer() // State object for external health analyzer
    @State private var selectedBodyPart: BodyPart? // State for selected body part
    @State private var capturedImage: PlatformImage? // State for captured image
    @State private var showImagePicker = false // State for showing image picker
    @State private var showCamera = false // State for showing camera
    @State private var isAnalyzing = false // State for analysis in progress
    @State private var analysisResult: AnalysisResult? // State for analysis result
    @State private var errorMessage: String? // State for error message
    
    enum BodyPart: String, CaseIterable, Identifiable { // Enum for body parts
        case skin = "Skin" // Skin
        case eyes = "Eyes" // Eyes
        case nose = "Nose" // Nose
        case nails = "Nails" // Nails
        case hair = "Hair" // Hair
        case beard = "Beard" // Beard
        
        var id: String { rawValue } // ID property
        var icon: String { // Icon property
            switch self { // Switch on body part
            case .skin: return "face.smiling.fill" // Return icon
            case .eyes: return "eye.fill" // Return icon
            case .nose: return "nose.fill" // Return icon
            case .nails: return "hand.raised.fill" // Return icon
            case .hair: return "scissors.badge.ellipsis" // Return icon
            case .beard: return "mustache.fill" // Return icon
            }
        }
        
        var instructions: String { // Instructions property
            switch self { // Switch on body part
            case .skin: return "Capture a clear photo of your face or skin area in good lighting" // Return instructions
            case .eyes: return "Capture a close-up photo of your eyes, looking straight ahead" // Return instructions
            case .nose: return "Capture a clear photo of your nose area" // Return instructions
            case .nails: return "Capture a clear photo of your fingernails or toenails" // Return instructions
            case .hair: return "Capture a clear photo of your hair and scalp" // Return instructions
            case .beard: return "Capture a clear photo of your beard area" // Return instructions
            }
        }
    }
    
    enum AnalysisResult { // Enum for analysis results
        case skin(ExternalSkinAnalysis) // Skin analysis
        case eyes(ExternalEyeAnalysis) // Eye analysis
        case nose(ExternalNoseAnalysis) // Nose analysis
        case nails(ExternalNailAnalysis) // Nail analysis
        case hair(ExternalHairAnalysis) // Hair analysis
        case beard(ExternalBeardAnalysis) // Beard analysis
    }
    
    var body: some View { // Define body property returning view hierarchy
        VStack(spacing: 0) { // Create vertical stack
            // Header with Done button
            HStack {
                Text("External Health")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                
                Spacer()
                
                Button("Done") {
                    dismiss() // Dismiss view
                }
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.primary)
                .padding(.trailing, AppDesign.Spacing.md)
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ScrollView { // Create scrollable view
                VStack(spacing: AppDesign.Spacing.lg) { // Create vertical stack
                    // Header
                    VStack(spacing: AppDesign.Spacing.sm) { // Create vertical stack
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppDesign.Colors.primary)
                        
                        Text("External Health Analysis")
                            .font(AppDesign.Typography.title)
                            .fontWeight(.bold)
                        
                        Text("Capture images of external body parts for health analysis using Vision framework")
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, AppDesign.Spacing.lg)
                    
                    // Body Part Selection
                    if selectedBodyPart == nil { // Check if no body part selected
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
                            Text("Select Body Part")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, AppDesign.Spacing.md)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppDesign.Spacing.md) { // Create grid
                                ForEach(BodyPart.allCases) { part in // Iterate through body parts
                                    BodyPartCard(part: part) { // Create body part card
                                        selectedBodyPart = part // Set selected body part
                                    }
                                }
                            }
                            .padding(.horizontal, AppDesign.Spacing.md)
                        }
                    } else { // If body part selected
                        // Capture Interface
                        VStack(spacing: AppDesign.Spacing.lg) { // Create vertical stack
                            // Instructions
                            ModernCard {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                                    HStack { // Create horizontal stack
                                        Image(systemName: selectedBodyPart?.icon ?? "camera.fill")
                                            .foregroundColor(AppDesign.Colors.primary)
                                        Text(selectedBodyPart?.rawValue ?? "")
                                            .font(AppDesign.Typography.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Text(selectedBodyPart?.instructions ?? "")
                                        .font(AppDesign.Typography.body)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                            }
                            .padding(.horizontal, AppDesign.Spacing.md)
                            
                            // Captured Image Preview
                            if let image = capturedImage { // Check if image captured
                                ModernCard {
                                    VStack(spacing: AppDesign.Spacing.md) { // Create vertical stack
                                        #if canImport(UIKit)
                                        // On iOS, PlatformImage is UIImage
                                        if let uiImage = image as? UIImage {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: 300)
                                                .cornerRadius(AppDesign.Radius.medium)
                                        }
                                        #elseif canImport(AppKit)
                                        // On macOS, PlatformImage is NSImage (no cast needed)
                                        Image(nsImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 300)
                                            .cornerRadius(AppDesign.Radius.medium)
                                        #endif
                                        
                                        if isAnalyzing { // Check if analyzing
                                            ProgressView("Analyzing...")
                                                .padding()
                                        } else { // If not analyzing
                                            Button(action: analyzeImage) { // Analyze button
                                                Text("Analyze Image")
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
                                        
                                        Button(action: { // Retake button
                                            capturedImage = nil // Clear image
                                        }) {
                                            Text("Retake Photo")
                                                .font(AppDesign.Typography.headline)
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, AppDesign.Spacing.md)
                            } else { // If no image captured
                                // Capture Buttons
                                VStack(spacing: AppDesign.Spacing.md) { // Create vertical stack
                                    #if canImport(UIKit)
                                    Button(action: { showCamera = true }) { // Camera button
                                        VStack(spacing: AppDesign.Spacing.sm) { // Create vertical stack
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 40))
                                            Text("Take Photo")
                                                .font(AppDesign.Typography.headline)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppDesign.Spacing.lg)
                                        .background(AppDesign.Colors.primary)
                                        .cornerRadius(AppDesign.Radius.medium)
                                    }
                                    #endif
                                    
                                    Button(action: { showImagePicker = true }) { // Photo library button
                                        VStack(spacing: AppDesign.Spacing.sm) { // Create vertical stack
                                            Image(systemName: "photo.on.rectangle")
                                                .font(.system(size: 40))
                                            Text("Choose from Library")
                                                .font(AppDesign.Typography.headline)
                                        }
                                        .foregroundColor(AppDesign.Colors.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppDesign.Spacing.lg)
                                        .background(AppDesign.Colors.primary.opacity(0.1))
                                        .cornerRadius(AppDesign.Radius.medium)
                                    }
                                }
                                .padding(.horizontal, AppDesign.Spacing.md)
                            }
                            
                            // Back Button
                            Button(action: { // Back button
                                selectedBodyPart = nil // Clear selection
                                capturedImage = nil // Clear image
                                analysisResult = nil // Clear result
                            }) {
                                Text("Back to Selection")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                    }
                    
                    // Analysis Results
                    if let result = analysisResult { // Check if result available
                        AnalysisResultsView(result: result) // Show results view
                            .padding(.horizontal, AppDesign.Spacing.md)
                    }
                    
                    // Error Message
                    if let error = errorMessage { // Check if error
                        ModernCard {
                            Text(error)
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.error)
                                .padding()
                        }
                        .padding(.horizontal, AppDesign.Spacing.md)
                    }
                }
                .padding(.bottom, AppDesign.Spacing.xl)
            }
        }
        #if canImport(UIKit)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $capturedImage) // Show image picker
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $capturedImage) // Show camera
        }
        #endif
    }
    
    // MARK: - Analyze Image
    private func analyzeImage() { // Analyze captured image
        guard let image = capturedImage, // Check if image available
              let bodyPart = selectedBodyPart else { return } // Check if body part selected
        
        isAnalyzing = true // Set analyzing state
        errorMessage = nil // Clear error message
        
        switch bodyPart { // Switch on body part
        case .skin: // Skin
            analyzer.analyzeSkin(from: image) { result in // Analyze skin
                handleAnalysisResult(result: result) // Handle result
            }
        case .eyes: // Eyes
            analyzer.analyzeEyes(from: image) { result in // Analyze eyes
                handleAnalysisResult(result: result) // Handle result
            }
        case .nose: // Nose
            analyzer.analyzeNose(from: image) { result in // Analyze nose
                handleAnalysisResult(result: result) // Handle result
            }
        case .nails: // Nails
            analyzer.analyzeNails(from: image) { result in // Analyze nails
                handleAnalysisResult(result: result) // Handle result
            }
        case .hair: // Hair
            analyzer.analyzeHair(from: image) { result in // Analyze hair
                handleAnalysisResult(result: result) // Handle result
            }
        case .beard: // Beard
            analyzer.analyzeBeard(from: image) { result in // Analyze beard
                handleAnalysisResult(result: result) // Handle result
            }
        }
    }
    
    // MARK: - Handle Analysis Result
    private func handleAnalysisResult<T>(result: Result<T, Error>) where T: Codable { // Handle analysis result
        DispatchQueue.main.async { // Switch to main thread
            isAnalyzing = false // Set analyzing state to false
            
            switch result { // Switch on result
            case .success(let analysis): // If success
                if let skinAnalysis = analysis as? ExternalSkinAnalysis { // Check if skin analysis
                    analysisResult = .skin(skinAnalysis) // Set result
                } else if let eyeAnalysis = analysis as? ExternalEyeAnalysis { // Check if eye analysis
                    analysisResult = .eyes(eyeAnalysis) // Set result
                } else if let noseAnalysis = analysis as? ExternalNoseAnalysis { // Check if nose analysis
                    analysisResult = .nose(noseAnalysis) // Set result
                } else if let nailAnalysis = analysis as? ExternalNailAnalysis { // Check if nail analysis
                    analysisResult = .nails(nailAnalysis) // Set result
                } else if let hairAnalysis = analysis as? ExternalHairAnalysis { // Check if hair analysis
                    analysisResult = .hair(hairAnalysis) // Set result
                } else if let beardAnalysis = analysis as? ExternalBeardAnalysis { // Check if beard analysis
                    analysisResult = .beard(beardAnalysis) // Set result
                }
            case .failure(let error): // If failure
                errorMessage = error.localizedDescription // Set error message
            }
        }
    }
}

// MARK: - Body Part Card
struct BodyPartCard: View { // Define BodyPartCard struct
    let part: ExternalHealthCaptureView.BodyPart // Body part
    let action: () -> Void // Action closure
    
    var body: some View { // Define body property
        Button(action: action) { // Create button
            ModernCard {
                VStack(spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Image(systemName: part.icon)
                        .font(.system(size: 40))
                        .foregroundColor(AppDesign.Colors.primary)
                    
                    Text(part.rawValue)
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                }
                .padding(AppDesign.Spacing.md)
            }
        }
    }
}

// MARK: - Analysis Results View
struct AnalysisResultsView: View { // Define AnalysisResultsView struct
    let result: ExternalHealthCaptureView.AnalysisResult // Analysis result
    
    var body: some View { // Define body property
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
                Text("Analysis Results")
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                
                switch result { // Switch on result
                case .skin(let analysis): // Skin analysis
                    SkinAnalysisView(analysis: analysis) // Show skin analysis
                case .eyes(let analysis): // Eye analysis
                    EyeAnalysisView(analysis: analysis) // Show eye analysis
                case .nose(let analysis): // Nose analysis
                    NoseAnalysisView(analysis: analysis) // Show nose analysis
                case .nails(let analysis): // Nail analysis
                    NailAnalysisView(analysis: analysis) // Show nail analysis
                case .hair(let analysis): // Hair analysis
                    HairAnalysisView(analysis: analysis) // Show hair analysis
                case .beard(let analysis): // Beard analysis
                    BeardAnalysisView(analysis: analysis) // Show beard analysis
                }
            }
            .padding(AppDesign.Spacing.md)
        }
    }
}

// MARK: - Image Picker
#if canImport(UIKit)
struct ImagePicker: UIViewControllerRepresentable { // Define ImagePicker struct
    @Binding var image: PlatformImage? // Binding for image
    
    func makeUIViewController(context: Context) -> UIImagePickerController { // Create picker controller
        let picker = UIImagePickerController() // Create picker
        picker.delegate = context.coordinator // Set delegate
        picker.sourceType = .photoLibrary // Set source type
        return picker // Return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { // Update controller
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator { // Create coordinator
        Coordinator(self) // Return coordinator
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate { // Define coordinator
        let parent: ImagePicker // Parent picker
        
        init(_ parent: ImagePicker) { // Initialize coordinator
            self.parent = parent // Set parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // Handle image selection
            if let uiImage = info[.originalImage] as? UIImage { // Get image
                parent.image = uiImage as? PlatformImage // Set image
            }
            picker.dismiss(animated: true) // Dismiss picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { // Handle cancellation
            picker.dismiss(animated: true) // Dismiss picker
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable { // Define CameraView struct
    @Binding var image: PlatformImage? // Binding for image
    
    func makeUIViewController(context: Context) -> UIImagePickerController { // Create picker controller
        let picker = UIImagePickerController() // Create picker
        picker.delegate = context.coordinator // Set delegate
        picker.sourceType = .camera // Set source type
        return picker // Return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { // Update controller
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator { // Create coordinator
        Coordinator(self) // Return coordinator
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate { // Define coordinator
        let parent: CameraView // Parent camera view
        
        init(_ parent: CameraView) { // Initialize coordinator
            self.parent = parent // Set parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // Handle image capture
            if let uiImage = info[.originalImage] as? UIImage { // Get image
                parent.image = uiImage as? PlatformImage // Set image
            }
            picker.dismiss(animated: true) // Dismiss picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { // Handle cancellation
            picker.dismiss(animated: true) // Dismiss picker
        }
    }
}
#endif
