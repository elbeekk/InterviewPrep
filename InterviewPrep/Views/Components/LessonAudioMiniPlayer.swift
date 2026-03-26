import SwiftUI

struct LessonAudioMiniPlayer: View {
    @Environment(LessonAudioPlayerService.self) private var lessonAudioPlayer

    var onNavigateToLesson: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: 14) {
                iconBadge

                VStack(alignment: .leading, spacing: 4) {
                    MarqueeTitleText(
                        text: lessonAudioPlayer.currentTitle,
                        isScrolling: lessonAudioPlayer.isPlaying
                    )
                    .frame(height: 20)

                    Text(lessonAudioPlayer.currentSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(.rect)
            .highPriorityGesture(TapGesture().onEnded {
                onNavigateToLesson()
            })

            HStack(spacing: 8) {
                playerButton(
                    systemImage: lessonAudioPlayer.isPlaying ? "pause.fill" : "play.fill",
                    isEnabled: lessonAudioPlayer.currentLesson != nil,
                    prominence: .primary
                ) {
                    lessonAudioPlayer.togglePlayPause()
                }

                playerButton(
                    systemImage: "goforward.30",
                    isEnabled: lessonAudioPlayer.canSkipForward,
                    prominence: .secondary
                ) {
                    lessonAudioPlayer.skipForward()
                }
            }
            .contentShape(.rect)
            .gesture(TapGesture().onEnded {})
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lesson audio player")
    }

    private var iconBadge: some View {
        Image(systemName: lessonAudioPlayer.currentTrackIcon)
            .font(.body.weight(.semibold))
            .foregroundStyle(AppTheme.accent)
            .frame(width: 38, height: 38)
    }

    private enum ButtonProminence {
        case primary
        case secondary
    }

    private func playerButton(
        systemImage: String,
        isEnabled: Bool,
        prominence: ButtonProminence,
        action: @escaping () -> Void
    ) -> some View {
        Image(systemName: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(foregroundColor(isEnabled: isEnabled, prominence: prominence))
            .frame(width: 40, height: 40)
            .contentShape(.circle)
            .highPriorityGesture(TapGesture().onEnded {
                guard isEnabled else { return }
                action()
            })
    }

    private func foregroundColor(isEnabled: Bool, prominence: ButtonProminence) -> Color {
        guard isEnabled else { return .secondary }
        return prominence == .primary ? AppTheme.accent : .primary
    }
}

private struct MarqueeTitleText: View {
    let text: String
    var isScrolling: Bool = false

    @State private var availableWidth: CGFloat = 0
    @State private var measuredTextWidth: CGFloat = 0
    @State private var animationStart = Date()

    private let spacing: CGFloat = 40
    private let edgeFadeWidth: CGFloat = 10

    private var shouldAnimate: Bool {
        measuredTextWidth > availableWidth + 6 && availableWidth > 0
    }

    private var loopDistance: CGFloat {
        measuredTextWidth + spacing
    }

    private var bounceDistance: CGFloat {
        max(0, measuredTextWidth - availableWidth + spacing)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if shouldAnimate {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    let offset = marqueeOffset(at: context.date)

                    HStack(spacing: spacing) {
                        titleLabel
                            .fixedSize(horizontal: true, vertical: false)

                        titleLabel
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .offset(x: offset)
                }
                .mask(fadeMask)
            } else {
                titleLabel
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .background(widthReader)
        .background(hiddenMeasurement)
        .onAppear {
            animationStart = Date()
        }
        .onChange(of: text) {
            animationStart = Date()
        }
        .onChange(of: shouldAnimate) {
            animationStart = Date()
        }
        .onChange(of: isScrolling) {
            animationStart = Date()
        }
    }

    private var titleLabel: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
    }

    private var hiddenMeasurement: some View {
        titleLabel
            .fixedSize(horizontal: true, vertical: false)
            .hidden()
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: MarqueeTextWidthKey.self, value: geometry.size.width)
                }
            }
            .onPreferenceChange(MarqueeTextWidthKey.self) { measuredTextWidth in
                self.measuredTextWidth = measuredTextWidth
            }
    }

    private var widthReader: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: MarqueeContainerWidthKey.self, value: geometry.size.width)
        }
        .onPreferenceChange(MarqueeContainerWidthKey.self) { availableWidth in
            self.availableWidth = availableWidth
        }
    }

    private var fadeMask: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: min(0.08, edgeFadeWidth / max(availableWidth, 1))),
                .init(color: .black, location: max(0.92, 1 - edgeFadeWidth / max(availableWidth, 1))),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func marqueeOffset(at date: Date) -> CGFloat {
        guard shouldAnimate else { return 0 }

        if isScrolling {
            // Continuous loop: scroll full text width + spacing, then seamlessly restart
            let speed: CGFloat = 30 // points per second
            let elapsed = date.timeIntervalSince(animationStart)
            let offset = CGFloat(elapsed) * speed
            return -(offset.truncatingRemainder(dividingBy: loopDistance))
        } else {
            // Bounce mode: scroll to end, pause, scroll back
            let leadPause: TimeInterval = 1.0
            let trailPause: TimeInterval = 0.8
            let travelDuration = max(6.0, Double(bounceDistance / 26))
            let cycleDuration = leadPause + travelDuration + trailPause
            let progress = date.timeIntervalSince(animationStart).truncatingRemainder(dividingBy: cycleDuration)

            if progress < leadPause {
                return 0
            }

            if progress > leadPause + travelDuration {
                return -bounceDistance
            }

            let traveledRatio = (progress - leadPause) / travelDuration
            return -bounceDistance * traveledRatio
        }
    }
}

private struct MarqueeTextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct MarqueeContainerWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
