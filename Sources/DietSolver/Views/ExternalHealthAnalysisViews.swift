//
//  ExternalHealthAnalysisViews.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

// MARK: - Skin Analysis View
struct SkinAnalysisView: View { // Define SkinAnalysisView struct
    let analysis: ExternalSkinAnalysis // Skin analysis data
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            // Conditions
            if !analysis.conditions.isEmpty { // Check if conditions exist
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Text("Detected Conditions")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.conditions, id: \.self) { condition in // Iterate through conditions
                        HStack { // Create horizontal stack
                            Image(systemName: conditionIcon(for: condition))
                                .foregroundColor(conditionColor(for: condition))
                            Text(condition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppDesign.Typography.body)
                        }
                    }
                }
            }
            
            // Attributes
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                if let texture = analysis.texture { // Check if texture available
                    InfoRow(label: "Texture", value: texture.rawValue.capitalized) // Show texture
                }
                
                if let color = analysis.color { // Check if color available
                    InfoRow(label: "Color", value: color.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) // Show color
                }
                
                if let hydration = analysis.hydration { // Check if hydration available
                    InfoRow(label: "Hydration", value: hydration.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) // Show hydration
                }
                
                InfoRow(label: "Confidence", value: String(format: "%.0f%%", analysis.confidence * 100)) // Show confidence
            }
        }
    }
    
    private func conditionIcon(for condition: ExternalSkinAnalysis.ExternalSkinCondition) -> String { // Get condition icon
        switch condition { // Switch on condition
        case .normal: return "checkmark.circle.fill" // Return icon
        default: return "exclamationmark.triangle.fill" // Return icon
        }
    }
    
    private func conditionColor(for condition: ExternalSkinAnalysis.ExternalSkinCondition) -> Color { // Get condition color
        switch condition { // Switch on condition
        case .normal: return AppDesign.Colors.success // Return color
        default: return AppDesign.Colors.warning // Return color
        }
    }
}

// MARK: - Eye Analysis View
struct EyeAnalysisView: View { // Define EyeAnalysisView struct
    let analysis: ExternalEyeAnalysis // Eye analysis data
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            // Conditions
            if !analysis.conditions.isEmpty { // Check if conditions exist
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Text("Detected Conditions")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.conditions, id: \.self) { condition in // Iterate through conditions
                        HStack { // Create horizontal stack
                            Image(systemName: condition == .normal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(condition == .normal ? AppDesign.Colors.success : AppDesign.Colors.warning)
                            Text(condition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppDesign.Typography.body)
                        }
                    }
                }
            }
            
            // Attributes
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                if let redness = analysis.redness { // Check if redness available
                    InfoRow(label: "Redness", value: redness.rawValue.capitalized) // Show redness
                }
                
                if let clarity = analysis.clarity { // Check if clarity available
                    InfoRow(label: "Clarity", value: clarity.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) // Show clarity
                }
                
                InfoRow(label: "Confidence", value: String(format: "%.0f%%", analysis.confidence * 100)) // Show confidence
            }
        }
    }
}

// MARK: - Nose Analysis View
struct NoseAnalysisView: View { // Define NoseAnalysisView struct
    let analysis: ExternalNoseAnalysis // Nose analysis data
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            // Conditions
            if !analysis.conditions.isEmpty { // Check if conditions exist
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Text("Detected Conditions")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.conditions, id: \.self) { condition in // Iterate through conditions
                        HStack { // Create horizontal stack
                            Image(systemName: condition == .normal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(condition == .normal ? AppDesign.Colors.success : AppDesign.Colors.warning)
                            Text(condition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppDesign.Typography.body)
                        }
                    }
                }
            }
            
            // Attributes
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                if let inflammation = analysis.inflammation { // Check if inflammation available
                    InfoRow(label: "Inflammation", value: inflammation.rawValue.capitalized) // Show inflammation
                }
                
                InfoRow(label: "Confidence", value: String(format: "%.0f%%", analysis.confidence * 100)) // Show confidence
            }
        }
    }
}

