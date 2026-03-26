import SwiftUI

struct MainTabView: View {
    @Environment(LessonAudioPlayerService.self) private var lessonAudioPlayer

    @State private var selectedTab = "home"
    @State private var lessonsNavigationPath = NavigationPath()

    var body: some View {
        Group {
            if #available(iOS 26.1, *) {
                tabViewContent
                    .tabViewBottomAccessory(isEnabled: lessonAudioPlayer.isMiniPlayerVisible) {
                        LessonAudioMiniPlayer(onNavigateToLesson: navigateToCurrentLesson)
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                            .padding(.bottom, 6)
                    }
            } else {
                tabViewContent
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if lessonAudioPlayer.isMiniPlayerVisible {
                            Color.clear.frame(height: 86)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if lessonAudioPlayer.isMiniPlayerVisible {
                            LessonAudioMiniPlayer(onNavigateToLesson: navigateToCurrentLesson)
                                .padding(.horizontal, 12)
                                .padding(.bottom, 58)
                        }
                    }
            }
        }
    }

    private var tabViewContent: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: "home") {
                NavigationStack {
                    HomeView()
                }
            }

            Tab("Lessons", systemImage: "book", value: "lessons") {
                LessonsListView(navigationPath: $lessonsNavigationPath)
            }

            Tab("Practice", systemImage: "puzzlepiece", value: "practice") {
                NavigationStack {
                    ExerciseListView()
                }
            }

            Tab("Interview", systemImage: "person.fill.questionmark", value: "interview") {
                InterviewQuestionsListView()
            }

            Tab("Profile", systemImage: "person", value: "profile") {
                ProfileView()
            }
        }
        .tint(AppTheme.accent)
    }

    private func navigateToCurrentLesson() {
        guard let lesson = lessonAudioPlayer.currentLesson else { return }

        // If already on the lessons tab viewing this lesson, just scroll to active section
        if selectedTab == "lessons", isShowingLesson(lesson) {
            lessonAudioPlayer.requestScrollToActiveSection()
            return
        }

        selectedTab = "lessons"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            lessonsNavigationPath = NavigationPath()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                lessonsNavigationPath.append(LessonScrollTarget(lesson: lesson))
            }
        }
    }

    private func isShowingLesson(_ lesson: Lesson) -> Bool {
        // Check if the navigation path contains a LessonScrollTarget or Lesson for this lesson
        // NavigationPath doesn't expose its elements, so track via a simple flag
        !lessonsNavigationPath.isEmpty
    }
}

#Preview {
    MainTabView()
        .environment(LessonAudioPlayerService())
}
