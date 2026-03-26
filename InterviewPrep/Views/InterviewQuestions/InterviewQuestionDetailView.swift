import SwiftUI

struct InterviewQuestionDetailView: View {
    let question: InterviewQuestion

    @Environment(ProgressService.self) private var progressService

    @State private var showHint = false
    @State private var showAnswer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header
                questionHeader

                // MARK: - Question Text
                questionSection

                // MARK: - Think First
                thinkFirstSection

                // MARK: - Reveal Answer
                revealAnswerSection

                // MARK: - Code Snippet
                if let code = question.codeSnippet, !code.isEmpty {
                    codeSnippetSection(code: code)
                }

                // MARK: - Follow-up Questions
                if !question.followUpQuestions.isEmpty {
                    followUpSection
                }

                // MARK: - Common Mistakes
                if !question.commonMistakes.isEmpty {
                    commonMistakesSection
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.top, AppTheme.spacing)
        }
        .navigationTitle("Question")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    progressService.toggleBookmark(
                        itemId: question.id,
                        itemType: "interview_question",
                        title: question.title
                    )
                } label: {
                    Image(systemName: progressService.isBookmarked(question.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(
                            progressService.isBookmarked(question.id) ? AppTheme.accent : .secondary
                        )
                }
            }
        }
    }

    // MARK: - Header

    private var questionHeader: some View {
        HStack(spacing: AppTheme.spacing) {
            Text(question.category.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.quaternary)

            Text(question.difficulty.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    // MARK: - Question

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text(question.title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(question.question)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Think First

    private var thinkFirstSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showHint.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text("Think First")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: showHint ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(AppTheme.padding)
            }
            .buttonStyle(.plain)

            if showHint {
                Divider()
                    .padding(.horizontal, AppTheme.padding)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Before revealing the answer, consider:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    bulletPoint("What are the key concepts involved?")
                    bulletPoint("Can you explain it in simple terms?")
                    bulletPoint("What real-world examples can you think of?")
                    bulletPoint("How would you structure your response?")
                }
                .padding(AppTheme.padding)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundStyle(.tertiary)
                .padding(.top, 7)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Reveal Answer

    private var revealAnswerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !showAnswer {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAnswer = true
                    }
                    ReviewRequestService.recordAction()
                } label: {
                    HStack {
                        Image(systemName: "eye")
                        Text("Show Answer")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(AppTheme.padding)
                    .foregroundStyle(AppTheme.accent)
                    .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
                }
                .buttonStyle(.plain)
            } else {
                VStack(alignment: .leading, spacing: AppTheme.spacing) {
                    HStack {
                        Text("Model Answer")
                            .font(.headline)

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showAnswer = false
                            }
                        } label: {
                            Image(systemName: "eye.slash")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Divider()

                    Text(question.modelAnswer)
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.primary)
                }
                .padding(AppTheme.padding)
                .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
                .transition(.opacity)
            }
        }
    }

    // MARK: - Code Snippet

    private func codeSnippetSection(code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Code Snippet")
                .font(.headline)

            CodeBlockView(
                code: code,
                language: question.track == .swift ? "Swift" :
                          question.track == .flutter ? "Dart" : nil
            )
        }
    }

    // MARK: - Follow-up Questions

    private var followUpSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text("Follow-up Questions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(question.followUpQuestions.enumerated()), id: \.offset) { index, followUp in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()

                        Text(followUp)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineSpacing(2)
                    }
                }
            }
        }
        .padding(AppTheme.padding)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Common Mistakes

    private var commonMistakesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text("Common Mistakes")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(question.commonMistakes.enumerated()), id: \.offset) { _, mistake in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 4))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 7)

                        Text(mistake)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                }
            }
        }
        .padding(AppTheme.padding)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        InterviewQuestionDetailView(
            question: InterviewQuestion(
                id: "preview_1",
                track: .swift,
                topic: "swiftui",
                category: .conceptual,
                difficulty: .medium,
                title: "What is the difference between @State and @Binding?",
                question: "Explain the difference between @State and @Binding property wrappers in SwiftUI. When would you use each one, and how do they relate to data flow in a SwiftUI application?",
                modelAnswer: "@State is a property wrapper that creates a source of truth for value types within a view. It should be used for private, local state that is owned by the view. When the state changes, SwiftUI automatically re-renders the view.\n\n@Binding creates a two-way connection to a source of truth owned by another view. It doesn't store data itself but rather provides read-write access to an existing piece of state.\n\nUse @State when the view owns the data, and @Binding when a child view needs to read and modify a parent's state.",
                followUpQuestions: [
                    "How does @StateObject differ from @State?",
                    "What happens if you use @State for a reference type?"
                ],
                commonMistakes: [
                    "Using @State for data that should be shared across multiple views",
                    "Forgetting that @State should be private to the view"
                ],
                codeSnippet: "struct ParentView: View {\n    @State private var isOn = false\n    \n    var body: some View {\n        ChildView(isOn: $isOn)\n    }\n}\n\nstruct ChildView: View {\n    @Binding var isOn: Bool\n    \n    var body: some View {\n        Toggle(\"Toggle\", isOn: $isOn)\n    }\n}",
                tags: ["swiftui", "state", "binding"],
                orderIndex: 1
            )
        )
    }
}
