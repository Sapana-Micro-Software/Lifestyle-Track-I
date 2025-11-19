//
//  DesignSystem.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Design System
struct AppDesign {
    // Colors
    struct Colors {
        static let primary = Color(red: 0.2, green: 0.6, blue: 0.9)
        static let secondary = Color(red: 0.4, green: 0.7, blue: 0.5)
        static let accent = Color(red: 0.9, green: 0.5, blue: 0.3)
        static let background = Color(red: 0.98, green: 0.98, blue: 0.99)
        static let surface = Color.white
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1) // Dark color for primary text
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4) // Medium gray for secondary text
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        
        // Gradient colors
        static let gradientStart = Color(red: 0.2, green: 0.6, blue: 0.9)
        static let gradientEnd = Color(red: 0.4, green: 0.7, blue: 0.5)
        
        // Category colors
        static func categoryColor(_ category: ExerciseCategory) -> Color {
            switch category {
            case .cardio: return Color(red: 0.9, green: 0.3, blue: 0.3)
            case .strength: return Color(red: 0.3, green: 0.5, blue: 0.9)
            case .flexibility: return Color(red: 0.3, green: 0.8, blue: 0.5)
            case .mindBody: return Color(red: 0.7, green: 0.3, blue: 0.9)
            case .breathing: return Color(red: 0.9, green: 0.6, blue: 0.3)
            case .dance: return Color(red: 0.9, green: 0.4, blue: 0.7)
            case .martialArts: return Color(red: 0.6, green: 0.4, blue: 0.3)
            case .functional: return Color(red: 0.5, green: 0.5, blue: 0.5)
            }
        }
    }
    
    // Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    }
    
    // Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // Corner Radius
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }
    
    // Shadows
    struct Shadow {
        static let small = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Modern Card View
struct ModernCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = AppDesign.Spacing.md
    var cornerRadius: CGFloat = AppDesign.Radius.medium
    var shadow: AppDesign.ShadowStyle = AppDesign.Shadow.small
    
    init(padding: CGFloat = AppDesign.Spacing.md,
         cornerRadius: CGFloat = AppDesign.Radius.medium,
         shadow: AppDesign.ShadowStyle = AppDesign.Shadow.small,
         @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(AppDesign.Colors.surface)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Gradient Button
struct GradientButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary
        case secondary
        case minimal
    }
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: AppDesign.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(AppDesign.Typography.headline)
                    .foregroundColor(style == .primary ? .white : AppDesign.Colors.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppDesign.Spacing.md)
            .background(
                Group {
                    if style == .primary {
                        LinearGradient(
                            colors: [AppDesign.Colors.gradientStart, AppDesign.Colors.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                    .stroke(style == .minimal ? Color.clear : AppDesign.Colors.primary, lineWidth: 2)
            )
            .cornerRadius(AppDesign.Radius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Icon Badge
struct IconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 40
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: String? = nil
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                HStack {
                    IconBadge(icon: icon, color: color, size: 36)
                    Spacer()
                    if let trend = trend {
                        Text(trend)
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                }
                Text(value)
                    .font(AppDesign.Typography.title2)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                Text(title)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif
            action()
        }) {
            VStack(spacing: AppDesign.Spacing.xs) {
                IconBadge(icon: icon, color: color, size: 50)
                Text(title)
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppDesign.Spacing.md)
            .background(AppDesign.Colors.surface)
            .cornerRadius(AppDesign.Radius.medium)
            .shadow(color: AppDesign.Shadow.small.color, radius: AppDesign.Shadow.small.radius, x: AppDesign.Shadow.small.x, y: AppDesign.Shadow.small.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Animated Progress Ring
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat = 8
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    
    init(_ title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppDesign.Typography.title2)
                .foregroundColor(AppDesign.Colors.textPrimary)
            Spacer()
            if let action = action {
                Button(action: action) {
                    Text("See All")
                        .font(AppDesign.Typography.subheadline)
                        .foregroundColor(AppDesign.Colors.primary)
                }
            }
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.lg) {
            IconBadge(icon: icon, color: AppDesign.Colors.primary, size: 80)
            VStack(spacing: AppDesign.Spacing.sm) {
                Text(title)
                    .font(AppDesign.Typography.title2)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                Text(message)
                    .font(AppDesign.Typography.body)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppDesign.Spacing.xl)
            }
            if let actionTitle = actionTitle, let action = action {
                GradientButton(title: actionTitle, icon: "plus.circle.fill", action: action)
                    .padding(.horizontal, AppDesign.Spacing.xl)
            }
        }
        .padding(.vertical, AppDesign.Spacing.xxl)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            #endif
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [AppDesign.Colors.gradientStart, AppDesign.Colors.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: AppDesign.Shadow.medium.color, radius: AppDesign.Shadow.medium.radius, x: AppDesign.Shadow.medium.x, y: AppDesign.Shadow.medium.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
