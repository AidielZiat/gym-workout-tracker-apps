import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // An enum to define our focusable fields
    private enum Field: Hashable {
        case reps, weight
    }
    
    // Use our centralized, grouped exercise data
    let groups = ExerciseData.groupNames
    
    @State private var selectedExercise: String = "Lat Pulldown" // A default value
    @State private var reps: String = ""
    @State private var weight: String = ""
    
    // --- CHANGE: A state variable to track which field is focused ---
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Your Set")) {
                    Picker("Exercise", selection: $selectedExercise) {
                        ForEach(groups, id: \.self) { group in
                            Section(header: Text(group)) {
                                ForEach(ExerciseData.exercisesByGroup[group]!, id: \.self) { exercise in
                                    Text(exercise).tag(exercise)
                                }
                            }
                        }
                    }

                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                        // --- CHANGE: Bind the focus state ---
                        .focused($focusedField, equals: .reps)
                    
                    TextField("Weight (kg/lbs)", text: $weight)
                        .keyboardType(.decimalPad)
                        // --- CHANGE: Bind the focus state ---
                        .focused($focusedField, equals: .weight)
                }
                
                Button(action: saveWorkout) {
                    Text("Save Set")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(reps.isEmpty || weight.isEmpty)
            }
            .navigationTitle("Log New Workout")
            // --- NEW: Add a toolbar with a "Done" button for the keyboard ---
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // Pushes the button to the right
                    Button("Done") {
                        focusedField = nil // This dismisses the keyboard
                    }
                }
            }
        }
    }

    private func saveWorkout() {
        let newWorkout = Workout(context: viewContext)
        let workoutDate = Date()
        
        newWorkout.id = UUID()
        newWorkout.name = selectedExercise
        newWorkout.date = workoutDate

        let newExercise = Exercise(context: viewContext)
        newExercise.id = UUID()
        newExercise.name = selectedExercise
        newExercise.reps = Int16(reps) ?? 0
        newExercise.weight = Double(weight) ?? 0.0
        newExercise.date = workoutDate
        
        newWorkout.addToExercises(newExercise)

        do {
            try viewContext.save()
            
            // --- CHANGE: Dismiss keyboard by clearing focus ---
            focusedField = nil
            
            reps = ""
            weight = ""
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
