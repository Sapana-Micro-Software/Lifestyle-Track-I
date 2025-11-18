//
//  HealthCertificate.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Health Certificate
struct HealthCertificate: Codable, Identifiable {
    let id: UUID
    let badgeId: UUID
    let badgeName: String
    let badgeLevel: HealthBadge.BadgeLevel
    let recipientName: String
    let issueDate: Date
    let expirationDate: Date?
    let certificateNumber: String
    var qrCodeData: String // Base64 encoded QR code with Reed-Solomon error correction
    let signature: CertificateSignature
    var verificationHash: String
    let metadata: CertificateMetadata
    
    struct CertificateSignature: Codable {
        let issuerName: String
        let issuerTitle: String
        let issuerOrganization: String
        let signatureHash: String
        let timestamp: Date
    }
    
    struct CertificateMetadata: Codable {
        let healthScore: Double
        let streakDays: Int
        let achievements: [String]
        let region: String? // For USA Master, International Master
        let verificationUrl: String
    }
    
    init(id: UUID = UUID(), badgeId: UUID, badgeName: String, badgeLevel: HealthBadge.BadgeLevel, recipientName: String, issueDate: Date = Date(), expirationDate: Date? = nil, signature: CertificateSignature, metadata: CertificateMetadata) {
        self.id = id
        self.badgeId = badgeId
        self.badgeName = badgeName
        self.badgeLevel = badgeLevel
        self.recipientName = recipientName
        self.issueDate = issueDate
        self.expirationDate = expirationDate
        self.certificateNumber = Self.generateCertificateNumber()
        self.signature = signature
        self.metadata = metadata
        
        // Initialize with placeholder values, then compute
        self.qrCodeData = ""
        self.verificationHash = ""
        
        // Generate verification hash first
        self.verificationHash = Self.generateVerificationHash(self)
        
        // Generate QR code with Reed-Solomon error correction
        let certificateData = Self.encodeCertificateData(self)
        self.qrCodeData = QRCodeGenerator.generateWithReedSolomon(data: certificateData)
    }
    
    private static func generateCertificateNumber() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 1000...9999)
        return "HC-\(timestamp)-\(random)"
    }
    
    static func generateVerificationHash(_ certificate: HealthCertificate) -> String {
        let data = "\(certificate.certificateNumber)\(certificate.badgeId)\(certificate.recipientName)\(certificate.issueDate.timeIntervalSince1970)".data(using: .utf8)!
        return data.sha256().base64EncodedString()
    }
    
    private static func encodeCertificateData(_ certificate: HealthCertificate) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(certificate) {
            return data.base64EncodedString()
        }
        return ""
    }
}

// MARK: - QR Code Generator with Reed-Solomon
class QRCodeGenerator {
    static func generateWithReedSolomon(data: String, errorCorrectionLevel: Int = 3) -> String {
        // Reed-Solomon error correction levels:
        // 0 = ~7% error correction
        // 1 = ~15% error correction
        // 2 = ~25% error correction
        // 3 = ~30% error correction (highest)
        
        let reedSolomonData = applyReedSolomonEncoding(data: data, errorCorrectionLevel: errorCorrectionLevel)
        
        // In a real implementation, this would generate an actual QR code image
        // For now, we return the encoded data that would be embedded in the QR code
        return reedSolomonData
    }
    
    private static func applyReedSolomonEncoding(data: String, errorCorrectionLevel: Int) -> String {
        // Simplified Reed-Solomon encoding
        // In production, use a proper Reed-Solomon library like zxing or similar
        
        let dataBytes = data.data(using: .utf8)!
        let errorCorrectionBytes = errorCorrectionLevel * (dataBytes.count / 4)
        
        // Create error correction codes (simplified)
        var encodedData = dataBytes
        let ecBytes = generateErrorCorrectionBytes(data: dataBytes, ecCount: errorCorrectionBytes)
        encodedData.append(ecBytes)
        
        return encodedData.base64EncodedString()
    }
    
    private static func generateErrorCorrectionBytes(data: Data, ecCount: Int) -> Data {
        // Simplified error correction byte generation
        // In production, use proper Reed-Solomon algorithm
        var ecBytes = Data()
        var checksum: UInt32 = 0
        
        for byte in data {
            checksum = checksum &+ UInt32(byte)
            checksum = checksum &* 31
        }
        
        for i in 0..<ecCount {
            let ecByte = UInt8((checksum &+ UInt32(i)) % 256)
            ecBytes.append(ecByte)
        }
        
        return ecBytes
    }
}

