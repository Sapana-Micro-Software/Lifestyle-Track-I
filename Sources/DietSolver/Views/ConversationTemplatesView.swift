//
//  ConversationTemplatesView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct ConversationTemplatesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var chatbotManager = PsychologistChatbotManager.shared
    
    @State private var selectedCategory: ConversationTemplate.TemplateCategory?
    @State private var selectedTemplate: ConversationTemplate?
    @State private var customizedText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Conversation Templates")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(AppDesign.Typography.headline)
                .foregroundColor(AppDesign.Colors.primary)
                .padding(.trailing, AppDesign.Spacing.md)
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Categories
                    ForEach(ConversationTemplate.TemplateCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(AppDesign.Colors.primary)
                                Text(category.rawValue)
                                    .font(AppDesign.Typography.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, AppDesign.Spacing.md)
                            
                            ForEach(ConversationTemplateLibrary.shared.templates(for: category)) { template in
                                Button(action: {
                                    selectedTemplate = template
                                    customizedText = template.template
                                }) {
                                    ModernCard {
                                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                                            Text(template.title)
                                                .font(AppDesign.Typography.headline)
                                            Text(template.description)
                                                .font(AppDesign.Typography.caption)
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        .padding(AppDesign.Spacing.md)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, AppDesign.Spacing.md)
                        }
                    }
                }
                .padding(.vertical, AppDesign.Spacing.lg)
            }
        }
        .background(AppDesign.Colors.background)
        .sheet(item: $selectedTemplate) { template in
            TemplateCustomizationView(template: template, customizedText: $customizedText, onSend: { text in
                Task {
                    await chatbotManager.processUserMessage(text)
                }
                dismiss()
            })
        }
    }
}

// MARK: - Template Customization View
struct TemplateCustomizationView: View {
    let template: ConversationTemplate
    @Binding var customizedText: String
    let onSend: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppDesign.Spacing.md) {
                Text("Customize your message")
                    .font(AppDesign.Typography.headline)
                    .padding(.top, AppDesign.Spacing.md)
                
                TextEditor(text: $customizedText)
                    .padding(AppDesign.Spacing.sm)
                    .background(AppDesign.Colors.surface)
                    .cornerRadius(AppDesign.Radius.medium)
                    .frame(minHeight: 200)
                    .padding(.horizontal, AppDesign.Spacing.md)
                
                Button("Send Message") {
                    onSend(customizedText)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, AppDesign.Spacing.md)
                
                Spacer()
            }
            .navigationTitle(template.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
