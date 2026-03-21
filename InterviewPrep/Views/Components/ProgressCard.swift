import SwiftUI

struct StatDisplay: View {
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
    }
}

#Preview {
    HStack(spacing: 24) {
        StatDisplay(label: "Streak", value: "5")
        StatDisplay(label: "Lessons", value: "12")
        StatDisplay(label: "Exercises", value: "38")
    }
    .padding()
}
