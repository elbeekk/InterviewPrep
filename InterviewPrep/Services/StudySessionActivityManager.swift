import ActivityKit
import Foundation

@MainActor
final class StudySessionActivityManager {
    static let shared = StudySessionActivityManager()

    private var currentActivity: Activity<StudySessionActivityAttributes>?
    private var currentSessionID: String?

    private init() {}

    func startLessonQuiz(_ lesson: Lesson) {
        let totalQuestions = max(lesson.miniQuiz.count, 1)
        start(
            sessionID: lessonSessionID(for: lesson),
            attributes: StudySessionActivityAttributes(
                title: lesson.compactListTitle,
                subtitle: lesson.track.displayName,
                kind: .lesson,
                systemImageName: "book.closed.fill"
            ),
            state: StudySessionActivityAttributes.ContentState(
                phase: .active,
                progress: 0,
                completedSteps: 0,
                totalSteps: totalQuestions,
                statusText: "Lesson quiz in progress",
                detailText: "0 of \(totalQuestions) answered"
            )
        )
    }

    func updateLessonQuiz(_ lesson: Lesson, answeredQuestions: Int) {
        let totalQuestions = max(lesson.miniQuiz.count, 1)
        update(
            sessionID: lessonSessionID(for: lesson),
            state: StudySessionActivityAttributes.ContentState(
                phase: .active,
                progress: normalizedProgress(step: answeredQuestions, total: totalQuestions),
                completedSteps: min(answeredQuestions, totalQuestions),
                totalSteps: totalQuestions,
                statusText: "Lesson quiz in progress",
                detailText: "\(min(answeredQuestions, totalQuestions)) of \(totalQuestions) answered"
            )
        )
    }

    func completeLesson(_ lesson: Lesson, score: Int) {
        let totalQuestions = max(lesson.miniQuiz.count, 1)
        finish(
            sessionID: lessonSessionID(for: lesson),
            state: StudySessionActivityAttributes.ContentState(
                phase: .completed,
                progress: 1,
                completedSteps: totalQuestions,
                totalSteps: totalQuestions,
                statusText: "Lesson completed",
                detailText: "Score \(score)%"
            )
        )
    }

    func endLesson(_ lesson: Lesson) {
        endIfNeeded(sessionID: lessonSessionID(for: lesson))
    }

    func startExercise(_ exercise: Exercise) {
        start(
            sessionID: exerciseSessionID(for: exercise),
            attributes: StudySessionActivityAttributes(
                title: exercise.compactListTitle,
                subtitle: exercise.track.displayName,
                kind: .exercise,
                systemImageName: "bolt.fill"
            ),
            state: StudySessionActivityAttributes.ContentState(
                phase: .active,
                progress: 0,
                completedSteps: 0,
                totalSteps: 1,
                statusText: "Practice in progress",
                detailText: "Answer the prompt"
            )
        )
    }

    func updateExercise(_ exercise: Exercise, isCorrect: Bool) {
        update(
            sessionID: exerciseSessionID(for: exercise),
            state: StudySessionActivityAttributes.ContentState(
                phase: isCorrect ? .completed : .review,
                progress: 1,
                completedSteps: 1,
                totalSteps: 1,
                statusText: isCorrect ? "Correct answer" : "Review the explanation",
                detailText: isCorrect ? "+\(exercise.xp) XP earned" : "Try to spot the gap"
            )
        )
    }

    func endExercise(_ exercise: Exercise) {
        endIfNeeded(sessionID: exerciseSessionID(for: exercise))
    }

    private func start(
        sessionID: String,
        attributes: StudySessionActivityAttributes,
        state: StudySessionActivityAttributes.ContentState
    ) {
        currentSessionID = sessionID

        Task {
            await endCurrentActivity(dismissalPolicy: .immediate)

            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                if currentSessionID == sessionID {
                    currentSessionID = nil
                }
                return
            }

            do {
                currentActivity = try Activity.request(
                    attributes: attributes,
                    content: activityContent(for: state),
                    pushType: nil
                )
            } catch {
                if currentSessionID == sessionID {
                    currentSessionID = nil
                }
                currentActivity = nil
            }
        }
    }

    private func update(
        sessionID: String,
        state: StudySessionActivityAttributes.ContentState
    ) {
        guard currentSessionID == sessionID else { return }

        Task {
            guard let activity = currentActivity else { return }
            try? await activity.update(activityContent(for: state))
        }
    }

    private func finish(
        sessionID: String,
        state: StudySessionActivityAttributes.ContentState
    ) {
        guard currentSessionID == sessionID else { return }
        currentSessionID = nil

        Task {
            guard let activity = currentActivity else { return }
            await activity.end(
                activityContent(for: state),
                dismissalPolicy: .after(.now + 15)
            )

            if currentActivity?.id == activity.id {
                currentActivity = nil
            }
        }
    }

    private func endIfNeeded(sessionID: String) {
        guard currentSessionID == sessionID else { return }
        currentSessionID = nil

        Task {
            await endCurrentActivity(dismissalPolicy: .immediate)
        }
    }

    private func endCurrentActivity(dismissalPolicy: ActivityUIDismissalPolicy) async {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        await activity.end(nil, dismissalPolicy: dismissalPolicy)
    }

    private func activityContent(
        for state: StudySessionActivityAttributes.ContentState
    ) -> ActivityContent<StudySessionActivityAttributes.ContentState> {
        ActivityContent(
            state: state,
            staleDate: .now.addingTimeInterval(2 * 60 * 60)
        )
    }

    private func normalizedProgress(step: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(max(Double(step) / Double(total), 0), 1)
    }

    private func lessonSessionID(for lesson: Lesson) -> String {
        "lesson:\(lesson.id)"
    }

    private func exerciseSessionID(for exercise: Exercise) -> String {
        "exercise:\(exercise.id)"
    }
}
