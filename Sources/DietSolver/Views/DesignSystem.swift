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
        static let textPrimary = Color.black // Black for primary text
        static let textSecondary = Color(red: 0.3, green: 0.3, blue: 0.3) // Dark gray for secondary text
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
        static let small = ShadowStyle(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(color: .black.opacity(0.16), radius: 16, x: 0, y: 8)
        static let xlarge = ShadowStyle(color: .black.opacity(0.2), radius: 24, x: 0, y: 12)
        static let glow = ShadowStyle(color: Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.3), radius: 12, x: 0, y: 0)
    }
    
    // Gradients
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.4, green: 0.7, blue: 0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let secondary = LinearGradient(
            colors: [Color(red: 0.9, green: 0.5, blue: 0.3), Color(red: 0.9, green: 0.6, blue: 0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let success = LinearGradient(
            colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let card = LinearGradient(
            colors: [Color.white, Color(red: 0.99, green: 0.99, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
        static let shimmer = LinearGradient(
            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1), Color.white.opacity(0.3)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // Animations
    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
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
    var gradient: Bool = false
    var border: Bool = false
    var borderColor: Color = AppDesign.Colors.primary.opacity(0.2)
    
    @State private var isHovered = false
    
    init(padding: CGFloat = AppDesign.Spacing.md,
         cornerRadius: CGFloat = AppDesign.Radius.medium,
         shadow: AppDesign.ShadowStyle = AppDesign.Shadow.small,
         gradient: Bool = false,
         border: Bool = false,
         borderColor: Color = AppDesign.Colors.primary.opacity(0.2),
         @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.gradient = gradient
        self.border = border
        self.borderColor = borderColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                Group {
                    if gradient {
                        AppDesign.Gradients.card
                    } else {
                        AppDesign.Colors.surface
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border ? borderColor : Color.clear, lineWidth: border ? 1 : 0)
            )
            .cornerRadius(cornerRadius)
            .shadow(
                color: isHovered ? shadow.color.opacity(1.3) : shadow.color,
                radius: isHovered ? shadow.radius * 1.2 : shadow.radius,
                x: shadow.x,
                y: isHovered ? shadow.y - 1 : shadow.y
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(AppDesign.Animation.spring, value: isHovered)
            #if os(macOS)
            .onHover { hovering in
                isHovered = hovering
            }
            #endif
    }
}

// MARK: - Gradient Button
struct GradientButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    @State private var isPressed = false
    
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
                        #if os(iOS)
                        .symbolEffect(.bounce, value: isPressed)
                        #endif
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
                        AppDesign.Gradients.primary
                    } else if style == .secondary {
                        AppDesign.Gradients.secondary
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
            .shadow(
                color: style == .primary ? AppDesign.Shadow.glow.color : Color.clear,
                radius: style == .primary ? 8 : 0
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppDesign.Animation.quick, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Icon Badge
struct IconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 40
    var gradient: Bool = false
    var animated: Bool = false
    
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            if gradient {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
            } else {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)
            }
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(color)
                .rotationEffect(.degrees(animated ? rotation : 0))
        }
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
        .onAppear {
            if animated {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
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
        ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                HStack {
                    IconBadge(icon: icon, color: color, size: 36, gradient: true)
                    Spacer()
                    if let trend = trend {
                        Text(trend)
                            .font(AppDesign.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppDesign.Colors.success)
                            .padding(.horizontal, AppDesign.Spacing.sm)
                            .padding(.vertical, AppDesign.Spacing.xs)
                            .background(AppDesign.Colors.success.opacity(0.1))
                            .cornerRadius(AppDesign.Radius.small)
                    }
                }
                Text(value)
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
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
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif
            action()
        }) {
            VStack(spacing: AppDesign.Spacing.xs) {
                IconBadge(icon: icon, color: color, size: 50, gradient: true)
                Text(title)
                    .font(AppDesign.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppDesign.Spacing.md)
            .background(AppDesign.Gradients.card)
            .cornerRadius(AppDesign.Radius.medium)
            .shadow(
                color: isPressed ? AppDesign.Shadow.medium.color : AppDesign.Shadow.small.color,
                radius: isPressed ? AppDesign.Shadow.medium.radius : AppDesign.Shadow.small.radius,
                x: AppDesign.Shadow.small.x,
                y: isPressed ? AppDesign.Shadow.small.y - 1 : AppDesign.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AppDesign.Animation.quick, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Animated Progress Ring
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat = 8
    var size: CGFloat = 60
    var showGlow: Bool = true
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.1), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(AppDesign.Animation.spring, value: progress)
                .shadow(
                    color: showGlow ? color.opacity(0.5) : Color.clear,
                    radius: showGlow ? 8 : 0
                )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    var icon: String? = nil
    
    init(_ title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: AppDesign.Spacing.sm) {
            if let icon = icon {
                IconBadge(icon: icon, color: AppDesign.Colors.primary, size: 28, gradient: true)
            }
            Text(title)
                .font(AppDesign.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(AppDesign.Colors.textPrimary)
            Spacer()
            if let action = action {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(AppDesign.Typography.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppDesign.Colors.primary)
                    .padding(.horizontal, AppDesign.Spacing.sm)
                    .padding(.vertical, AppDesign.Spacing.xs)
                    .background(AppDesign.Colors.primary.opacity(0.1))
                    .cornerRadius(AppDesign.Radius.small)
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
    
    @State private var isAnimating = false
    
    init(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.lg) {
            IconBadge(icon: icon, color: AppDesign.Colors.primary, size: 80, gradient: true, animated: isAnimating)
            VStack(spacing: AppDesign.Spacing.sm) {
                Text(title)
                    .font(AppDesign.Typography.title2)
                    .fontWeight(.bold)
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
        .onAppear {
            withAnimation(AppDesign.Animation.spring) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulse: Bool = false
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            #endif
            action()
        }) {
            ZStack {
                // Pulse effect
                Circle()
                    .fill(AppDesign.Colors.primary.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .scaleEffect(pulse ? 1.3 : 1.0)
                    .opacity(pulse ? 0 : 1)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(AppDesign.Gradients.primary)
                    .clipShape(Circle())
                    .shadow(
                        color: AppDesign.Shadow.glow.color,
                        radius: AppDesign.Shadow.glow.radius
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    AppDesign.Gradients.shimmer
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Bounce Animation
struct BounceEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.5)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func bounce() -> some View {
        modifier(BounceEffect())
    }
}
