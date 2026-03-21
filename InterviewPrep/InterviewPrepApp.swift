import SwiftUI
import SwiftData

@main
struct InterviewOSApp: App {
    @AppStorage("colorScheme") private var selectedColorScheme: String = "system"

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self,
            ExerciseProgress.self,
            Bookmark.self,
            DailyStreak.self,
            Achievement.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var contentService = ContentService()

    init() {
        ReminderNotificationService.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(contentService)
                .task {
                    contentService.loadContent()
                }
                .preferredColorScheme(colorSchemeValue)
        }
        .modelContainer(sharedModelContainer)
    }

    private var colorSchemeValue: ColorScheme? {
        switch selectedColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @State private var progressService: ProgressService?

    var body: some View {
        Group {
            if let progressService {
                Group {
                    if hasCompletedOnboarding {
                        MainTabView()
                    } else {
                        OnboardingContainerView()
                    }
                }
                .environment(progressService)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if progressService == nil {
                progressService = ProgressService(modelContext: modelContext)
            }
        }
    }
}
