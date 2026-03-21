import SwiftUI

struct SettingsView: View {
    @Environment(ProgressService.self) private var progressService
    @AppStorage("selectedTrack") private var selectedTrack: Track = .swift
    @AppStorage("colorScheme") private var selectedColorScheme: String = "system"
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var showResetAlert = false
    @State private var showResetConfirmation = false
    @State private var reminderDate = Date()
    @State private var reminderAlertMessage: String?

    var body: some View {
        Form {
            Section {
                Picker(selection: $selectedTrack) {
                    ForEach(Track.allCases.filter { $0 != .general }) { track in
                        Label(track.displayName, systemImage: track.icon)
                            .tag(track)
                    }
                } label: {
                    Label("Primary Track", systemImage: "arrow.triangle.branch")
                }
            } header: {
                Text("Track")
            }

            Section {
                Picker(selection: $selectedColorScheme) {
                    Label("System", systemImage: "circle.lefthalf.filled")
                        .tag("system")
                    Label("Light", systemImage: "sun.max.fill")
                        .tag("light")
                    Label("Dark", systemImage: "moon.fill")
                        .tag("dark")
                } label: {
                    Label("Appearance", systemImage: "paintbrush")
                }
            } header: {
                Text("Appearance")
            }

            Section {
                Toggle(isOn: reminderToggleBinding) {
                    Label("Daily Reminder", systemImage: "bell.badge")
                }
                .tint(AppTheme.accent)

                if dailyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $reminderDate,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: reminderDate) {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                        reminderHour = components.hour ?? 9
                        reminderMinute = components.minute ?? 0

                        if dailyReminderEnabled {
                            scheduleReminderFromSettings()
                        }
                    }
                }
            } header: {
                Text("Notifications")
            } footer: {
                if dailyReminderEnabled {
                    Text("You'll receive a reminder to practice every day.")
                }
            }

            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                        .foregroundStyle(AppTheme.incorrect)
                }
            } header: {
                Text("Data")
            } footer: {
                Text("This will permanently delete all your progress, bookmarks, and streaks.")
            }

            Section {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Build", systemImage: "hammer")
                    Spacer()
                    Text("1")
                        .foregroundStyle(.secondary)
                }

                Link(destination: URL(string: "https://github.com")!) {
                    Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }

                Link(destination: URL(string: "https://github.com")!) {
                    Label("Report an Issue", systemImage: "ladybug")
                }
            } header: {
                Text("About")
            } footer: {
                VStack(spacing: 4) {
                    Text("Interview preparation for mobile developers")
                        .font(.footnote)
                    Text("InterviewOS")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(colorSchemeValue)
        .onAppear {
            // Initialize date from stored values
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            if let date = Calendar.current.date(from: components) {
                reminderDate = date
            }

            if dailyReminderEnabled {
                scheduleReminderFromSettings()
            }
        }
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset Everything", role: .destructive) {
                showResetConfirmation = true
            }
        } message: {
            Text("Are you sure you want to reset all progress? This action cannot be undone.")
        }
        .alert("Final Confirmation", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Reset", role: .destructive) {
                progressService.resetAllProgress()
            }
        } message: {
            Text("This will permanently delete ALL your data including XP, streaks, bookmarks, and lesson progress.")
        }
        .alert(
            "Reminder Not Enabled",
            isPresented: Binding(
                get: { reminderAlertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        reminderAlertMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(reminderAlertMessage ?? "")
        }
    }

    private var colorSchemeValue: ColorScheme? {
        switch selectedColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var reminderToggleBinding: Binding<Bool> {
        Binding(
            get: { dailyReminderEnabled },
            set: { isEnabled in
                dailyReminderEnabled = isEnabled

                if isEnabled {
                    scheduleReminderFromSettings()
                } else {
                    ReminderNotificationService.disableDailyReminders()
                }
            }
        )
    }

    private func scheduleReminderFromSettings() {
        Task {
            do {
                let scheduled = try await ReminderNotificationService.enableDailyReminders(
                    hour: reminderHour,
                    minute: reminderMinute
                )

                if !scheduled {
                    dailyReminderEnabled = false
                    reminderAlertMessage = "Notifications are disabled for InterviewOS. Enable them in the system Settings app if you want daily reminders."
                }
            } catch {
                dailyReminderEnabled = false
                reminderAlertMessage = "InterviewOS couldn't update the reminder schedule. Please try again."
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
}
