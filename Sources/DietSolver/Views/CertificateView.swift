//
//  CertificateView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

struct CertificateView: View {
    let certificate: HealthCertificate
    @State private var showQRCode = true
    
    private var certificateColor: Color {
        switch certificate.badgeLevel {
        case .usaMaster: return Color(hex: "#1E90FF") ?? AppDesign.Colors.primary
        case .internationalMaster: return Color(hex: "#4169E1") ?? AppDesign.Colors.primary
        case .grandmaster: return Color(hex: "#FFD700") ?? AppDesign.Colors.primary
        case .worldGrandmaster: return Color(hex: "#FF1493") ?? AppDesign.Colors.primary
        default: return AppDesign.Colors.primary
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [certificateColor.opacity(0.1), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppDesign.Spacing.xl) {
                    // Certificate Header
                    VStack(spacing: AppDesign.Spacing.md) {
                        Image(systemName: certificateIcon)
                            .font(.system(size: 80))
                            .foregroundColor(certificateColor)
                        
                        Text(certificate.badgeLevel.rawValue)
                            .font(AppDesign.Typography.largeTitle)
                            .foregroundColor(certificateColor)
                        
                        Text(certificate.badgeName)
                            .font(AppDesign.Typography.title)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppDesign.Spacing.xl)
                    
                    // Certificate Card
                    ModernCard(shadow: AppDesign.Shadow.large) {
                        VStack(spacing: AppDesign.Spacing.lg) {
                            // Recipient
                            VStack(spacing: AppDesign.Spacing.sm) {
                                Text("This certifies that")
                                    .font(AppDesign.Typography.body)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                Text(certificate.recipientName)
                                    .font(AppDesign.Typography.title)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                                Text("has achieved")
                                    .font(AppDesign.Typography.body)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            
                            Divider()
                            
                            // Details
                            VStack(spacing: AppDesign.Spacing.md) {
                                DetailRow(label: "Certificate Number", value: certificate.certificateNumber)
                                DetailRow(label: "Issue Date", value: formatDate(certificate.issueDate))
                                if let expiration = certificate.expirationDate {
                                    DetailRow(label: "Expiration Date", value: formatDate(expiration))
                                }
                                DetailRow(label: "Health Score", value: String(format: "%.1f", certificate.metadata.healthScore))
                                DetailRow(label: "Streak Days", value: "\(certificate.metadata.streakDays)")
                                if let region = certificate.metadata.region {
                                    DetailRow(label: "Region", value: region)
                                }
                            }
                            
                            // Achievements
                            if !certificate.metadata.achievements.isEmpty {
                                Divider()
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                                    Text("Achievements")
                                        .font(AppDesign.Typography.headline)
                                    ForEach(certificate.metadata.achievements, id: \.self) { achievement in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(AppDesign.Colors.success)
                                            Text(achievement)
                                                .font(AppDesign.Typography.body)
                                        }
                                    }
                                }
                            }
                            
                            // QR Code
                            if showQRCode {
                                Divider()
                                VStack(spacing: AppDesign.Spacing.sm) {
                                    Text("Verification QR Code")
                                        .font(AppDesign.Typography.headline)
                                    Text("Scan to verify certificate")
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                    
                                    // QR Code Display (simplified - in production, use proper QR code rendering)
                                    RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                                        .fill(Color.black)
                                        .frame(width: 200, height: 200)
                                        .overlay(
                                            Text("QR")
                                                .foregroundColor(.white)
                                                .font(.system(size: 40))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                                                .stroke(Color.white, lineWidth: 4)
                                        )
                                    
                                    Text("Verification Hash:")
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                    Text(certificate.verificationHash.prefix(16) + "...")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                            }
                            
                            // Signature
                            Divider()
                            VStack(alignment: .trailing, spacing: AppDesign.Spacing.sm) {
                                Text(certificate.signature.issuerName)
                                    .font(AppDesign.Typography.headline)
                                Text(certificate.signature.issuerTitle)
                                    .font(AppDesign.Typography.subheadline)
                                Text(certificate.signature.issuerOrganization)
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                Text(formatDate(certificate.signature.timestamp))
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                    
                    // Verification URL
                    Button(action: {
                        // Open verification URL
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Verify Online")
                        }
                        .font(AppDesign.Typography.subheadline)
                        .foregroundColor(AppDesign.Colors.primary)
                        .padding(.horizontal, AppDesign.Spacing.md)
                        .padding(.vertical, AppDesign.Spacing.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDesign.Radius.medium)
                                .stroke(AppDesign.Colors.primary, lineWidth: 2)
                        )
                    }
                    .padding(.bottom, AppDesign.Spacing.xl)
                }
            }
        }
        .navigationTitle("Certificate")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private var certificateIcon: String {
        switch certificate.badgeLevel {
        case .usaMaster: return "star.circle.fill"
        case .internationalMaster: return "globe.americas.fill"
        case .grandmaster: return "crown.fill"
        case .worldGrandmaster: return "star.circle.fill"
        default: return "medal.fill"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(AppDesign.Typography.body)
                .foregroundColor(AppDesign.Colors.textPrimary)
        }
    }
}
