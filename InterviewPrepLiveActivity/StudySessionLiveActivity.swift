import ActivityKit
import SwiftUI
import WidgetKit

struct StudySessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudySessionActivityAttributes.self) { context in
            StudySessionLockScreenView(context: context)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.systemImageName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(accentColor(for: context.state.phase)))
                        .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(progressLabel(for: context.state))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(minWidth: 52)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)

                        Text(context.state.statusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: context.state.progress)
                            .tint(accentColor(for: context.state.phase))

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(phaseLabel(for: context.state.phase))
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(accentColor(for: context.state.phase))

                            Text(context.state.detailText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                }
            } compactLeading: {
                Image(systemName: context.attributes.systemImageName)
                    .foregroundStyle(accentColor(for: context.state.phase))
            } compactTrailing: {
                Text(compactProgressLabel(for: context.state))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: true, vertical: false)
            } minimal: {
                Image(systemName: context.attributes.systemImageName)
                    .foregroundStyle(accentColor(for: context.state.phase))
            }
            .contentMargins(.horizontal, 16, for: .expanded)
            .contentMargins(.vertical, 12, for: .expanded)
        }
    }

    private func progressLabel(for state: StudySessionActivityAttributes.ContentState) -> String {
        "\(state.completedSteps)/\(max(state.totalSteps, 1))"
    }

    private func compactProgressLabel(for state: StudySessionActivityAttributes.ContentState) -> String {
        if state.totalSteps <= 1 {
            return state.phase == .completed ? "Done" : "Go"
        }
        return "\(state.completedSteps)/\(state.totalSteps)"
    }

    private func phaseLabel(for phase: StudySessionActivityAttributes.ContentState.Phase) -> String {
        switch phase {
        case .active:
            return "Active"
        case .completed:
            return "Done"
        case .review:
            return "Review"
        }
    }

    private func accentColor(for phase: StudySessionActivityAttributes.ContentState.Phase) -> Color {
        switch phase {
        case .active:
            return .blue
        case .completed:
            return .green
        case .review:
            return .orange
        }
    }
}

private struct StudySessionLockScreenView: View {
    let context: ActivityViewContext<StudySessionActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: context.attributes.systemImageName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(accentColor))

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(context.state.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(context.state.completedSteps)/\(max(context.state.totalSteps, 1))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text(context.attributes.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }

            ProgressView(value: context.state.progress)
                .tint(accentColor)

            Text(context.state.detailText)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accentColor: Color {
        switch context.state.phase {
        case .active:
            return .blue
        case .completed:
            return .green
        case .review:
            return .orange
        }
    }

}
