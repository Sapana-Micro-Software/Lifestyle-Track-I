//
//  MedicalTests.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation // Import Foundation framework for basic Swift types and functionality

// MARK: - Medical Test Base
protocol MedicalTest: Codable { // Define MedicalTest protocol requiring Codable conformance for serialization
    var id: UUID { get }
    var date: Date { get }
    var testType: String { get }
}

// MARK: - Blood Test Reports
struct BloodTestReport: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Blood Test"
    
    // Complete Blood Count (CBC)
    var whiteBloodCellCount: Double? // cells/μL
    var redBloodCellCount: Double? // million cells/μL
    var hemoglobin: Double? // g/dL
    var hematocrit: Double? // %
    var plateletCount: Double? // cells/μL
    var meanCorpuscularVolume: Double? // fL
    var meanCorpuscularHemoglobin: Double? // pg
    var meanCorpuscularHemoglobinConcentration: Double? // g/dL
    
    // Metabolic Panel
    var glucose: Double? // mg/dL
    var hba1c: Double? // %
    var insulin: Double? // μIU/mL
    var cPeptide: Double? // ng/mL
    
    // Lipid Panel
    var totalCholesterol: Double? // mg/dL
    var ldlCholesterol: Double? // mg/dL
    var hdlCholesterol: Double? // mg/dL
    var triglycerides: Double? // mg/dL
    
    // Liver Function
    var alt: Double? // U/L
    var ast: Double? // U/L
    var alkalinePhosphatase: Double? // U/L
    var bilirubinTotal: Double? // mg/dL
    var bilirubinDirect: Double? // mg/dL
    var albumin: Double? // g/dL
    var totalProtein: Double? // g/dL
    
    // Kidney Function
    var creatinine: Double? // mg/dL
    var bun: Double? // mg/dL
    var egfr: Double? // mL/min/1.73m²
    var uricAcid: Double? // mg/dL
    
    // Thyroid
    var tsh: Double? // mIU/L
    var freeT4: Double? // ng/dL
    var freeT3: Double? // pg/mL
    var reverseT3: Double? // ng/dL
    
    // Vitamins & Minerals
    var vitaminD: Double? // ng/mL
    var vitaminB12: Double? // pg/mL
    var folate: Double? // ng/mL
    var iron: Double? // μg/dL
    var ferritin: Double? // ng/mL
    var transferrin: Double? // mg/dL
    var totalIronBindingCapacity: Double? // μg/dL
    var calcium: Double? // mg/dL
    var magnesium: Double? // mg/dL
    var zinc: Double? // μg/dL
    var selenium: Double? // μg/L
    var copper: Double? // μg/dL
    
    // Hormones
    var testosterone: Double? // ng/dL
    var freeTestosterone: Double? // pg/mL
    var estradiol: Double? // pg/mL
    var progesterone: Double? // ng/mL
    var cortisol: Double? // μg/dL
    var dhea: Double? // μg/dL
    var shbg: Double? // nmol/L
    var lh: Double? // mIU/mL
    var fsh: Double? // mIU/mL
    var prolactin: Double? // ng/mL
    
    // Inflammatory Markers
    var crp: Double? // mg/L
    var esr: Double? // mm/hr
    var homocysteine: Double? // μmol/L
    var fibrinogen: Double? // mg/dL
    
    // Blood Source Location
    var sourceLocation: BloodSourceLocation?
    
    enum BloodSourceLocation: String, Codable {
        case venous = "Venous"
        case arterial = "Arterial"
        case capillary = "Capillary"
        case specificVein = "Specific Vein"
        case specificArtery = "Specific Artery"
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Urine Analysis
struct UrineAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Urine Analysis"
    
    // Physical Properties
    var color: String?
    var appearance: String?
    var specificGravity: Double?
    var pH: Double?
    
    // Chemical Analysis
    var protein: Double? // mg/dL
    var glucose: Double? // mg/dL
    var ketones: Double? // mg/dL
    var bilirubin: String? // negative/positive
    var urobilinogen: Double? // mg/dL
    var nitrite: String? // negative/positive
    var leukocyteEsterase: String? // negative/positive
    
    // Microscopic
    var redBloodCells: Int? // per HPF
    var whiteBloodCells: Int? // per HPF
    var epithelialCells: Int? // per HPF
    var casts: String?
    var crystals: String?
    var bacteria: String?
    var yeast: String?
    
    // Additional
    var sodium: Double? // mEq/L
    var potassium: Double? // mEq/L
    var chloride: Double? // mEq/L
    var creatinine: Double? // mg/dL
    var microalbumin: Double? // mg/L
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Semen Analysis
struct SemenAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Semen Analysis"
    
    // Volume & Physical
    var volume: Double? // mL
    var pH: Double?
    var viscosity: String?
    var liquefactionTime: Double? // minutes
    var color: String?
    var odor: String?
    
    // Sperm Count
    var spermConcentration: Double? // million/mL
    var totalSpermCount: Double? // million
    var totalMotileSperm: Double? // million
    
    // Motility
    var progressiveMotility: Double? // %
    var nonProgressiveMotility: Double? // %
    var immotile: Double? // %
    
    // Morphology
    var normalForms: Double? // %
    var abnormalForms: Double? // %
    var headDefects: Double? // %
    var midpieceDefects: Double? // %
    var tailDefects: Double? // %
    
    // Vitality
    var liveSperm: Double? // %
    var deadSperm: Double? // %
    
    // Additional
    var whiteBloodCells: Double? // million/mL
    var roundCells: Double? // million/mL
    var agglutination: String?
    var antispermAntibodies: String?
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Bone Marrow Analysis
struct BoneMarrowAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Bone Marrow Analysis"
    
    var cellularity: Double? // %
    var myeloidErythroidRatio: Double?
    var blastCells: Double? // %
    var promyelocytes: Double? // %
    var myelocytes: Double? // %
    var metamyelocytes: Double? // %
    var neutrophils: Double? // %
    var eosinophils: Double? // %
    var basophils: Double? // %
    var lymphocytes: Double? // %
    var plasmaCells: Double? // %
    var monocytes: Double? // %
    var erythroidPrecursors: Double? // %
    var megakaryocytes: String? // normal/increased/decreased
    var ironStores: String? // present/absent/increased
    var fibrosis: String? // none/mild/moderate/severe
    var cytogenetics: String?
    var molecularStudies: String?
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Saliva Analysis
struct SalivaAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Saliva Analysis"
    
    var volume: Double? // mL/min
    var pH: Double?
    var flowRate: Double? // mL/min
    var cortisol: Double? // ng/mL
    var dhea: Double? // ng/mL
    var testosterone: Double? // pg/mL
    var estradiol: Double? // pg/mL
    var progesterone: Double? // pg/mL
    var melatonin: Double? // pg/mL
    var iga: Double? // mg/dL
    var lysozyme: Double? // μg/mL
    var lactoferrin: Double? // μg/mL
    var amylase: Double? // U/mL
    var electrolytes: SalivaElectrolytes?
    
    struct SalivaElectrolytes: Codable {
        var sodium: Double? // mEq/L
        var potassium: Double? // mEq/L
        var chloride: Double? // mEq/L
        var bicarbonate: Double? // mEq/L
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Skin Analysis
struct SkinAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Skin Analysis"
    
    var bodyPart: BodyPart
    var moistureLevel: Double? // 0-100
    var oilLevel: Double? // 0-100
    var elasticity: Double? // 0-100
    var pH: Double?
    var melaninIndex: Double?
    var erythemaIndex: Double?
    var sebumLevel: Double? // μg/cm²
    var transepidermalWaterLoss: Double? // g/m²/h
    var skinThickness: Double? // mm
    var collagenDensity: Double? // %
    var hydrationLevel: Double? // %
    var barrierFunction: String? // normal/impaired
    var microflora: String?
    var lesions: [SkinLesion]?
    
    enum BodyPart: String, Codable, CaseIterable {
        case face = "Face"
        case forehead = "Forehead"
        case cheeks = "Cheeks"
        case chin = "Chin"
        case neck = "Neck"
        case chest = "Chest"
        case back = "Back"
        case abdomen = "Abdomen"
        case arms = "Arms"
        case legs = "Legs"
        case hands = "Hands"
        case feet = "Feet"
        case scalp = "Scalp"
    }
    
    struct SkinLesion: Codable {
        var type: String
        var location: String
        var size: String
        var description: String
    }
    
    init(id: UUID = UUID(), date: Date = Date(), bodyPart: BodyPart = .face) {
        self.id = id
        self.date = date
        self.bodyPart = bodyPart
    }
}

// MARK: - Hair Analysis
struct HairAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Hair Analysis"
    
    // Heavy Metals
    var mercury: Double? // ppm
    var lead: Double? // ppm
    var cadmium: Double? // ppm
    var arsenic: Double? // ppm
    var aluminum: Double? // ppm
    var chromium: Double? // ppm
    var nickel: Double? // ppm
    
    // Essential Minerals
    var calcium: Double? // ppm
    var magnesium: Double? // ppm
    var zinc: Double? // ppm
    var copper: Double? // ppm
    var selenium: Double? // ppm
    var iron: Double? // ppm
    var manganese: Double? // ppm
    var potassium: Double? // ppm
    var sodium: Double? // ppm
    var phosphorus: Double? // ppm
    
    // Trace Elements
    var boron: Double? // ppm
    var cobalt: Double? // ppm
    var molybdenum: Double? // ppm
    var vanadium: Double? // ppm
    var lithium: Double? // ppm
    var strontium: Double? // ppm
    
    // Drug Compounds
    var cocaine: Double? // ng/mg
    var amphetamines: Double? // ng/mg
    var opiates: Double? // ng/mg
    var cannabinoids: Double? // ng/mg
    var benzodiazepines: Double? // ng/mg
    
    // Additional
    var hairSegment: String? // root/mid/end
    var sampleLength: Double? // cm
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Organ Analysis
struct OrganAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Organ Analysis"
    
    var organ: OrganType
    var condition: OrganCondition
    var findings: [String]
    var measurements: OrganMeasurements?
    var imagingResults: String?
    var functionTests: [String: Double]?
    
    enum OrganType: String, Codable, CaseIterable {
        case heart = "Heart"
        case lungs = "Lungs"
        case liver = "Liver"
        case kidneys = "Kidneys"
        case spleen = "Spleen"
        case pancreas = "Pancreas"
        case stomach = "Stomach"
        case smallIntestine = "Small Intestine"
        case largeIntestine = "Large Intestine"
        case esophagus = "Esophagus"
        case thymus = "Thymus"
        case adrenalGlands = "Adrenal Glands"
    }
    
    enum OrganCondition: String, Codable {
        case normal = "Normal"
        case mildAbnormality = "Mild Abnormality"
        case moderateAbnormality = "Moderate Abnormality"
        case severeAbnormality = "Severe Abnormality"
        case disease = "Disease Present"
    }
    
    struct OrganMeasurements: Codable {
        var size: String?
        var volume: Double? // cm³
        var weight: Double? // g
        var thickness: Double? // mm
        var other: [String: Double]?
    }
    
    init(id: UUID = UUID(), date: Date = Date(), organ: OrganType = .heart, condition: OrganCondition = .normal) {
        self.id = id
        self.date = date
        self.organ = organ
        self.condition = condition
        self.findings = []
    }
}

