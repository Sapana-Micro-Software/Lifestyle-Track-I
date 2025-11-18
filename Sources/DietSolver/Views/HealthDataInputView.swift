import SwiftUI

struct HealthDataInputView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    @State private var glucose: String = ""
    @State private var hemoglobin: String = ""
    @State private var cholesterol: String = ""
    @State private var systolicBP: String = ""
    @State private var diastolicBP: String = ""
    @State private var age: String = "30"
    @State private var gender: HealthData.Gender = .male
    @State private var weight: String = "70"
    @State private var height: String = "170"
    @State private var activityLevel: HealthData.ActivityLevel = .moderate
    
    var body: some View {
        Form {
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
                    Text("Weight (kg)")
                    Spacer()
                    TextField("Weight", text: $weight)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Height (cm)")
                    Spacer()
                    TextField("Height", text: $height)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
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
                NavigationLink("Exercise & Health Data") {
                    if let healthData = viewModel.healthData {
                        ExerciseInputView(healthData: Binding(
                            get: { healthData },
                            set: { viewModel.updateHealthData($0) }
                        ))
                    } else {
                        Text("Please complete basic health data first")
                    }
                }
                
                Button("Generate Diet Plan") {
                    let healthData = HealthData(
                        glucose: Double(glucose),
                        hemoglobin: Double(hemoglobin),
                        cholesterol: Double(cholesterol),
                        bloodPressure: createBloodPressure(),
                        age: Int(age) ?? 30,
                        gender: gender,
                        weight: Double(weight) ?? 70,
                        height: Double(height) ?? 170,
                        activityLevel: activityLevel
                    )
                    viewModel.setHealthData(healthData)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Diet Solver")
    }
    
    private func createBloodPressure() -> HealthData.BloodPressure? {
        guard let sys = Int(systolicBP), let dia = Int(diastolicBP) else {
            return nil
        }
        return HealthData.BloodPressure(systolic: sys, diastolic: dia)
    }
}
