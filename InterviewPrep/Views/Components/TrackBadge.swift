import SwiftUI

struct TrackBadge: View {
    let track: Track

    var body: some View {
        Text(track.shortDisplayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: 8) {
        TrackBadge(track: .swift)
        TrackBadge(track: .flutter)
        TrackBadge(track: .general)
    }
    .padding()
}
