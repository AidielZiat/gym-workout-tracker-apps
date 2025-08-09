import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Helper function to reduce repeated code.
        func createSampleExercise(name: String, date: Date, weight: Double, context: NSManagedObjectContext) {
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.name = name
            workout.date = date

            let exercise = Exercise(context: context)
            exercise.id = UUID()
            exercise.name = name
            exercise.date = date
            exercise.reps = 5
            exercise.weight = weight
            exercise.workout = workout
        }
        
        // Now we can safely use the function
        let calendar = Calendar.current
        let today = Date()

        // Create sample data for "Squat"
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -(i * 7), to: today)! // Data points a week apart
            // --- CORRECTED ---
            createSampleExercise(name: "Squat", date: date, weight: 80.0 + (Double(i) * 5), context: viewContext)
        }

        // Create sample data for "Bench Press"
        for i in 0..<4 {
            let date = calendar.date(byAdding: .day, value: -(i * 7 + 2), to: today)! // Stagger the dates
            // --- CORRECTED ---
            createSampleExercise(name: "Bench Press", date: date, weight: 60.0 + (Double(i) * 2.5), context: viewContext)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WorkoutTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
