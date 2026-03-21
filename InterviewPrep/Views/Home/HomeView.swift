import SwiftUI

struct HomeView: View {
    @Environment(ContentService.self) private var contentService
    @Environment(ProgressService.self) private var progressService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift

    @State private var dailyChallenge: Exercise?

    private var availableTracks: [Track] {
        if selectedTrack == .general {
            return [.general]
        }
        return [selectedTrack, .general]
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
                .foregroundStyle(.secondary)
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
                    TopicRow(
                        topic: topic,
                        progress: progressService.topicProgress(
                            topic: rawTopicName(for: topic),
                            track: topic.track,
                            contentService: contentService
                        ),
                        showsTrackBadge: duplicateTopicNames.contains(topic.name)
                    )
                }
            }
        }
    }

    private var trackPicker: some View {
        Menu {
            ForEach(Track.allCases) { track in
                Button {
                    selectedTrack = track
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

    private func rawTopicName(for topic: Topic) -> String {
        topic.id.replacingOccurrences(of: "\(topic.track.rawValue)_", with: "")
    }

    private func randomDailyChallenge() -> Exercise? {
        let exercises = availableTracks.flatMap { contentService.exercises(for: $0) }
        return exercises.randomElement()
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
}
