import Foundation
import CoreData
import SwiftUI

// --- THE MISSING STRUCT DEFINITIONS ---
// These need to be here, outside the class.

// A struct to hold a single data point for our chart.
struct DatedWeight: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let weight: Double
    let name: String
}

// A custom, hashable struct to use as our dictionary key.
struct DailyExerciseKey: Hashable {
    let startOfDay: Date
    let exerciseName: String
}


// --- THE REST OF THE VIEWMODEL ---
@MainActor
class ProgressViewModel: ObservableObject {
    
    // STATE FOR NEW FILTERS
    @Published var selectedGroup: String = "Chest"
    @Published var selectedExercise: String = "All"
    @Published var availableExercises: [String] = []
    
    @Published var chartData: [DatedWeight] = []
    // --- REMOVED ---
    // The following property is no longer needed.
    // @Published var latestDataPoint: DatedWeight? = nil
    
    private var allExercises: [String: [Exercise]] = [:]

    func fetchData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.date, ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            allExercises = Dictionary(grouping: results, by: { $0.name ?? "Unnamed" })
            groupDidChange()
        } catch {
            print("Failed to fetch exercises for chart: \(error)")
        }
    }
    
    func groupDidChange() {
        availableExercises = ["All"] + (ExerciseData.exercisesByGroup[selectedGroup] ?? [])
        selectedExercise = "All"
        updateChart()
    }

    func updateChart() {
        var exercisesToProcess: [Exercise] = []
        let exercisesInGroup = ExerciseData.exercisesByGroup[selectedGroup] ?? []

        if selectedExercise == "All" {
            exercisesToProcess = allExercises.filter { exercisesInGroup.contains($0.key) }.flatMap { $0.value }
        } else {
            exercisesToProcess = allExercises[selectedExercise] ?? []
        }

        var latestEntryPerDayAndExercise: [DailyExerciseKey: Exercise] = [:]
        for exercise in exercisesToProcess {
            guard let date = exercise.date, let name = exercise.name else { continue }
            let startOfDay = Calendar.current.startOfDay(for: date)
            let key = DailyExerciseKey(startOfDay: startOfDay, exerciseName: name)
            
            if let existingEntry = latestEntryPerDayAndExercise[key], date > (existingEntry.date ?? date) {
                latestEntryPerDayAndExercise[key] = exercise
            } else if latestEntryPerDayAndExercise[key] == nil {
                latestEntryPerDayAndExercise[key] = exercise
            }
        }
        
        self.chartData = latestEntryPerDayAndExercise.values
            .compactMap { DatedWeight(date: $0.date!, weight: $0.weight, name: $0.name!) }
            .sorted { $0.date < $1.date }
        
        // --- REMOVED ---
        // This line is no longer needed.
        // self.latestDataPoint = self.chartData.last
    }
}
