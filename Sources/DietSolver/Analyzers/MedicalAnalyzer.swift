import Foundation

// MARK: - Medical Analyzer
class MedicalAnalyzer {
    
    // MARK: - Analyze Medical Tests
    func analyze(collection: MedicalTestCollection, gender: HealthData.Gender? = nil) -> MedicalAnalysisReport {
        var report = MedicalAnalysisReport()
        
        // Analyze latest tests
        if let latestBlood = collection.bloodTests.last {
            report.bloodAnalysis = analyzeBloodTest(latestBlood, gender: gender)
        }
        
        if let latestUrine = collection.urineAnalyses.last {
            report.urineAnalysis = analyzeUrine(latestUrine)
        }
        
        if let latestSemen = collection.semenAnalyses.last {
            report.semenAnalysis = analyzeSemen(latestSemen)
        }
        
        if let latestBoneMarrow = collection.boneMarrowAnalyses.last {
            report.boneMarrowAnalysis = analyzeBoneMarrow(latestBoneMarrow)
        }
        
        if let latestSaliva = collection.salivaAnalyses.last {
            report.salivaAnalysis = analyzeSaliva(latestSaliva)
        }
        
        report.skinAnalysis = analyzeSkin(collection.skinAnalyses)
        report.hairAnalysis = analyzeHair(collection.hairAnalyses)
        report.organAnalysis = analyzeOrgans(collection.organAnalyses)
        report.sexualOrganAnalysis = analyzeSexualOrgans(collection.sexualOrganAnalyses)
        report.reflexAnalysis = analyzeReflexes(collection.reflexAnalyses)
        
        // Generate recommendations
        report.recommendations = generateRecommendations(from: report)
        
        return report
    }
    
    // MARK: - Blood Test Analysis
    private func analyzeBloodTest(_ test: BloodTestReport, gender: HealthData.Gender? = nil) -> BloodAnalysisResult {
        var result = BloodAnalysisResult()
        var issues: [String] = []
        var warnings: [String] = []
        
        // Glucose analysis
        if let glucose = test.glucose {
            if glucose > 140 {
                issues.append("Elevated glucose - possible diabetes or prediabetes")
            } else if glucose < 70 {
                issues.append("Low glucose - possible hypoglycemia")
            }
        }
        
        if let hba1c = test.hba1c {
            if hba1c >= 6.5 {
                issues.append("HbA1c indicates diabetes")
            } else if hba1c >= 5.7 {
                warnings.append("HbA1c indicates prediabetes")
            }
        }
        
        // Lipid analysis
        if let totalChol = test.totalCholesterol {
            if totalChol > 240 {
                issues.append("High total cholesterol")
            }
        }
        
        if let ldl = test.ldlCholesterol {
            if ldl > 160 {
                issues.append("High LDL cholesterol - increased cardiovascular risk")
            }
        }
        
        if let hdl = test.hdlCholesterol {
            if hdl < 40 {
                warnings.append("Low HDL cholesterol")
            }
        }
        
        // Anemia check
        if let hgb = test.hemoglobin {
            if hgb < 12 {
                issues.append("Low hemoglobin - possible anemia")
            }
        }
        
        if let ferritin = test.ferritin {
            if ferritin < 15 {
                issues.append("Low ferritin - iron deficiency")
            }
        }
        
        // Thyroid
        if let tsh = test.tsh {
            if tsh > 4.5 {
                warnings.append("Elevated TSH - possible hypothyroidism")
            } else if tsh < 0.4 {
                warnings.append("Low TSH - possible hyperthyroidism")
            }
        }
        
        // Vitamin deficiencies
        if let vitD = test.vitaminD {
            if vitD < 20 {
                issues.append("Severe vitamin D deficiency")
            } else if vitD < 30 {
                warnings.append("Vitamin D insufficiency")
            }
        }
        
        if let vitB12 = test.vitaminB12 {
            if vitB12 < 200 {
                issues.append("Low vitamin B12")
            }
        }
        
        // Hormonal
        if let testosterone = test.testosterone {
            if gender == .male && testosterone < 300 {
                warnings.append("Low testosterone")
            } else if gender == .female && testosterone > 70 {
                warnings.append("Elevated testosterone")
            }
        }
        
        if let cortisol = test.cortisol {
            if cortisol > 25 {
                warnings.append("Elevated cortisol - possible stress")
            }
        }
        
        result.issues = issues
        result.warnings = warnings
        result.overallHealth = issues.isEmpty ? (warnings.isEmpty ? .good : .fair) : .poor
        
        return result
    }
    
