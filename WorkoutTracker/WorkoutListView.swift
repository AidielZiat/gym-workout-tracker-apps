import SwiftUI
import CoreData

struct WorkoutListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: false)],
        animation: .default)
    private var workouts: FetchedResults<Workout>
    
    // State to hold the URL of the file we want to share.
    @State private var fileToShareURL: URL?
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            List {
                // Find this ForEach loop
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        VStack(alignment: .leading) {
                            Text(workout.name ?? "Untitled Workout")
                                .font(.headline)
                            Text(workout.date ?? Date(), formatter: itemFormatter)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                // --- ADD THIS MODIFIER ---
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Workout History")
            .toolbar {
                // Add an EditButton to enable delete mode
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: generateAndShareCSV) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(item: $fileToShareURL) { url in
                ShareSheet(activityItems: [url])
            }
        }
    }

    // --- NEW, CORRECTED CODE ---
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // 1. Get the specific items to delete from the offsets.
            let itemsToDelete = offsets.map { workouts[$0] }
            
            // 2. Loop through them and mark each one for deletion explicitly.
            for item in itemsToDelete {
                viewContext.delete(item)
            }

            // 3. Save the changes.
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // ... (the rest of the file remains the same) ...
    private func generateAndShareCSV() {
        var csvString = "Date,Exercise,Reps,Weight\n"
        for workout in workouts {
            if let exercise = workout.exercises?.anyObject() as? Exercise {
                let dateString = itemFormatter.string(from: workout.date ?? Date())
                let safeDateString = "\"\(dateString)\""
                let exerciseName = workout.name ?? "N/A"
                let reps = exercise.reps
                let weight = exercise.weight
                csvString.append("\(safeDateString),\(exerciseName),\(reps),\(weight)\n")
            }
        }
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("WorkoutData.csv")
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            self.fileToShareURL = fileURL
        } catch {
            print("Error creating CSV file: \(error)")
        }
    }
}

// Helper struct for the Share Sheet (no changes needed)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


// Date Formatter (no changes needed)
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()

// Add this wrapper to make URL identifiable for the .sheet modifier
extension URL: Identifiable {
    public var id: String {
        return self.absoluteString
    }
}


struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
