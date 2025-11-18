//
//  UnitSystemToggleView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

// MARK: - Unit System Toggle View
struct UnitSystemToggleView: View { // Define UnitSystemToggleView struct conforming to View protocol
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    @State private var isToggling = false // State variable to track toggle animation
    
    var body: some View { // Define body property returning view hierarchy
        HStack(spacing: AppDesign.Spacing.md) { // Create horizontal stack with medium spacing
            Image(systemName: "ruler") // Display ruler icon
                .foregroundColor(AppDesign.Colors.primary) // Set icon color to primary
                .font(.system(size: 16)) // Set icon font size
            
            Text("Units:") // Display "Units:" label
                .font(AppDesign.Typography.subheadline) // Set font to subheadline
                .foregroundColor(AppDesign.Colors.textSecondary) // Set text color to secondary
            
            Picker("", selection: $viewModel.unitSystem) { // Create picker for unit system selection
                ForEach(UnitSystem.allCases, id: \.self) { system in // Iterate through all unit systems
                    Text(system.rawValue).tag(system) // Display system name and tag
                }
            }
            .pickerStyle(.menu) // Set picker style to menu
            .onChange(of: viewModel.unitSystem) { _ in // Observe unit system changes
                withAnimation(.spring()) { // Animate toggle change
                    isToggling.toggle() // Toggle animation state
                }
            }
            
            Spacer() // Add spacer to push content to left
        }
        .padding(.horizontal, AppDesign.Spacing.md) // Add horizontal padding
        .padding(.vertical, AppDesign.Spacing.sm) // Add vertical padding
    }
}

// MARK: - Compact Unit System Toggle
struct CompactUnitSystemToggle: View { // Define CompactUnitSystemToggle struct for compact display
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    
    var body: some View { // Define body property returning view hierarchy
        Button(action: { // Create button with toggle action
            withAnimation(.spring()) { // Animate toggle change
                viewModel.toggleUnitSystem() // Toggle unit system
            }
        }) {
            HStack(spacing: AppDesign.Spacing.xs) { // Create horizontal stack with extra small spacing
                Image(systemName: "arrow.left.arrow.right") // Display swap arrows icon
                    .font(.system(size: 12)) // Set icon font size
                Text(viewModel.unitSystem.rawValue) // Display current unit system
                    .font(AppDesign.Typography.caption) // Set font to caption
            }
            .foregroundColor(AppDesign.Colors.primary) // Set foreground color to primary
            .padding(.horizontal, AppDesign.Spacing.sm) // Add horizontal padding
            .padding(.vertical, AppDesign.Spacing.xs) // Add vertical padding
            .background(AppDesign.Colors.surface) // Set background to surface color
            .cornerRadius(AppDesign.Radius.small) // Apply small corner radius
        }
        .buttonStyle(PlainButtonStyle()) // Apply plain button style
    }
}