    // MARK: - Urine Analysis
    private func analyzeUrine(_ test: UrineAnalysis) -> UrineAnalysisResult {
        var result = UrineAnalysisResult()
        var issues: [String] = []
        
        if let ketones = test.ketones, ketones > 0 {
            issues.append("Ketones present - possible ketosis or diabetic ketoacidosis")
        }
        
        if let protein = test.protein, protein > 150 {
            issues.append("Proteinuria - possible kidney disease")
        }
        
        if let glucose = test.glucose, glucose > 0 {
            issues.append("Glucosuria - possible diabetes")
        }
        
        result.issues = issues
        result.overallHealth = issues.isEmpty ? .good : .poor
        
        return result
    }
    
    // MARK: - Semen Analysis
    private func analyzeSemen(_ test: SemenAnalysis) -> SemenAnalysisResult {
        var result = SemenAnalysisResult()
        var issues: [String] = []
        
        if let concentration = test.spermConcentration {
            if concentration < 15 {
                issues.append("Low sperm concentration - possible infertility")
            }
        }
        
        if let motility = test.progressiveMotility {
            if motility < 32 {
                issues.append("Low progressive motility")
            }
        }
        
        if let morphology = test.normalForms {
            if morphology < 4 {
                issues.append("Low normal morphology")
            }
        }
        
        result.issues = issues
        result.fertilityStatus = issues.isEmpty ? .normal : .abnormal
        
        return result
    }
    
    // MARK: - Bone Marrow Analysis
    private func analyzeBoneMarrow(_ test: BoneMarrowAnalysis) -> BoneMarrowAnalysisResult {
        var result = BoneMarrowAnalysisResult()
        
        if let blasts = test.blastCells, blasts > 5 {
            result.issues.append("Elevated blast cells - possible leukemia")
        }
        
        result.overallHealth = result.issues.isEmpty ? .good : .poor
        
        return result
    }
    
    // MARK: - Saliva Analysis
    private func analyzeSaliva(_ test: SalivaAnalysis) -> SalivaAnalysisResult {
        var result = SalivaAnalysisResult()
        
        if let cortisol = test.cortisol {
            if cortisol > 3.0 {
                result.warnings.append("Elevated cortisol - possible chronic stress")
            }
        }
        
        if let flowRate = test.flowRate, flowRate < 0.1 {
            result.warnings.append("Low saliva flow rate - possible dry mouth")
        }
        
        return result
    }
    
    // MARK: - Skin Analysis
    private func analyzeSkin(_ tests: [SkinAnalysis]) -> SkinAnalysisResult {
        var result = SkinAnalysisResult()
        
        for test in tests {
            if let moisture = test.moistureLevel, moisture < 30 {
                result.issues.append("Low moisture in \(test.bodyPart.rawValue)")
            }
            
            if let pH = test.pH {
                if pH < 4.5 || pH > 6.5 {
                    result.warnings.append("Abnormal pH in \(test.bodyPart.rawValue)")
                }
            }
        }
        
        return result
    }
    
    // MARK: - Hair Analysis
    private func analyzeHair(_ tests: [HairAnalysis]) -> HairAnalysisResult {
        var result = HairAnalysisResult()
        
        for test in tests {
            if let mercury = test.mercury, mercury > 1.0 {
                result.issues.append("Elevated mercury - possible toxicity")
            }
            
            if let lead = test.lead, lead > 1.0 {
                result.issues.append("Elevated lead - possible toxicity")
            }
            
            if let zinc = test.zinc, zinc < 150 {
                result.warnings.append("Low zinc levels")
            }
        }
        
        return result
    }
    
    // MARK: - Organ Analysis
    private func analyzeOrgans(_ tests: [OrganAnalysis]) -> OrganAnalysisResult {
        var result = OrganAnalysisResult()
        
        for test in tests {
            if test.condition != .normal {
                result.issues.append("\(test.organ.rawValue): \(test.condition.rawValue)")
            }
        }
        
        return result
    }
    
    // MARK: - Sexual Organ Analysis
    private func analyzeSexualOrgans(_ tests: [SexualOrganAnalysis]) -> SexualOrganAnalysisResult {
        var result = SexualOrganAnalysisResult()
        
        for test in tests {
            if test.condition != .normal {
                result.issues.append("\(test.organPart.rawValue): \(test.condition.rawValue)")
            }
        }
        
        return result
    }
    
    // MARK: - Reflex Analysis
    private func analyzeReflexes(_ tests: [ReflexAnalysis]) -> ReflexAnalysisResult {
        var result = ReflexAnalysisResult()
        
        for test in tests {
            for reflex in test.reflexes {
                if reflex.response == .absent || reflex.response == .diminished {
                    result.issues.append("Abnormal \(reflex.name) reflex")
                }
            }
        }
        
        return result
    }
    
