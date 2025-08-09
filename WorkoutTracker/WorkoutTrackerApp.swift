import SwiftUI

@main
struct WorkoutTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // This is the line to change
            MainView() // Changed from ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
