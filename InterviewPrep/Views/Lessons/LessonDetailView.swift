import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson

    @Environment(ProgressService.self) private var progressService
    @State private var showQuiz = false

    private var isCompleted: Bool {
        progressService.isLessonCompleted(lesson.id)
    }

    private var isBookmarked: Bool {
        progressService.isBookmarked(lesson.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                contentSections
                codeExamplesSection
                keyTakeawaysSection
                quizSection
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    progressService.toggleBookmark(
                        itemId: lesson.id,
                        itemType: "lesson",
                        title: lesson.title
                    )
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isBookmarked ? AppTheme.accent : .secondary)
                }
            }
        }
        .sheet(isPresented: $showQuiz) {
            NavigationStack {
                LessonQuizView(
                    lesson: lesson,
                    questions: lesson.miniQuiz
                )
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text(lesson.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            HStack(spacing: AppTheme.spacing) {
                Text(lesson.difficulty.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("·")
                    .foregroundStyle(.tertiary)

                Text(lesson.track.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if isCompleted {
                    Spacer()
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !lesson.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(lesson.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                    }
                }
            }
        }
        .padding(AppTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.primaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Content Sections

    private var contentSections: some View {
        VStack(alignment: .leading, spacing: AppTheme.padding) {
            ForEach(lesson.content) { section in
                VStack(alignment: .leading, spacing: 10) {
                    Text(section.heading)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(section.body)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    if let codeSnippet = section.codeSnippet, !codeSnippet.isEmpty {
                        CodeBlockView(code: codeSnippet, language: codeLanguage)
                    }
                }

                if section.id != lesson.content.last?.id {
                    Divider()
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(AppTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.primaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Code Examples

    @ViewBuilder
    private var codeExamplesSection: some View {
        if !lesson.codeExamples.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.padding) {
                Label("Code Examples", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.headline)
                    .foregroundStyle(.primary)

                ForEach(lesson.codeExamples) { example in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(example.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        CodeBlockView(code: example.code, language: example.language)

                        Text(example.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if example.id != lesson.codeExamples.last?.id {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
            }
            .padding(AppTheme.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.primaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    // MARK: - Key Takeaways

    @ViewBuilder
    private var keyTakeawaysSection: some View {
        if !lesson.keyTakeaways.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                Text("Key Takeaways")
                    .font(.headline)
                    .foregroundStyle(.primary)

                ForEach(Array(lesson.keyTakeaways.enumerated()), id: \.offset) { _, takeaway in
                    HStack(alignment: .top, spacing: 8) {
                        Text("--")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)

                        Text(takeaway)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(AppTheme.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.primaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    // MARK: - Quiz Section

    @ViewBuilder
    private var quizSection: some View {
        if !lesson.miniQuiz.isEmpty {
            Button {
                showQuiz = true
            } label: {
                HStack {
                    Text("Take Quiz")
                        .font(.headline)
                    Spacer()
                    Text("\(lesson.miniQuiz.count) question\(lesson.miniQuiz.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    Image(systemName: "arrow.right")
                        .font(.subheadline)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - Helpers

    private var codeLanguage: String {
        switch lesson.track {
        case .flutter: "Dart"
        case .swift: "Swift"
        case .general: "Code"
        }
    }
}

// MARK: - Flow Layout for tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(
            lesson: Lesson(
                id: "preview",
                track: .swift,
                topic: "swift_basics",
                title: "Introduction to Swift",
                difficulty: .easy,
                content: [
                    LessonSection(id: "s1", heading: "What is Swift?", body: "Swift is a powerful and intuitive programming language developed by Apple.", codeSnippet: "let greeting = \"Hello, Swift!\"")
                ],
                codeExamples: [
                    CodeExample(id: "e1", title: "Variables", code: "var name = \"Swift\"\nlet version = 5", language: "Swift", explanation: "Use var for mutable and let for immutable values.")
                ],
                keyTakeaways: ["Swift is type-safe", "Swift uses value types extensively"],
                miniQuiz: [
                    QuizQuestion(id: "q1", question: "What keyword declares a constant?", options: ["var", "let", "const", "final"], correctAnswer: 1, explanation: "let is used for constants.")
                ],
                tags: ["basics", "introduction"],
                orderIndex: 0
            )
        )
    }
}
