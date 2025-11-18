import SwiftUI

struct SolvingView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    
    var body: some View {
        ModernSolvingView(viewModel: viewModel)
    }
}
