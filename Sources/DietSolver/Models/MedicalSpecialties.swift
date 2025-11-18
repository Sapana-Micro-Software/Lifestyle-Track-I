//
//  MedicalSpecialties.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import Foundation

// MARK: - Radiology Analysis
struct RadiologyAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Radiology"
    
    var imagingModality: ImagingModality
    var bodyRegion: BodyRegion
    var findings: [RadiologyFinding]
    var measurements: RadiologyMeasurements?
    var contrastUsed: Bool
    var radiationDose: Double? // mSv
    
    enum ImagingModality: String, Codable, CaseIterable {
        case xray = "X-Ray"
        case ct = "CT Scan"
        case mri = "MRI"
        case ultrasound = "Ultrasound"
        case pet = "PET Scan"
        case spect = "SPECT Scan"
        case nuclearMedicine = "Nuclear Medicine"
        case mammography = "Mammography"
        case fluoroscopy = "Fluoroscopy"
        case angiography = "Angiography"
    }
    
    enum BodyRegion: String, Codable, CaseIterable {
        case head = "Head"
        case neck = "Neck"
        case chest = "Chest"
        case abdomen = "Abdomen"
        case pelvis = "Pelvis"
        case spine = "Spine"
        case extremities = "Extremities"
        case wholeBody = "Whole Body"
    }
    
    struct RadiologyFinding: Codable {
        var description: String
        var location: String
        var size: String?
        var characteristics: [String]
        var significance: FindingSignificance
        
        enum FindingSignificance: String, Codable {
            case normal = "Normal"
            case benign = "Benign"
            case suspicious = "Suspicious"
            case malignant = "Malignant"
            case indeterminate = "Indeterminate"
        }
    }
    
    struct RadiologyMeasurements: Codable {
        var organSize: [String: Double]? // cm
        var lesionSize: [String: Double]? // cm
        var density: [String: Double]? // HU for CT
        var signalIntensity: [String: String]? // For MRI
        var flowVelocity: [String: Double]? // cm/s for Doppler
    }
    
    init(id: UUID = UUID(), date: Date = Date(), imagingModality: ImagingModality = .xray, bodyRegion: BodyRegion = .chest, findings: [RadiologyFinding] = [], measurements: RadiologyMeasurements? = nil, contrastUsed: Bool = false, radiationDose: Double? = nil) {
        self.id = id
        self.date = date
        self.imagingModality = imagingModality
        self.bodyRegion = bodyRegion
        self.findings = findings
        self.measurements = measurements
        self.contrastUsed = contrastUsed
        self.radiationDose = radiationDose
    }
}

// MARK: - Cardiology Analysis
struct CardiologyAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Cardiology"
    
    var ecg: ECGResults?
    var echocardiogram: EchocardiogramResults?
    var stressTest: StressTestResults?
    var cardiacCatheterization: CardiacCatheterizationResults?
    var holterMonitor: HolterMonitorResults?
    var cardiacMRI: CardiacMRIResults?
    
    struct ECGResults: Codable {
        var heartRate: Int? // bpm
        var rhythm: String? // Normal sinus, AFib, etc.
        var prInterval: Double? // ms
        var qrsDuration: Double? // ms
        var qtInterval: Double? // ms
        var qtcInterval: Double? // ms
        var axis: String?
        var abnormalities: [String]
    }
    
    struct EchocardiogramResults: Codable {
        var ejectionFraction: Double? // %
        var leftVentricularSize: String?
        var leftVentricularWallThickness: Double? // mm
        var leftAtrialSize: Double? // cm
        var valvularFunction: [String: String]
        var wallMotion: String?
        var pericardialEffusion: Bool
    }
    
    struct StressTestResults: Codable {
        var testType: String // Exercise, Pharmacological
        var maxHeartRate: Int? // bpm
        var targetHeartRateAchieved: Bool
        var bloodPressureResponse: String?
        var ecgChanges: [String]
        var symptoms: [String]
        var result: TestResult
        
        enum TestResult: String, Codable {
            case normal = "Normal"
            case abnormal = "Abnormal"
            case equivocal = "Equivocal"
        }
    }
    
    struct CardiacCatheterizationResults: Codable {
        var coronaryArteries: [CoronaryArtery]
        var leftVentricularPressure: Double? // mmHg
        var aorticPressure: Double? // mmHg
        var cardiacOutput: Double? // L/min
        var cardiacIndex: Double? // L/min/m²
        
        struct CoronaryArtery: Codable {
            var name: String
            var stenosis: Double? // %
            var patency: String
        }
    }
    
    struct HolterMonitorResults: Codable {
        var duration: Int // hours
        var averageHeartRate: Int? // bpm
        var maxHeartRate: Int? // bpm
        var minHeartRate: Int? // bpm
        var arrhythmias: [ArrhythmiaEvent]
        
        struct ArrhythmiaEvent: Codable {
            var type: String
            var count: Int
            var description: String
        }
    }
    
    struct CardiacMRIResults: Codable {
        var ejectionFraction: Double? // %
        var myocardialMass: Double? // g
        var wallThickness: [String: Double]? // mm
        var perfusion: String?
        var viability: String?
        var scar: String?
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Nuclear Medicine Analysis
struct NuclearMedicineAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Nuclear Medicine"
    
    var studyType: NuclearStudyType
    var radiopharmaceutical: String
    var activityAdministered: Double // MBq
    var imagingTime: Date
    var findings: [NuclearFinding]
    var quantitativeAnalysis: QuantitativeAnalysis?
    
    enum NuclearStudyType: String, Codable, CaseIterable {
        case boneScan = "Bone Scan"
        case petScan = "PET Scan"
        case spectScan = "SPECT Scan"
        case thyroidScan = "Thyroid Scan"
        case cardiacPerfusion = "Cardiac Perfusion"
        case lungVentilation = "Lung Ventilation/Perfusion"
        case renalScan = "Renal Scan"
        case hepatobiliaryScan = "Hepatobiliary Scan"
        case brainPerfusion = "Brain Perfusion"
    }
    
    struct NuclearFinding: Codable {
        var description: String
        var location: String
        var uptake: UptakeLevel
        var size: String?
        
        enum UptakeLevel: String, Codable {
            case normal = "Normal"
            case decreased = "Decreased"
            case increased = "Increased"
            case absent = "Absent"
        }
    }
    
    struct QuantitativeAnalysis: Codable {
        var suvMax: [String: Double]? // Standardized Uptake Value
        var suvMean: [String: Double]?
        var metabolicVolume: [String: Double]? // cm³
        var totalLesionGlycolysis: [String: Double]? // g
        var kTrans: [String: Double]? // Perfusion parameter
        var ve: [String: Double]? // Extravascular extracellular volume
    }
    
    init(id: UUID = UUID(), date: Date = Date(), studyType: NuclearStudyType = .boneScan, radiopharmaceutical: String = "", activityAdministered: Double = 0, imagingTime: Date = Date(), findings: [NuclearFinding] = [], quantitativeAnalysis: QuantitativeAnalysis? = nil) {
        self.id = id
        self.date = date
        self.studyType = studyType
        self.radiopharmaceutical = radiopharmaceutical
        self.activityAdministered = activityAdministered
        self.imagingTime = imagingTime
        self.findings = findings
        self.quantitativeAnalysis = quantitativeAnalysis
    }
}

