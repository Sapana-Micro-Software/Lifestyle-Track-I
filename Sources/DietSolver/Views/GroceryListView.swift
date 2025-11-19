//
//  GroceryListView.swift
//  DietSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI

// MARK: - Grocery List View
struct GroceryListView: View {
    @ObservedObject var viewModel: DietSolverViewModel
    @State private var groceryList: GroceryList?
    @State private var daysToGenerate: Int = 7
    @State private var isGenerating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
                    HStack(spacing: AppDesign.Spacing.sm) {
                        IconBadge(icon: "cart.fill", color: AppDesign.Colors.primary, size: 40, gradient: true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Grocery List Generator")
                                .font(AppDesign.Typography.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            
                            Text("Generate shopping lists from your meal plans")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Generation Controls
                ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
                    VStack(spacing: AppDesign.Spacing.md) {
                        HStack {
                            IconBadge(icon: "calendar", color: AppDesign.Colors.primary, size: 24)
                            Text("Days to include:")
                                .font(AppDesign.Typography.body)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                            Spacer()
                            Picker("", selection: $daysToGenerate) {
                                Text("3 days").tag(3)
                                Text("7 days").tag(7)
                                Text("14 days").tag(14)
                                Text("30 days").tag(30)
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        
                        GradientButton(
                            title: isGenerating ? "Generating..." : "Generate Grocery List",
                            icon: isGenerating ? nil : "cart.fill",
                            action: generateGroceryList,
                            style: .primary
                        )
                        .disabled(isGenerating || (viewModel.dailyPlans.isEmpty && viewModel.dietPlan == nil))
                        .opacity(isGenerating ? 0.7 : 1.0)
                        .overlay(
                            Group {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        )
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Grocery List Display
                if let list = groceryList {
                    groceryListContent(list: list)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !isGenerating {
                    EmptyStateView(
                        icon: "cart",
                        title: "No grocery list generated yet",
                        message: "Generate a list from your meal plans"
                    )
                    .padding(.horizontal, AppDesign.Spacing.md)
                }
            }
            .padding(.bottom, AppDesign.Spacing.xl)
        }
        .navigationTitle("Grocery List")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .background(AppDesign.Colors.background.ignoresSafeArea())
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                if let list = groceryList {
                    ShareLink(item: GroceryListGenerator.shared.formatForSharing(list)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            #endif
        }
    }
    
    // MARK: - Generate Grocery List
    private func generateGroceryList() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let list: GroceryList
            
            // Use daily plans if available, otherwise use current diet plan
            if !viewModel.dailyPlans.isEmpty {
                list = GroceryListGenerator.shared.generateGroceryList(
                    from: viewModel.dailyPlans,
                    days: daysToGenerate
                )
            } else if let dietPlan = viewModel.dietPlan {
                // Generate from current diet plan
                list = GroceryListGenerator.shared.generateGroceryList(from: dietPlan)
            } else {
                // No data available
                DispatchQueue.main.async {
                    self.isGenerating = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.groceryList = list
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Grocery List Content
    private func groceryListContent(list: GroceryList) -> some View {
        VStack(spacing: AppDesign.Spacing.md) {
            // Summary
            ModernCard(shadow: AppDesign.Shadow.medium, gradient: true) {
                VStack(spacing: AppDesign.Spacing.sm) {
                    HStack {
                        HStack(spacing: AppDesign.Spacing.xs) {
                            IconBadge(icon: "cart.fill", color: AppDesign.Colors.primary, size: 32)
                            Text("Summary")
                                .font(AppDesign.Typography.headline)
                                .foregroundColor(AppDesign.Colors.textPrimary)
                        }
                        Spacer()
                    }
                    
                    HStack(spacing: AppDesign.Spacing.lg) {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.xs) {
                            Text("\(list.items.count)")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.primary)
                            Text("Items")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: AppDesign.Spacing.xs) {
                            Text("$\(String(format: "%.2f", list.totalEstimatedCost))")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppDesign.Colors.success)
                            Text("Estimated Cost")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(AppDesign.Spacing.md)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            .transition(.move(edge: .top).combined(with: .opacity))
            
            // Items by Category
            ForEach(GroceryCategory.allCases, id: \.self) { category in
                let categoryItems = list.items.filter { $0.category == category }
                if !categoryItems.isEmpty {
                    categorySection(category: category, items: categoryItems)
                }
            }
        }
    }
    
    // MARK: - Category Section
    private func categorySection(category: GroceryCategory, items: [GroceryItem]) -> some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            HStack {
                IconBadge(icon: category.icon, color: AppDesign.Colors.primary, size: 28)
                Text(category.rawValue)
                    .font(AppDesign.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppDesign.Colors.textPrimary)
                Spacer()
                Text("\(items.count) items")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
                    .padding(.horizontal, AppDesign.Spacing.sm)
                    .padding(.vertical, AppDesign.Spacing.xs)
                    .background(AppDesign.Colors.primary.opacity(0.1))
                    .cornerRadius(AppDesign.Radius.small)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            
            ModernCard(gradient: true) {
                VStack(spacing: AppDesign.Spacing.xs) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: AppDesign.Spacing.sm) {
                            Button(action: { 
                                withAnimation(AppDesign.Animation.spring) {
                                    toggleItem(item)
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(item.isChecked ? AppDesign.Colors.success.opacity(0.2) : Color.clear)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(item.isChecked ? AppDesign.Colors.success : AppDesign.Colors.textSecondary)
                                        #if os(iOS)
                                        .symbolEffect(.bounce, value: item.isChecked)
                                        #endif
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(AppDesign.Typography.body)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                                    .strikethrough(item.isChecked)
                                
                                if !item.meals.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "fork.knife")
                                            .font(.system(size: 10))
                                            .foregroundColor(AppDesign.Colors.accent)
                                        Text("Used in: \(item.meals.joined(separator: ", "))")
                                            .font(AppDesign.Typography.caption)
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(String(format: "%.1f", item.quantity)) \(item.unit)")
                                    .font(AppDesign.Typography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppDesign.Colors.textPrimary)
                                Text("$\(String(format: "%.2f", item.estimatedCost))")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.success)
                            }
                        }
                        .padding(.vertical, AppDesign.Spacing.xs)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        
                        if index < items.count - 1 {
                            Divider()
                                .background(AppDesign.Colors.textSecondary.opacity(0.2))
                        }
                    }
                }
                .padding(AppDesign.Spacing.md)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
        }
    }
    
    private func toggleItem(_ item: GroceryItem) {
        guard var list = groceryList,
              let index = list.items.firstIndex(where: { $0.id == item.id }) else { return }
        list.items[index].isChecked.toggle()
        groceryList = list
    }
}
