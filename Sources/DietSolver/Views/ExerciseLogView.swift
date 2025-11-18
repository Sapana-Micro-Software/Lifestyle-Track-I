import SwiftUI

struct ExerciseLogView: View {
    @Binding var healthData: HealthData
    @State private var selectedActivity: ExerciseActivity?
    @State private var duration: String = "30"
    @State private var heartRateAvg: String = ""
    @State private var heartRateMax: String = ""
    @State private var steps: String = ""
    @State private var stairs: String = ""
    @State private var restingHR: String = ""
    @State private var minHR: String = ""
    @State private var maxHR: String = ""
    @State private var meditationMinutes: String = ""
    @State private var breathingMinutes: String = ""
    
    private let exerciseDatabase = ExerciseDatabase.shared
    
    var body: some View {
        Form {
            Section(header: Text("Log Exercise Session")) {
                Picker("Activity", selection: $selectedActivity) {
                    Text("Select Activity").tag(nil as ExerciseActivity?)
                    ForEach(exerciseDatabase.activities) { activity in
                        Text(activity.name).tag(activity as ExerciseActivity?)
                    }
                }
                
                HStack {
                    Text("Duration (minutes)")
                    Spacer()
                    TextField("30", text: $duration)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                if selectedActivity != nil {
                    let calories = calculateCalories()
                    Text("Estimated Calories: \(String(format: "%.0f", calories)) kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Heart Rate (Optional)")) {
                HStack {
                    Text("Average HR")
                    Spacer()
                    TextField("Optional", text: $heartRateAvg)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Max HR")
                    Spacer()
                    TextField("Optional", text: $heartRateMax)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section(header: Text("Daily Metrics")) {
                HStack {
                    Text("Steps")
                    Spacer()
                    TextField("Optional", text: $steps)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Stairs Climbed")
                    Spacer()
                    TextField("Optional", text: $stairs)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section(header: Text("Heart Rate Variation")) {
                HStack {
                    Text("Resting HR")
                    Spacer()
                    TextField("Optional", text: $restingHR)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Min HR")
                    Spacer()
                    TextField("Optional", text: $minHR)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Max HR")
                    Spacer()
                    TextField("Optional", text: $maxHR)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section(header: Text("Mind-Body Practice")) {
                HStack {
                    Text("Meditation (minutes)")
                    Spacer()
                    TextField("Optional", text: $meditationMinutes)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
                
                HStack {
                    Text("Breathing Practice (minutes)")
                    Spacer()
                    TextField("Optional", text: $breathingMinutes)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                        .multilineTextAlignment(TextAlignment.trailing)
                }
            }
            
            Section {
                Button("Save Exercise Log") {
                    saveLog()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Log Exercise")
    }
    
    private func calculateCalories() -> Double {
        guard let activity = selectedActivity,
              let durationValue = Double(duration) else {
            return 0
        }
        let planner = ExercisePlanner()
        return planner.calculateCaloriesBurned(
            activity: activity,
            duration: durationValue,
            weight: healthData.weight
        )
    }
    
    private func saveLog() {
        var sessions: [ExerciseSession] = []
        
        if let activity = selectedActivity, let durationValue = Double(duration) {
            let calories = calculateCalories()
            let session = ExerciseSession(
                activity: activity,
                duration: durationValue,
                date: Date(),
                heartRateAverage: Int(heartRateAvg),
                heartRateMax: Int(heartRateMax),
                caloriesBurned: calories
            )
            sessions.append(session)
        }
        
        let heartRateVariation = DailyExerciseLog.HeartRateVariation(
            resting: Int(restingHR) ?? 0,
            average: Int(heartRateAvg) ?? 0,
            max: Int(maxHR) ?? 0,
            min: Int(minHR) ?? 0
        )
        
        let log = DailyExerciseLog(
            date: Date(),
            sessions: sessions,
            steps: Int(steps) ?? 0,
            stairsClimbed: Int(stairs) ?? 0,
            heartRateVariation: heartRateVariation,
            meditationMinutes: Double(meditationMinutes) ?? 0,
            breathingPracticeMinutes: Double(breathingMinutes) ?? 0
        )
        
        healthData.exerciseLogs.append(log)
        
        // Reset form
        selectedActivity = nil
        duration = "30"
        heartRateAvg = ""
        heartRateMax = ""
        steps = ""
        stairs = ""
        restingHR = ""
        minHR = ""
        maxHR = ""
        meditationMinutes = ""
        breathingMinutes = ""
    }
}
