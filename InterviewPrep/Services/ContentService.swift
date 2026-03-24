import Foundation

@Observable
final class ContentService {
    private(set) var lessons: [Lesson] = []
    private(set) var exercises: [Exercise] = []
    private(set) var interviewQuestions: [InterviewQuestion] = []
    private(set) var isLoaded = false

    func loadContent() {
        guard !isLoaded else { return }

        if let url = Bundle.main.url(forResource: "content", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let bundle = try JSONDecoder().decode(ContentBundle.self, from: data)
                self.lessons = bundle.lessons
                self.exercises = bundle.exercises
                self.interviewQuestions = bundle.interviewQuestions
                self.isLoaded = true
            } catch {
                print("Failed to load content: \(error)")
                loadFallbackContent()
            }
        } else {
            loadFallbackContent()
        }
    }

    func lessons(for track: Track, topic: String? = nil) -> [Lesson] {
        lessons.filter { lesson in
            lesson.track == track &&
            (topic == nil || lesson.topic == topic)
        }.sorted { $0.orderIndex < $1.orderIndex }
    }

    func exercises(for track: Track, topic: String? = nil, type: ExerciseType? = nil) -> [Exercise] {
        exercises.filter { exercise in
            exercise.track == track &&
            (topic == nil || exercise.topic == topic) &&
            (type == nil || exercise.type == type)
        }.sorted { $0.orderIndex < $1.orderIndex }
    }

    func interviewQuestions(for track: Track, topic: String? = nil, category: InterviewQuestionCategory? = nil) -> [InterviewQuestion] {
        interviewQuestions.filter { question in
            question.track == track &&
            (topic == nil || question.topic == topic) &&
            (category == nil || question.category == category)
        }.sorted { $0.orderIndex < $1.orderIndex }
    }

    func topics(for track: Track) -> [Topic] {
        let trackLessons = lessons.filter { $0.track == track }
        let trackExercises = exercises.filter { $0.track == track }
        let trackQuestions = interviewQuestions.filter { $0.track == track }

        let topicNames = Array(Set(trackLessons.map(\.topic) + trackExercises.map(\.topic) + trackQuestions.map(\.topic)))
            .sorted { lhs, rhs in
                compareTopics(
                    lhsTopic: lhs,
                    lhsTrack: track,
                    rhsTopic: rhs,
                    rhsTrack: track,
                    selectedTrack: track
                )
            }

        return topicNames.map { topicName in
            Topic(
                id: "\(track.rawValue)_\(topicName)",
                name: displayName(for: topicName),
                icon: iconForTopic(topicName),
                track: track,
                lessonCount: trackLessons.filter { $0.topic == topicName }.count,
                exerciseCount: trackExercises.filter { $0.topic == topicName }.count,
                questionCount: trackQuestions.filter { $0.topic == topicName }.count
            )
        }
    }

    func randomExercise(for track: Track) -> Exercise? {
        let trackExercises = exercises.filter { $0.track == track }
        return trackExercises.randomElement()
    }

    func randomQuestion(for track: Track) -> InterviewQuestion? {
        let trackQuestions = interviewQuestions.filter { $0.track == track }
        return trackQuestions.randomElement()
    }

    func compareTopics(
        lhsTopic: String,
        lhsTrack: Track,
        rhsTopic: String,
        rhsTrack: Track,
        selectedTrack: Track
    ) -> Bool {
        let lhsTrackRank = trackRank(lhsTrack, selectedTrack: selectedTrack)
        let rhsTrackRank = trackRank(rhsTrack, selectedTrack: selectedTrack)

        if lhsTrackRank != rhsTrackRank {
            return lhsTrackRank < rhsTrackRank
        }

        let lhsTopicRank = topicRank(for: lhsTopic, track: lhsTrack)
        let rhsTopicRank = topicRank(for: rhsTopic, track: rhsTrack)

        if lhsTopicRank != rhsTopicRank {
            return lhsTopicRank < rhsTopicRank
        }

        return displayName(for: lhsTopic).localizedStandardCompare(displayName(for: rhsTopic)) == .orderedAscending
    }

    private func iconForTopic(_ topic: String) -> String {
        let topicIcons: [String: String] = [
            "dart_basics": "d.circle",
            "widgets": "square.on.square",
            "layouts": "rectangle.3.group",
            "state_management": "arrow.triangle.2.circlepath",
            "navigation": "arrow.right.arrow.left",
            "networking": "network",
            "local_storage": "externaldrive",
            "animations": "wand.and.stars",
            "testing": "checkmark.shield",
            "swift_basics": "swift",
            "swiftui": "paintbrush",
            "uikit": "uiwindow.split.2x1",
            "data_flow": "arrow.triangle.branch",
            "concurrency": "arrow.2.squarepath",
            "persistence": "cylinder",
            "architecture": "building.2",
            "oop": "cube.transparent",
            "design_patterns": "puzzlepiece",
            "data_structures": "list.bullet.rectangle",
            "rest_api": "cloud",
            "git": "arrow.triangle.branch",
            "security": "lock.shield",
            "databases": "tablecells",
            "system_design": "cpu",
            "clean_code": "sparkles",
            "accessibility": "accessibility",
        ]
        if let icon = topicIcons[topic] {
            return icon
        }

        if topic.contains("navigation") { return "arrow.left.arrow.right" }
        if topic.contains("state") || topic.contains("observation") { return "arrow.triangle.2.circlepath" }
        if topic.contains("network") || topic.contains("api") || topic.contains("graphql") || topic.contains("websocket") { return "network" }
        if topic.contains("storage") || topic.contains("data") || topic.contains("database") || topic.contains("swiftdata") || topic.contains("core_data") { return "externaldrive" }
        if topic.contains("test") { return "checkmark.shield" }
        if topic.contains("perform") { return "speedometer" }
        if topic.contains("security") || topic.contains("auth") || topic.contains("keychain") { return "lock.shield" }
        if topic.contains("accessibility") { return "accessibility" }
        if topic.contains("animation") || topic.contains("transition") { return "sparkles" }
        if topic.contains("gesture") { return "hand.tap" }
        if topic.contains("layout") || topic.contains("grid") || topic.contains("sliver") { return "square.grid.2x2" }
        if topic.contains("design") || topic.contains("pattern") || topic.contains("architecture") { return "puzzlepiece" }
        if topic.contains("git") || topic.contains("ci_cd") || topic.contains("publish") || topic.contains("app_store") || topic.contains("flavor") { return "hammer" }
        if topic.contains("localization") || topic.contains("internationalization") { return "globe" }
        if topic.contains("concurrency") || topic.contains("async") || topic.contains("isolate") { return "arrow.2.squarepath" }
        if topic.contains("memory") { return "memorychip" }
        if topic.contains("widget") || topic.contains("view") { return "square.on.square" }
        if topic.contains("algorithm") || topic.contains("data_structure") { return "list.bullet.rectangle" }

        return "book"
    }

    private func loadFallbackContent() {
        self.lessons = Self.sampleLessons
        self.exercises = Self.sampleExercises
        self.interviewQuestions = Self.sampleInterviewQuestions
        self.isLoaded = true
    }

    private func displayName(for topic: String) -> String {
        topic.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func trackRank(_ track: Track, selectedTrack: Track) -> Int {
        switch track {
        case selectedTrack:
            return 0
        case .general:
            return 1
        default:
            return 2
        }
    }

    private func topicRank(for topic: String, track: Track) -> Int {
        Self.topicPriorityByTrack[track]?[topic] ?? Self.unknownTopicRank
    }

    private static func priorityMap(for topics: [String]) -> [String: Int] {
        Dictionary(uniqueKeysWithValues: topics.enumerated().map { ($0.element, $0.offset) })
    }

    private static let unknownTopicRank = 10_000

    private static let topicPriorityByTrack: [Track: [String: Int]] = [
        .flutter: priorityMap(for: [
            "variables_constants_type_system",
            "null_safety",
            "functions",
            "control_flow",
            "collections",
            "oop_in_dart",
            "async_programming",
            "error_handling",
            "generics_type_system",
            "widget_tree_element_tree_renderobject_tree",
            "statelesswidget_vs_statefulwidget_lifecycle",
            "buildcontext",
            "layouts",
            "responsive_design",
            "forms_input",
            "state_management",
            "navigation",
            "networking",
            "local_storage",
            "dependency_injection",
            "architecture_patterns",
            "testing",
            "performance",
            "theming",
            "animations",
            "keys",
            "slivers",
            "isolates_concurrency",
            "firebase_integration",
            "platform_channels",
            "internationalization",
            "accessibility",
            "custom_painting",
            "dart_3_features",
            "flavors_environment_configuration",
            "ci_cd",
            "publishing",
        ]),
        .swift: priorityMap(for: [
            "variables_constants_type_inference",
            "optionals",
            "functions_closures",
            "control_flow",
            "collections",
            "oop",
            "value_types_vs_reference_types",
            "error_handling",
            "generics_associated_types",
            "concurrency",
            "memory_management",
            "property_wrappers",
            "view_protocol_view_lifecycle",
            "modifiers",
            "layout_system",
            "lists_grids",
            "forms_user_input",
            "state_management",
            "observation_framework",
            "data_flow_architecture",
            "navigation",
            "sheets_alerts_confirmations_popovers",
            "gestures",
            "animations_transitions",
            "networking",
            "combine",
            "swiftdata",
            "core_data",
            "app_architecture",
            "testing",
            "performance",
            "keychain_security",
            "accessibility",
            "localization",
            "drawing",
            "uikit_interop",
            "widgetkit",
            "push_notifications",
            "app_intents_shortcuts",
            "opaque_types_some_keyword",
            "macros",
            "swift_5_9_features",
            "ci_cd",
            "app_store",
        ]),
        .general: priorityMap(for: [
            "oop_principles",
            "solid_principles",
            "clean_code",
            "code_quality",
            "design_patterns",
            "data_structures",
            "algorithms",
            "networking_fundamentals",
            "rest_api",
            "authentication_authorization",
            "databases",
            "caching_strategies",
            "security",
            "system_design_basics",
            "git",
            "dependency_management",
            "websocket",
            "graphql",
            "app_performance",
            "accessibility",
            "internationalization_localization",
            "ci_cd_concepts",
            "agile_scrum",
        ]),
    ]
}
