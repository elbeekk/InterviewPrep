import Foundation

@Observable
final class ContentService {
    private struct TrackTopicKey: Hashable {
        let track: Track
        let topic: String
    }

    private struct TrackExerciseTypeKey: Hashable {
        let track: Track
        let type: ExerciseType
    }

    private struct TrackQuestionCategoryKey: Hashable {
        let track: Track
        let category: InterviewQuestionCategory
    }

    private(set) var lessons: [Lesson] = []
    private(set) var exercises: [Exercise] = []
    private(set) var interviewQuestions: [InterviewQuestion] = []
    private(set) var isLoaded = false

    private var lessonsByTrack: [Track: [Lesson]] = [:]
    private var lessonsByTrackTopic: [TrackTopicKey: [Lesson]] = [:]
    private var exercisesByTrack: [Track: [Exercise]] = [:]
    private var exercisesByTrackTopic: [TrackTopicKey: [Exercise]] = [:]
    private var exercisesByTrackType: [TrackExerciseTypeKey: [Exercise]] = [:]
    private var questionsByTrack: [Track: [InterviewQuestion]] = [:]
    private var questionsByTrackTopic: [TrackTopicKey: [InterviewQuestion]] = [:]
    private var questionsByTrackCategory: [TrackQuestionCategoryKey: [InterviewQuestion]] = [:]
    private var topicsByTrack: [Track: [Topic]] = [:]

    func loadContent() {
        guard !isLoaded else { return }

        if let url = Bundle.main.url(forResource: "content", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let bundle = try JSONDecoder().decode(ContentBundle.self, from: data)
                self.lessons = bundle.lessons
                self.exercises = bundle.exercises
                self.interviewQuestions = bundle.interviewQuestions
                rebuildIndexes()
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
        if let topic {
            return lessonsByTrackTopic[TrackTopicKey(track: track, topic: topic)] ?? []
        }
        return lessonsByTrack[track] ?? []
    }

    func exercises(for track: Track, topic: String? = nil, type: ExerciseType? = nil) -> [Exercise] {
        switch (topic, type) {
        case let (.some(topic), .some(type)):
            return (exercisesByTrackTopic[TrackTopicKey(track: track, topic: topic)] ?? [])
                .filter { $0.type == type }
        case let (.some(topic), .none):
            return exercisesByTrackTopic[TrackTopicKey(track: track, topic: topic)] ?? []
        case let (.none, .some(type)):
            return exercisesByTrackType[TrackExerciseTypeKey(track: track, type: type)] ?? []
        case (.none, .none):
            return exercisesByTrack[track] ?? []
        }
    }

    func interviewQuestions(for track: Track, topic: String? = nil, category: InterviewQuestionCategory? = nil) -> [InterviewQuestion] {
        switch (topic, category) {
        case let (.some(topic), .some(category)):
            return (questionsByTrackTopic[TrackTopicKey(track: track, topic: topic)] ?? [])
                .filter { $0.category == category }
        case let (.some(topic), .none):
            return questionsByTrackTopic[TrackTopicKey(track: track, topic: topic)] ?? []
        case let (.none, .some(category)):
            return questionsByTrackCategory[TrackQuestionCategoryKey(track: track, category: category)] ?? []
        case (.none, .none):
            return questionsByTrack[track] ?? []
        }
    }

    func topics(for track: Track) -> [Topic] {
        topicsByTrack[track] ?? []
    }

    func randomExercise(for track: Track) -> Exercise? {
        exercisesByTrack[track]?.randomElement()
    }

    func randomQuestion(for track: Track) -> InterviewQuestion? {
        questionsByTrack[track]?.randomElement()
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
        rebuildIndexes()
        self.isLoaded = true
    }

    private func rebuildIndexes() {
        lessonsByTrack = Dictionary(grouping: lessons, by: \.track)
            .mapValues(Self.sortedByOrderIndex)
        lessonsByTrackTopic = Dictionary(grouping: lessons) { lesson in
            TrackTopicKey(track: lesson.track, topic: lesson.topic)
        }
        .mapValues(Self.sortedByOrderIndex)

        exercisesByTrack = Dictionary(grouping: exercises, by: \.track)
            .mapValues(Self.sortedByOrderIndex)
        exercisesByTrackTopic = Dictionary(grouping: exercises) { exercise in
            TrackTopicKey(track: exercise.track, topic: exercise.topic)
        }
        .mapValues(Self.sortedByOrderIndex)
        exercisesByTrackType = Dictionary(grouping: exercises) { exercise in
            TrackExerciseTypeKey(track: exercise.track, type: exercise.type)
        }
        .mapValues(Self.sortedByOrderIndex)

        questionsByTrack = Dictionary(grouping: interviewQuestions, by: \.track)
            .mapValues(Self.sortedByOrderIndex)
        questionsByTrackTopic = Dictionary(grouping: interviewQuestions) { question in
            TrackTopicKey(track: question.track, topic: question.topic)
        }
        .mapValues(Self.sortedByOrderIndex)
        questionsByTrackCategory = Dictionary(grouping: interviewQuestions) { question in
            TrackQuestionCategoryKey(track: question.track, category: question.category)
        }
        .mapValues(Self.sortedByOrderIndex)

        topicsByTrack = Dictionary(uniqueKeysWithValues: Track.allCases.map { track in
            (track, buildTopics(for: track))
        })
    }

    private func buildTopics(for track: Track) -> [Topic] {
        let trackLessons = lessonsByTrack[track] ?? []
        let trackExercises = exercisesByTrack[track] ?? []
        let trackQuestions = questionsByTrack[track] ?? []

        let lessonCounts = Dictionary(grouping: trackLessons, by: \.topic).mapValues(\.count)
        let exerciseCounts = Dictionary(grouping: trackExercises, by: \.topic).mapValues(\.count)
        let questionCounts = Dictionary(grouping: trackQuestions, by: \.topic).mapValues(\.count)

        let topicNames = Array(Set(lessonCounts.keys)
            .union(exerciseCounts.keys)
            .union(questionCounts.keys))
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
                lessonCount: lessonCounts[topicName] ?? 0,
                exerciseCount: exerciseCounts[topicName] ?? 0,
                questionCount: questionCounts[topicName] ?? 0
            )
        }
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

    private static func sortedByOrderIndex(_ items: [Lesson]) -> [Lesson] {
        items.sorted { $0.orderIndex < $1.orderIndex }
    }

    private static func sortedByOrderIndex(_ items: [Exercise]) -> [Exercise] {
        items.sorted { $0.orderIndex < $1.orderIndex }
    }

    private static func sortedByOrderIndex(_ items: [InterviewQuestion]) -> [InterviewQuestion] {
        items.sorted { $0.orderIndex < $1.orderIndex }
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
