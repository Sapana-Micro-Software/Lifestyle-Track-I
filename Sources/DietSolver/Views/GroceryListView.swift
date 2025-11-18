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
                    Text("Grocery List Generator")
                        .font(AppDesign.Typography.title)
                        .fontWeight(.bold)
                    
                    Text("Generate shopping lists from your meal plans")
                        .font(AppDesign.Typography.body)
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Generation Controls
                ModernCard {
                    VStack(spacing: AppDesign.Spacing.md) {
                        HStack {
                            Text("Days to include:")
                                .font(AppDesign.Typography.body)
                            Spacer()
                            Picker("", selection: $daysToGenerate) {
                                Text("3 days").tag(3)
                                Text("7 days").tag(7)
                                Text("14 days").tag(14)
                                Text("30 days").tag(30)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Button(action: generateGroceryList) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "cart.fill")
                                    Text("Generate Grocery List")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppDesign.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating || viewModel.dailyPlans.isEmpty)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .padding(.horizontal, AppDesign.Spacing.md)
                
                // Grocery List Display
                if let list = groceryList {
                    groceryListContent(list: list)
                } else if !isGenerating {
                    ModernCard {
                        VStack(spacing: AppDesign.Spacing.md) {
                            Image(systemName: "cart")
                                .font(.system(size: 50))
                                .foregroundColor(AppDesign.Colors.textSecondary)
                            Text("No grocery list generated yet")
                                .font(AppDesign.Typography.headline)
                            Text("Generate a list from your meal plans")
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
        .navigationTitle("Grocery List")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
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
        guard !viewModel.dailyPlans.isEmpty else { return }
        
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let list = GroceryListGenerator.shared.generateGroceryList(
                from: viewModel.dailyPlans,
                days: daysToGenerate
            )
            
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
            ModernCard {
                VStack(spacing: AppDesign.Spacing.sm) {
                    HStack {
                        Text("Summary")
                            .font(AppDesign.Typography.headline)
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(list.items.count)")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                            Text("Items")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("$\(String(format: "%.2f", list.totalEstimatedCost))")
                                .font(AppDesign.Typography.title2)
                                .fontWeight(.bold)
                            Text("Estimated Cost")
                                .font(AppDesign.Typography.caption)
                                .foregroundColor(AppDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(AppDesign.Spacing.md)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            
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
                Image(systemName: category.icon)
                    .foregroundColor(AppDesign.Colors.primary)
                Text(category.rawValue)
                    .font(AppDesign.Typography.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(items.count) items")
                    .font(AppDesign.Typography.caption)
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            .padding(.horizontal, AppDesign.Spacing.md)
            
            ModernCard {
                VStack(spacing: AppDesign.Spacing.xs) {
                    ForEach(items) { item in
                        HStack {
                            Button(action: { toggleItem(item) }) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? AppDesign.Colors.success : AppDesign.Colors.textSecondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(AppDesign.Typography.body)
                                    .strikethrough(item.isChecked)
                                
                                if !item.meals.isEmpty {
                                    Text("Used in: \(item.meals.joined(separator: ", "))")
                                        .font(AppDesign.Typography.caption)
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(String(format: "%.1f", item.quantity)) \(item.unit)")
                                    .font(AppDesign.Typography.body)
                                    .fontWeight(.semibold)
                                Text("$\(String(format: "%.2f", item.estimatedCost))")
                                    .font(AppDesign.Typography.caption)
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                        }
                        .padding(.vertical, AppDesign.Spacing.xs)
                        
                        if item.id != items.last?.id {
                            Divider()
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