// MARK: - Certificate Manager
class CertificateManager {
    static let shared = CertificateManager()
    
    private var certificates: [HealthCertificate] = []
    
    private init() {}
    
    func generateCertificate(for badge: HealthBadge, recipientName: String, healthData: HealthData?, streakDays: Int) -> HealthCertificate? {
        guard badge.isEarned && badge.level.requiresCertificate else {
            return nil
        }
        
        let signature = HealthCertificate.CertificateSignature(
            issuerName: "Lifestyle Track Certification Authority",
            issuerTitle: "Chief Health Officer",
            issuerOrganization: "Lifestyle Track",
            signatureHash: generateSignatureHash(),
            timestamp: Date()
        )
        
        let healthScore = calculateOverallHealthScore(healthData: healthData)
        let achievements = getAchievements(healthData: healthData)
        let region = determineRegion(for: badge.level)
        
        let metadata = HealthCertificate.CertificateMetadata(
            healthScore: healthScore,
            streakDays: streakDays,
            achievements: achievements,
            region: region,
            verificationUrl: "https://lifestyletrack.app/verify/\(UUID().uuidString)"
        )
        
        let certificate = HealthCertificate(
            badgeId: badge.id,
            badgeName: badge.name,
            badgeLevel: badge.level,
            recipientName: recipientName,
            expirationDate: calculateExpirationDate(for: badge.level),
            signature: signature,
            metadata: metadata
        )
        
        certificates.append(certificate)
        return certificate
    }
    
    private func generateSignatureHash() -> String {
        let data = "\(Date().timeIntervalSince1970)\(UUID().uuidString)".data(using: .utf8)!
        return data.sha256().base64EncodedString()
    }
    
    private func calculateOverallHealthScore(healthData: HealthData?) -> Double {
        guard let healthData = healthData else { return 0.0 }
        return BadgeManager.shared.calculateOverallHealthScore(healthData: healthData)
    }
    
    private func getAchievements(healthData: HealthData?) -> [String] {
        var achievements: [String] = []
        
        if let healthData = healthData {
            if healthData.visionAnalysis != nil {
                achievements.append("Excellent Vision Health")
            }
            if healthData.hearingAnalysis != nil {
                achievements.append("Excellent Hearing Health")
            }
            if healthData.tactileAnalysis != nil {
                achievements.append("Excellent Tactile Health")
            }
            if healthData.tongueAnalysis != nil {
                achievements.append("Excellent Tongue Health")
            }
        }
        
        return achievements
    }
    
    private func determineRegion(for level: HealthBadge.BadgeLevel) -> String? {
        switch level {
        case .usaMaster:
            return "USA"
        case .internationalMaster:
            return "International"
        default:
            return nil
        }
    }
    
    private func calculateExpirationDate(for level: HealthBadge.BadgeLevel) -> Date? {
        let calendar = Calendar.current
        switch level {
        case .usaMaster, .internationalMaster:
            return calendar.date(byAdding: .year, value: 1, to: Date())
        case .grandmaster:
            return calendar.date(byAdding: .year, value: 2, to: Date())
        case .worldGrandmaster:
            return nil // Never expires
        default:
            return nil
        }
    }
    
    func verifyCertificate(_ certificate: HealthCertificate) -> Bool {
        let expectedHash = HealthCertificate.generateVerificationHash(certificate)
        return certificate.verificationHash == expectedHash
    }
    
    func getCertificates() -> [HealthCertificate] {
        return certificates
    }
}


// MARK: - Data Extension for SHA256
// Fallback implementation for SHA256
extension Data {
    func sha256() -> Data {
        // Simplified hash implementation
        // In production, use proper cryptographic library
        var hash: UInt64 = 5381
        for byte in self {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        var result = Data()
        Swift.withUnsafeBytes(of: hash) { bytes in
            result.append(contentsOf: bytes)
        }
        // Pad to 32 bytes for SHA256
        while result.count < 32 {
            result.append(0)
        }
        return result.prefix(32)
    }
}
