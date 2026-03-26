import ActivityKit
import Foundation

struct StudySessionActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        enum Phase: String, Codable, Hashable {
            case active
            case completed
            case review
        }

        var phase: Phase
        var progress: Double
        var completedSteps: Int
        var totalSteps: Int
        var statusText: String
        var detailText: String
    }

    enum Kind: String, Codable, Hashable {
        case lesson
        case exercise
    }

    var title: String
    var subtitle: String
    var kind: Kind
    var systemImageName: String
}
