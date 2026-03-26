import SwiftUI

struct LessonQuizView: View {
    let lesson: Lesson
    let questions: [QuizQuestion]

    @Environment(ProgressService.self) private var progressService
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var hasAnswered = false
    @State private var correctCount = 0
    @State private var quizFinished = false
    @State private var didCompleteLesson = false

    private var currentQuestion: QuizQuestion {
        questions[currentIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            if quizFinished {
                scoreSummaryView
            } else {
                questionView
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !quizFinished {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(currentIndex + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            StudySessionActivityManager.shared.startLessonQuiz(lesson)
        }
        .onDisappear {
            if !didCompleteLesson {
                StudySessionActivityManager.shared.endLesson(lesson)
            }
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(currentQuestion.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, AppTheme.padding)

                VStack(spacing: 10) {
                    ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                        optionButton(index: index, text: option)
                    }
                }

                if hasAnswered {
                    explanationView
                        .transition(.opacity)

                    nextButton
                }
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut(duration: 0.25), value: hasAnswered)
    }

    // MARK: - Option Button

    private func optionButton(index: Int, text: String) -> some View {
        let isSelected = selectedAnswer == index
        let isCorrect = index == currentQuestion.correctAnswer
        let showCorrect = hasAnswered && isCorrect
        let showIncorrect = hasAnswered && isSelected && !isCorrect

        return Button {
            guard !hasAnswered else { return }
            selectedAnswer = index
            hasAnswered = true
            if index == currentQuestion.correctAnswer {
                correctCount += 1
            }
            StudySessionActivityManager.shared.updateLessonQuiz(
                lesson,
                answeredQuestions: currentIndex + 1
            )
        } label: {
            HStack(spacing: AppTheme.spacing) {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if showCorrect {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.correct)
                } else if showIncorrect {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.incorrect)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(optionFill(showCorrect: showCorrect, showIncorrect: showIncorrect))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .strokeBorder(
                        optionBorder(isSelected: isSelected, showCorrect: showCorrect, showIncorrect: showIncorrect),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Explanation

    private var explanationView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Explanation")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(currentQuestion.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.smallCornerRadius))
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                if currentIndex + 1 < questions.count {
                    currentIndex += 1
                    selectedAnswer = nil
                    hasAnswered = false
                } else {
                    quizFinished = true
                }
            }
        } label: {
            Text(currentIndex + 1 < questions.count ? "Next Question" : "See Results")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    // MARK: - Score Summary

    private var scoreSummaryView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: AppTheme.spacing) {
                Text("\(correctCount)/\(questions.count) correct")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(scoreSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: AppTheme.spacing) {
                Button {
                    let score = Int((Double(correctCount) / Double(questions.count)) * 100)
                    didCompleteLesson = true
                    StudySessionActivityManager.shared.completeLesson(lesson, score: score)
                    progressService.markLessonCompleted(lesson.id, quizScore: score)
                    ReviewRequestService.recordAction()
                    dismiss()
                } label: {
                    Text("Complete Lesson")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    withAnimation {
                        StudySessionActivityManager.shared.startLessonQuiz(lesson)
                        didCompleteLesson = false
                        currentIndex = 0
                        selectedAnswer = nil
                        hasAnswered = false
                        correctCount = 0
                        quizFinished = false
                    }
                } label: {
                    Text("Retake Quiz")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal, AppTheme.padding)

            Spacer()
        }
        .padding(.horizontal, AppTheme.padding)
    }

    // MARK: - Helpers

    private func optionFill(showCorrect: Bool, showIncorrect: Bool) -> Color {
        if showCorrect { return AppTheme.correct.opacity(0.08) }
        if showIncorrect { return AppTheme.incorrect.opacity(0.08) }
        return AppTheme.primaryBackground
    }

    private func optionBorder(isSelected: Bool, showCorrect: Bool, showIncorrect: Bool) -> Color {
        if showCorrect { return AppTheme.correct.opacity(0.4) }
        if showIncorrect { return AppTheme.incorrect.opacity(0.4) }
        if isSelected { return AppTheme.accent }
        return Color(.separator)
    }

    private var scoreSubtitle: String {
        let pct = Int((Double(correctCount) / Double(questions.count)) * 100)
        if pct >= 90 { return "You have a strong grasp of this topic." }
        if pct >= 70 { return "You understand most of the concepts." }
        if pct >= 50 { return "Review the lesson to strengthen your knowledge." }
        return "Consider re-reading the lesson before retrying."
    }
}

// MARK: - Safe Array subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        LessonQuizView(
            lesson: Lesson(
                id: "preview",
                track: .swift,
                topic: "swift_basics",
                title: "Introduction to Swift",
                difficulty: .easy,
                content: [],
                codeExamples: [],
                keyTakeaways: [],
                miniQuiz: [
                    QuizQuestion(id: "q1", question: "What keyword declares a constant in Swift?", options: ["var", "let", "const", "final"], correctAnswer: 1, explanation: "In Swift, 'let' is used to declare constants."),
                    QuizQuestion(id: "q2", question: "Which type is used for text?", options: ["Int", "Bool", "String", "Double"], correctAnswer: 2, explanation: "String is the text type in Swift.")
                ],
                tags: [],
                orderIndex: 0
            ),
            questions: [
                QuizQuestion(id: "q1", question: "What keyword declares a constant in Swift?", options: ["var", "let", "const", "final"], correctAnswer: 1, explanation: "In Swift, 'let' is used to declare constants."),
                QuizQuestion(id: "q2", question: "Which type is used for text?", options: ["Int", "Bool", "String", "Double"], correctAnswer: 2, explanation: "String is the text type in Swift.")
            ]
        )
    }
}
