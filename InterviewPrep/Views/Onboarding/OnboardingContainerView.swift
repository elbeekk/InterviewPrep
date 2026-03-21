import SwiftUI

struct OnboardingContainerView: View {
    private enum Step {
        case welcome
        case trackSelection
        case reminder
    }

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedTrack") private var selectedTrack: String = Track.flutter.rawValue

    @State private var step: Step = .welcome

    var body: some View {
        Group {
            switch step {
            case .welcome:
                WelcomeView(onContinue: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        step = .trackSelection
                    }
                })
                .transition(.move(edge: .leading))
            case .trackSelection:
                TrackSelectionView(
                    selectedTrack: $selectedTrack,
                    onContinue: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            step = .reminder
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            case .reminder:
                ReminderSetupView(onComplete: {
                    hasCompletedOnboarding = true
                })
                .transition(.move(edge: .trailing))
            }
        }
    }
}
