import SwiftUI

struct LessonsListView: View {
    @Environment(ContentService.self) private var contentService
    @Environment(ProgressService.self) private var progressService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift

    @State private var searchText = ""
    @State private var expandedTopics: Set<String> = []
    @State private var navigationPath = NavigationPath()

    private var tracks: [Track] {
        if selectedTrack == .general {
            return [.general]
        }
        return [selectedTrack, .general]
    }

    private var allTopics: [Topic] {
        tracks.flatMap { contentService.topics(for: $0) }
    }

    private var filteredTopics: [Topic] {
        if searchText.isEmpty {
            return allTopics
        }
        return allTopics.filter { topic in
            let topicLessons = contentService.lessons(for: topic.track, topic: topic.id.replacingOccurrences(of: "\(topic.track.rawValue)_", with: ""))
            let matchesTopic = topic.name.localizedCaseInsensitiveContains(searchText)
            let matchesLesson = topicLessons.contains {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.compactListTitle.localizedCaseInsensitiveContains(searchText)
            }
            return matchesTopic || matchesLesson
        }
    }

    private var duplicateTopicNames: Set<String> {
        let names = filteredTopics.map(\.name)
        return Set(names.filter { candidate in names.filter { $0 == candidate }.count > 1 })
    }

    private func lessonsForTopic(_ topic: Topic) -> [Lesson] {
        let rawTopic = topic.id.replacingOccurrences(of: "\(topic.track.rawValue)_", with: "")
        let lessons = contentService.lessons(for: topic.track, topic: rawTopic)
        if searchText.isEmpty {
            return lessons
        }
        return lessons.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.compactListTitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func completedCount(for topic: Topic) -> Int {
        lessonsForTopic(topic).filter { progressService.isLessonCompleted($0.id) }.count
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                if filteredTopics.isEmpty {
                    emptyStateView
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredTopics) { topic in
                        topicSection(topic)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Lessons")
            .searchable(text: $searchText, prompt: "Search lessons...")
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
        }
    }

    // MARK: - Topic Section

    @ViewBuilder
    private func topicSection(_ topic: Topic) -> some View {
        let isExpanded = expandedTopics.contains(topic.id)
        let lessons = lessonsForTopic(topic)
        let completed = completedCount(for: topic)
        let total = lessons.count

        Section {
            if isExpanded {
                ForEach(lessons) { lesson in
                    NavigationLink(value: lesson) {
                        lessonRow(lesson)
                    }
                }
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded {
                        expandedTopics.remove(topic.id)
                    } else {
                        expandedTopics.insert(topic.id)
                    }
                }
            } label: {
                HStack(spacing: AppTheme.spacing) {
                    Image(systemName: topic.icon)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    Text(topic.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    if duplicateTopicNames.contains(topic.name) || (topic.track == .general && selectedTrack != .general) {
                        TrackBadge(track: topic.track)
                    }

                    Spacer()

                    Text("\(completed)/\(total) complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Lesson Row

    private func lessonRow(_ lesson: Lesson) -> some View {
        let isCompleted = progressService.isLessonCompleted(lesson.id)

        return HStack(spacing: AppTheme.spacing) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.body)
                .foregroundStyle(isCompleted ? AppTheme.accent : Color(.quaternaryLabel))

            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.compactListTitle)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(lesson.difficulty.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: AppTheme.padding) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)

            Text("No lessons found")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - Hashable conformance for navigation

extension Lesson: Hashable {
    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    LessonsListView()
        .environment(ContentService())
}
