//
//  PlanningSessionView.swift
//  HealthAndWellnessLifestyleSolver
//
//  Copyright (C) Shyamal Chandra, 2025 (No MIT License)
//

import SwiftUI // Import SwiftUI framework for user interface components and declarative syntax

struct PlanningSessionView: View { // Define PlanningSessionView struct conforming to View protocol
    @ObservedObject var viewModel: DietSolverViewModel // Observed object for view model
    @State private var selectedDate = Date() // State variable for selected date
    
    var body: some View { // Define body property returning view hierarchy
        VStack(spacing: 0) { // Create vertical stack
            // Custom Header
            HStack {
                Text("Planning Session")
                    .font(AppDesign.Typography.title)
                    .fontWeight(.bold)
                    .padding(.leading, AppDesign.Spacing.md)
                Spacer()
            }
            .padding(.vertical, AppDesign.Spacing.sm)
            .background(AppDesign.Colors.surface)
            
            VStack(spacing: 20) { // Create vertical stack with spacing
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date) // Create date picker for date selection
                    .padding() // Add padding around date picker
                
                if let session = viewModel.currentPlanningSession { // Check if planning session exists
                    ScrollView { // Create scrollable view
                        VStack(alignment: .leading, spacing: 16) { // Create vertical stack with leading alignment
                            // Session Header
                            VStack(alignment: .leading, spacing: 8) { // Create vertical stack for header
                                Text(session.sessionType.rawValue) // Display session type
                                    .font(.title) // Set title font
                                    .bold() // Make text bold
                                Text(session.date, style: .date) // Display session date
                                    .font(.subheadline) // Set subheadline font
                                    .foregroundColor(AppDesign.Colors.textSecondary) // Set secondary color
                            }
                            .padding() // Add padding around header
                            
                            // Tasks Section
                            if !session.tasks.isEmpty { // Check if tasks exist
                                Section(header: Text("Tasks").font(.headline)) { // Create section with header
                                    ForEach(session.tasks) { task in // Loop through tasks
                                        TaskRowView(task: task) // Display task row
                                    }
                                }
                                .padding(.horizontal) // Add horizontal padding
                            }
                            
                            // Reflections Section
                            if !session.reflections.isEmpty { // Check if reflections exist
                                Section(header: Text("Reflections").font(.headline)) { // Create section with header
                                    ForEach(session.reflections) { reflection in // Loop through reflections
                                        ReflectionRowView(reflection: reflection) // Display reflection row
                                    }
                                }
                                .padding(.horizontal) // Add horizontal padding
                            }
                            
                            // Goals Section
                            if !session.goals.isEmpty { // Check if goals exist
                                Section(header: Text("Goals").font(.headline)) { // Create section with header
                                    ForEach(session.goals) { goal in // Loop through goals
                                        GoalRowView(goal: goal) // Display goal row
                                    }
                                }
                                .padding(.horizontal) // Add horizontal padding
                            }
                            
                            // Priorities Section
                            if !session.priorities.isEmpty { // Check if priorities exist
                                Section(header: Text("Priorities").font(.headline)) { // Create section with header
                                    ForEach(session.priorities) { priority in // Loop through priorities
                                        PriorityRowView(priority: priority) // Display priority row
                                    }
                                }
                                .padding(.horizontal) // Add horizontal padding
                            }
                            
                            // Notes Section
                            if let notes = session.notes { // Check if notes exist
                                VStack(alignment: .leading, spacing: 8) { // Create vertical stack for notes
                                    Text("Notes") // Display notes label
                                        .font(.headline) // Set headline font
                                    Text(notes) // Display notes text
                                        .font(.body) // Set body font
                                }
                                .padding() // Add padding around notes
                            }
                            
                            // Calendar Schedule Button
                            if !viewModel.calendarScheduleItems.isEmpty { // Check if schedule items exist
                                Button(action: { // Create button action
                                    Task { // Create async task
                                        do { // Try to schedule
                                            try await viewModel.scheduleDayInCalendar() // Schedule day in calendar
                                        } catch { // Catch errors
                                            print("Error scheduling: \(error)") // Print error
                                        }
                                    }
                                }) { // Button label
                                    HStack { // Create horizontal stack
                                        Image(systemName: "calendar") // Display calendar icon
                                        Text("Add to Calendar") // Display button text
                                    }
                                    .frame(maxWidth: .infinity) // Set frame to fill width
                                    .padding() // Add padding
                                    .background(Color.blue) // Set blue background
                                    .foregroundColor(.white) // Set white text color
                                    .cornerRadius(10) // Set corner radius
                                }
                                .padding() // Add padding around button
                            }
                        }
                    }
                } else { // If no session
                    VStack(spacing: 16) { // Create vertical stack
                        Text("No planning session generated") // Display message
                            .foregroundColor(AppDesign.Colors.textSecondary) // Set secondary color
                        Text("Select a planning type below") // Display instruction
                            .font(.subheadline) // Set subheadline font
                            .foregroundColor(AppDesign.Colors.textSecondary) // Set secondary color
                    }
                    .padding() // Add padding
                }
                
                // Planning Type Buttons
                VStack(spacing: 12) { // Create vertical stack for buttons
                    HStack(spacing: 12) { // Create horizontal stack
                        PlanningButton(title: "Day Start", action: { viewModel.generateDayStartPlan(for: selectedDate) }) // Day start button
                        PlanningButton(title: "Day End", action: { viewModel.generateDayEndPlan(for: selectedDate) }) // Day end button
                    }
                    HStack(spacing: 12) { // Create horizontal stack
                        PlanningButton(title: "Week Start", action: { viewModel.generateWeekStartPlan(for: selectedDate) }) // Week start button
                        PlanningButton(title: "Week End", action: { viewModel.generateWeekEndPlan(for: selectedDate) }) // Week end button
                    }
                    HStack(spacing: 12) { // Create horizontal stack
                        PlanningButton(title: "Month Start", action: { viewModel.generateMonthStartPlan(for: selectedDate) }) // Month start button
                        PlanningButton(title: "Month End", action: { viewModel.generateMonthEndPlan(for: selectedDate) }) // Month end button
                    }
                }
                .padding() // Add padding around buttons
            }
            .onAppear { // When view appears
                Task { // Create async task
                    await viewModel.requestCalendarAccess() // Request calendar access
                }
            }
        }
    }
}

