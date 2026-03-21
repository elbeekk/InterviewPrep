import SwiftUI

struct BookmarksView: View {
    @Environment(ProgressService.self) private var progressService
    @State private var searchText = ""

    private var bookmarks: [Bookmark] {
        let all = progressService.allBookmarks()
        if searchText.isEmpty { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    private var lessonBookmarks: [Bookmark] {
        bookmarks.filter { $0.itemType == "lesson" }
    }

    private var exerciseBookmarks: [Bookmark] {
        bookmarks.filter { $0.itemType == "exercise" }
    }

    private var questionBookmarks: [Bookmark] {
        bookmarks.filter { $0.itemType == "interview_question" }
    }

    private var hasBookmarks: Bool {
        !bookmarks.isEmpty
    }

    var body: some View {
        Group {
            if hasBookmarks {
                bookmarksList
            } else {
                emptyState
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search bookmarks...")
    }

    // MARK: - Bookmarks List

    private var bookmarksList: some View {
        List {
            if !lessonBookmarks.isEmpty {
                Section {
                    ForEach(lessonBookmarks, id: \.itemId) { bookmark in
                        BookmarkRow(bookmark: bookmark, typeBadge: "Lesson", badgeColor: AppTheme.accent)
                    }
                    .onDelete { indexSet in
                        deleteBookmarks(from: lessonBookmarks, at: indexSet)
                    }
                } header: {
                    Label("Lessons", systemImage: "book.fill")
                }
            }

            if !exerciseBookmarks.isEmpty {
                Section {
                    ForEach(exerciseBookmarks, id: \.itemId) { bookmark in
                        BookmarkRow(bookmark: bookmark, typeBadge: "Exercise", badgeColor: AppTheme.accent)
                    }
                    .onDelete { indexSet in
                        deleteBookmarks(from: exerciseBookmarks, at: indexSet)
                    }
                } header: {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
            }

            if !questionBookmarks.isEmpty {
                Section {
                    ForEach(questionBookmarks, id: \.itemId) { bookmark in
                        BookmarkRow(bookmark: bookmark, typeBadge: "Question", badgeColor: AppTheme.accent)
                    }
                    .onDelete { indexSet in
                        deleteBookmarks(from: questionBookmarks, at: indexSet)
                    }
                } header: {
                    Label("Interview Questions", systemImage: "questionmark.bubble.fill")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "bookmark")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("No Bookmarks Yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Save lessons, exercises, and interview questions\nfor quick access later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func deleteBookmarks(from list: [Bookmark], at offsets: IndexSet) {
        for index in offsets {
            let bookmark = list[index]
            progressService.toggleBookmark(
                itemId: bookmark.itemId,
                itemType: bookmark.itemType,
                title: bookmark.title
            )
        }
    }
}

// MARK: - Bookmark Row

private struct BookmarkRow: View {
    let bookmark: Bookmark
    let typeBadge: String
    let badgeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(typeBadge)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(badgeColor.opacity(0.12))
                            .foregroundStyle(badgeColor)
                            .clipShape(Capsule())

                        Text(bookmark.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Image(systemName: "bookmark.fill")
                    .font(.caption)
                    .foregroundStyle(badgeColor)
            }

            if let note = bookmark.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BookmarksView()
    }
}
