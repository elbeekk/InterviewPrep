import SwiftUI

struct DailyChallengeRow: View {
    let exercise: Exercise

    var body: some View {
        NavigationLink {
            ExerciseView(exercise: exercise)
        } label: {
            HStack(spacing: AppTheme.spacing) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.compactListTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(exercise.difficulty.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Daily")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accent)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            DailyChallengeRow(
                exercise: Exercise(
                    id: "preview_1",
                    track: .swift,
                    topic: "swift_basics",
                    type: .mcq,
                    difficulty: .medium,
                    title: "What is the difference between let and var?",
                    question: "Sample question",
                    codeSnippet: nil,
                    options: ["A", "B", "C", "D"],
                    correctAnswer: 0,
                    correctAnswerBool: nil,
                    explanation: "Explanation",
                    xp: 15,
                    tags: ["basics"],
                    codeTemplate: nil,
                    blanks: nil,
                    correctTokens: nil,
                    wordBank: nil,
                    shuffledLines: nil,
                    correctOrder: nil,
                    leftColumn: nil,
                    rightColumn: nil,
                    correctPairs: nil,
                    bugLineIndex: nil,
                    fixOptions: nil,
                    correctFixIndex: nil,
                    orderIndex: 0
                )
            )
        }
    }
}
