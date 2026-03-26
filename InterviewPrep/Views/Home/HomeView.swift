import SwiftUI

struct HomeView: View {
    @Environment(ContentService.self) private var contentService
    @Environment(ProgressService.self) private var progressService
    @Environment(TrackSelectionStore.self) private var trackSelection
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift

    @State private var dailyChallenge: Exercise?

    private var availableTracks: [Track] {
        if selectedTrack == .general {
            return [.general]
        }
        return [selectedTrack, .general]
    }

    private var visibleTopics: [Topic] {
        availableTracks.flatMap { contentService.topics(for: $0) }
    }

    private var duplicateTopicNames: Set<String> {
        let names = visibleTopics.map(\.name)
        return Set(names.filter { candidate in names.filter { $0 == candidate }.count > 1 })
    }

    private var recommendedTopic: Topic? {
        let topicsWithLessons = visibleTopics.filter {
            !contentService.lessons(for: $0.track, topic: $0.rawName).isEmpty
        }

        return topicsWithLessons.first {
            progressService.topicProgress(topic: $0.rawName, track: $0.track, contentService: contentService) < 1
        } ?? topicsWithLessons.first
    }

    private var recommendedLesson: Lesson? {
        guard let topic = recommendedTopic else { return nil }
        return nextLesson(for: topic)
    }

    var body: some View {
        List {
            Section {
                headerSection
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            if let exercise = dailyChallenge {
                Section {
                    DailyChallengeRow(exercise: exercise)
                } header: {
                    Text("Daily Challenge")
                }
            }

            if let topic = recommendedTopic, let lesson = recommendedLesson {
                Section {
                    startHereRow(topic: topic, lesson: lesson)
                } header: {
                    Text("Start Here")
                }
            }

            Section {
                statsRow
            } header: {
                Text("Progress")
            }

            Section {
                continueLearningSectionView
            } header: {
                Text("Continue Learning")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                trackPicker
            }
        }
        .onAppear {
            contentService.loadContent()
            progressService.refresh()
            dailyChallenge = randomDailyChallenge()
        }
        .onChange(of: selectedTrack) {
            dailyChallenge = randomDailyChallenge()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingText)
                .font(.title2)
                .fontWeight(.bold)

            Text("\(progressService.currentLevel.rawValue) level")
                .font(.subheadline)
                .foregroundStyle(AppTheme.accent)
        }
        .padding(.horizontal, AppTheme.padding)
        .padding(.vertical, AppTheme.spacing)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good evening"
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatItem(label: "Streak", value: "\(progressService.currentStreak)")
            Divider()
                .frame(height: 32)
            StatItem(label: "XP", value: "\(progressService.totalXP)")
            Divider()
                .frame(height: 32)
            StatItem(label: "Lessons", value: "\(progressService.completedLessons)")
            Divider()
                .frame(height: 32)
            StatItem(label: "Exercises", value: "\(progressService.completedExercises)")
        }
    }

    // MARK: - Continue Learning

    private var continueLearningSectionView: some View {
        Group {
            if visibleTopics.isEmpty {
                ContentUnavailableView {
                    Label("No Topics", systemImage: "tray")
                } description: {
                    Text("No topics available yet.")
                }
            } else {
                ForEach(visibleTopics.prefix(6)) { topic in
                    if let lesson = nextLesson(for: topic) {
                        NavigationLink {
                            LessonDetailView(lesson: lesson)
                        } label: {
                            topicRow(topic)
                        }
                    } else {
                        topicRow(topic)
                    }
                }
            }
        }
    }

    private func startHereRow(topic: Topic, lesson: Lesson) -> some View {
        let progress = progressService.topicProgress(
            topic: topic.rawName,
            track: topic.track,
            contentService: contentService
        )

        return NavigationLink {
            LessonDetailView(lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: topic.icon)
                        .foregroundStyle(AppTheme.accent)

                    Text(topic.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if topic.track == .general && selectedTrack != .general {
                        TrackBadge(track: topic.track)
                    }

                    Spacer()

                    Text(progress == 0 ? "New" : "\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(AppTheme.accent)
                }

                Text(lesson.compactListTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text("Most useful interview foundations first.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }

    private func topicRow(_ topic: Topic) -> some View {
        TopicRow(
            topic: topic,
            progress: progressService.topicProgress(
                topic: topic.rawName,
                track: topic.track,
                contentService: contentService
            ),
            showsTrackBadge: duplicateTopicNames.contains(topic.name)
        )
    }

    private var trackPicker: some View {
        Menu {
            ForEach(Track.allCases) { track in
                Button {
                    trackSelection.switchTo(track)
                } label: {
                    if selectedTrack == track {
                        Label(track.displayName, systemImage: "checkmark")
                    } else {
                        Label(track.displayName, systemImage: track.icon)
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.headline)
        }
        .accessibilityLabel("Selected track")
        .accessibilityValue(selectedTrack.displayName)
    }

    private func nextLesson(for topic: Topic) -> Lesson? {
        let lessons = contentService.lessons(for: topic.track, topic: topic.rawName)
        return lessons.first { !progressService.isLessonCompleted($0.id) } ?? lessons.first
    }

    private func randomDailyChallenge() -> Exercise? {
        let exercises = availableTracks.flatMap { contentService.exercises(for: $0) }
        return exercises.randomElement()
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(ContentService())
    .environment(TrackSelectionStore())
}
