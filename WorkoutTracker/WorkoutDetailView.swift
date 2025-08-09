import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    let workout: Workout
    
    // State to control the presentation of the edit sheet.
    @State private var isShowingEditSheet = false

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                Text(workout.name ?? "Untitled Workout")
                // Use the main workout date, as it's the primary timestamp.
                Text("Date: \(workout.date ?? Date(), formatter: longDateFormatter)")
            }

            Section(header: Text("Logged Set")) {
                // Since we simplified to one exercise per workout, we can be more direct.
                if let exercise = workout.exercises?.anyObject() as? Exercise {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reps: \(exercise.reps)")
                        Text("Weight: \(exercise.weight, specifier: "%.1f")")
                    }
                } else {
                    Text("No exercise data found.")
                }
            }
        }
        .navigationTitle("Workout Details")
        // --- ADD THE EDIT BUTTON AND SHEET ---
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            // Present our new EditWorkoutView.
            EditWorkoutView(workout: workout)
        }
    }
}

// Helper for formatting the date
private let longDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()
