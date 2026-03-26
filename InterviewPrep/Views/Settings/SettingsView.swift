import AudioToolbox
import AVFoundation
import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    private let sourceCodeURL = URL(string: "https://github.com/elbeekk/InterviewPrep.git")!
    private let issuesURL = URL(string: "https://github.com/elbeekk/InterviewPrep/issues")!

    @Environment(ProgressService.self) private var progressService
    @Environment(TrackSelectionStore.self) private var trackSelection
    @AppStorage("selectedTrack") private var selectedTrackRaw = Track.swift.rawValue
    @AppStorage("colorScheme") private var selectedColorScheme: String = "system"
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var showResetAlert = false
    @State private var showResetConfirmation = false

    var body: some View {
        Form {
            Section {
                Picker(selection: selectedTrackBinding) {
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
                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    HStack {
                        Label("Notifications", systemImage: "bell.badge")
                        Spacer()
                        Text(notificationSummary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Notifications")
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

                Link(destination: sourceCodeURL) {
                    Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }

                Link(destination: issuesURL) {
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
    }

    private var colorSchemeValue: ColorScheme? {
        switch selectedColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private var selectedTrackBinding: Binding<Track> {
        Binding(
            get: { Track(rawValue: selectedTrackRaw) ?? .swift },
            set: { trackSelection.switchTo($0) }
        )
    }

    private var notificationSummary: String {
        guard dailyReminderEnabled else {
            return "Off"
        }
        return reminderTimeSummary(hour: reminderHour, minute: reminderMinute)
    }
}

private struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("reminderSoundOption") private var reminderSoundOptionRaw = ReminderSoundOption.system.rawValue

    @State private var reminderDate = Date()
    @State private var reminderAlertMessage: String?
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var soundPreviewPlayer = ReminderSoundPreviewPlayer()

    var body: some View {
        Form {
            Section("Reminder") {
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
                        scheduleReminder()
                    }
                }

                Picker("Sound", selection: selectedSoundBinding) {
                    ForEach(ReminderSoundOption.allCases) { option in
                        Text(option.displayName)
                            .tag(option)
                    }
                }
            }

            Section {
                Text("Reminder text changes automatically every day. Sound only controls the notification tone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Notes")
            }

            Section("System Status") {
                LabeledContent("Permission", value: permissionSummary)

                if authorizationStatus == .denied {
                    Button("Open iPhone Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reminderDate = makeReminderDate(hour: reminderHour, minute: reminderMinute)
            refreshAuthorizationStatus()
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

    private var selectedSound: ReminderSoundOption {
        ReminderSoundOption(rawValue: reminderSoundOptionRaw) ?? .system
    }

    private var permissionSummary: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Allowed"
        case .denied:
            return "Disabled in iOS"
        case .notDetermined:
            return "Not requested yet"
        @unknown default:
            return "Unknown"
        }
    }

    private var reminderToggleBinding: Binding<Bool> {
        Binding(
            get: { dailyReminderEnabled },
            set: { isEnabled in
                dailyReminderEnabled = isEnabled

                if isEnabled {
                    scheduleReminder()
                } else {
                    ReminderNotificationService.disableDailyReminders()
                }
            }
        )
    }

    private var selectedSoundBinding: Binding<ReminderSoundOption> {
        Binding(
            get: { selectedSound },
            set: { option in
                reminderSoundOptionRaw = option.rawValue
                soundPreviewPlayer.play(option)
                if dailyReminderEnabled {
                    scheduleReminder()
                }
            }
        )
    }

    private func scheduleReminder() {
        Task {
            do {
                let scheduled = try await ReminderNotificationService.enableDailyReminders(
                    hour: reminderHour,
                    minute: reminderMinute,
                    sound: selectedSound
                )

                await MainActor.run {
                    refreshAuthorizationStatus()

                    if !scheduled {
                        dailyReminderEnabled = false
                        reminderAlertMessage = "Notifications are disabled for InterviewOS. Enable them in the system Settings app if you want daily reminders."
                    }
                }
            } catch {
                await MainActor.run {
                    dailyReminderEnabled = false
                    reminderAlertMessage = "InterviewOS couldn't update the reminder schedule. Please try again."
                    refreshAuthorizationStatus()
                }
            }
        }
    }

    private func refreshAuthorizationStatus() {
        Task {
            let status = await ReminderNotificationService.authorizationStatus()
            await MainActor.run {
                authorizationStatus = status
            }
        }
    }
}

private func makeReminderDate(hour: Int, minute: Int) -> Date {
    var components = DateComponents()
    components.hour = hour
    components.minute = minute
    return Calendar.current.date(from: components) ?? .now
}

private func reminderTimeSummary(hour: Int, minute: Int) -> String {
    let date = makeReminderDate(hour: hour, minute: minute)
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: date)
}

@MainActor
private final class ReminderSoundPreviewPlayer {
    private var audioPlayer: AVAudioPlayer?

    func play(_ option: ReminderSoundOption) {
        audioPlayer?.stop()

        switch option {
        case .off:
            return
        case .system:
            AudioServicesPlaySystemSound(SystemSoundID(1007))
        case .bloom, .pulse, .glass:
            guard
                let fileName = option.bundledFileName,
                let url = Bundle.main.url(forResource: (fileName as NSString).deletingPathExtension,
                                          withExtension: (fileName as NSString).pathExtension)
            else {
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                audioPlayer = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(TrackSelectionStore())
}
