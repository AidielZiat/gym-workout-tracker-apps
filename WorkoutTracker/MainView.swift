import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            CreateWorkoutView()
                .tabItem {
                    Label("Log Workout", systemImage: "plus.circle.fill")
                }
            
            WorkoutListView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            // The final piece is in place!
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
