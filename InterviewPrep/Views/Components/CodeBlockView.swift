import SwiftUI
import UIKit

struct CodeBlockView: View {
    let code: String
    var language: String? = nil
    var showLineNumbers: Bool = true

    @State private var copied = false

    private var lines: [String] {
        code.components(separatedBy: "\n")
    }

    private let backgroundColor = Color(.secondarySystemBackground)
    private let textColor = Color(.label)
    private let lineNumberColor = Color(.tertiaryLabel)

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    if showLineNumbers {
                        VStack(alignment: .trailing, spacing: 0) {
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                                Text("\(index + 1)")
                                    .font(AppTheme.codeFontSmall)
                                    .foregroundStyle(lineNumberColor)
                                    .frame(minWidth: 28, alignment: .trailing)
                                    .padding(.vertical, 1)
                            }
                        }
                        .padding(.trailing, 12)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            Text(line.isEmpty ? " " : line)
                                .font(AppTheme.codeFont)
                                .foregroundStyle(textColor)
                                .padding(.vertical, 1)
                        }
                    }
                }
                .padding(AppTheme.padding)
            }

            Button {
                UIPasteboard.general.string = code
                withAnimation(.easeInOut(duration: 0.2)) {
                    copied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        copied = false
                    }
                }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.caption)
                    .foregroundStyle(copied ? AppTheme.correct : Color(.secondaryLabel))
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
            }
            .padding(8)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        CodeBlockView(
            code: """
            struct ContentView: View {
                @State private var count = 0

                var body: some View {
                    VStack {
                        Text("Count: \\(count)")
                        Button("Increment") {
                            count += 1
                        }
                    }
                }
            }
            """,
            language: "Swift"
        )

        CodeBlockView(
            code: "print(\"Hello, world!\")",
            language: "Swift",
            showLineNumbers: false
        )
    }
    .padding()
}
