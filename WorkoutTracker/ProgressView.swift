import SwiftUI
import Charts

struct ProgressView: View {
    
    @StateObject private var viewModel = ProgressViewModel()
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack {
                // --- TWO-LEVEL FILTER UI ---
                HStack {
                    // Filter 1: Muscle Group
                    Menu {
                        Picker("Select Group", selection: $viewModel.selectedGroup) {
                            ForEach(ExerciseData.groupNames, id: \.self) { group in
                                Text(group).tag(group)
                            }
                        }
                    } label: {
                        FilterButton(title: viewModel.selectedGroup)
                    }
                    
                    // Filter 2: Specific Exercise
                    Menu {
                        Picker("Select Exercise", selection: $viewModel.selectedExercise) {
                            ForEach(viewModel.availableExercises, id: \.self) { exercise in
                                // Use a more descriptive label for the "All" option
                                Text(exercise == "All" ? "All \(viewModel.selectedGroup)" : exercise).tag(exercise)
                            }
                        }
                    } label: {
                        FilterButton(title: viewModel.selectedExercise)
                    }
                }
                .padding(.top)

                if viewModel.chartData.isEmpty {
                    Spacer()
                    Text("No workout data found for this selection.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    // The chart logic
                    Chart(viewModel.chartData) { item in
                        LineMark(x: .value("Date", item.date, unit: .day), y: .value("Weight", item.weight))
                            .foregroundStyle(by: .value("Exercise", item.name))
                        PointMark(x: .value("Date", item.date, unit: .day), y: .value("Weight", item.weight))
                            .foregroundStyle(by: .value("Exercise", item.name))
                            // --- CHANGE IS HERE ---
                            .annotation(position: .top, alignment: .center) {
                                // The "if" condition has been removed to show all labels.
                                Text("\(item.weight, specifier: "%.1f")")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color(.systemGray5).opacity(0.8))
                                    .cornerRadius(4)
                            }
                            // --- END OF CHANGE ---
                    }
                    .chartLegend(position: .top, alignment: .center)
                    .chartXAxis { AxisMarks(values: .automatic(desiredCount: 5)) { AxisGridLine(); AxisTick(); AxisValueLabel(format: .dateTime.month(.abbreviated).day()) } }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.fetchData(context: viewContext) }
            .onChange(of: viewModel.selectedGroup) { viewModel.groupDidChange() }
            .onChange(of: viewModel.selectedExercise) { viewModel.updateChart() }
        }
    }
}

// --- THESE WERE MOVED OUTSIDE ---

// A helper view to make our filter buttons look nice
struct FilterButton: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
            Image(systemName: "chevron.down")
        }
        .font(.headline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
