import SwiftUI
import UIKit

struct FillBlankExerciseView: View {
    let exercise: Exercise
    @Binding var isAnswered: Bool
    @Binding var isCorrect: Bool
    let onAnswer: (Bool) -> Void

    @State private var filledBlanks: [String?] = []
    @State private var usedWordIndices: Set<Int> = []
    @State private var blankResults: [Bool] = []

    private var blanks: [String] {
        exercise.blanks ?? exercise.correctTokens ?? []
    }

    private var wordBank: [String] {
        exercise.wordBank ?? []
    }

    private var codeTemplate: String {
        exercise.codeTemplate ?? exercise.codeSnippet ?? ""
    }

    private var allBlanksFilled: Bool {
        filledBlanks.allSatisfy { $0 != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let question = exercise.question {
                Text(question)
                    .font(.body)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }

            codeTemplateView
            wordBankView

            if allBlanksFilled && !isAnswered {
                checkButton
            }
        }
        .onAppear {
            filledBlanks = Array(repeating: nil, count: blanks.count)
        }
    }

    // MARK: - Code Template View

    private var codeTemplateView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let lines = codeTemplate.components(separatedBy: "\n")

            ForEach(Array(lines.enumerated()), id: \.offset) { lineIndex, line in
                buildCodeLine(line, lineNumber: lineIndex + 1)
            }
        }
        .padding(AppTheme.padding)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.smallCornerRadius))
    }

    @ViewBuilder
    private func buildCodeLine(_ line: String, lineNumber: Int) -> some View {
        let parts = line.components(separatedBy: "___")
        let hasBlanks = parts.count > 1

        if hasBlanks {
            // Use wrapping FlowLayout for lines with blanks so they don't overflow
            FlowLayout(spacing: 4) {
                Text("\(lineNumber) ")
                    .font(AppTheme.codeFontSmall)
                    .foregroundStyle(.tertiary)

                ForEach(Array(parts.enumerated()), id: \.offset) { partIndex, part in
                    if !part.isEmpty {
                        Text(part)
                            .font(AppTheme.codeFont)
                            .foregroundStyle(.primary)
                    }

                    if partIndex < parts.count - 1 {
                        let blankIndex = blankIndexFor(line: line, blankPosition: partIndex)
                        if let blankIndex, blankIndex < filledBlanks.count {
                            blankSlot(at: blankIndex)
                        }
                    }
                }
            }
        } else {
            // Plain code line — single HStack, no overflow risk
            HStack(alignment: .center, spacing: 0) {
                Text("\(lineNumber)")
                    .font(AppTheme.codeFontSmall)
                    .foregroundStyle(.tertiary)
                    .frame(minWidth: 24, alignment: .trailing)
                    .padding(.trailing, 8)

                Text(line)
                    .font(AppTheme.codeFont)
                    .foregroundStyle(.primary)
            }
        }
    }

    private func blankIndexFor(line: String, blankPosition: Int) -> Int? {
        let lines = codeTemplate.components(separatedBy: "\n")
        var blankCount = 0
        for l in lines {
            let blanksInLine = l.components(separatedBy: "___").count - 1
            if l == line {
                let index = blankCount + blankPosition
                return index < blanks.count ? index : nil
            }
            blankCount += blanksInLine
        }
        return nil
    }

    @ViewBuilder
    private func blankSlot(at index: Int) -> some View {
        let filled = filledBlanks[index]
        let hasResult = index < blankResults.count

        Button {
            guard !isAnswered else { return }
            if filled != nil {
                removeBlank(at: index)
            }
        } label: {
            Text(filled ?? "___")
                .font(AppTheme.codeFont)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(blankBackground(filled: filled, result: hasResult ? blankResults[index] : nil))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            blankBorder(filled: filled, result: hasResult ? blankResults[index] : nil),
                            style: filled == nil ? StrokeStyle(lineWidth: 1, dash: [4]) : StrokeStyle(lineWidth: 1)
                        )
                )
                .foregroundStyle(filled != nil ? .primary : .tertiary)
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }

    private func blankBackground(filled: String?, result: Bool?) -> Color {
        guard let result else {
            return filled != nil ? AppTheme.accent.opacity(0.06) : Color.clear
        }
        return result ? AppTheme.correct.opacity(0.08) : AppTheme.incorrect.opacity(0.08)
    }

    private func blankBorder(filled: String?, result: Bool?) -> Color {
        guard let result else {
            return filled != nil ? AppTheme.accent.opacity(0.3) : Color(.separator).opacity(0.3)
        }
        return result ? AppTheme.correct.opacity(0.4) : AppTheme.incorrect.opacity(0.4)
    }

    // MARK: - Word Bank

    private var wordBankView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Word Bank")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(Array(wordBank.enumerated()), id: \.offset) { index, word in
                    let isUsed = usedWordIndices.contains(index)

                    Button {
                        guard !isAnswered, !isUsed else { return }
                        fillNextBlank(with: word, wordIndex: index)
                    } label: {
                        Text(word)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(isUsed ? Color(.systemGray5) : AppTheme.secondaryBackground)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                            )
                            .foregroundStyle(isUsed ? .tertiary : .primary)
                    }
                    .buttonStyle(.plain)
                    .disabled(isUsed || isAnswered)
                }
            }
        }
        .padding(AppTheme.padding)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Check Button

    private var checkButton: some View {
        Button {
            checkAnswers()
        } label: {
            Text("Check")
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .transition(.opacity)
    }

    // MARK: - Logic

    private func fillNextBlank(with word: String, wordIndex: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        guard let nextEmptyIndex = filledBlanks.firstIndex(where: { $0 == nil }) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            filledBlanks[nextEmptyIndex] = word
            usedWordIndices.insert(wordIndex)
        }
    }

    private func removeBlank(at index: Int) {
        guard let word = filledBlanks[index] else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if let matchingUsedIndex = usedWordIndices.first(where: { usedIdx in
            usedIdx < wordBank.count && wordBank[usedIdx] == word
        }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                usedWordIndices.remove(matchingUsedIndex)
                _ = ()
            }
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            filledBlanks[index] = nil
        }
    }

    private func checkAnswers() {
        let generator = UINotificationFeedbackGenerator()

        var results: [Bool] = []
        let correctTokens = exercise.correctTokens ?? blanks

        for (index, filled) in filledBlanks.enumerated() {
            if index < correctTokens.count {
                results.append(filled == correctTokens[index])
            } else {
                results.append(false)
            }
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            blankResults = results
        }

        let allCorrect = results.allSatisfy { $0 }
        generator.notificationOccurred(allCorrect ? .success : .error)

        onAnswer(allCorrect)
    }
}

// FlowLayout is defined in LessonDetailView.swift

#Preview {
    FillBlankExerciseView(
        exercise: Exercise(
            id: "preview_fb",
            track: .swift,
            topic: "swift_basics",
            type: .fillBlank,
            difficulty: .medium,
            title: "Complete the function",
            question: "Fill in the blanks to complete this function.",
            codeSnippet: nil,
            options: nil,
            correctAnswer: nil,
            correctAnswerBool: nil,
            explanation: "Functions use func keyword and return with ->.",
            xp: 15,
            tags: [],
            codeTemplate: "___ greet(name: ___) -> String {\n    return \"Hello, \\(name)!\"\n}",
            blanks: ["func", "String"],
            correctTokens: ["func", "String"],
            wordBank: ["func", "var", "String", "Int", "let", "class"],
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
