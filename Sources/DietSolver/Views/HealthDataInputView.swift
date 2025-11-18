import SwiftUI

struct HealthDataInputView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var previousUnitSystem: UnitSystem = .metric
    @State private var showExerciseInput = false
    
    @State private var glucose: String = ""
    @State private var hemoglobin: String = ""
    @State private var cholesterol: String = ""
    @State private var systolicBP: String = ""
    @State private var diastolicBP: String = ""
    @State private var age: String = "30"
    @State private var gender: HealthData.Gender = .male
    @State private var weight: String = "70"
    @State private var height: String = "170"
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var activityLevel: HealthData.ActivityLevel = .moderate
    
    var body: some View {
        Form {
            Section(header: HStack {
                Text("Unit System")
                Spacer()
                CompactUnitSystemToggle(viewModel: viewModel)
            }) {
                EmptyView()
            }
            Section(header: Text("Basic Information")) {
                Picker("Gender", selection: $gender) {
                    ForEach(HealthData.Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue.capitalized).tag(gender)
                    }
                }
                
                HStack {
                    Text("Age")
                    Spacer()
                    TextField("Age", text: $age)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Weight (\(viewModel.unitSystem.weightUnit))")
                    Spacer()
                    TextField("Weight", text: $weight)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                if viewModel.unitSystem == .metric {
                    HStack {
                        Text("Height (\(viewModel.unitSystem.heightUnit))")
                        Spacer()
                        TextField("Height", text: $height)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .frame(width: 100)
                            .multilineTextAlignment(TextAlignment.trailing)
                    }
                } else {
                    HStack {
                        Text("Height")
                        Spacer()
                        HStack {
                            TextField("Feet", text: $heightFeet)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .frame(width: 60)
                            Text("ft")
                            TextField("Inches", text: $heightInches)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .frame(width: 60)
                            Text("in")
                        }
                    }
                }
                
                Picker("Activity Level", selection: $activityLevel) {
                    ForEach(HealthData.ActivityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
            }
            
            Section(header: Text("Blood Test Results (Optional)")) {
                HStack {
                    Text("Glucose (mg/dL)")
                    Spacer()
                    TextField("Optional", text: $glucose)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Hemoglobin (g/dL)")
                    Spacer()
                    TextField("Optional", text: $hemoglobin)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Cholesterol (mg/dL)")
                    Spacer()
                    TextField("Optional", text: $cholesterol)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section(header: Text("Blood Pressure (Optional)")) {
                HStack {
                    Text("Systolic")
                    Spacer()
                    TextField("Optional", text: $systolicBP)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Diastolic")
                    Spacer()
                    TextField("Optional", text: $diastolicBP)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section {
                Button("Exercise & Health Data") {
                    if viewModel.healthData != nil {
                        showExerciseInput = true
                    }
                }
                
                Button("Generate Diet Plan") {
                    // Convert to metric (internal storage is always metric)
                    let converter = UnitConverter.shared
                    var finalWeight = Double(weight) ?? 70.0
                    var finalHeight = Double(height) ?? 170.0
                    
                    // Convert weight
                    finalWeight = converter.convertWeight(finalWeight, from: viewModel.unitSystem, to: .metric)
                    
                    // Convert height
                    if viewModel.unitSystem == .imperial {
                        let feet = Int(heightFeet) ?? 0
                        let inches = Double(heightInches) ?? 0
                        let totalInches = converter.feetInchesToHeight(feet: feet, inches: inches)
                        finalHeight = converter.convertHeight(totalInches, from: .imperial, to: .metric)
                    }
                    
                    let healthData = HealthData(
                        glucose: Double(glucose),
                        hemoglobin: Double(hemoglobin),
                        cholesterol: Double(cholesterol),
                        bloodPressure: createBloodPressure(),
                        age: Int(age) ?? 30,
                        gender: gender,
                        weight: finalWeight,
                        height: finalHeight,
                        activityLevel: activityLevel
                    )
                    viewModel.setHealthData(healthData)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Diet Solver")
        .onChange(of: viewModel.unitSystem) { newSystem in
            convertValues(from: previousUnitSystem, to: newSystem)
            previousUnitSystem = newSystem
        }
        .onAppear {
            previousUnitSystem = viewModel.unitSystem
        }
        .sheet(isPresented: $showExerciseInput) {
            if let healthData = viewModel.healthData {
                ExerciseInputView(healthData: Binding(
                    get: { healthData },
                    set: { viewModel.updateHealthData($0) }
                ))
                .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Convert Values
    private func convertValues(from: UnitSystem, to: UnitSystem) {
        let converter = UnitConverter.shared
        
        // Convert weight
        if let weightValue = Double(weight), !weight.isEmpty {
            let converted = converter.convertWeight(weightValue, from: from, to: to)
            weight = String(format: "%.1f", converted)
        }
        
        // Convert height
        if viewModel.unitSystem == .imperial {
            // Convert to feet/inches
            if let heightValue = Double(height), !height.isEmpty {
                let inches = converter.convertHeight(heightValue, from: from, to: to)
                let (feet, remainingInches) = converter.heightToFeetInches(inches)
                heightFeet = String(feet)
                heightInches = String(format: "%.1f", remainingInches)
                height = ""
            }
        } else {
            // Convert to cm
            if !heightFeet.isEmpty || !heightInches.isEmpty {
                let feet = Int(heightFeet) ?? 0
                let inches = Double(heightInches) ?? 0
                let totalInches = converter.feetInchesToHeight(feet: feet, inches: inches)
                let cm = converter.convertHeight(totalInches, from: .imperial, to: .metric)
                height = String(format: "%.1f", cm)
                heightFeet = ""
                heightInches = ""
            }
        }
    }
    
    private func createBloodPressure() -> HealthData.BloodPressure? {
        guard let sys = Int(systolicBP), let dia = Int(diastolicBP) else {
            return nil
        }
        return HealthData.BloodPressure(systolic: sys, diastolic: dia)
    }
}
