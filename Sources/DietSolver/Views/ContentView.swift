import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

public struct ContentView: View { // Define ContentView struct conforming to View protocol
    @StateObject private var viewModel = DietSolverViewModel() // State object for view model instance
    
    public init() {} // Public initializer for ContentView
    
    public var body: some View { // Define body property returning view hierarchy
        TabView { // Create tab view container
            // Main Diet Plan Tab
            NavigationView { // Create navigation view
                if viewModel.healthData == nil { // Check if health data exists
                    HealthDataInputView(viewModel: viewModel) // Display health data input view
                } else if viewModel.dietPlan == nil { // Check if diet plan exists
                    SolvingView(viewModel: viewModel) // Display solving view
                } else { // If diet plan exists
                    DietPlanView(viewModel: viewModel) // Display diet plan view
                }
            }
            .tabItem { // Set tab item
                Label("Diet Plan", systemImage: "fork.knife") // Set label and icon
            }
            
            // Planning Sessions Tab
            PlanningSessionView(viewModel: viewModel) // Display planning session view
                .tabItem { // Set tab item
                    Label("Planning", systemImage: "calendar") // Set label and icon
                }
            
            // Journal Analysis Tab
            JournalAnalysisView(viewModel: viewModel) // Display journal analysis view
                .tabItem { // Set tab item
                    Label("Journal", systemImage: "book") // Set label and icon
                }
            
            // Vision Health Tab
            VisionHealthTabView(viewModel: viewModel) // Display vision health tab view
                .tabItem { // Set tab item
                    Label("Vision", systemImage: "eye") // Set label and icon
                }
        }
    }
}

struct VisionHealthTabView: View { // Define VisionHealthTabView struct for vision health tab
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    
    var body: some View { // Define body property returning view hierarchy
        TabView { // Create tab view container
            VisionCheckView(viewModel: viewModel) // Display vision check view
                .tabItem { // Set tab item
                    Label("Check", systemImage: "checkmark.circle") // Set label and icon
                }
            VisionGamesView(viewModel: viewModel) // Display vision games view
                .tabItem { // Set tab item
                    Label("Games", systemImage: "gamecontroller") // Set label and icon
                }
        }
    }
}