// MARK: - Sexual Organ Analysis
struct SexualOrganAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Sexual Organ Analysis"
    
    var organPart: SexualOrganPart
    var condition: OrganCondition
    var measurements: SexualOrganMeasurements?
    var findings: [String]
    var sensitivity: Double? // 0-10
    var bloodFlow: String? // normal/reduced/increased
    var tissueHealth: String?
    
    enum SexualOrganPart: String, Codable, CaseIterable {
        case foreskin = "Foreskin"
        case glans = "Glans"
        case shaft = "Shaft"
        case scrotum = "Scrotum"
        case testicles = "Testicles"
        case prostate = "Prostate"
        case vulva = "Vulva"
        case clitoris = "Clitoris"
        case labia = "Labia"
        case vagina = "Vagina"
        case cervix = "Cervix"
        case uterus = "Uterus"
        case ovaries = "Ovaries"
    }
    
    enum OrganCondition: String, Codable {
        case normal = "Normal"
        case mildAbnormality = "Mild Abnormality"
        case moderateAbnormality = "Moderate Abnormality"
        case severeAbnormality = "Severe Abnormality"
        case disease = "Disease Present"
    }
    
    struct SexualOrganMeasurements: Codable {
        var length: Double? // cm
        var width: Double? // cm
        var circumference: Double? // cm
        var thickness: Double? // mm
        var other: [String: Double]?
    }
    
    init(id: UUID = UUID(), date: Date = Date(), organPart: SexualOrganPart = .foreskin, condition: OrganCondition = .normal) {
        self.id = id
        self.date = date
        self.organPart = organPart
        self.condition = condition
        self.findings = []
    }
}

