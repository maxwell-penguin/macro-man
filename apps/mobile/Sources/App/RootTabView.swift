import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem { Label("Camera", systemImage: "camera") }
            DiaryView()
                .tabItem { Label("Diary", systemImage: "book") }
            ExerciseView()
                .tabItem { Label("Exercise", systemImage: "figure.run") }
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
