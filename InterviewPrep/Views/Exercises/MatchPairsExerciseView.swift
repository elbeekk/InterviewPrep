import SwiftUI
import UIKit

struct MatchPairsExerciseView: View {
    let exercise: Exercise
    @Binding var isAnswered: Bool
    @Binding var isCorrect: Bool
    let onAnswer: (Bool) -> Void

    @State private var selectedLeft: Int? = nil
    @State private var selectedRight: Int? = nil
    @State private var pairs: [MatchPair] = []
    @State private var pairResults: [Bool] = []

    private var leftItems: [String] {
        exercise.leftColumn ?? []
    }

    private var rightItems: [String] {
        exercise.rightColumn ?? []
    }

    private var correctPairs: [Int] {
        exercise.correctPairs ?? []
    }

    private var allPaired: Bool {
        pairs.count == leftItems.count
    }

    // Assign a consistent color to each pair
    private let pairColors: [Color] = [
        .blue, .purple, .orange, .pink, .cyan, .mint, .indigo, .teal
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question
            if let question = exercise.question {
                Text(question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Match each item on the left with its pair on the right:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Optional code
            if let code = exercise.codeSnippet {
                CodeBlockView(
                    code: code,
                    language: exercise.track == .swift ? "Swift" : exercise.track == .flutter ? "Dart" : nil
                )
            }

            // Columns
            matchColumnsView

            // Check button
            if allPaired && !isAnswered {
                checkButton
            }
        }
    }

    // MARK: - Match Columns

    private var matchColumnsView: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left column
            VStack(spacing: 8) {
                Text("Items")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(Array(leftItems.enumerated()), id: \.offset) { index, item in
                    MatchItemButton(
                        text: item,
                        isSelected: selectedLeft == index,
                        pairedColorIndex: pairedColorIndex(forLeft: index),
                        result: resultForLeft(index),
                        isAnswered: isAnswered,
                        pairColors: pairColors
                    ) {
                        guard !isAnswered else { return }
                        selectLeft(index)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Right column
            VStack(spacing: 8) {
                Text("Matches")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(Array(rightItems.enumerated()), id: \.offset) { index, item in
                    MatchItemButton(
                        text: item,
                        isSelected: selectedRight == index,
                        pairedColorIndex: pairedColorIndex(forRight: index),
                        result: resultForRight(index),
                        isAnswered: isAnswered,
                        pairColors: pairColors
                    ) {
                        guard !isAnswered else { return }
                        selectRight(index)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Check Button

    private var checkButton: some View {
        Button {
            checkPairs()
        } label: {
            HStack {
                Image(systemName: "link.circle")
                Text("Check Pairs")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .glassEffect(.regular.tint(AppTheme.accent), in: .rect(cornerRadius: AppTheme.cornerRadius))
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Selection Logic

    private func selectLeft(_ index: Int) {
        // If already paired, unpair it
        if let existingPairIndex = pairs.firstIndex(where: { $0.leftIndex == index }) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                pairs.remove(at: existingPairIndex)
                selectedLeft = nil
            }
            return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedLeft = index
        }

        // If right is already selected, create pair
        if let right = selectedRight {
            createPair(left: index, right: right)
        }
    }

    private func selectRight(_ index: Int) {
        // If already paired, unpair it
        if let existingPairIndex = pairs.firstIndex(where: { $0.rightIndex == index }) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                pairs.remove(at: existingPairIndex)
                selectedRight = nil
            }
            return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedRight = index
        }

        // If left is already selected, create pair
        if let left = selectedLeft {
            createPair(left: left, right: index)
        }
    }

    private func createPair(left: Int, right: Int) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Remove any existing pairs involving these indices
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            pairs.removeAll { $0.leftIndex == left || $0.rightIndex == right }
            pairs.append(MatchPair(leftIndex: left, rightIndex: right))
            selectedLeft = nil
            selectedRight = nil
        }
    }

    // MARK: - Pair Color Helpers

    private func pairedColorIndex(forLeft index: Int) -> Int? {
        if let pairIndex = pairs.firstIndex(where: { $0.leftIndex == index }) {
            return pairIndex % pairColors.count
        }
        return nil
    }

    private func pairedColorIndex(forRight index: Int) -> Int? {
        if let pairIndex = pairs.firstIndex(where: { $0.rightIndex == index }) {
            return pairIndex % pairColors.count
        }
        return nil
    }

    // MARK: - Result Helpers

    private func resultForLeft(_ index: Int) -> Bool? {
        guard !pairResults.isEmpty else { return nil }
        if let pairIndex = pairs.firstIndex(where: { $0.leftIndex == index }),
           pairIndex < pairResults.count {
            return pairResults[pairIndex]
        }
        return nil
    }

    private func resultForRight(_ index: Int) -> Bool? {
        guard !pairResults.isEmpty else { return nil }
        if let pairIndex = pairs.firstIndex(where: { $0.rightIndex == index }),
           pairIndex < pairResults.count {
            return pairResults[pairIndex]
        }
        return nil
    }

    // MARK: - Check

    private func checkPairs() {
        let generator = UINotificationFeedbackGenerator()

        var results: [Bool] = []
        for pair in pairs {
            if pair.leftIndex < correctPairs.count {
                results.append(pair.rightIndex == correctPairs[pair.leftIndex])
            } else {
                results.append(false)
            }
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            pairResults = results
        }

        let allCorrect = results.allSatisfy { $0 }
        generator.notificationOccurred(allCorrect ? .success : .error)

        onAnswer(allCorrect)
    }
}

// MARK: - Match Pair Data

private struct MatchPair: Equatable {
    let leftIndex: Int
    let rightIndex: Int
}

// MARK: - Match Item Button

private struct MatchItemButton: View {
    let text: String
    let isSelected: Bool
    let pairedColorIndex: Int?
    let result: Bool?
    let isAnswered: Bool
    let pairColors: [Color]
    let onTap: () -> Void

    private var backgroundColor: Color {
        if let result {
            return result ? AppTheme.correct.opacity(0.12) : AppTheme.incorrect.opacity(0.12)
        }
        if let colorIdx = pairedColorIndex {
            return pairColors[colorIdx].opacity(0.12)
        }
        if isSelected {
            return AppTheme.accent.opacity(0.12)
        }
        return AppTheme.secondaryBackground
    }

    private var borderColor: Color {
        if let result {
            return result ? AppTheme.correct : AppTheme.incorrect
        }
        if let colorIdx = pairedColorIndex {
            return pairColors[colorIdx]
        }
        if isSelected {
            return AppTheme.accent
        }
        return Color(.systemGray4)
    }

    private var pairIndicator: some View {
        Group {
            if let colorIdx = pairedColorIndex {
                Circle()
                    .fill(pairColors[colorIdx])
                    .frame(width: 8, height: 8)
            }
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                pairIndicator

                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                Spacer(minLength: 0)

                if let result {
                    Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(result ? AppTheme.correct : AppTheme.incorrect)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(borderColor, lineWidth: isSelected || pairedColorIndex != nil ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
        .scaleEffect(isSelected ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    MatchPairsExerciseView(
        exercise: Exercise(
            id: "preview_match",
            track: .swift,
            topic: "swift_basics",
            type: .matchPairs,
            difficulty: .medium,
            title: "Match Swift types",
            question: "Match each Swift type with its description.",
            codeSnippet: nil,
            options: nil,
            correctAnswer: nil,
            correctAnswerBool: nil,
            explanation: "These are fundamental Swift types.",
            xp: 15,
            tags: [],
            codeTemplate: nil,
            blanks: nil,
            correctTokens: nil,
            wordBank: nil,
            shuffledLines: nil,
            correctOrder: nil,
            leftColumn: ["Int", "String", "Bool", "Double"],
            rightColumn: ["Text value", "True/False", "Whole number", "Decimal number"],
            correctPairs: [2, 0, 1, 3],
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
