import SwiftUI

struct ExerciseListView: View {
    @Environment(ContentService.self) private var contentService
    @Environment(ProgressService.self) private var progressService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift

    @State private var selectedFilter: ExerciseTypeFilter = .all
    @State private var searchText = ""

    enum ExerciseTypeFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case mcq = "MCQ"
        case trueFalse = "True/False"
        case fillBlank = "Fill Blank"
        case reorder = "Reorder"
        case matchPairs = "Match"

        var id: String { rawValue }

        var exerciseType: ExerciseType? {
            switch self {
            case .all: nil
            case .mcq: .mcq
            case .trueFalse: .trueFalse
            case .fillBlank: .fillBlank
            case .reorder: .reorder
            case .matchPairs: .matchPairs
            }
        }
    }

    private struct ExerciseSection: Identifiable {
        let id: String
        let title: String
        let rawTopic: String
        let track: Track
        let exercises: [Exercise]
    }

    private var filteredExercises: [Exercise] {
        let trackExercises = contentService.exercises(for: selectedTrack, type: selectedFilter.exerciseType)
        let generalExercises = selectedTrack != .general
            ? contentService.exercises(for: .general, type: selectedFilter.exerciseType)
            : []
        let combined = trackExercises + generalExercises

        if searchText.isEmpty {
            return combined
        }
        return combined.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.compactListTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.topic.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedExercises: [ExerciseSection] {
        let grouped = Dictionary(grouping: filteredExercises) { exercise in
            "\(exercise.track.rawValue)|\(exercise.topic)"
        }

        return grouped.compactMap { _, exercises in
            guard let first = exercises.first else { return nil }
            return ExerciseSection(
                id: "\(first.track.rawValue)|\(first.topic)",
                title: first.topic.replacingOccurrences(of: "_", with: " ").capitalized,
                rawTopic: first.topic,
                track: first.track,
                exercises: exercises.sorted { $0.orderIndex < $1.orderIndex }
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
        let titles = groupedExercises.map(\.title)
        return Set(titles.filter { candidate in titles.filter { $0 == candidate }.count > 1 })
    }

    var body: some View {
        exerciseList
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                filterMenu
            }
        }
    }

    private var exerciseList: some View {
        List {
            if groupedExercises.isEmpty {
                ContentUnavailableView(
                    "No Exercises Found",
                    systemImage: "dumbbell",
                    description: Text("Try changing your filter or search term.")
                )
            } else {
                ForEach(groupedExercises) { section in
                    Section {
                        ForEach(section.exercises) { exercise in
                            NavigationLink(value: exercise) {
                                ExerciseRowView(
                                    exercise: exercise,
                                    isCompleted: progressService.isExerciseCompleted(exercise.id)
                                )
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
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseView(exercise: exercise)
        }
    }

    private var filterMenu: some View {
        Menu {
            ForEach(ExerciseTypeFilter.allCases) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    if selectedFilter == filter {
                        Label(filter.rawValue, systemImage: "checkmark")
                    } else {
                        Text(filter.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: selectedFilter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Filter exercises")
        .accessibilityValue(selectedFilter.rawValue)
    }

}

// MARK: - Exercise Row

private struct ExerciseRowView: View {
    let exercise: Exercise
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            Circle()
                .fill(isCompleted ? AppTheme.correct : Color(.systemGray4))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.compactListTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(exerciseTypeLabel(exercise.type))
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Text(exercise.difficulty.displayName)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func exerciseTypeLabel(_ type: ExerciseType) -> String {
        switch type {
        case .mcq: "MCQ"
        case .trueFalse: "True/False"
        case .fillBlank: "Fill Blank"
        case .reorder: "Reorder"
        case .matchPairs: "Match"
        case .spotBug: "Spot Bug"
        case .predictOutput: "Predict"
        case .swipe: "Swipe"
        }
    }
}

// MARK: - Make Exercise Hashable for NavigationLink

extension Exercise: Hashable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
}
