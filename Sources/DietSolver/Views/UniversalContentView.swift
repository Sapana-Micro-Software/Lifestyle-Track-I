//
//  UniversalContentView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Universal Content View (Platform-Aware)
public struct UniversalContentView: View {
    @StateObject private var controller = DietSolverController()
    
    public init() {}
    
    public var body: some View {
        Group {
            switch Platform.current {
            case .iOS:
                iOSContentView()
            case .iPadOS:
                iPadOSContentView()
            case .macOS, .macCatalyst:
                macOSContentView()
            case .watchOS:
                #if os(watchOS)
                watchOSContentView()
                #else
                Text("watchOS not available")
                #endif
            case .tvOS:
                #if os(tvOS)
                tvOSContentView()
                #else
                Text("tvOS not available")
                #endif
            case .visionOS:
                #if os(visionOS)
                visionOSContentView()
                #else
                Text("visionOS not available")
                #endif
            case .carPlay:
                CarPlayContentView()
            }
        }
        .environmentObject(controller)
    }
}
