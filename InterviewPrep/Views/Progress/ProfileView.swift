import SwiftUI

struct ProfileView: View {
    @Environment(ContentService.self) private var contentService
    @Environment(ProgressService.self) private var progressService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift

    private var availableTracks: [Track] {
        if selectedTrack == .general {
            return [.general]
        }
        return [selectedTrack, .general]
    }

    private var accuracyText: String {
        guard progressService.completedExercises > 0 else { return "0%" }
        let accuracy = Double(progressService.correctExercises) / Double(progressService.completedExercises) * 100
        return "\(Int(accuracy))%"
    }

    private var visibleTopics: [Topic] {
        availableTracks
            .flatMap { contentService.topics(for: $0) }
            .sorted { lhs, rhs in
                if trackSortOrder(lhs.track) == trackSortOrder(rhs.track) {
                    return lhs.name < rhs.name
                }
                return trackSortOrder(lhs.track) < trackSortOrder(rhs.track)
            }
    }

    private var duplicateTopicNames: Set<String> {
        let names = visibleTopics.map(\.name)
        return Set(names.filter { candidate in names.filter { $0 == candidate }.count > 1 })
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: AppTheme.spacing) {
                        Text("\(progressService.currentLevel.rawValue) · \(progressService.totalXP.formatted()) XP")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)

                        if progressService.nextLevel != nil {
                            VStack(spacing: 6) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 4)

                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(AppTheme.accent)
                                            .frame(width: geo.size.width * progressService.levelProgress, height: 4)
                                    }
                                }
                                .frame(height: 4)

                                Text("\(progressService.xpToNextLevel) XP to \(progressService.nextLevel!.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("Max level reached")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Statistics") {
                    StatRow(label: "Total XP", value: "\(progressService.totalXP)")
                    StatRow(label: "Streak", value: "\(progressService.currentStreak) days")
                    StatRow(label: "Lessons", value: "\(progressService.completedLessons)")
                    StatRow(label: "Exercises", value: "\(progressService.completedExercises)")
                    StatRow(label: "Accuracy", value: accuracyText)
                }

                Section("Topic Mastery") {
                    if visibleTopics.isEmpty {
                        Text("No topics available")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(visibleTopics) { topic in
                            let progress = progressService.topicProgress(
                                topic: rawTopicName(for: topic),
                                track: topic.track,
                                contentService: contentService
                            )
                            TopicMasteryRow(
                                topic: topic,
                                progress: progress,
                                showsTrackBadge: duplicateTopicNames.contains(topic.name)
                            )
                        }
                    }
                }

                Section {
                    NavigationLink {
                        BookmarksView()
                    } label: {
                        HStack {
                            Label("Bookmarks", systemImage: "bookmark")
                            Spacer()
                            Text("\(progressService.allBookmarks().count)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                contentService.loadContent()
                progressService.refresh()
            }
        }
    }

    private func rawTopicName(for topic: Topic) -> String {
        topic.id.replacingOccurrences(of: "\(topic.track.rawValue)_", with: "")
    }

    private func trackSortOrder(_ track: Track) -> Int {
        switch track {
        case selectedTrack:
            return 0
        case .general:
            return 1
        default:
            return 2
        }
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

private struct TopicMasteryRow: View {
    let topic: Topic
    let progress: Double
    let showsTrackBadge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(topic.name)
                    .font(.body)

                if showsTrackBadge {
                    TrackBadge(track: topic.track)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            ProgressView(value: progress)
                .tint(progress >= 1.0 ? AppTheme.correct : AppTheme.accent)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ProfileView()
        .environment(ContentService())
}
