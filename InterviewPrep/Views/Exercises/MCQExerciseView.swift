import SwiftUI
import UIKit

struct MCQExerciseView: View {
    let exercise: Exercise
    @Binding var isAnswered: Bool
    @Binding var isCorrect: Bool
    let onAnswer: (Bool) -> Void

    @State private var selectedIndex: Int? = nil

    private var questionText: String {
        exercise.question ?? exercise.title
    }

    private var options: [String] {
        if exercise.type == .spotBug {
            return exercise.fixOptions ?? []
        }
        return exercise.options ?? []
    }

    private var correctIndex: Int {
        if exercise.type == .spotBug {
            return exercise.correctFixIndex ?? 0
        }
        return exercise.correctAnswer ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.padding) {
            Text(questionText)
                .font(.body)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)

            if let code = exercise.codeSnippet {
                CodeBlockView(
                    code: code,
                    language: exercise.track == .swift ? "Swift" : exercise.track == .flutter ? "Dart" : nil
                )
            }

            VStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button {
                        guard !isAnswered else { return }
                        selectOption(index)
                    } label: {
                        HStack(spacing: AppTheme.spacing) {
                            Text(option)
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.primary)

                            Spacer()

                            if isAnswered && index == correctIndex {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.correct)
                            } else if isAnswered && selectedIndex == index && index != correctIndex {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.incorrect)
                            }
                        }
                        .padding(AppTheme.padding)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .fill(rowBackground(for: index))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .stroke(rowBorder(for: index), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isAnswered)
                }
            }
        }
    }

    private func rowBackground(for index: Int) -> Color {
        guard isAnswered else {
            return AppTheme.secondaryBackground
        }
        if index == correctIndex {
            return AppTheme.correct.opacity(0.08)
        }
        if selectedIndex == index && index != correctIndex {
            return AppTheme.incorrect.opacity(0.08)
        }
        return AppTheme.secondaryBackground
    }

    private func rowBorder(for index: Int) -> Color {
        guard isAnswered else {
            return Color(.separator).opacity(0.3)
        }
        if index == correctIndex {
            return AppTheme.correct.opacity(0.3)
        }
        if selectedIndex == index && index != correctIndex {
            return AppTheme.incorrect.opacity(0.3)
        }
        return Color(.separator).opacity(0.3)
    }

    private func selectOption(_ index: Int) {
        let correct = index == correctIndex
        let generator = UIImpactFeedbackGenerator(style: correct ? .light : .medium)
        generator.impactOccurred()

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedIndex = index
        }

        onAnswer(correct)
    }
}

#Preview {
    MCQExerciseView(
        exercise: Exercise(
            id: "preview_mcq",
            track: .swift,
            topic: "swift_basics",
            type: .mcq,
            difficulty: .easy,
            title: "What is an Optional?",
            question: "Which keyword declares an optional in Swift?",
            codeSnippet: "var name: String? = nil",
            options: ["var", "let", "?", "!"],
            correctAnswer: 2,
            correctAnswerBool: nil,
            explanation: "The ? symbol makes a type optional.",
            xp: 10,
            tags: [],
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
        ),
        isAnswered: .constant(false),
        isCorrect: .constant(false)
    ) { _ in }
        .padding()
}
