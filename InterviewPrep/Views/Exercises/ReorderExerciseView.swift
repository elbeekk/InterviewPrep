import SwiftUI
import UIKit

struct ReorderExerciseView: View {
    let exercise: Exercise
    @Binding var isAnswered: Bool
    @Binding var isCorrect: Bool
    let onAnswer: (Bool) -> Void

    @State private var lines: [ReorderLine] = []
    @State private var lineResults: [Bool] = []

    private var correctOrder: [Int] {
        exercise.correctOrder ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question
            if let question = exercise.question {
                Text(question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Drag to reorder the code lines into the correct sequence:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Optional code context
            if let code = exercise.codeSnippet {
                CodeBlockView(
                    code: code,
                    language: exercise.track == .swift ? "Swift" : exercise.track == .flutter ? "Dart" : nil
                )
            }

            // Reorderable lines
            reorderableList

            // Check button
            if !isAnswered {
                checkButton
            }
        }
        .onAppear {
            setupLines()
        }
    }

    // MARK: - Reorderable List

    private var reorderableList: some View {
        VStack(spacing: 6) {
            ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                ReorderLineRow(
                    line: line,
                    lineNumber: index + 1,
                    result: index < lineResults.count ? lineResults[index] : nil,
                    isAnswered: isAnswered,
                    onMoveUp: index > 0 ? { moveLine(from: index, to: index - 1) } : nil,
                    onMoveDown: index < lines.count - 1 ? { moveLine(from: index, to: index + 1) } : nil
                )
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Check Button

    private var checkButton: some View {
        Button {
            checkOrder()
        } label: {
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle")
                Text("Check Order")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .glassEffect(.regular.tint(AppTheme.accent), in: .rect(cornerRadius: AppTheme.cornerRadius))
        }
    }

    // MARK: - Logic

    private func setupLines() {
        guard let shuffled = exercise.shuffledLines else { return }
        lines = shuffled.enumerated().map { index, text in
            ReorderLine(id: index, text: text)
        }
    }

    private func moveLine(from source: Int, to destination: Int) {
        guard !isAnswered else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let item = lines.remove(at: source)
            lines.insert(item, at: destination)
        }
    }

    private func checkOrder() {
        let generator = UINotificationFeedbackGenerator()

        var results: [Bool] = []
        let currentOrder = lines.map(\.id)

        for (index, lineId) in currentOrder.enumerated() {
            if index < correctOrder.count {
                results.append(lineId == correctOrder[index])
            } else {
                results.append(false)
            }
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            lineResults = results
        }

        let allCorrect = results.allSatisfy { $0 }
        generator.notificationOccurred(allCorrect ? .success : .error)

        onAnswer(allCorrect)
    }
}

// MARK: - Data Model

private struct ReorderLine: Identifiable, Equatable {
    let id: Int
    let text: String
}

// MARK: - Line Row

private struct ReorderLineRow: View {
    let line: ReorderLine
    let lineNumber: Int
    let result: Bool?
    let isAnswered: Bool
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?

    private var backgroundColor: Color {
        guard let result else { return AppTheme.secondaryBackground }
        return result ? AppTheme.correct.opacity(0.1) : AppTheme.incorrect.opacity(0.1)
    }

    private var borderColor: Color {
        guard let result else { return Color(.systemGray4) }
        return result ? AppTheme.correct : AppTheme.incorrect
    }

    private var resultIcon: String? {
        guard let result else { return nil }
        return result ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    var body: some View {
        HStack(spacing: 10) {
            // Line number
            Text("\(lineNumber)")
                .font(AppTheme.codeFontSmall)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            // Code text
            Text(line.text)
                .font(AppTheme.codeFont)
                .foregroundStyle(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Result icon
            if let icon = resultIcon {
                Image(systemName: icon)
                    .foregroundStyle(result == true ? AppTheme.correct : AppTheme.incorrect)
                    .transition(.scale.combined(with: .opacity))
            }

            // Move buttons
            if !isAnswered {
                VStack(spacing: 2) {
                    if let onMoveUp {
                        Button {
                            onMoveUp()
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .frame(width: 24, height: 20)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }

                    if let onMoveDown {
                        Button {
                            onMoveDown()
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .frame(width: 24, height: 20)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

#Preview {
    ReorderExerciseView(
        exercise: Exercise(
            id: "preview_reorder",
            track: .swift,
            topic: "swift_basics",
            type: .reorder,
            difficulty: .medium,
            title: "Order the struct definition",
            question: "Reorder these lines to create a valid Swift struct.",
            codeSnippet: nil,
            options: nil,
            correctAnswer: nil,
            correctAnswerBool: nil,
            explanation: "A struct needs the struct keyword, name, braces, and properties inside.",
            xp: 15,
            tags: [],
            codeTemplate: nil,
            blanks: nil,
            correctTokens: nil,
            wordBank: nil,
            shuffledLines: [
                "    var name: String",
                "}",
                "struct Person {",
                "    var age: Int"
            ],
            correctOrder: [2, 0, 3, 1],
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
