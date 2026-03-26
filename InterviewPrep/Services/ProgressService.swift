import Foundation
import SwiftData

@Observable
final class ProgressService {
    private var modelContext: ModelContext
    private var completedLessonIDs: Set<String> = []
    private var completedExerciseIDs: Set<String> = []
    private var bookmarkIDs: Set<String> = []
    private var cachedBookmarks: [Bookmark] = []

    var totalXP: Int = 0
    var currentStreak: Int = 0
    var completedLessons: Int = 0
    var completedExercises: Int = 0
    var correctExercises: Int = 0

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    var currentLevel: DevLevel {
        for level in DevLevel.allCases.reversed() {
            if totalXP >= level.xpRequired {
                return level
            }
        }
        return .junior
    }

    var nextLevel: DevLevel? {
        let levels = DevLevel.allCases
        guard let currentIndex = levels.firstIndex(of: currentLevel),
              currentIndex + 1 < levels.count else { return nil }
        return levels[currentIndex + 1]
    }

    var xpToNextLevel: Int {
        guard let next = nextLevel else { return 0 }
        return next.xpRequired - totalXP
    }

    var levelProgress: Double {
        guard let next = nextLevel else { return 1.0 }
        let current = currentLevel.xpRequired
        let range = next.xpRequired - current
        guard range > 0 else { return 1.0 }
        return Double(totalXP - current) / Double(range)
    }

    func refresh() {
        do {
            let lessonDescriptor = FetchDescriptor<UserProgress>(
                predicate: #Predicate { $0.completed }
            )
            let lessonResults = try modelContext.fetch(lessonDescriptor)
            completedLessons = lessonResults.count
            completedLessonIDs = Set(lessonResults.map(\.lessonId))

            let exerciseDescriptor = FetchDescriptor<ExerciseProgress>(
                predicate: #Predicate { $0.completed }
            )
            let exerciseResults = try modelContext.fetch(exerciseDescriptor)
            completedExercises = exerciseResults.count
            correctExercises = exerciseResults.filter(\.correct).count
            completedExerciseIDs = Set(exerciseResults.map(\.exerciseId))

            let streakDescriptor = FetchDescriptor<DailyStreak>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let streaks = try modelContext.fetch(streakDescriptor)
            currentStreak = calculateStreak(from: streaks)

            totalXP = streaks.reduce(0) { $0 + $1.xpEarned }
            refreshBookmarks()
        } catch {
            print("Failed to fetch progress: \(error)")
        }
    }

    func markLessonCompleted(_ lessonId: String, quizScore: Int? = nil) {
        let descriptor = FetchDescriptor<UserProgress>(
            predicate: #Predicate<UserProgress> { progress in
                progress.lessonId == lessonId
            }
        )