struct TaskRowView: View { // Define TaskRowView struct for displaying tasks
    let task: TimeBasedPlanningSession.PlanningTask // Task to display
    
    var body: some View { // Define body property
        HStack { // Create horizontal stack
            VStack(alignment: .leading, spacing: 4) { // Create vertical stack with leading alignment
                Text(task.title) // Display task title
                    .font(.headline) // Set headline font
                    .foregroundColor(AppDesign.Colors.textPrimary)
                if let description = task.description { // Check if description exists
                    Text(description) // Display description
                        .font(.caption) // Set caption font
                        .foregroundColor(AppDesign.Colors.textSecondary) // Set secondary color
                }
                HStack { // Create horizontal stack
                    Text(task.category.rawValue) // Display category
                        .font(.caption) // Set caption font
                        .padding(.horizontal, 8) // Add horizontal padding
                        .padding(.vertical, 4) // Add vertical padding
                        .background(Color.blue.opacity(0.2)) // Set background color
                        .cornerRadius(8) // Set corner radius
                    Text(task.priority.rawValue) // Display priority
                        .font(.caption) // Set caption font
                        .padding(.horizontal, 8) // Add horizontal padding
                        .padding(.vertical, 4) // Add vertical padding
                        .background(task.priority == .urgent ? Color.red.opacity(0.2) : Color.gray.opacity(0.2)) // Set background color
                        .cornerRadius(8) // Set corner radius
                    if let duration = task.estimatedDuration { // Check if duration exists
                        Text("\(Int(duration)) min") // Display duration
                            .font(.caption) // Set caption font
                            .foregroundColor(AppDesign.Colors.textSecondary) // Set secondary color
                    }
                }
            }
            Spacer() // Add spacer
            if task.isCompleted { // Check if task completed
                Image(systemName: "checkmark.circle.fill") // Display checkmark icon
                    .foregroundColor(.green) // Set green color
            }
        }
        .padding() // Add padding
        .background(Color.gray.opacity(0.1)) // Set background color
        .cornerRadius(10) // Set corner radius
    }
}

