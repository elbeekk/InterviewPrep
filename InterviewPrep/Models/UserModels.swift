import Foundation
import SwiftData

@Model
final class UserProgress {
    var lessonId: String
    var completed: Bool
    var completedAt: Date?
    var quizScore: Int?

    init(lessonId: String, completed: Bool = false, completedAt: Date? = nil, quizScore: Int? = nil) {
        self.lessonId = lessonId
        self.completed = completed
        self.completedAt = completedAt
        self.quizScore = quizScore
    }
}

@Model
final class ExerciseProgress {
    var exerciseId: String
    var completed: Bool
    var correct: Bool
    var completedAt: Date?
    var attempts: Int

    init(exerciseId: String, completed: Bool = false, correct: Bool = false, completedAt: Date? = nil, attempts: Int = 0) {
        self.exerciseId = exerciseId
        self.completed = completed
        self.correct = correct
        self.completedAt = completedAt
        self.attempts = attempts
    }
}

@Model
final class Bookmark {
    var itemId: String
    var itemType: String // "lesson", "exercise", "interview_question"
    var title: String
    var note: String?
    var createdAt: Date

    init(itemId: String, itemType: String, title: String, note: String? = nil, createdAt: Date = Date()) {
        self.itemId = itemId
        self.itemType = itemType
        self.title = title
        self.note = note
        self.createdAt = createdAt
    }
}

@Model
final class DailyStreak {
    var date: Date
    var exercisesCompleted: Int
    var xpEarned: Int

    init(date: Date = Date(), exercisesCompleted: Int = 0, xpEarned: Int = 0) {
        self.date = date
        self.exercisesCompleted = exercisesCompleted
        self.xpEarned = xpEarned
    }
}

@Model
final class Achievement {
    var achievementId: String
    var title: String
    var achievementDescription: String
    var icon: String
    var unlockedAt: Date?
    var unlocked: Bool

    init(achievementId: String, title: String, achievementDescription: String, icon: String, unlockedAt: Date? = nil, unlocked: Bool = false) {
        self.achievementId = achievementId
        self.title = title
        self.achievementDescription = achievementDescription
        self.icon = icon
        self.unlockedAt = unlockedAt
        self.unlocked = unlocked
    }
}