// MARK: - Other Medical Specialties
struct NeurologyAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Neurology"
    
    var eeg: EEGResults?
    var emg: EMGResults?
    var nerveConduction: NerveConductionResults?
    var cognitiveTests: [String: Double]?
    
    struct EEGResults: Codable {
        var background: String
        var abnormalities: [String]
        var seizureActivity: Bool
    }
    
    struct EMGResults: Codable {
        var muscle: String
        var findings: [String]
        var diagnosis: String?
    }
    
    struct NerveConductionResults: Codable {
        var nerve: String
        var conductionVelocity: Double? // m/s
        var amplitude: Double? // mV
        var latency: Double? // ms
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

struct PulmonologyAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Pulmonology"
    
    var spirometry: SpirometryResults?
    var lungVolumes: LungVolumeResults?
    var diffusionCapacity: DiffusionCapacityResults?
    var arterialBloodGas: ArterialBloodGasResults?
    
    struct SpirometryResults: Codable {
        var fev1: Double? // L
        var fvc: Double? // L
        var fev1FvcRatio: Double? // %
        var pef: Double? // L/s
    }
    
    struct LungVolumeResults: Codable {
        var tlc: Double? // Total Lung Capacity, L
        var rv: Double? // Residual Volume, L
        var frc: Double? // Functional Residual Capacity, L
    }
    
    struct DiffusionCapacityResults: Codable {
        var dlco: Double? // mL/min/mmHg
        var dlcoVa: Double? // mL/min/mmHg/L
    }
    
    struct ArterialBloodGasResults: Codable {
        var ph: Double?
        var pco2: Double? // mmHg
        var po2: Double? // mmHg
        var hco3: Double? // mEq/L
        var o2Saturation: Double? // %
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

struct GastroenterologyAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let testType: String = "Gastroenterology"
    
    var endoscopy: EndoscopyResults?
    var colonoscopy: ColonoscopyResults?
    var manometry: ManometryResults?
    var phMonitoring: PHMonitoringResults?
    
    struct EndoscopyResults: Codable {
        var findings: [String]
        var biopsies: [String]
        var diagnosis: String?
    }
    
    struct ColonoscopyResults: Codable {
        var findings: [String]
        var polyps: [PolypFinding]
        var biopsies: [String]
        
        struct PolypFinding: Codable {
            var location: String
            var size: String
            var type: String
            var removed: Bool
        }
    }
    
    struct ManometryResults: Codable {
        var esophagealPressure: [String: Double]?
        var lowerEsophagealSphincter: Double? // mmHg
        var peristalsis: String?
    }
    
    struct PHMonitoringResults: Codable {
        var ph: Double?
        var refluxEvents: Int?
        var symptomCorrelation: String?
    }
    
    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}

// MARK: - Medical Specialty Collection
struct MedicalSpecialtyCollection: Codable {
    var radiologyAnalyses: [RadiologyAnalysis] = []
    var cardiologyAnalyses: [CardiologyAnalysis] = []
    var nuclearMedicineAnalyses: [NuclearMedicineAnalysis] = []
    var neurologyAnalyses: [NeurologyAnalysis] = []
    var pulmonologyAnalyses: [PulmonologyAnalysis] = []
    var gastroenterologyAnalyses: [GastroenterologyAnalysis] = []
}
