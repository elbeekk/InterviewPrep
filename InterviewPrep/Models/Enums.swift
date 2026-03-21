import Foundation

enum Track: String, Codable, CaseIterable, Identifiable {
    case flutter = "flutter"
    case swift = "swift"
    case general = "general"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flutter: "Flutter & Dart"
        case .swift: "Swift & iOS"
        case .general: "General Programming"
        }
    }

    var shortDisplayName: String {
        switch self {
        case .flutter: "Flutter"
        case .swift: "Swift"
        case .general: "General"
        }
    }

    var icon: String {
        switch self {
        case .flutter: "chevron.left.forwardslash.chevron.right"
        case .swift: "swift"
        case .general: "globe"
        }
    }

    var subtitle: String {
        switch self {
        case .flutter: "Cross-platform mobile development"
        case .swift: "Native iOS development"
        case .general: "Universal programming concepts"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }
}

enum ExerciseType: String, Codable, CaseIterable {
    case mcq
    case fillBlank = "fill_blank"
    case spotBug = "spot_bug"
    case reorder
    case trueFalse = "true_false"
    case matchPairs = "match_pairs"
    case predictOutput = "predict_output"
    case swipe
}

enum ContentType: String, Codable {
    case lesson
    case exercise
    case interviewQuestion = "interview_question"
}

enum InterviewQuestionCategory: String, Codable, CaseIterable, Identifiable {
    case conceptual
    case practical
    case behavioral
    case systemDesign = "system_design"
    case liveCoding = "live_coding"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .conceptual: "Conceptual"
        case .practical: "Practical"
        case .behavioral: "Behavioral"
        case .systemDesign: "System Design"
        case .liveCoding: "Live Coding"
        }
    }

    var icon: String {
        switch self {
        case .conceptual: "lightbulb"
        case .practical: "wrench.and.screwdriver"
        case .behavioral: "person.2"
        case .systemDesign: "cpu"
        case .liveCoding: "chevron.left.forwardslash.chevron.right"
        }
    }
}

enum DevLevel: String, CaseIterable {
    case junior = "Junior"
    case mid = "Mid-Level"
    case senior = "Senior"
    case staff = "Staff"
    case principal = "Principal"

    var xpRequired: Int {
        switch self {
        case .junior: 0
        case .mid: 500
        case .senior: 2000
        case .staff: 5000
        case .principal: 10000
        }
    }
}
