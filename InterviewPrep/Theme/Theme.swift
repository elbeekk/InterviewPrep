import SwiftUI

enum AppTheme {
    // Single accent color aligned with Apple's default blue tint
    static let accent = Color.accentColor

    // Feedback colors — subtle tints only, never full-screen
    static let correct = Color(.systemGreen)
    static let incorrect = Color(.systemRed)

    // Backgrounds — used for non-glass fallback contexts
    static let primaryBackground = Color(.secondarySystemGroupedBackground)
    static let secondaryBackground = Color(.tertiarySystemGroupedBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)

    // Shapes
    static let cardShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    // Code
    static let codeFont = Font.system(.body, design: .monospaced)
    static let codeFontSmall = Font.system(.caption, design: .monospaced)
    static let codeBackground = Color(.secondarySystemBackground)

    // Layout
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 12

    // XP
    static let xpPerExercise = 10
    static let xpPerLesson = 25
    static let xpPerQuiz = 50
}