// MARK: - Reflex Analysis
struct ReflexAnalysis: MedicalTest, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Reflex Analysis"
    
    var reflexes: [ReflexTest]
    
    struct ReflexTest: Codable {
        var name: String
        var response: ReflexResponse
        var grade: Int? // 0-4+
        var notes: String?
        
        enum ReflexResponse: String, Codable {
            case absent = "Absent"
            case diminished = "Diminished"
            case normal = "Normal"
            case brisk = "Brisk"
            case hyperactive = "Hyperactive"
            case clonus = "Clonus"
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
        self.reflexes = []
    }
}

// MARK: - Medical Test Collection
struct MedicalTestCollection: Codable {
    var bloodTests: [BloodTestReport] = []
    var urineAnalyses: [UrineAnalysis] = []
    var semenAnalyses: [SemenAnalysis] = []
    var boneMarrowAnalyses: [BoneMarrowAnalysis] = []
    var salivaAnalyses: [SalivaAnalysis] = []
    var skinAnalyses: [SkinAnalysis] = []
    var hairAnalyses: [HairAnalysis] = []
    var organAnalyses: [OrganAnalysis] = []
    var sexualOrganAnalyses: [SexualOrganAnalysis] = []
    var reflexAnalyses: [ReflexAnalysis] = []
    
    var allTests: [any MedicalTest] {
        var tests: [any MedicalTest] = []
        tests.append(contentsOf: bloodTests)
        tests.append(contentsOf: urineAnalyses)
        tests.append(contentsOf: semenAnalyses)
        tests.append(contentsOf: boneMarrowAnalyses)
        tests.append(contentsOf: salivaAnalyses)
        tests.append(contentsOf: skinAnalyses)
        tests.append(contentsOf: hairAnalyses)
        tests.append(contentsOf: organAnalyses)
        tests.append(contentsOf: sexualOrganAnalyses)
        tests.append(contentsOf: reflexAnalyses)
        return tests
    }
}
