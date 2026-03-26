import SwiftUI

struct ExerciseView: View {
    let exercise: Exercise

    @Environment(ProgressService.self) private var progressService
    @Environment(ContentService.self) private var contentService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift
    @Environment(\.dismiss) private var dismiss

    @State private var isAnswered = false
    @State private var isCorrect = false
    @State private var showExplanation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                exerciseContent
                if showExplanation {
                    explanationCard
                    nextButton
                }
            }
            .padding(AppTheme.padding)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(exercise.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
        }
        .onAppear {
            StudySessionActivityManager.shared.startExercise(exercise)
        }
        .onDisappear {
            StudySessionActivityManager.shared.endExercise(exercise)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: AppTheme.spacing) {
            Text(exercise.difficulty.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(exercise.xp) XP")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if progressService.isExerciseCompleted(exercise.id) {
                Label("Done", systemImage: "checkmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Exercise Content (Type Switch)

    @ViewBuilder
    private var exerciseContent: some View {
        switch exercise.type {
        case .mcq, .predictOutput:
            MCQExerciseView(exercise: exercise, isAnswered: $isAnswered, isCorrect: $isCorrect) {
                handleAnswer(correct: $0)
            }
        case .trueFalse, .swipe:
            TrueFalseExerciseView(exercise: exercise, isAnswered: $isAnswered, isCorrect: $isCorrect) {
                handleAnswer(correct: $0)
            }
        case .fillBlank:
            FillBlankExerciseView(exercise: exercise, isAnswered: $isAnswered, isCorrect: $isCorrect) {
                handleAnswer(correct: $0)
            }
        case .reorder:
            ReorderExerciseView(exercise: exercise, isAnswered: $isAnswered, isCorrect: $isCorrect) {
                handleAnswer(correct: $0)
            }
        case .matchPairs:
            MatchPairsExerciseView(exercise: exercise, isAnswered: $isAnswered, isCorrect: $isCorrect) {
                handleAnswer(correct: $0)
            }
        case .spotBug:
            MCQExerciseView(exercise: exercise, isAnswered: $isAnswered, isCorrect: $isCorrect) {
                handleAnswer(correct: $0)
            }
        }
    }

    // MARK: - Explanation Card

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            HStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isCorrect ? AppTheme.correct : AppTheme.incorrect)

                Text(isCorrect ? "Correct" : "Incorrect")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(isCorrect ? "+\(exercise.xp) XP" : "+0 XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text(exercise.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.padding)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
        .transition(.opacity)
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button {
            navigateToNext()
        } label: {
            HStack {
                Text("Next Exercise")
                    .fontWeight(.medium)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .glassEffect(.regular.tint(AppTheme.accent), in: .rect(cornerRadius: AppTheme.cornerRadius))
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private func handleAnswer(correct: Bool) {
        isCorrect = correct
        isAnswered = true

        progressService.markExerciseCompleted(exercise.id, correct: correct, xp: exercise.xp)
        StudySessionActivityManager.shared.updateExercise(exercise, isCorrect: correct)

        withAnimation(.easeInOut(duration: 0.25)) {
            showExplanation = true
        }
    }

    private func navigateToNext() {
        let allExercises = contentService.exercises(for: selectedTrack)
            + (selectedTrack != .general ? contentService.exercises(for: .general) : [])
        if let currentIndex = allExercises.firstIndex(where: { $0.id == exercise.id }),
           currentIndex + 1 < allExercises.count {
            dismiss()
        } else {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseView(
            exercise: Exercise(
                id: "preview_1",
                track: .swift,
                topic: "swift_basics",
                type: .mcq,
                difficulty: .easy,
                title: "What is an Optional?",
                question: "Which keyword is used to declare an optional in Swift?",
                codeSnippet: nil,
                options: ["var", "let", "?", "!"],
                correctAnswer: 2,
                correctAnswerBool: nil,
                explanation: "The ? symbol is used after a type to declare it as optional.",
                xp: 10,
                tags: ["swift", "optionals"],
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
