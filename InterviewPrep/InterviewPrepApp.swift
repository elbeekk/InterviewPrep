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
    @State private var trackSelection = TrackSelectionStore()
    @State private var lessonAudioPlayer = LessonAudioPlayerService()

    init() {
        Self.resetOnboardingIfFreshInstall()
        ReminderNotificationService.configure()
    }

    /// UserDefaults can survive app deletion via iCloud key-value sync.
    /// Detect a truly fresh install by checking for a local-only sentinel file
    /// inside the app container (which IS deleted with the app).
    private static func resetOnboardingIfFreshInstall() {
        let sentinelURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("onboarding_sentinel")

        if FileManager.default.fileExists(atPath: sentinelURL.path) {
            return // Not a fresh install
        }

        // Fresh install — clear any stale onboarding flag from iCloud-synced defaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

        // Create the sentinel so future launches skip this reset
        try? FileManager.default.createDirectory(
            at: sentinelURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        FileManager.default.createFile(atPath: sentinelURL.path, contents: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(contentService)
                .environment(trackSelection)
                .environment(lessonAudioPlayer)
                .task {
                    contentService.loadContent()
                }
                .tint(AppTheme.accent)
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

@MainActor
@Observable
final class TrackSelectionStore {
    private let defaults: UserDefaults
    private let storageKey = "selectedTrack"

    private(set) var selectedTrack: Track

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.selectedTrack = Track(rawValue: defaults.string(forKey: storageKey) ?? "") ?? .swift
    }

    func switchTo(_ track: Track) {
        guard track != selectedTrack else { return }
        selectedTrack = track
        defaults.set(track.rawValue, forKey: storageKey)
    }
}
