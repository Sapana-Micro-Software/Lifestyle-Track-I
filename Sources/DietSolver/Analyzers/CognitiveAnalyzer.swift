import Foundation

// MARK: - Cognitive Analyzer
class CognitiveAnalyzer {
    
    func analyze(_ assessment: CognitiveAssessment) -> CognitiveAnalysisReport {
        var report = CognitiveAnalysisReport()
        
        // IQ Analysis
        if let iq = assessment.iq {
            report.iqAnalysis = analyzeIQ(iq)
        }
        
        // EQ Analysis
        if let eq = assessment.eq {
            report.eqAnalysis = analyzeEQ(eq)
        }
        
        // CQ Analysis
        if let cq = assessment.cq {
            report.cqAnalysis = analyzeCQ(cq)
        }
        
        // Spatial Reasoning
        if let spatial = assessment.spatialReasoning {
            report.spatialAnalysis = analyzeSpatial(spatial)
        }
        
        // Temporal Reasoning
        if let temporal = assessment.temporalReasoning {
            report.temporalAnalysis = analyzeTemporal(temporal)
        }
        
        // Tactical Problem-Solving
        if let tactical = assessment.tacticalProblemSolving {
            report.tacticalAnalysis = analyzeTactical(tactical)
        }
        
        // Strategic Problem-Solving
        if let strategic = assessment.strategicProblemSolving {
            report.strategicAnalysis = analyzeStrategic(strategic)
        }
        
        // Psychic Capabilities
        if let psychic = assessment.psychicCapabilities {
            report.psychicAnalysis = analyzePsychic(psychic)
        }
        
        // Generate recommendations
        report.recommendations = generateCognitiveRecommendations(from: report)
        
        return report
    }
    
    private func analyzeIQ(_ iq: IQAssessment) -> IQAnalysisResult {
        var result = IQAnalysisResult()
        
        if let fsiq = iq.fullScaleIQ {
            result.overallScore = fsiq
            if fsiq >= 130 {
                result.strengths.append("Very Superior intellectual ability")
            } else if fsiq >= 120 {
                result.strengths.append("Superior intellectual ability")
            } else if fsiq < 70 {
                result.areasForImprovement.append("Intellectual support may be beneficial")
            }
        }
        
        if let verbal = iq.verbalIQ, let performance = iq.performanceIQ {
            let difference = abs(verbal - performance)
            if difference > 15 {
                result.areasForImprovement.append("Significant discrepancy between verbal and performance IQ")
            }
        }
        
        return result
    }
    
    private func analyzeEQ(_ eq: EQAssessment) -> EQAnalysisResult {
        var result = EQAnalysisResult()
        
        if let total = eq.totalScore {
            result.overallScore = total
            if total >= 80 {
                result.strengths.append("High emotional intelligence")
            } else if total < 50 {
                result.areasForImprovement.append("Emotional intelligence development")
            }
        }
        
        if let empathy = eq.empathy, empathy < 15 {
            result.areasForImprovement.append("Empathy skills development")
        }
        
        return result
    }
    
    private func analyzeCQ(_ cq: CQAssessment) -> CQAnalysisResult {
        var result = CQAnalysisResult()
        
        if let total = cq.totalScore {
            result.overallScore = total
            if total >= 80 {
                result.strengths.append("High creative intelligence")
            }
        }
        
        return result
    }
    
    private func analyzeSpatial(_ spatial: SpatialReasoningAssessment) -> SpatialAnalysisResult {
        var result = SpatialAnalysisResult()
        
        if let score = spatial.score {
            result.overallScore = score
            if score >= 80 {
                result.strengths.append("Strong spatial reasoning abilities")
            }
        }
        
        return result
    }
    
    private func analyzeTemporal(_ temporal: TemporalReasoningAssessment) -> TemporalAnalysisResult {
        var result = TemporalAnalysisResult()
        
        if let score = temporal.score {
            result.overallScore = score
            if score >= 80 {
                result.strengths.append("Strong temporal reasoning abilities")
            }
        }
        
        return result
    }
    
    private func analyzeTactical(_ tactical: TacticalProblemSolvingAssessment) -> TacticalAnalysisResult {
        var result = TacticalAnalysisResult()
        
        if let score = tactical.score {
            result.overallScore = score
            if score >= 80 {
                result.strengths.append("Strong tactical problem-solving")
            }
        }
        
        if let accuracy = tactical.accuracy, accuracy < 70 {
            result.areasForImprovement.append("Improve tactical accuracy")
        }
        
        return result
    }
    
