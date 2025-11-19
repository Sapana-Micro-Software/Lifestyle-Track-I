//
//  PsychologistChatView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI
import NaturalLanguage
#if canImport(UIKit)
import UIKit
import PhotosUI
import Vision
#endif
#if os(macOS)
import AppKit
#endif

struct PsychologistChatView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @StateObject private var chatbotManager = PsychologistChatbotManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var messageText: String = ""
    @State private var selectedImage: Any? = nil
    @State private var showImagePicker: Bool = false
    @State private var showCamera: Bool = false
    @State private var showCrisisAlert: Bool = false
    @State private var showProgress: Bool = false
    @State private var showCBTTools: Bool = false
    @State private var showEmotionRegulation: Bool = false
    @State private var showBreathing: Bool = false
    @State private var showTemplates: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppDesign.Spacing.md) {
                        if let session = chatbotManager.currentSession {
                            ForEach(session.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.vertical, AppDesign.Spacing.sm)
                }
                .onChange(of: chatbotManager.currentSession?.messages.count) { _ in
                    if let lastMessage = chatbotManager.currentSession?.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Crisis Alert
            if chatbotManager.crisisDetected {
                crisisAlertBanner
            }
            
            // Input Area
            messageInputArea
        }
        .background(AppDesign.Colors.background)
        .onAppear {
            setupChatbot()
        }
        .onChange(of: chatbotManager.crisisDetected) { detected in
            if detected {
                showCrisisAlert = true
            }
        }
        .alert("Crisis Detected", isPresented: $showCrisisAlert) {
            Button("Call Emergency Services", role: .destructive) {
                // Call emergency services
                #if os(iOS)
                if let url = URL(string: "tel://911") {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            Button("Crisis Hotline") {
                // Open crisis hotline
                #if os(iOS)
                if let url = URL(string: "tel://988") {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            Button("I'm Safe", role: .cancel) {
                chatbotManager.crisisDetected = false
            }
        } message: {
            Text("We're concerned about your safety. Please reach out for immediate help. You don't have to go through this alone.")
        }
        #if canImport(UIKit)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        #endif
        .sheet(isPresented: $showProgress) {
            PsychologistProgressView()
        }
        .sheet(isPresented: $showCBTTools) {
            CBTToolsView()
        }
        .sheet(isPresented: $showEmotionRegulation) {
            EmotionRegulationView()
        }
        .sheet(isPresented: $showBreathing) {
            BreathingVisualizationView(technique: .box)
        }
        .sheet(isPresented: $showTemplates) {
            ConversationTemplatesView()
        }
    }
    
    private var chatHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Psychologist Chat")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                
                if let session = chatbotManager.currentSession {
                    Text("Session started \(session.startDate, style: .relative)")
                        .font(AppDesign.Typography.caption)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: { showCBTTools = true }) {
                    Label("CBT Tools", systemImage: "brain.head.profile")
                }
                Button(action: { showEmotionRegulation = true }) {
                    Label("Emotion Regulation", systemImage: "heart.circle")
                }
                Button(action: { showBreathing = true }) {
                    Label("Breathing", systemImage: "wind")
                }
                Button(action: { showTemplates = true }) {
                    Label("Templates", systemImage: "doc.text")
                }
                Button(action: { showProgress = true }) {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(AppDesign.Colors.primary)
            }
            
            Button("Done") {
                chatbotManager.endCurrentSession()
                dismiss()
            }
            .font(AppDesign.Typography.headline)
            .foregroundColor(AppDesign.Colors.primary)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.sm)
        .background(AppDesign.Colors.surface)
    }
    
    private var crisisAlertBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text("Crisis detected - Please seek immediate help")
                .font(AppDesign.Typography.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Button("Get Help") {
                showCrisisAlert = true
            }
            .font(AppDesign.Typography.caption)
            .padding(.horizontal, AppDesign.Spacing.sm)
            .padding(.vertical, 4)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
        .padding(.vertical, AppDesign.Spacing.sm)
        .background(Color.red.opacity(0.1))
    }
    
    private var messageInputArea: some View {
        VStack(spacing: AppDesign.Spacing.sm) {
            // Image preview if selected
            if selectedImage != nil {
                HStack {
                    #if canImport(UIKit)
                    if let uiImage = selectedImage as? UIImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    }
                    #endif
                    Spacer()
                    Button(action: { selectedImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
            
            HStack(spacing: AppDesign.Spacing.sm) {
                // Image picker buttons
                #if canImport(UIKit)
                Menu {
                    Button(action: { showImagePicker = true }) {
                        Label("Photo Library", systemImage: "photo")
                    }
                    Button(action: { showCamera = true }) {
                        Label("Camera", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundColor(AppDesign.Colors.primary)
                }
                #endif
                
                // Text input
                TextField("Type your message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.black)
                    .lineLimit(1...5)
                
                // Send button
                Button(action: sendMessage) {
                    if chatbotManager.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? AppDesign.Colors.textSecondary : AppDesign.Colors.primary)
                    }
                }
                .disabled(messageText.isEmpty || chatbotManager.isProcessing)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
        }
    }
    
    private func setupChatbot() {
        chatbotManager.updateHealthData(viewModel.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate))
        chatbotManager.loadUserProfile()
        
        if chatbotManager.currentSession == nil {
            chatbotManager.startNewSession()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let text = messageText
        let image = selectedImage
        messageText = ""
        selectedImage = nil
        
        Task {
            await chatbotManager.processUserMessage(text, image: image)
            
            // Save to journal
            if var healthData = viewModel.healthData {
                var journalCollection = healthData.journalCollection
                let journalEntry = JournalEntry(
                    date: Date(),
                    entryType: .unstructured,
                    unstructuredText: text,
                    tags: ["psychologist_chat"]
                )
                journalCollection.entries.append(journalEntry)
                healthData.journalCollection = journalCollection
                viewModel.updateHealthData(healthData)
                
                // Update chatbot manager with new health data
                chatbotManager.updateHealthData(healthData)
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: AppDesign.Spacing.sm) {
            if message.role == .psychologist {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(AppDesign.Typography.body)
                    .foregroundColor(message.role == .user ? .white : AppDesign.Colors.textPrimary)
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.vertical, AppDesign.Spacing.sm)
                    .background(
                        Group {
                            if message.role == .user {
                                LinearGradient(
                                    colors: [AppDesign.Colors.primary, AppDesign.Colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                AppDesign.Colors.surface
                            }
                        }
                    )
                    .cornerRadius(AppDesign.Radius.large)
                    .shadow(color: AppDesign.Shadow.small.color, radius: AppDesign.Shadow.small.radius)
                
                // Sentiment indicator
                if let sentiment = message.sentiment, message.role == .user {
                    HStack(spacing: 4) {
                        Image(systemName: sentimentEmoji(sentiment))
                            .font(.caption)
                        Text(sentiment.dominantEmotion.rawValue)
                            .font(AppDesign.Typography.caption)
                    }
                    .foregroundColor(AppDesign.Colors.textSecondary)
                }
                
                // Therapy technique indicator
                if let technique = message.therapyTechnique, message.role == .psychologist {
                    HStack(spacing: AppDesign.Spacing.xs) {
                        Text(technique.rawValue)
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        
                        // Feedback buttons
                        HStack(spacing: 4) {
                            Button(action: {
                                let feedback = MessageFeedback(
                                    messageId: message.id,
                                    helpful: true,
                                    therapyTechnique: technique
                                )
                                FeedbackLearningManager.shared.recordFeedback(feedback)
                            }) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppDesign.Colors.success)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                let feedback = MessageFeedback(
                                    messageId: message.id,
                                    helpful: false,
                                    therapyTechnique: technique
                                )
                                FeedbackLearningManager.shared.recordFeedback(feedback)
                            }) {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppDesign.Colors.error)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Image analysis
                if let imageAnalysis = message.imageAnalysis {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                        Text("Emotional state: \(imageAnalysis.emotionalState.rawValue)")
                    }
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                }
            }
            .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .user {
                Spacer()
            }
        }
    }
    
    private func sentimentEmoji(_ sentiment: SentimentAnalysis) -> String {
        switch sentiment.dominantEmotion {
        case .joy, .gratitude, .hope: return "😊"
        case .sadness: return "😢"
        case .anger: return "😠"
        case .fear, .anxiety: return "😰"
        case .stress: return "😓"
        default: return "😐"
        }
    }
}

#if canImport(UIKit)
// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Any?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        self.parent.selectedImage = uiImage
                    }
                }
            }
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: Any?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif
