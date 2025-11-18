import SwiftUI

struct SolvingView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Optimizing Your Diet Plan...")
                .font(.title2)
                .padding()
            
            Text("Analyzing nutrients, balancing taste, digestion, and seasonal availability")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .onAppear {
            viewModel.solveDiet()
        }
    }
}