struct ReflectionRowView: View { // Define ReflectionRowView struct for displaying reflections
    let reflection: TimeBasedPlanningSession.Reflection // Reflection to display
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: 8) { // Create vertical stack with leading alignment
            Text(reflection.category.rawValue) // Display category
                .font(.headline) // Set headline font
                .foregroundColor(AppDesign.Colors.textPrimary)
            Text(reflection.content) // Display content
                .font(.body) // Set body font
                .foregroundColor(AppDesign.Colors.textPrimary)
            if !reflection.insights.isEmpty { // Check if insights exist
                VStack(alignment: .leading, spacing: 4) { // Create vertical stack for insights
                    Text("Insights:") // Display insights label
                        .font(.subheadline) // Set subheadline font
                        .bold() // Make text bold
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    ForEach(reflection.insights, id: \.self) { insight in // Loop through insights
                        Text("• \(insight)") // Display insight
                            .font(.caption) // Set caption font
                            .foregroundColor(AppDesign.Colors.textPrimary)
                    }
                }
            }
        }
        .padding() // Add padding
        .background(Color.gray.opacity(0.1)) // Set background color
        .cornerRadius(10) // Set corner radius
    }
}

struct GoalRowView: View { // Define GoalRowView struct for displaying goals
    let goal: TimeBasedPlanningSession.Goal // Goal to display
    
    var body: some View { // Define body property
        VStack(alignment: .leading, spacing: 8) { // Create vertical stack with leading alignment
            Text(goal.title) // Display goal title
                .font(.headline) // Set headline font
            if let description = goal.description { // Check if description exists
                Text(description) // Display description
                    .font(.body) // Set body font
            }
            ProgressView(value: goal.progress, total: 100) // Display progress bar
            Text("\(Int(goal.progress))% Complete") // Display progress percentage
                .font(.caption) // Set caption font
                .foregroundColor(.secondary) // Set secondary color
        }
        .padding() // Add padding
        .background(Color.gray.opacity(0.1)) // Set background color
        .cornerRadius(10) // Set corner radius
    }
}

struct PriorityRowView: View { // Define PriorityRowView struct for displaying priorities
    let priority: TimeBasedPlanningSession.Priority // Priority to display
    
    var body: some View { // Define body property
        HStack { // Create horizontal stack
            VStack(alignment: .leading, spacing: 4) { // Create vertical stack with leading alignment
                Text(priority.title) // Display priority title
                    .font(.headline) // Set headline font
                if let description = priority.description { // Check if description exists
                    Text(description) // Display description
                        .font(.caption) // Set caption font
                        .foregroundColor(AppDesign.Colors.textSecondary) // Set secondary color
                }
            }
            Spacer() // Add spacer
            Text(priority.importance.rawValue) // Display importance
                .font(.caption) // Set caption font
                .padding(.horizontal, 8) // Add horizontal padding
                .padding(.vertical, 4) // Add vertical padding
                .background(priority.importance == .critical ? Color.red.opacity(0.2) : Color.orange.opacity(0.2)) // Set background color
                .cornerRadius(8) // Set corner radius
        }
        .padding() // Add padding
        .background(Color.gray.opacity(0.1)) // Set background color
        .cornerRadius(10) // Set corner radius
    }
}

struct PlanningButton: View { // Define PlanningButton struct for planning buttons
    let title: String // Button title
    let action: () -> Void // Button action
    
    var body: some View { // Define body property
        Button(action: action) { // Create button with action
            Text(title) // Display button title
                .frame(maxWidth: .infinity) // Set frame to fill width
                .padding() // Add padding
                .background(Color.blue.opacity(0.1)) // Set background color
                .foregroundColor(.blue) // Set blue text color
                .cornerRadius(10) // Set corner radius
        }
    }
}
