//
//  PassportMRZScannerView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax
#if canImport(UIKit)
import UIKit // Import UIKit for camera and image processing
#endif

// MARK: - Passport MRZ Scanner View
#if canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *) // Require iOS 13+ or macOS 10.15+ for Vision framework
struct PassportMRZScannerView: View { // Define PassportMRZScannerView struct conforming to View protocol
    @ObservedObject var passportManager: PassportManager // Observed passport manager
    let onComplete: (PassportData?) -> Void // Completion handler
    @Environment(\.dismiss) var dismiss // Dismiss environment value
    @State private var capturedImage: UIImage? // State for captured image
    @State private var isProcessing = false // State for processing status
    @State private var showImagePicker = false // State for showing image picker
    
    var body: some View { // Define body property returning view hierarchy
        NavigationView { // Create navigation view
            VStack(spacing: AppDesign.Spacing.lg) { // Create vertical stack
                if let image = capturedImage { // Check if image captured
                    // Show captured image with processing
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(AppDesign.Radius.medium)
                        .padding()
                    
                    if isProcessing { // Check if processing
                        ProgressView("Processing MRZ...")
                            .padding()
                    }
                    
                    HStack(spacing: AppDesign.Spacing.md) { // Create horizontal stack
                        Button("Retake") { // Retake button
                            capturedImage = nil // Clear image
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Process") { // Process button
                            processImage(image) // Process image
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isProcessing) // Disable if processing
                    }
                } else { // If no image
                    // Instructions
                    VStack(spacing: AppDesign.Spacing.md) { // Create vertical stack
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppDesign.Colors.primary)
                        
                        Text("Scan Passport MRZ")
                            .font(AppDesign.Typography.title2)
                            .fontWeight(.bold)
                        
                        Text("Position the Machine Readable Zone (MRZ) at the bottom of your passport within the frame")
                            .font(AppDesign.Typography.body)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { // Camera button
                            showImagePicker = true // Show image picker
                        }) {
                            HStack { // Create horizontal stack
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                            .font(AppDesign.Typography.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, AppDesign.Spacing.md)
                            .padding(.horizontal, AppDesign.Spacing.lg)
                            .background(AppDesign.Colors.primary)
                            .cornerRadius(AppDesign.Radius.medium)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Passport Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { // Cancel button
                        dismiss() // Dismiss view
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) { // Image picker sheet
            ImagePicker(image: $capturedImage) // Image picker
        }
    }
    
    // MARK: - Process Image
    private func processImage(_ image: UIImage) { // Process captured image
        isProcessing = true // Set processing status
        
        passportManager.scanMRZFromImage(image) { passportData in // Scan MRZ from image
            DispatchQueue.main.async { // Switch to main thread
                isProcessing = false // Set processing status to false
                onComplete(passportData) // Call completion handler
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable { // Define ImagePicker struct for UIKit integration
    @Binding var image: UIImage? // Binding for selected image
    @Environment(\.dismiss) var dismiss // Dismiss environment value
    
    func makeUIViewController(context: Context) -> UIImagePickerController { // Create image picker controller
        let picker = UIImagePickerController() // Create picker
        picker.delegate = context.coordinator // Set delegate
        picker.sourceType = .camera // Set source type to camera
        picker.allowsEditing = false // Disable editing
        return picker // Return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { // Update view controller
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator { // Create coordinator
        Coordinator(self) // Return coordinator
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate { // Define coordinator class
        let parent: ImagePicker // Parent image picker
        
        init(_ parent: ImagePicker) { // Initialize coordinator
            self.parent = parent // Set parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // Handle image selection
            if let image = info[.originalImage] as? UIImage { // Get original image
                parent.image = image // Set image
            }
            parent.dismiss() // Dismiss picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { // Handle cancellation
            parent.dismiss() // Dismiss picker
        }
    }
}
#else
// MARK: - Passport MRZ Scanner View (Unavailable)
struct PassportMRZScannerView: View { // Define fallback view
    @ObservedObject var passportManager: PassportManager // Observed passport manager
    let onComplete: (PassportData?) -> Void // Completion handler
    @Environment(\.dismiss) var dismiss // Dismiss environment value
    
    var body: some View { // Define body property
        Text("MRZ scanning is not available on this platform")
            .padding()
    }
}
#endif
