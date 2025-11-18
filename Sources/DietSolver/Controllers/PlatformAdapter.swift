//
//  PlatformAdapter.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI
import Foundation

// MARK: - Platform Detection
enum Platform {
    case iOS
    case iPadOS
    case macOS
    case macCatalyst
    case watchOS
    case tvOS
    case visionOS
    case carPlay
    
    static var current: Platform {
        #if os(iOS)
        #if targetEnvironment(macCatalyst)
        return .macCatalyst
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPadOS
        } else {
            return .iOS
        }
        #endif
        #elseif os(macOS)
        return .macOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(visionOS)
        return .visionOS
        #endif
    }
    
    var isMobile: Bool {
        switch self {
        case .iOS, .iPadOS, .watchOS: return true
        default: return false
        }
    }
    
    var isDesktop: Bool {
        switch self {
        case .macOS, .macCatalyst: return true
        default: return false
        }
    }
    
    var supportsNavigation: Bool {
        switch self {
        case .carPlay, .tvOS: return false
        default: return true
        }
    }
}

// MARK: - Platform-Specific Layout
struct PlatformLayout {
    let columns: Int
    let spacing: CGFloat
    let padding: CGFloat
    
    static func forPlatform(_ platform: Platform) -> PlatformLayout {
        switch platform {
        case .iOS:
            return PlatformLayout(columns: 2, spacing: 16, padding: 16)
        case .iPadOS:
            return PlatformLayout(columns: 3, spacing: 20, padding: 20)
        case .macOS, .macCatalyst:
            return PlatformLayout(columns: 4, spacing: 24, padding: 24)
        case .watchOS:
            return PlatformLayout(columns: 1, spacing: 8, padding: 8)
        case .tvOS:
            return PlatformLayout(columns: 3, spacing: 40, padding: 40)
        case .visionOS:
            return PlatformLayout(columns: 2, spacing: 20, padding: 20)
        case .carPlay:
            return PlatformLayout(columns: 1, spacing: 12, padding: 12)
        }
    }
}

// MARK: - Platform View Adapter
struct UniversalViewAdapter {
    let platform: Platform
    
    init(platform: Platform = .current) {
        self.platform = platform
    }
    
    func adapt<Content: View>(_ content: Content) -> AnyView {
        switch platform {
        case .iOS:
            return AnyView(iOSView(content))
        case .iPadOS:
            return AnyView(iPadOSView(content))
        case .macOS, .macCatalyst:
            return AnyView(macOSView(content))
        case .watchOS:
            return AnyView(watchOSView(content))
        case .tvOS:
            return AnyView(tvOSView(content))
        case .visionOS:
            return AnyView(visionOSView(content))
        case .carPlay:
            return AnyView(carPlayView(content))
        }
    }
    
    @ViewBuilder
    private func iOSView<Content: View>(_ content: Content) -> some View {
        content
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
    }
    
    @ViewBuilder
    private func iPadOSView<Content: View>(_ content: Content) -> some View {
        content
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .frame(maxWidth: 800)
    }
    
    @ViewBuilder
    private func macOSView<Content: View>(_ content: Content) -> some View {
        content
            .frame(minWidth: 600, minHeight: 400)
    }
    
    @ViewBuilder
    private func watchOSView<Content: View>(_ content: Content) -> some View {
        content
            .font(.caption)
    }
    
    @ViewBuilder
    private func tvOSView<Content: View>(_ content: Content) -> some View {
        content
            .focusable()
    }
    
    @ViewBuilder
    private func visionOSView<Content: View>(_ content: Content) -> some View {
        content
            .padding(20)
    }
    
    @ViewBuilder
    private func carPlayView<Content: View>(_ content: Content) -> some View {
        content
            .font(.headline)
    }
}
