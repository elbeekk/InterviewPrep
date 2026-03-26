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

    /// Break the entire template into an array of segments: either a word or a blank index.
    private var templateSegments: [TemplateSegment] {
        var segments: [TemplateSegment] = []
        var blankIndex = 0
        let fullText = codeTemplate

        // Split by the blank placeholder "___"
        let parts = fullText.components(separatedBy: "___")
        for (partIndex, part) in parts.enumerated() {
            // Split the text part into individual words so they can wrap
            let words = part.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            for word in words {
                segments.append(.word(word))
            }

            // Add a blank between parts (not after the last part)
            if partIndex < parts.count - 1 {
                segments.append(.blank(blankIndex))
                blankIndex += 1
            }
        }

        return segments
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let question = exercise.question {
                Text(question)
                    .font(.body)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }

            sentenceTemplateView
            wordBankView

            if allBlanksFilled && !isAnswered {
                checkButton
            }
        }
        .onAppear {
            filledBlanks = Array(repeating: nil, count: blanks.count)
        }
    }

    // MARK: - Sentence Template (Duolingo-style flowing text with inline blanks)

    private var sentenceTemplateView: some View {
        FlowLayout(spacing: 6) {
            ForEach(Array(templateSegments.enumerated()), id: \.offset) { _, segment in
                switch segment {
                case .word(let text):
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                case .blank(let index):
                    if index < filledBlanks.count {
                        blankChip(at: index)
                    }
                }
            }
        }
        .padding(AppTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Blank Chip

    private func blankChip(at index: Int) -> some View {
        let filled = filledBlanks[index]
        let hasResult = index < blankResults.count

        return Button {
            guard !isAnswered else { return }
            if filled != nil {
                removeBlank(at: index)
            }
        } label: {
            Text(filled ?? "          ")
                .font(.body)
                .fontWeight(filled != nil ? .medium : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(blankBackground(filled: filled, result: hasResult ? blankResults[index] : nil))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            blankBorder(filled: filled, result: hasResult ? blankResults[index] : nil),
                            lineWidth: filled != nil ? 1.5 : 1
                        )
                )
                .foregroundStyle(filled != nil ? .primary : .quaternary)
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }

    private func blankBackground(filled: String?, result: Bool?) -> Color {
        if let result {
            return result ? AppTheme.correct.opacity(0.1) : AppTheme.incorrect.opacity(0.1)
        }
        if filled != nil {
            return AppTheme.accent.opacity(0.08)
        }
        return Color(.systemGray6)
    }

    private func blankBorder(filled: String?, result: Bool?) -> Color {
        if let result {
            return result ? AppTheme.correct.opacity(0.5) : AppTheme.incorrect.opacity(0.5)
        }
        if filled != nil {
            return AppTheme.accent.opacity(0.4)
        }
        return Color(.separator).opacity(0.4)
    }

    // MARK: - Word Bank

    private var wordBankView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tap to fill in the blanks")
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
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(isUsed ? .tertiary : .primary)
                            .background(
                                isUsed ? AnyShape(Capsule()).fill(Color(.systemGray5)) : nil
                            )
                            .glassEffect(.regular, in: .capsule)
                            .opacity(isUsed ? 0.4 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(isUsed || isAnswered)
                }
            }
        }
        .padding(AppTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Check Button

    private var checkButton: some View {
        Button {
            checkAnswers()
        } label: {
            Text("Check Answer")
                .fontWeight(.semibold)
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

// MARK: - Template Segment

private enum TemplateSegment {
    case word(String)
    case blank(Int)
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
