import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    HomeView()
                }
            }

            Tab("Lessons", systemImage: "book") {
                LessonsListView()
            }

            Tab("Practice", systemImage: "puzzlepiece") {
                NavigationStack {
                    ExerciseListView()
                }
            }

            Tab("Interview", systemImage: "person.fill.questionmark") {
                InterviewQuestionsListView()
            }

            Tab("Profile", systemImage: "person") {
                ProfileView()
            }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    MainTabView()
}