    private func analyzeStrategic(_ strategic: StrategicProblemSolvingAssessment) -> StrategicAnalysisResult {
        var result = StrategicAnalysisResult()
        
        if let score = strategic.score {
            result.overallScore = score
            if score >= 80 {
                result.strengths.append("Strong strategic problem-solving")
            }
        }
        
        if let planning = strategic.planningQuality, planning < 70 {
            result.areasForImprovement.append("Improve strategic planning depth")
        }
        
        return result
    }
    
    private func analyzePsychic(_ psychic: PsychicCapabilitiesAssessment) -> PsychicAnalysisResult {
        var result = PsychicAnalysisResult()
        
        if let remoteViewing = psychic.remoteViewing {
            if let accuracy = remoteViewing.accuracy, accuracy > 60 {
                result.strengths.append("Remote viewing capabilities detected")
            }
        }
        
        if let overall = psychic.overallScore {
            result.overallScore = overall
        }
        
        return result
    }
    
    private func generateCognitiveRecommendations(from report: CognitiveAnalysisReport) -> [CognitiveRecommendation] {
        var recommendations: [CognitiveRecommendation] = []
        
        // Based on IQ
        if let iq = report.iqAnalysis {
            if iq.overallScore != nil && iq.overallScore! < 85 {
                recommendations.append(CognitiveRecommendation(
                    category: .intellectual,
                    title: "Intellectual Development",
                    description: "Engage in cognitive training and educational activities",
                    actions: ["Brain training exercises", "Educational courses", "Reading programs"]
                ))
            }
        }
        
        // Based on EQ
        if let eq = report.eqAnalysis {
            if eq.overallScore != nil && eq.overallScore! < 60 {
                recommendations.append(CognitiveRecommendation(
                    category: .emotional,
                    title: "Emotional Intelligence Development",
                    description: "Develop emotional awareness and regulation skills",
                    actions: ["Mindfulness practice", "Therapy or counseling", "Emotional regulation exercises"]
                ))
            }
        }
        
        // Based on spatial reasoning
        if let spatial = report.spatialAnalysis {
            if spatial.overallScore != nil && spatial.overallScore! < 70 {
                recommendations.append(CognitiveRecommendation(
                    category: .spatial,
                    title: "Spatial Reasoning Enhancement",
                    description: "Improve spatial thinking through targeted exercises",
                    actions: ["3D puzzles", "Spatial visualization games", "Architecture/modeling activities"]
                ))
            }
        }
        
        return recommendations
    }
}

// MARK: - Cognitive Analysis Results
struct CognitiveAnalysisReport: Codable {
    var iqAnalysis: IQAnalysisResult?
    var eqAnalysis: EQAnalysisResult?
    var cqAnalysis: CQAnalysisResult?
    var spatialAnalysis: SpatialAnalysisResult?
    var temporalAnalysis: TemporalAnalysisResult?
    var tacticalAnalysis: TacticalAnalysisResult?
    var strategicAnalysis: StrategicAnalysisResult?
    var psychicAnalysis: PsychicAnalysisResult?
    var recommendations: [CognitiveRecommendation] = []
}

struct IQAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
    var areasForImprovement: [String] = []
}

struct EQAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
    var areasForImprovement: [String] = []
}

struct CQAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
}

struct SpatialAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
    var areasForImprovement: [String] = []
}

struct TemporalAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
    var areasForImprovement: [String] = []
}

struct TacticalAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
    var areasForImprovement: [String] = []
}

struct StrategicAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
    var areasForImprovement: [String] = []
}

struct PsychicAnalysisResult: Codable {
    var overallScore: Int?
    var strengths: [String] = []
}

struct CognitiveRecommendation: Codable, Identifiable {
    let id: UUID
    let category: RecommendationCategory
    let title: String
    let description: String
    let actions: [String]
    
    enum RecommendationCategory: String, Codable {
        case intellectual, emotional, creative, spatial, temporal, tactical, strategic, psychic
    }
    
    init(id: UUID = UUID(), category: RecommendationCategory, title: String, description: String, actions: [String]) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.actions = actions
    }
}
