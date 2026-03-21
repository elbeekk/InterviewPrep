import SwiftUI
import UIKit

struct TrueFalseExerciseView: View {
    let exercise: Exercise
    @Binding var isAnswered: Bool
    @Binding var isCorrect: Bool
    let onAnswer: (Bool) -> Void

    @State private var selectedAnswer: Bool? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0

    private var questionText: String {
        exercise.question ?? exercise.title
    }

    private var correctAnswer: Bool {
        exercise.correctAnswerBool ?? true
    }

    private var isSwipeMode: Bool {
        exercise.type == .swipe
    }

    var body: some View {
        VStack(spacing: 24) {
            if isSwipeMode {
                swipeInstructions
            }

            statementCard

            if !isSwipeMode {
                buttonControls
            }
        }
    }

    // MARK: - Swipe Instructions

    private var swipeInstructions: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "arrow.left")
                Text("False")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 4) {
                Text("True")
                Image(systemName: "arrow.right")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Statement Card

    private var statementCard: some View {
        VStack(spacing: AppTheme.padding) {
            Text(questionText)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let code = exercise.codeSnippet {
                CodeBlockView(
                    code: code,
                    language: exercise.track == .swift ? "Swift" : exercise.track == .flutter ? "Dart" : nil
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
        )
        .rotationEffect(.degrees(cardRotation))
        .offset(x: dragOffset.width)
        .gesture(isSwipeMode && !isAnswered ? swipeGesture : nil)
        .animation(.easeInOut(duration: 0.2), value: dragOffset)
    }

    private var cardBackground: Color {
        guard isAnswered else {
            return AppTheme.secondaryBackground
        }
        return isCorrect ? AppTheme.correct.opacity(0.06) : AppTheme.incorrect.opacity(0.06)
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                cardRotation = Double(value.translation.width) / 25
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                if value.translation.width > threshold {
                    submitAnswer(true)
                } else if value.translation.width < -threshold {
                    submitAnswer(false)
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = .zero
                        cardRotation = 0
                    }
                }
            }
    }

    // MARK: - Button Controls

    private var buttonControls: some View {
        HStack(spacing: AppTheme.padding) {
            tfButton(label: "False", value: false)
            tfButton(label: "True", value: true)
        }
    }

    private func tfButton(label: String, value: Bool) -> some View {
        let isSelected = selectedAnswer == value
        let isCorrectAnswer = value == correctAnswer

        return Button {
            guard !isAnswered else { return }
            submitAnswer(value)
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(tfBackground(isSelected: isSelected, isCorrectAnswer: isCorrectAnswer))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(tfBorder(isSelected: isSelected, isCorrectAnswer: isCorrectAnswer), lineWidth: 1)
                )
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }

    private func tfBackground(isSelected: Bool, isCorrectAnswer: Bool) -> Color {
        guard isAnswered else {
            return AppTheme.secondaryBackground
        }
        if isCorrectAnswer {
            return AppTheme.correct.opacity(0.08)
        }
        if isSelected && !isCorrectAnswer {
            return AppTheme.incorrect.opacity(0.08)
        }
        return AppTheme.secondaryBackground
    }

    private func tfBorder(isSelected: Bool, isCorrectAnswer: Bool) -> Color {
        guard isAnswered else {
            return Color(.separator).opacity(0.3)
        }
        if isCorrectAnswer {
            return AppTheme.correct.opacity(0.3)
        }
        if isSelected && !isCorrectAnswer {
            return AppTheme.incorrect.opacity(0.3)
        }
        return Color(.separator).opacity(0.3)
    }

    // MARK: - Submit

    private func submitAnswer(_ answer: Bool) {
        let correct = answer == correctAnswer

        let generator = UIImpactFeedbackGenerator(style: correct ? .light : .medium)
        generator.impactOccurred()

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedAnswer = answer
            if isSwipeMode {
                dragOffset = CGSize(width: answer ? 300 : -300, height: 0)
                cardRotation = answer ? 12 : -12
            }
        }

        let delay: Double = isSwipeMode ? 0.3 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if isSwipeMode {
                withAnimation(.easeOut(duration: 0.2)) {
                    dragOffset = .zero
                    cardRotation = 0
                }
            }
            onAnswer(correct)
        }
    }
}

#Preview {
    TrueFalseExerciseView(
        exercise: Exercise(
            id: "preview_tf",
            track: .swift,
            topic: "swift_basics",
            type: .trueFalse,
            difficulty: .easy,
            title: "Swift is a compiled language",
            question: "Swift is a compiled language.",
            codeSnippet: nil,
            options: nil,
            correctAnswer: nil,
            correctAnswerBool: true,
            explanation: "Swift is indeed a compiled language using LLVM.",
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
