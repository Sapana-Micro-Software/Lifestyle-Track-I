//
//  SessionExportManager.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation
#if canImport(PDFKit)
import PDFKit
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Session Export Manager
class SessionExportManager {
    static let shared = SessionExportManager()
    
    private init() {}
    
    // MARK: - Export Session Summary
    
    func exportSessionSummary(_ session: ConversationSession, anonymize: Bool = false) -> String {
        var summary = "Therapy Session Summary\n"
        summary += "=" + String(repeating: "=", count: 50) + "\n\n"
        
        // Session metadata
        summary += "Date: \(formatDate(session.startDate))\n"
        if let endDate = session.endDate {
            let duration = endDate.timeIntervalSince(session.startDate)
            let minutes = Int(duration / 60)
            summary += "Duration: \(minutes) minutes\n"
        }
        if let approach = session.therapyApproach {
            summary += "Therapy Approach: \(approach.rawValue)\n"
        }
        summary += "Crisis Detected: \(session.crisisDetected ? "Yes" : "No")\n"
        if let crisisLevel = session.crisisLevel {
            summary += "Crisis Level: \(crisisLevel.rawValue)\n"
        }
        summary += "\n"
        
        // Messages
        summary += "Conversation:\n"
        summary += "-" + String(repeating: "-", count: 50) + "\n"
        for message in session.messages {
            let role = anonymize ? "User" : (message.role == .user ? "You" : "Therapist")
            summary += "\n[\(role)]\n"
            summary += "\(message.content)\n"
            
            if let sentiment = message.sentiment, !anonymize {
                summary += "  (Sentiment: \(sentiment.dominantEmotion.rawValue), Score: \(String(format: "%.2f", sentiment.score)))\n"
            }
        }
        summary += "\n"
        
        // Insights
        if !session.personalizedInsights.isEmpty {
            summary += "Key Insights:\n"
            summary += "-" + String(repeating: "-", count: 50) + "\n"
            for insight in session.personalizedInsights {
                summary += "• \(insight.insight)\n"
                if !anonymize {
                    summary += "  (Based on: \(insight.basedOn.rawValue), Confidence: \(String(format: "%.0f", insight.confidence * 100))%)\n"
                }
            }
            summary += "\n"
        }
        
        // Summary text
        if let sessionSummary = session.sessionSummary {
            summary += "Session Summary:\n"
            summary += "-" + String(repeating: "-", count: 50) + "\n"
            
            if !sessionSummary.keyTopics.isEmpty {
                summary += "Key Topics:\n"
                for topic in sessionSummary.keyTopics {
                    summary += "• \(topic)\n"
                }
                summary += "\n"
            }
            
            if !sessionSummary.emotionalPatterns.isEmpty {
                summary += "Emotional Patterns:\n"
                for pattern in sessionSummary.emotionalPatterns {
                    summary += "• \(pattern)\n"
                }
                summary += "\n"
            }
            
            if !sessionSummary.progressNotes.isEmpty {
                summary += "Progress Notes:\n"
                for note in sessionSummary.progressNotes {
                    summary += "• \(note)\n"
                }
                summary += "\n"
            }
            
            if !sessionSummary.recommendations.isEmpty {
                summary += "Recommendations:\n"
                for (index, rec) in sessionSummary.recommendations.enumerated() {
                    summary += "\(index + 1). \(rec)\n"
                }
                summary += "\n"
            }
            
            if let nextFocus = sessionSummary.nextSessionFocus {
                summary += "Next Session Focus: \(nextFocus)\n\n"
            }
        }
        
        // Privacy notice
        if anonymize {
            summary += "\n" + String(repeating: "-", count: 52) + "\n"
            summary += "This summary has been anonymized for privacy.\n"
        }
        
        summary += "\nGenerated: \(formatDate(Date()))\n"
        
        return summary
    }
    
    // MARK: - Export Progress Report
    
    func exportProgressReport(profile: PsychologistUserProfile, anonymize: Bool = false) -> String {
        var report = "Mental Health Progress Report\n"
        report += "=" + String(repeating: "=", count: 50) + "\n\n"
        
        // Overview
        report += "Overview:\n"
        report += "-" + String(repeating: "-", count: 50) + "\n"
        report += "Total Sessions: \(profile.conversationHistory.count)\n"
        report += "Active Goals: \(profile.goals.filter { $0.progress < 1.0 }.count)\n"
        report += "Completed Goals: \(profile.goals.filter { $0.progress >= 1.0 }.count)\n"
        report += "Coping Strategies: \(profile.copingStrategies.count)\n\n"
        
        // Progress metrics
        let metrics = profile.progressMetrics
        report += "Progress Metrics:\n"
        report += "-" + String(repeating: "-", count: 50) + "\n"
        report += "Average Sentiment: \(String(format: "%.2f", metrics.averageSentiment))\n"
        report += "Sentiment Trend: \(metrics.sentimentTrend.rawValue)\n"
        report += "Session Frequency: \(String(format: "%.1f", metrics.sessionFrequency)) per week\n"
        report += "Engagement Score: \(String(format: "%.0f", metrics.engagementScore * 100))%\n\n"
        
        // Goals
        if !profile.goals.isEmpty {
            report += "Goals:\n"
            report += "-" + String(repeating: "-", count: 50) + "\n"
            for goal in profile.goals {
                let status = goal.progress >= 1.0 ? "Completed" : "In Progress"
                report += "• \(goal.goal): \(status) (\(String(format: "%.0f", goal.progress * 100))%)\n"
            }
            report += "\n"
        }
        
        // Recent sessions summary
        let recentSessions = profile.conversationHistory.suffix(5)
        if !recentSessions.isEmpty {
            report += "Recent Sessions:\n"
            report += "-" + String(repeating: "-", count: 50) + "\n"
            for session in recentSessions {
                let approach = session.therapyApproach?.rawValue ?? "Not specified"
                report += "• \(formatDate(session.startDate)): \(approach)\n"
                if session.crisisDetected {
                    report += "  (Crisis detected)\n"
                }
            }
            report += "\n"
        }
        
        // Privacy notice
        if anonymize {
            report += "\n" + String(repeating: "-", count: 52) + "\n"
            report += "This report has been anonymized for privacy.\n"
        }
        
        report += "\nGenerated: \(formatDate(Date()))\n"
        
        return report
    }
    
    // MARK: - Save to File
    
    func saveToFile(content: String, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - PDF Export (if available)
    
    #if canImport(PDFKit) && canImport(UIKit)
    func exportToPDF(content: String, filename: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "DietSolver",
            kCGPDFContextAuthor: "Therapy Session Export",
            kCGPDFContextTitle: filename
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let textRect = pageRect.insetBy(dx: 72, dy: 72)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            let attributedString = NSAttributedString(string: content, attributes: attributes)
            attributedString.draw(in: textRect)
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(filename).pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    #else
    func exportToPDF(content: String, filename: String) -> URL? {
        // PDF export not available on this platform
        return nil
    }
    #endif
}
