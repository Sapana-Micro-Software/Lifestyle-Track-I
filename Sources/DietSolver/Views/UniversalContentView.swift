//
//  UniversalContentView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Universal Content View (Platform-Aware)
public struct UniversalContentView: View {
    @StateObject private var viewModel = DietSolverViewModel()
    @StateObject private var controller: DietSolverController
    
    public init() {
        let vm = DietSolverViewModel()
        _viewModel = StateObject(wrappedValue: vm)
        _controller = StateObject(wrappedValue: DietSolverController(viewModel: vm))
    }
    
    public var body: some View {
        Group {
            switch Platform.current {
            case .iOS:
                iOSContentView()
                    .environmentObject(controller)
            case .iPadOS:
                iPadOSContentView()
                    .environmentObject(controller)
            case .macOS, .macCatalyst:
                macOSContentView()
                    .environmentObject(controller)
            case .watchOS:
                #if os(watchOS)
                watchOSContentView()
                    .environmentObject(controller)
                #else
                Text("watchOS not available")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
            case .tvOS:
                #if os(tvOS)
                tvOSContentView()
                    .environmentObject(controller)
                #else
                Text("tvOS not available")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
            case .visionOS:
                #if os(visionOS)
                visionOSContentView()
                    .environmentObject(controller)
                #else
                Text("visionOS not available")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
            case .carPlay:
                CarPlayContentView()
                    .environmentObject(controller)
            }
        }
        .environmentObject(viewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppDesign.Colors.background)
    }
}
