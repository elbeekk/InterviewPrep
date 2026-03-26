import SwiftUI

struct TrackSelectionView: View {
    @Binding var selectedTrack: String
    var onContinue: () -> Void

    private let tracks: [Track] = [.flutter, .swift]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Choose Your Track")
                    .font(.title)
                    .fontWeight(.bold)

                Text("You can switch anytime in Settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
                .frame(height: 48)

            VStack(spacing: 12) {
                ForEach(tracks) { track in
                    Button {
                        selectedTrack = track.rawValue
                        onContinue()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: track.icon)
                                .font(.title3)
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.displayName)
                                    .font(.headline)
                                Text(track.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .glassEffect(.regular, in: .rect(cornerRadius: AppTheme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
