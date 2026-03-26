import SwiftUI

struct LessonDetailView: View {
    @State private var lesson: Lesson
    var scrollToActiveSection: Bool = false

    @Environment(ContentService.self) private var contentService
    @Environment(LessonAudioPlayerService.self) private var lessonAudioPlayer
    @Environment(ProgressService.self) private var progressService

    init(lesson: Lesson, scrollToActiveSection: Bool = false) {
        _lesson = State(initialValue: lesson)
        self.scrollToActiveSection = scrollToActiveSection
    }

    private var isCompleted: Bool {
        progressService.isLessonCompleted(lesson.id)
    }

    private var isBookmarked: Bool {
        progressService.isBookmarked(lesson.id)
    }

    private var lessonQueue: [Lesson] {
        let queue = contentService.lessons(for: lesson.track, topic: lesson.topic)
        return queue.isEmpty ? [lesson] : queue
    }

    private var queuePositionLabel: String? {
        guard
            lessonQueue.count > 1,
            let index = lessonQueue.firstIndex(where: { $0.id == lesson.id })
        else {
            return nil
        }

        return "\(index + 1) of \(lessonQueue.count)"
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    audioPlaybackSection
                    contentSections
                    codeExamplesSection
                    keyTakeawaysSection
                    quizSection
                }
                .padding(.horizontal, AppTheme.padding)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .onAppear {
                if scrollToActiveSection, let sectionId = lessonAudioPlayer.activeSectionId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo(sectionId, anchor: .top)
                        }
                    }
                }
            }
            .onChange(of: lessonAudioPlayer.activeSectionId) { _, newId in
                guard let newId, scrollToActiveSection else { return }
                withAnimation {
                    proxy.scrollTo(newId, anchor: .top)
                }
            }
            .onChange(of: lessonAudioPlayer.scrollToSectionTrigger) {
                guard lessonAudioPlayer.isCurrentLesson(lesson),
                      let sectionId = lessonAudioPlayer.activeSectionId else { return }
                withAnimation {
                    proxy.scrollTo(sectionId, anchor: .top)
                }
            }
        }
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
        .onChange(of: lessonAudioPlayer.currentLesson?.id) {
            guard let currentLesson = lessonAudioPlayer.currentLesson else { return }
            if lessonQueue.contains(where: { $0.id == currentLesson.id }) {
                lesson = currentLesson
            }
        }
    }

    // MARK: - Audio Playback

    private var audioPlaybackSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Label("Lesson Audio", systemImage: "speaker.wave.2.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if let queuePositionLabel {
                    Text(queuePositionLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(audioDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                lessonAudioPlayer.togglePlayback(for: lesson, queue: lessonQueue)
            } label: {
                Label(playbackButtonTitle, systemImage: playbackButtonIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(AppTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
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
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Content Sections

    private var contentSections: some View {
        VStack(alignment: .leading, spacing: AppTheme.padding) {
            ForEach(lesson.content) { section in
                let isActive = lessonAudioPlayer.isCurrentLesson(lesson)
                    && lessonAudioPlayer.isPlaying
                    && lessonAudioPlayer.activeSectionId == section.id

                VStack(alignment: .leading, spacing: 10) {
                    Text(section.heading)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(isActive ? AppTheme.accent : .primary)

                    Text(section.body)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    if let codeSnippet = section.codeSnippet, !codeSnippet.isEmpty {
                        CodeBlockView(code: codeSnippet, language: codeLanguage)
                    }
                }
                .padding(isActive ? 12 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isActive ? AppTheme.accent.opacity(0.08) : .clear)
                )
                .animation(.easeInOut(duration: 0.3), value: isActive)
                .id(section.id)

                if section.id != lesson.content.last?.id {
                    Divider()
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(AppTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
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
            .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
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
            .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
        }
    }

    // MARK: - Quiz Section

    @ViewBuilder
    private var quizSection: some View {
        if !lesson.miniQuiz.isEmpty {
            NavigationLink {
                LessonQuizView(
                    lesson: lesson,
                    questions: lesson.miniQuiz
                )
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
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .glassEffect(.regular.tint(AppTheme.accent), in: .rect(cornerRadius: AppTheme.cornerRadius))
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

    private var playbackButtonTitle: String {
        if lessonAudioPlayer.isCurrentLesson(lesson) {
            return lessonAudioPlayer.isPlaying ? "Pause Narration" : "Resume Narration"
        }

        return "Play Lesson Audio"
    }

    private var playbackButtonIcon: String {
        if lessonAudioPlayer.isCurrentLesson(lesson) {
            return lessonAudioPlayer.isPlaying ? "pause.fill" : "play.fill"
        }

        return "play.fill"
    }

    private var audioDescription: String {
        if lessonQueue.count > 1 {
            return "Text to speech keeps playing across the app, and previous or next controls move through the other lessons in this topic."
        }

        return "Text to speech keeps playing across the app and shows system media controls while this lesson is playing."
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
        let maxWidth = proposal.width ?? .infinity
        for (index, position) in result.positions.enumerated() {
            let remainingWidth = maxWidth - position.x
            let childProposal = ProposedViewSize(width: remainingWidth, height: nil)
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: childProposal)
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
            // Measure with constrained width so long text can wrap
            let proposedWidth = maxWidth - x
            let size = subview.sizeThatFits(ProposedViewSize(width: proposedWidth, height: nil))

            // If it doesn't fit on the current line, start a new row
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            // Re-measure on the new line if we wrapped
            let finalSize: CGSize
            if x == 0 && positions.count > 0 {
                finalSize = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            } else {
                finalSize = size
            }

            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, finalSize.height)
            x += finalSize.width + spacing
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
    .environment(ContentService())
    .environment(LessonAudioPlayerService())
}