        do {
            let existing = try modelContext.fetch(descriptor)
            if let progress = existing.first {
                progress.completed = true
                progress.completedAt = Date()
                progress.quizScore = quizScore
            } else {
                let progress = UserProgress(
                    lessonId: lessonId,
                    completed: true,
                    completedAt: Date(),
                    quizScore: quizScore
                )
                modelContext.insert(progress)
            }
            addXP(AppTheme.xpPerLesson)
            try modelContext.save()
            refresh()
        } catch {
            print("Failed to save lesson progress: \(error)")
        }
    }

    func markExerciseCompleted(_ exerciseId: String, correct: Bool, xp: Int) {
        let descriptor = FetchDescriptor<ExerciseProgress>(
            predicate: #Predicate<ExerciseProgress> { progress in
                progress.exerciseId == exerciseId
            }
        )

        do {
            let existing = try modelContext.fetch(descriptor)
            if let progress = existing.first {
                progress.attempts += 1
                if correct {
                    progress.correct = true
                    progress.completed = true
                    progress.completedAt = Date()
                }
            } else {
                let progress = ExerciseProgress(
                    exerciseId: exerciseId,
                    completed: correct,
                    correct: correct,
                    completedAt: correct ? Date() : nil,
                    attempts: 1
                )
                modelContext.insert(progress)
            }
            if correct {
                addXP(xp)
            }
            try modelContext.save()
            refresh()
        } catch {
            print("Failed to save exercise progress: \(error)")
        }
    }

    func isLessonCompleted(_ lessonId: String) -> Bool {
        completedLessonIDs.contains(lessonId)
    }

    func isExerciseCompleted(_ exerciseId: String) -> Bool {
        completedExerciseIDs.contains(exerciseId)
    }

    func topicProgress(topic: String, track: Track, contentService: ContentService) -> Double {
        let lessons = contentService.lessons(for: track, topic: topic)
        let exercises = contentService.exercises(for: track, topic: topic)
        let totalItems = lessons.count + exercises.count
        guard totalItems > 0 else { return 0 }

        var completed = 0
        for lesson in lessons {
            if isLessonCompleted(lesson.id) { completed += 1 }
        }
        for exercise in exercises {
            if isExerciseCompleted(exercise.id) { completed += 1 }
        }
        return Double(completed) / Double(totalItems)
    }

    private func addXP(_ amount: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let descriptor = FetchDescriptor<DailyStreak>(
            predicate: #Predicate<DailyStreak> { streak in
                streak.date >= today
            }
        )

        do {
            let existing = try modelContext.fetch(descriptor)
            if let todayStreak = existing.first {
                todayStreak.xpEarned += amount
                todayStreak.exercisesCompleted += 1
            } else {
                let streak = DailyStreak(date: today, exercisesCompleted: 1, xpEarned: amount)
                modelContext.insert(streak)
            }
        } catch {
            print("Failed to update daily streak: \(error)")
        }
    }

    private func calculateStreak(from streaks: [DailyStreak]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        for dailyStreak in streaks {
            let streakDate = calendar.startOfDay(for: dailyStreak.date)
            if streakDate == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if streakDate < checkDate {
                break
            }
        }
        return streak
    }

    private func refreshBookmarks() {
        let descriptor = FetchDescriptor<Bookmark>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let bookmarks = (try? modelContext.fetch(descriptor)) ?? []
        cachedBookmarks = bookmarks
        bookmarkIDs = Set(bookmarks.map(\.itemId))
    }

    // MARK: - Bookmarks

    func toggleBookmark(itemId: String, itemType: String, title: String) {
        let descriptor = FetchDescriptor<Bookmark>(
            predicate: #Predicate<Bookmark> { $0.itemId == itemId }
        )

        do {
            let existing = try modelContext.fetch(descriptor)
            if let bookmark = existing.first {
                modelContext.delete(bookmark)
            } else {
                let bookmark = Bookmark(itemId: itemId, itemType: itemType, title: title)
                modelContext.insert(bookmark)
            }
            try modelContext.save()
            refreshBookmarks()
        } catch {
            print("Failed to toggle bookmark: \(error)")
        }
    }

    func isBookmarked(_ itemId: String) -> Bool {
        bookmarkIDs.contains(itemId)
    }

    func allBookmarks() -> [Bookmark] {
        cachedBookmarks
    }

    func resetAllProgress() {
        do {
            try modelContext.fetch(FetchDescriptor<UserProgress>()).forEach(modelContext.delete)
            try modelContext.fetch(FetchDescriptor<ExerciseProgress>()).forEach(modelContext.delete)
            try modelContext.fetch(FetchDescriptor<Bookmark>()).forEach(modelContext.delete)
            try modelContext.fetch(FetchDescriptor<DailyStreak>()).forEach(modelContext.delete)
            try modelContext.fetch(FetchDescriptor<Achievement>()).forEach(modelContext.delete)

            try modelContext.save()
            refresh()
        } catch {
            print("Failed to reset progress: \(error)")
        }
    }
}