    // MARK: - Generate Recommendations
    private func generateRecommendations(from report: MedicalAnalysisReport) -> [MedicalRecommendation] {
        var recommendations: [MedicalRecommendation] = []
        
        // Blood-based recommendations
        if let blood = report.bloodAnalysis {
            if blood.issues.contains(where: { $0.contains("glucose") || $0.contains("diabetes") }) {
                recommendations.append(MedicalRecommendation(
                    category: .diet,
                    priority: .high,
                    title: "Blood Sugar Management",
                    description: "Focus on low glycemic index foods and regular meal timing",
                    actions: ["Reduce refined carbohydrates", "Increase fiber intake", "Regular glucose monitoring"]
                ))
            }
            
            if blood.issues.contains(where: { $0.contains("cholesterol") }) {
                recommendations.append(MedicalRecommendation(
                    category: .diet,
                    priority: .high,
                    title: "Cardiovascular Health",
                    description: "Reduce saturated fats and increase omega-3 fatty acids",
                    actions: ["Increase fish consumption", "Reduce red meat", "Add nuts and seeds"]
                ))
            }
            
            if blood.issues.contains(where: { $0.contains("anemia") || $0.contains("iron") }) {
                recommendations.append(MedicalRecommendation(
                    category: .diet,
                    priority: .high,
                    title: "Iron Deficiency",
                    description: "Increase iron-rich foods and vitamin C for absorption",
                    actions: ["Add leafy greens", "Include lean red meat", "Pair with vitamin C sources"]
                ))
            }
        }
        
        // Urine-based recommendations
        if let urine = report.urineAnalysis {
            if urine.issues.contains(where: { $0.contains("ketones") }) {
                recommendations.append(MedicalRecommendation(
                    category: .diet,
                    priority: .high,
                    title: "Ketone Management",
                    description: "Monitor ketone levels and ensure adequate carbohydrate intake if not on ketogenic diet",
                    actions: ["Check blood glucose", "Ensure adequate hydration", "Review diet plan"]
                ))
            }
        }
        
        // Hair analysis recommendations
        if let hair = report.hairAnalysis {
            if hair.issues.contains(where: { $0.contains("mercury") || $0.contains("lead") }) {
                recommendations.append(MedicalRecommendation(
                    category: .supplement,
                    priority: .high,
                    title: "Heavy Metal Detoxification",
                    description: "Support detoxification pathways with specific nutrients",
                    actions: ["Increase selenium", "Add chlorella/spirulina", "Ensure adequate zinc"]
                ))
            }
        }
        
        return recommendations
    }
}

// MARK: - Analysis Results
struct MedicalAnalysisReport: Codable {
    var bloodAnalysis: BloodAnalysisResult?
    var urineAnalysis: UrineAnalysisResult?
    var semenAnalysis: SemenAnalysisResult?
    var boneMarrowAnalysis: BoneMarrowAnalysisResult?
    var salivaAnalysis: SalivaAnalysisResult?
    var skinAnalysis: SkinAnalysisResult?
    var hairAnalysis: HairAnalysisResult?
    var organAnalysis: OrganAnalysisResult?
    var sexualOrganAnalysis: SexualOrganAnalysisResult?
    var reflexAnalysis: ReflexAnalysisResult?
    var recommendations: [MedicalRecommendation] = []
}

struct BloodAnalysisResult: Codable {
    var issues: [String] = []
    var warnings: [String] = []
    var overallHealth: HealthStatus = .good
}

struct UrineAnalysisResult: Codable {
    var issues: [String] = []
    var overallHealth: HealthStatus = .good
}

struct SemenAnalysisResult: Codable {
    var issues: [String] = []
    var fertilityStatus: FertilityStatus = .normal
    
    enum FertilityStatus: String, Codable {
        case normal, abnormal, unknown
    }
}

struct BoneMarrowAnalysisResult: Codable {
    var issues: [String] = []
    var overallHealth: HealthStatus = .good
}

struct SalivaAnalysisResult: Codable {
    var warnings: [String] = []
}

struct SkinAnalysisResult: Codable {
    var issues: [String] = []
    var warnings: [String] = []
}

struct HairAnalysisResult: Codable {
    var issues: [String] = []
    var warnings: [String] = []
}

struct OrganAnalysisResult: Codable {
    var issues: [String] = []
}

struct SexualOrganAnalysisResult: Codable {
    var issues: [String] = []
}

struct ReflexAnalysisResult: Codable {
    var issues: [String] = []
}

enum HealthStatus: String, Codable {
    case excellent, good, fair, poor
}

struct MedicalRecommendation: Codable, Identifiable {
    let id: UUID
    let category: RecommendationCategory
    let priority: Priority
    let title: String
    let description: String
    let actions: [String]
    
    enum RecommendationCategory: String, Codable {
        case diet, exercise, supplement, lifestyle, medical
    }
    
    enum Priority: String, Codable {
        case low, medium, high, critical
    }
    
    init(id: UUID = UUID(), category: RecommendationCategory, priority: Priority, title: String, description: String, actions: [String]) {
        self.id = id
        self.category = category
        self.priority = priority
        self.title = title
        self.description = description
        self.actions = actions
    }
}