// MARK: - Nail Analysis View
struct NailAnalysisView: View { // Define NailAnalysisView struct
    let analysis: ExternalNailAnalysis // Nail analysis data
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            // Conditions
            if !analysis.conditions.isEmpty { // Check if conditions exist
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Text("Detected Conditions")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.conditions, id: \.self) { condition in // Iterate through conditions
                        HStack { // Create horizontal stack
                            Image(systemName: condition == .normal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(condition == .normal ? AppDesign.Colors.success : AppDesign.Colors.warning)
                            Text(condition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppDesign.Typography.body)
                        }
                    }
                }
            }
            
            // Attributes
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                if let color = analysis.color { // Check if color available
                    InfoRow(label: "Color", value: color.rawValue.capitalized) // Show color
                }
                
                if let texture = analysis.texture { // Check if texture available
                    InfoRow(label: "Texture", value: texture.rawValue.capitalized) // Show texture
                }
                
                InfoRow(label: "Confidence", value: String(format: "%.0f%%", analysis.confidence * 100)) // Show confidence
            }
        }
    }
}

// MARK: - Hair Analysis View
struct HairAnalysisView: View { // Define HairAnalysisView struct
    let analysis: ExternalHairAnalysis // Hair analysis data
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            // Conditions
            if !analysis.conditions.isEmpty { // Check if conditions exist
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Text("Detected Conditions")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.conditions, id: \.self) { condition in // Iterate through conditions
                        HStack { // Create horizontal stack
                            Image(systemName: condition == .normal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(condition == .normal ? AppDesign.Colors.success : AppDesign.Colors.warning)
                            Text(condition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppDesign.Typography.body)
                        }
                    }
                }
            }
            
            // Attributes
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                if let texture = analysis.texture { // Check if texture available
                    InfoRow(label: "Texture", value: texture.rawValue.capitalized) // Show texture
                }
                
                if let thickness = analysis.thickness { // Check if thickness available
                    InfoRow(label: "Thickness", value: thickness.rawValue.capitalized) // Show thickness
                }
                
                if let health = analysis.health { // Check if health available
                    InfoRow(label: "Health", value: health.rawValue.capitalized) // Show health
                }
                
                InfoRow(label: "Confidence", value: String(format: "%.0f%%", analysis.confidence * 100)) // Show confidence
            }
        }
    }
}

// MARK: - Beard Analysis View
struct BeardAnalysisView: View { // Define BeardAnalysisView struct
    let analysis: ExternalBeardAnalysis // Beard analysis data
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) { // Create vertical stack
            // Conditions
            if !analysis.conditions.isEmpty { // Check if conditions exist
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                    Text("Detected Conditions")
                        .font(AppDesign.Typography.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.conditions, id: \.self) { condition in // Iterate through conditions
                        HStack { // Create horizontal stack
                            Image(systemName: condition == .normal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(condition == .normal ? AppDesign.Colors.success : AppDesign.Colors.warning)
                            Text(condition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppDesign.Typography.body)
                        }
                    }
                }
            }
            
            // Attributes
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) { // Create vertical stack
                if let texture = analysis.texture { // Check if texture available
                    InfoRow(label: "Texture", value: texture.rawValue.capitalized) // Show texture
                }
                
                if let thickness = analysis.thickness { // Check if thickness available
                    InfoRow(label: "Thickness", value: thickness.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) // Show thickness
                }
                
                if let health = analysis.health { // Check if health available
                    InfoRow(label: "Health", value: health.rawValue.capitalized) // Show health
                }
                
                InfoRow(label: "Confidence", value: String(format: "%.0f%%", analysis.confidence * 100)) // Show confidence
            }
        }
    }
}

// MARK: - Info Row
struct InfoRow: View { // Define InfoRow struct
    let label: String // Label text
    let value: String // Value text
    
    var body: some View { // Define body property
        HStack { // Create horizontal stack
            Text(label + ":")
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textSecondary)
            Spacer() // Add spacer
            Text(value)
                .font(AppDesign.Typography.body)
                .fontWeight(.semibold)
        }
    }
}
