import SwiftUI

struct ExerciseInputView: View {
    @Binding var healthData: HealthData
    @EnvironmentObject var viewModel: DietSolverViewModel
    @State private var muscleMass: String = ""
    @State private var bodyFatPercentage: String = ""
    @State private var steps: String = "10000"
    @State private var stairsClimbed: String = "10"
    
    // Sexual Health
    @State private var libidoLevel: HealthData.SexualHealth.LibidoLevel = .moderate
    @State private var sexualHealthConcerns: String = ""
    
    // Mental Health
    @State private var stressLevel: HealthData.MentalHealth.StressLevel = .moderate
    @State private var anxietyLevel: HealthData.MentalHealth.AnxietyLevel = .none
    @State private var sleepQuality: HealthData.MentalHealth.SleepQuality = .good
    @State private var currentTherapy: Bool = false
    @State private var mentalHealthMedications: String = ""
    @State private var depressionSymptoms: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Fitness Metrics")) {
                HStack {
                    Text("Muscle Mass (\(viewModel.unitSystem.weightUnit))")
                    Spacer()
                    TextField("Optional", text: $muscleMass)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Body Fat %")
                    Spacer()
                    TextField("Optional", text: $bodyFatPercentage)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Daily Steps Goal")
                    Spacer()
                    TextField("Steps", text: $steps)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Stairs Climbed (flights)")
                    Spacer()
                    TextField("Flights", text: $stairsClimbed)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section(header: Text("Mental Health")) {
                Picker("Stress Level", selection: $stressLevel) {
                    ForEach(HealthData.MentalHealth.StressLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Picker("Anxiety Level", selection: $anxietyLevel) {
                    ForEach(HealthData.MentalHealth.AnxietyLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Picker("Sleep Quality", selection: $sleepQuality) {
                    ForEach(HealthData.MentalHealth.SleepQuality.allCases, id: \.self) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
                
                Toggle("Currently in Therapy", isOn: $currentTherapy)
                
                HStack {
                    Text("Medications")
                    Spacer()
                    TextField("Optional", text: $mentalHealthMedications)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Depression Symptoms")
                    Spacer()
                    TextField("Optional", text: $depressionSymptoms)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section(header: Text("Sexual Health")) {
                Picker("Libido Level", selection: $libidoLevel) {
                    ForEach(HealthData.SexualHealth.LibidoLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                HStack {
                    Text("Concerns")
                    Spacer()
                    TextField("Optional", text: $sexualHealthConcerns)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section {
                Button("Save Exercise & Health Data") {
                    saveData()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Exercise & Health")
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        if let mm = healthData.muscleMass {
            // Convert from metric to display unit system
            let converter = UnitConverter.shared
            let displayValue = converter.convertWeight(mm, from: .metric, to: viewModel.unitSystem)
            muscleMass = String(format: "%.1f", displayValue)
        }
        if let bf = healthData.bodyFatPercentage {
            bodyFatPercentage = String(format: "%.1f", bf)
        }
        if let goals = healthData.exerciseGoals {
            steps = String(goals.dailySteps)
            stairsClimbed = String(goals.dailyStairs)
        }
        if let mental = healthData.mentalHealth {
            stressLevel = mental.stressLevel
            anxietyLevel = mental.anxietyLevel
            sleepQuality = mental.sleepQuality
            currentTherapy = mental.currentTherapy
            mentalHealthMedications = mental.medications.joined(separator: ", ")
            depressionSymptoms = mental.depressionSymptoms.joined(separator: ", ")
        }
        if let sexual = healthData.sexualHealth {
            libidoLevel = sexual.libidoLevel
            sexualHealthConcerns = sexual.concerns.joined(separator: ", ")
        }
    }
    
    private func saveData() {
        // Convert muscle mass to metric (internal storage is always metric)
        if let muscleValue = Double(muscleMass), !muscleMass.isEmpty {
            let converter = UnitConverter.shared
            healthData.muscleMass = converter.convertWeight(muscleValue, from: viewModel.unitSystem, to: .metric)
        } else {
            healthData.muscleMass = nil
        }
        healthData.bodyFatPercentage = Double(bodyFatPercentage)
        
        var goals = healthData.exerciseGoals ?? ExerciseGoals()
        goals.dailySteps = Int(steps) ?? 10000
        goals.dailyStairs = Int(stairsClimbed) ?? 10
        healthData.exerciseGoals = goals
        
        healthData.mentalHealth = HealthData.MentalHealth(
            stressLevel: stressLevel,
            anxietyLevel: anxietyLevel,
            depressionSymptoms: depressionSymptoms.isEmpty ? [] : depressionSymptoms.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            currentTherapy: currentTherapy,
            medications: mentalHealthMedications.isEmpty ? [] : mentalHealthMedications.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            sleepQuality: sleepQuality
        )
        
        healthData.sexualHealth = HealthData.SexualHealth(
            libidoLevel: libidoLevel,
            concerns: sexualHealthConcerns.isEmpty ? [] : sexualHealthConcerns.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            medications: []
        )
    }
}
