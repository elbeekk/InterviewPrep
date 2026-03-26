import StoreKit
import SwiftUI

enum ReviewRequestService {
    private static let actionsKey = "completedActionsCount"
    private static let hasRequestedKey = "hasRequestedReview"

    /// Call after the user completes a meaningful action (exercise, quiz, reading an answer).
    /// Shows the review dialog once, after the first action.
    static func recordAction() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: hasRequestedKey) else { return }

        let count = defaults.integer(forKey: actionsKey) + 1
        defaults.set(count, forKey: actionsKey)

        // Show after the very first completed action
        if count >= 1 {
            defaults.set(true, forKey: hasRequestedKey)
            requestReview()
        }
    }

    private static func requestReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
