import SwiftUI

struct InterviewQuestionsListView: View {
    @Environment(ContentService.self) private var contentService
    @Environment(ProgressService.self) private var progressService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift

    @State private var selectedCategory: InterviewQuestionCategory?
    @State private var selectedDifficulty: Difficulty?
    @State private var searchText = ""

    private struct QuestionSection: Identifiable {
        let id: String
        let title: String
        let rawTopic: String
        let track: Track
        let questions: [InterviewQuestion]
    }

    private var availableTracks: [Track] {
        if selectedTrack == .general {
            return [.general]
        }
        return [selectedTrack, .general]
    }

    private var filteredQuestions: [InterviewQuestion] {
        var questions = availableTracks.flatMap {
            contentService.interviewQuestions(for: $0, category: selectedCategory)
        }
        .sorted { lhs, rhs in
            if lhs.topic == rhs.topic {
                return lhs.orderIndex < rhs.orderIndex
            }
            return contentService.compareTopics(
                lhsTopic: lhs.topic,
                lhsTrack: lhs.track,
                rhsTopic: rhs.topic,
                rhsTrack: rhs.track,
                selectedTrack: selectedTrack
            )
        }

        if let difficulty = selectedDifficulty {
            questions = questions.filter { $0.difficulty == difficulty }
        }

        if !searchText.isEmpty {
            questions = questions.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.compactListTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return questions
    }

    private var groupedQuestions: [QuestionSection] {
        let grouped = Dictionary(grouping: filteredQuestions) { question in
            "\(question.track.rawValue)|\(question.topic)"
        }

        return grouped.compactMap { _, questions in
            guard let first = questions.first else { return nil }
            return QuestionSection(
                id: "\(first.track.rawValue)|\(first.topic)",
                title: first.topic.replacingOccurrences(of: "_", with: " ").capitalized,
                rawTopic: first.topic,
                track: first.track,
                questions: questions.sorted { $0.orderIndex < $1.orderIndex }
            )
        }
        .sorted { lhs, rhs in
            contentService.compareTopics(
                lhsTopic: lhs.rawTopic,
                lhsTrack: lhs.track,
                rhsTopic: rhs.rawTopic,
                rhsTrack: rhs.track,
                selectedTrack: selectedTrack
            )
        }
    }

    private var duplicateSectionTitles: Set<String> {
        let titles = groupedQuestions.map(\.title)
        return Set(titles.filter { candidate in titles.filter { $0 == candidate }.count > 1 })
    }

    var body: some View {
        NavigationStack {
            List {
                if groupedQuestions.isEmpty {
                    emptyStateView
                } else {
                    ForEach(groupedQuestions) { section in
                        Section {
                            ForEach(section.questions) { question in
                                NavigationLink(value: question.id) {
                                    QuestionRow(question: question)
                                }
                            }
                        } header: {
                            HStack(spacing: 8) {
                                Text(section.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .textCase(nil)

                                if duplicateSectionTitles.contains(section.title) || (section.track == .general && selectedTrack != .general) {
                                    TrackBadge(track: section.track)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Interview Questions")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search questions...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .navigationDestination(for: String.self) { questionId in
                if let question = question(for: questionId) {
                    InterviewQuestionDetailView(question: question)
                }
            }
            .onAppear {
                contentService.loadContent()
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Questions Found",
            systemImage: "magnifyingglass",
            description: Text("Try adjusting your filters or search terms.")
        )
    }

    private func question(for id: String) -> InterviewQuestion? {
        filteredQuestions.first(where: { $0.id == id })
            ?? availableTracks
                .flatMap { contentService.interviewQuestions(for: $0) }
                .first(where: { $0.id == id })
    }

    private var filterMenu: some View {
        Menu {
            Section("Category") {
                Button {
                    selectedCategory = nil
                } label: {
                    if selectedCategory == nil {
                        Label("All Categories", systemImage: "checkmark")
                    } else {
                        Text("All Categories")
                    }
                }

                ForEach(InterviewQuestionCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        if selectedCategory == category {
                            Label(category.displayName, systemImage: "checkmark")
                        } else {
                            Text(category.displayName)
                        }
                    }
                }
            }

            Section("Difficulty") {
                Button {
                    selectedDifficulty = nil
                } label: {
                    if selectedDifficulty == nil {
                        Label("All Levels", systemImage: "checkmark")
                    } else {
                        Text("All Levels")
                    }
                }

                ForEach(Difficulty.allCases) { difficulty in
                    Button {
                        selectedDifficulty = difficulty
                    } label: {
                        if selectedDifficulty == difficulty {
                            Label(difficulty.displayName, systemImage: "checkmark")
                        } else {
                            Text(difficulty.displayName)
                        }
                    }
                }
            }

            if selectedCategory != nil || selectedDifficulty != nil {
                Button("Clear Filters") {
                    selectedCategory = nil
                    selectedDifficulty = nil
                }
            }
        } label: {
            Image(systemName: selectedCategory == nil && selectedDifficulty == nil
                ? "line.3.horizontal.decrease.circle"
                : "line.3.horizontal.decrease.circle.fill"
            )
        }
        .accessibilityLabel("Filter interview questions")
    }

}

private struct QuestionRow: View {
    let question: InterviewQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question.compactListTitle)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(2)

            HStack(spacing: AppTheme.spacing) {
                Label(question.category.displayName, systemImage: question.category.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(question.difficulty.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    InterviewQuestionsListView()
        .environment(ContentService())
}
