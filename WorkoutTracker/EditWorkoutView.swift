import SwiftUI

struct EditWorkoutView: View {
    // This allows us to close the sheet after saving.
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    // The workout object passed in from the detail view.
    let workout: Workout
    
    // A pre-defined list of exercises, same as the creation view.
    let exercises: [String] = [
        "Squat", "Bench Press", "Deadlift", "Overhead Press",
        "Barbell Row", "Leg Press", "Bicep Curl", "Tricep Extension",
        "Lat Pulldown", "Dumbbell Flyes", "Leg Curl", "Calf Raise",
        "Shoulder Press", "Pull Up", "Push Up"
    ].sorted()

    // State variables to hold the edited values.
    @State private var selectedExercise: String = ""
    @State private var reps: String = ""
    @State private var weight: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Your Set")) {
                    Picker("Exercise", selection: $selectedExercise) {
                        ForEach(exercises, id: \.self) {
                            Text($0)
                        }
                    }

                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                    TextField("Weight (kg/lbs)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Button(action: updateWorkout) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(reps.isEmpty || weight.isEmpty)
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss() // Add a cancel button
            })
            .onAppear(perform: loadWorkoutData)
        }
    }

    // Pre-fill the form with the existing workout data.
    private func loadWorkoutData() {
        // We edit the first exercise associated with the workout.
        if let exercise = workout.exercises?.anyObject() as? Exercise {
            self.selectedExercise = exercise.name ?? ""
            self.reps = String(exercise.reps)
            self.weight = String(exercise.weight)
        }
    }

    private func updateWorkout() {
        // Update the properties of the existing workout and its exercise.
        workout.name = selectedExercise
        
        if let exercise = workout.exercises?.anyObject() as? Exercise {
            exercise.name = selectedExercise
            exercise.reps = Int16(reps) ?? 0
            exercise.weight = Double(weight) ?? 0.0
        }

        do {
            try viewContext.save()
            print("Workout updated successfully!")
            dismiss() // Close the sheet.
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
