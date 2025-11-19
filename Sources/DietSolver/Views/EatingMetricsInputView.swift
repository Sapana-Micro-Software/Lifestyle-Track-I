//
//  EatingMetricsInputView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct EatingMetricsInputView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var mealType: EatingMetrics.MealType = .breakfast
    @State private var duration: Double = 20.0
    @State private var totalBites: Int = 30
    @State private var totalChews: Int = 600
    @State private var foodPieces: [EatingMetrics.FoodPiece] = []
    @State private var currentFoodPiece: FoodPieceInput = FoodPieceInput()
    @State private var notes: String = ""
    
    struct FoodPieceInput {
        var name: String = ""
        var length: Double = 2.0
        var width: Double = 2.0
        var height: Double = 2.0
        var weight: Double? = nil
        var bites: Int = 1
        var chews: Int = 20
    }
    
    var body: some View {
        ZStack {
            AppDesign.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.lg) {
                    // Header
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            IconBadge(icon: "fork.knife.circle.fill", color: AppDesign.Colors.primary, size: 60)
                            Text("Eating Metrics")
                                .font(AppDesign.Typography.title2)
                            Text("Track your eating speed, chewing habits, and food piece sizes")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.top, AppDesign.Spacing.lg)
                    
                    // Meal Type
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            Text("Meal Type")
                                .font(AppDesign.Typography.subheadline)
                            Picker("", selection: $mealType) {
                                ForEach(EatingMetrics.MealType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Duration
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            HStack {
                                Text("Duration")
                                    .font(AppDesign.Typography.subheadline)
                                Spacer()
                                Text("\(Int(duration)) minutes")
                                    .font(AppDesign.Typography.headline)
                                    .foregroundColor(AppDesign.Colors.primary)
                            }
                            Slider(value: $duration, in: 5...60, step: 1)
                                .tint(AppDesign.Colors.primary)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Bites and Chews
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                    Text("Total Bites")
                                        .font(AppDesign.Typography.subheadline)
                                    Stepper("\(totalBites)", value: $totalBites, in: 1...200)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                    Text("Total Chews")
                                        .font(AppDesign.Typography.subheadline)
                                    Stepper("\(totalChews)", value: $totalChews, in: 1...2000)
                                }
                            }
                            
                            Divider()
                            
                            // Calculated metrics
                            VStack(spacing: AppDesign.Spacing.xs) {
                                HStack {
                                    Text("Eating Speed")
                                    Spacer()
                                    Text(String(format: "%.1f bites/min", Double(totalBites) / duration))
                                        .font(AppDesign.Typography.headline)
                                        .foregroundColor(AppDesign.Colors.primary)
                                }
                                HStack {
                                    Text("Chews per Bite")
                                    Spacer()
                                    Text(String(format: "%.1f", Double(totalChews) / Double(totalBites)))
                                        .font(AppDesign.Typography.headline)
                                        .foregroundColor(AppDesign.Colors.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Food Pieces
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                            Text("Food Pieces")
                                .font(AppDesign.Typography.headline)
                            
                            // Add food piece form
                            VStack(spacing: AppDesign.Spacing.sm) {
                                TextField("Food name", text: $currentFoodPiece.name)
                                    .foregroundColor(.black)
                                    .textFieldStyle(.roundedBorder)
                                
                                HStack {
                                    VStack {
                                        Text("Length (cm)")
                                            .font(AppDesign.Typography.caption)
                                        TextField("", value: $currentFoodPiece.length, format: .number)
                                            .foregroundColor(.black)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    VStack {
                                        Text("Width (cm)")
                                            .font(AppDesign.Typography.caption)
                                        TextField("", value: $currentFoodPiece.width, format: .number)
                                            .foregroundColor(.black)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    VStack {
                                        Text("Height (cm)")
                                            .font(AppDesign.Typography.caption)
                                        TextField("", value: $currentFoodPiece.height, format: .number)
                                            .foregroundColor(.black)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                }
                                
                                HStack {
                                    VStack {
                                        Text("Bites")
                                            .font(AppDesign.Typography.caption)
                                        Stepper("\(currentFoodPiece.bites)", value: $currentFoodPiece.bites, in: 1...50)
                                    }
                                    VStack {
                                        Text("Chews")
                                            .font(AppDesign.Typography.caption)
                                        Stepper("\(currentFoodPiece.chews)", value: $currentFoodPiece.chews, in: 1...200)
                                    }
                                }
                                
                                Button(action: addFoodPiece) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Food Piece")
                                    }
                                    .font(AppDesign.Typography.subheadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppDesign.Spacing.sm)
                                    .background(AppDesign.Colors.primary)
                                    .cornerRadius(AppDesign.Radius.medium)
                                }
                            }
                            
                            // List of added pieces
                            if !foodPieces.isEmpty {
                                Divider()
                                ForEach(foodPieces) { piece in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(piece.name)
                                                .font(AppDesign.Typography.body)
                                            Text("\(Int(piece.volume)) cm³ • \(piece.bites) bites • \(piece.chews) chews")
                                                .font(AppDesign.Typography.caption)
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        Spacer()
                                        Button(action: { removeFoodPiece(piece) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Notes
                    ModernCard {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                            Text("Notes")
                                .font(AppDesign.Typography.subheadline)
                            TextEditor(text: $notes)
                                .foregroundColor(.black)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Radius.small)
                                        .stroke(AppDesign.Colors.primary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Save Button
                    GradientButton(
                        title: "Save Metrics",
                        icon: "checkmark.circle.fill",
                        action: saveMetrics
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.bottom, AppDesign.Spacing.xl)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Text("Eating Metrics")
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
        }
    }
    
    private func addFoodPiece() {
        guard !currentFoodPiece.name.isEmpty else { return }
        let piece = EatingMetrics.FoodPiece(
            name: currentFoodPiece.name,
            length: currentFoodPiece.length,
            width: currentFoodPiece.width,
            height: currentFoodPiece.height,
            weight: currentFoodPiece.weight,
            bites: currentFoodPiece.bites,
            chews: currentFoodPiece.chews
        )
        foodPieces.append(piece)
        currentFoodPiece = FoodPieceInput()
    }
    
    private func removeFoodPiece(_ piece: EatingMetrics.FoodPiece) {
        foodPieces.removeAll { $0.id == piece.id }
    }
    
    private func saveMetrics() {
        let metrics = EatingMetrics(
            date: Date(),
            mealType: mealType,
            duration: duration,
            totalBites: totalBites,
            totalChews: totalChews,
            foodPieces: foodPieces,
            notes: notes.isEmpty ? nil : notes
        )
        
        // Create health data if it doesn't exist (for fake data testing)
        var healthData = viewModel.healthData ?? HealthData(age: 30, gender: .male, weight: 70, height: 170, activityLevel: .moderate)
        healthData.eatingMetrics.append(metrics)
        viewModel.updateHealthData(healthData)
        dismiss()
    }
}
