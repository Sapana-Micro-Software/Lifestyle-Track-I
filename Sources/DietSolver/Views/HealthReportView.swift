//
//  HealthReportView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Health Report View
struct HealthReportView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var healthReport: HealthReport?
    @State private var selectedTimeframe: ReportTimeframe = .monthly
    @State private var isGenerating = false
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                    Text("Health Report")
                        .font(AppDesign.Typography.title)
                        .fontWeight(.bold)
                    
                    Text("Generate comprehensive health reports for your healthcare provider")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Generation Controls
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            ForEach(ReportTimeframe.allCases, id: \.self) { timeframe in
                                Text(timeframe.rawValue).tag(timeframe)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Button(action: generateReport) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "doc.text.fill")
                                    Text("Generate Report")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppDesign.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating || viewModel.healthData == nil)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Report Display
                if let report = healthReport {
                    healthReportContent(report: report)
                } else if !isGenerating {
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 50))
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            Text("No health report generated yet")
                                .font(AppDesign.Typography.headline)
                            Text("Generate a report from your health data")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        .padding()
                    }
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.bottom, AppDesign.Spacing.xl)
        }
        .navigationTitle("Health Report")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                if healthReport != nil {
                    Button(action: exportPDF) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showShareSheet) {
            if let report = healthReport,
               let pdfData = HealthReportGenerator.shared.exportToPDF(report) {
                #if os(iOS)
                ShareSheet(activityItems: [pdfData])
                #else
                EmptyView()
                #endif
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Generate Report
    private func generateReport() {
        guard let healthData = viewModel.healthData else { return }
        
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let report = HealthReportGenerator.shared.generateHealthReport(
                healthData: healthData,
                longTermPlan: viewModel.longTermPlan,
                dailyPlans: viewModel.dailyPlans,
                timeframe: selectedTimeframe
            )
            
            DispatchQueue.main.async {
                self.healthReport = report
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Export PDF
    private func exportPDF() {
        guard healthReport != nil else { return }
        showShareSheet = true
    }
    
    // MARK: - Report Content
    private func healthReportContent(report: HealthReport) -> some View {
        VStack(spacing: AppDesign.Spacing.md) {
            // Summary Section
            summarySection(summary: report.summary, generatedDate: report.generatedDate)
            
            // Goals Section
            if !report.goals.isEmpty {
                goalsSection(goals: report.goals)
            }
            
            // Progress Section
            progressSection(progress: report.progress)
            
            // Recommendations Section
            if !report.recommendations.isEmpty {
                recommendationsSection(recommendations: report.recommendations)
            }
            
            // Trends Section
            if !report.trends.isEmpty {
                trendsSection(trends: report.trends)
            }
        }
    }
    
    // MARK: - Summary Section
    private func summarySection(summary: ReportSummary, generatedDate: Date) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Summary")
                    .font(AppDesign.Typography.headline)
                
                VStack(spacing: AppDesign.Spacing.sm) {
                    HStack {
                        Text("Current Weight:")
                        Spacer()
                        Text("\(String(format: "%.1f", summary.currentWeight)) kg")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("BMI:")
                        Spacer()
                        Text(String(format: "%.1f", summary.currentBMI))
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Health Score:")
                        Spacer()
                        Text("\(String(format: "%.0f", summary.healthScore))/100")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Plan Duration:")
                        Spacer()
                        Text(summary.planDuration)
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Goals:")
                        Spacer()
                        Text("\(summary.goalsCount)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Milestones:")
                        Spacer()
                        Text("\(summary.milestonesAchieved)/\(summary.totalMilestones)")
                            .fontWeight(.semibold)
                    }
                }
                
                Text("Generated: \(formatDate(generatedDate))")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .padding(.top, AppDesign.Spacing.xs)
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Goals Section
    private func goalsSection(goals: [GoalProgress]) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            Text("Goal Progress")
                .font(AppDesign.Typography.headline)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(goals) { goal in
                ModernCard {
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                        Text(goal.goalName)
                            .font(AppDesign.Typography.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(goal.category)
                            .font(AppDesign.Typography.caption)
                            .foregroundColor(AppDesign.Colors.textSecondary)
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(AppDesign.Colors.primary.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(AppDesign.Colors.primary)
                                    .frame(width: geometry.size.width * goal.progress, height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            if let current = goal.currentValue {
                                Text("Current: \(String(format: "%.1f", current))")
                                    .font(AppDesign.Typography.caption)
                            }
                            Spacer()
                            if let target = goal.targetValue {
                                Text("Target: \(String(format: "%.1f", target))")
                                    .font(AppDesign.Typography.caption)
                            }
                            Text("\(Int(goal.progress * 100))%")
                                .font(AppDesign.Typography.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppDesign.Colors.textSecondary)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Progress Section
    private func progressSection(progress: ProgressMetrics) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
                Text("Progress Metrics")
                    .font(AppDesign.Typography.headline)
                
                VStack(spacing: AppDesign.Spacing.sm) {
                    HStack {
                        Text("Days Tracked:")
                        Spacer()
                        Text("\(progress.daysTracked)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Total Meals:")
                        Spacer()
                        Text("\(progress.totalMeals)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Exercise Minutes:")
                        Spacer()
                        Text("\(String(format: "%.0f", progress.totalExerciseMinutes))")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Avg Water Intake:")
                        Spacer()
                        Text("\(String(format: "%.1f", progress.averageWaterIntake)) L")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Avg Sleep:")
                        Spacer()
                        Text("\(String(format: "%.1f", progress.averageSleepHours)) hrs")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Plan Adherence:")
                        Spacer()
                        Text("\(String(format: "%.0f", progress.planAdherence))%")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(AppDesign.Spacing.md)
        }
        .padding(.horizontal, AppDesign.Spacing.md)
    }
    
    // MARK: - Recommendations Section
    private func recommendationsSection(recommendations: [String]) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            Text("Recommendations")
                .font(AppDesign.Typography.headline)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                ModernCard {
                    HStack(alignment: .top, spacing: AppDesign.Spacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(AppDesign.Colors.accent)
                        Text(recommendation)
                            .font(AppDesign.Typography.body)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Trends Section
    private func trendsSection(trends: [Trend]) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            Text("Trends")
                .font(AppDesign.Typography.headline)
                .padding(.horizontal, AppDesign.Spacing.md)
            
            ForEach(trends) { trend in
                ModernCard {
                    HStack {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                            Text(trend.metric)
                                .font(AppDesign.Typography.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(trend.description)
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(trend.direction.rawValue)
                                .font(AppDesign.Typography.subheadline)
                                .foregroundColor(trendColor(trend.direction))
                            
                            if trend.change != 0 {
                                Text(String(format: "%.1f", trend.change))
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
            }
        }
    }
    
    private func trendColor(_ direction: Trend.TrendDirection) -> Color {
        switch direction {
        case .improving: return AppDesign.Colors.success
        case .declining: return .red
        case .stable: return AppDesign.Colors.textSecondary
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// InfoRow is already defined in ExternalHealthAnalysisViews.swift

// MARK: - Share Sheet (iOS)
#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
