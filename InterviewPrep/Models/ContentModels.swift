import Foundation

struct Lesson: Codable, Identifiable {
    let id: String
    let track: Track
    let topic: String
    let title: String
    let difficulty: Difficulty
    let content: [LessonSection]
    let codeExamples: [CodeExample]
    let keyTakeaways: [String]
    let miniQuiz: [QuizQuestion]
    let tags: [String]
    let orderIndex: Int

    enum CodingKeys: String, CodingKey {
        case id, track, topic, title, difficulty, content
        case codeExamples = "code_examples"
        case keyTakeaways = "key_takeaways"
        case miniQuiz = "mini_quiz"
        case tags
        case orderIndex = "order_index"
    }

    var compactListTitle: String {
        ContentTitleFormatter.compact(title)
    }
}

struct LessonSection: Codable, Identifiable {
    let id: String
    let heading: String
    let body: String
    let codeSnippet: String?

    enum CodingKeys: String, CodingKey {
        case id, heading, body
        case codeSnippet = "code_snippet"
    }
}

struct CodeExample: Codable, Identifiable {
    let id: String
    let title: String
    let code: String
    let language: String
    let explanation: String
}

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String

    enum CodingKeys: String, CodingKey {
        case id, question, options
        case correctAnswer = "correct_answer"
        case explanation
    }
}

struct Exercise: Codable, Identifiable {
    let id: String
    let track: Track
    let topic: String
    let type: ExerciseType
    let difficulty: Difficulty
    let title: String
    let question: String?
    let codeSnippet: String?
    let options: [String]?
    let correctAnswer: Int?
    let correctAnswerBool: Bool?
    let explanation: String
    let xp: Int
    let tags: [String]

    // Fill in the blank
    let codeTemplate: String?
    let blanks: [String]?
    let correctTokens: [String]?
    let wordBank: [String]?

    // Reorder
    let shuffledLines: [String]?
    let correctOrder: [Int]?

    // Match pairs
    let leftColumn: [String]?
    let rightColumn: [String]?
    let correctPairs: [Int]?

    // Spot the bug
    let bugLineIndex: Int?
    let fixOptions: [String]?
    let correctFixIndex: Int?

    let orderIndex: Int

    enum CodingKeys: String, CodingKey {
        case id, track, topic, type, difficulty, title, question
        case codeSnippet = "code_snippet"
        case options
        case correctAnswer = "correct_answer"
        case correctAnswerBool = "correct_answer_bool"
        case explanation, xp, tags
        case codeTemplate = "code_template"
        case blanks
        case correctTokens = "correct_tokens"
        case wordBank = "word_bank"
        case shuffledLines = "shuffled_lines"
        case correctOrder = "correct_order"
        case leftColumn = "left_column"
        case rightColumn = "right_column"
        case correctPairs = "correct_pairs"
        case bugLineIndex = "bug_line_index"
        case fixOptions = "fix_options"
        case correctFixIndex = "correct_fix_index"
        case orderIndex = "order_index"
    }

    var compactListTitle: String {
        ContentTitleFormatter.compact(title)
    }
}

struct InterviewQuestion: Codable, Identifiable {
    let id: String
    let track: Track
    let topic: String
    let category: InterviewQuestionCategory
    let difficulty: Difficulty
    let title: String
    let question: String
    let modelAnswer: String
    let followUpQuestions: [String]
    let commonMistakes: [String]
    let codeSnippet: String?
    let tags: [String]
    let orderIndex: Int

    enum CodingKeys: String, CodingKey {
        case id, track, topic, category, difficulty, title, question
        case modelAnswer = "model_answer"
        case followUpQuestions = "follow_up_questions"
        case commonMistakes = "common_mistakes"
        case codeSnippet = "code_snippet"
        case tags
        case orderIndex = "order_index"
    }

    var compactListTitle: String {
        ContentTitleFormatter.compact(title)
    }
}

struct Topic: Identifiable {
    let id: String
    let name: String
    let icon: String
    let track: Track
    let lessonCount: Int
    let exerciseCount: Int
    let questionCount: Int
}

struct ContentBundle: Codable {
    let lessons: [Lesson]
    let exercises: [Exercise]
    let interviewQuestions: [InterviewQuestion]

    enum CodingKeys: String, CodingKey {
        case lessons, exercises
        case interviewQuestions = "interview_questions"
    }
}

private enum ContentTitleFormatter {
    static func compact(_ title: String) -> String {
        if let range = title.range(of: " · ") {
            let base = stripDetails(from: String(title[..<range.lowerBound]))
            let suffix = String(title[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return [base, suffix].filter { !$0.isEmpty }.joined(separator: " · ")
        }

        let mappedSuffixes: [(String, String)] = [
            (" Fill In The Blank", "Fill Blank"),
            (" Match The Ideas", "Match"),
            (" Predict The Outcome", "Predict"),
            (" Workflow", "Reorder"),
            (" Statement", "True / False"),
        ]

        for (suffix, replacement) in mappedSuffixes where title.hasSuffix(suffix) {
            let base = stripDetails(from: String(title.dropLast(suffix.count)))
            return [base, replacement].filter { !$0.isEmpty }.joined(separator: " · ")
        }

        if let range = title.range(of: #" Check \d+$"#, options: .regularExpression) {
            let base = stripDetails(from: String(title[..<range.lowerBound]))
            let suffix = String(title[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return [base, suffix].filter { !$0.isEmpty }.joined(separator: " · ")
        }

        return stripDetails(from: title)
    }

    private static func stripDetails(from title: String) -> String {
        let withoutParentheticals = title.replacingOccurrences(
            of: #"\s*\([^)]*\)"#,
            with: "",
            options: .regularExpression
        )

        return withoutParentheticals
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
