import SwiftUI

struct TopicRow: View {
    let topic: Topic
    let progress: Double
    var showsTrackBadge: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            Image(systemName: topic.icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(topic.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if showsTrackBadge {
                        TrackBadge(track: topic.track)
                    }

                    Spacer(minLength: 0)

                    Text(progressText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: progress)
                    .tint(progressTint)
            }
        }
    }

    private var progressText: String {
        let total = topic.lessonCount + topic.exerciseCount
        let completed = Int(Double(total) * progress)
        return "\(completed)/\(total)"
    }

    private var progressTint: Color {
        if progress >= 1.0 {
            return AppTheme.correct
        }
        return AppTheme.accent
    }
}

#Preview {
    List {
        TopicRow(
            topic: Topic(
                id: "swift_basics",
                name: "Swift Basics",
                icon: "swift",
                track: .swift,
                lessonCount: 8,
                exerciseCount: 15,
                questionCount: 5
            ),
            progress: 0.65,
            showsTrackBadge: true
        )

        TopicRow(
            topic: Topic(
                id: "widgets",
                name: "Widgets",
                icon: "square.on.square",
                track: .flutter,
                lessonCount: 5,
                exerciseCount: 10,
                questionCount: 3
            ),
            progress: 0.0
        )

        TopicRow(
            topic: Topic(
                id: "oop",
                name: "OOP",
                icon: "cube.transparent",
                track: .general,
                lessonCount: 6,
                exerciseCount: 12,
                questionCount: 4
            ),
            progress: 1.0
        )
    }
}
