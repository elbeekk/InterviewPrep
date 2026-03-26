import SwiftUI

struct ReminderSetupView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("reminderSoundOption") private var reminderSoundOptionRaw = ReminderSoundOption.system.rawValue

    @State private var reminderDate = Date()
    @State private var isSchedulingReminder = false
    @State private var reminderAlertMessage: String?

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button("Skip") {
                    skipReminder()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)

                VStack(spacing: 8) {
                    Text("Daily Reminder")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Choose a time for a short preparation reminder. You can change it later in Settings.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                DatePicker(
                    "Reminder Time",
                    selection: $reminderDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 180)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    scheduleReminder()
                } label: {
                    if isSchedulingReminder {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        Text("Enable Reminder")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSchedulingReminder)

                Text("Local notifications only. No account, no backend.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            reminderDate = Self.makeReminderDate(hour: reminderHour, minute: reminderMinute)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
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

    private func scheduleReminder() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        reminderHour = components.hour ?? 9
        reminderMinute = components.minute ?? 0
        isSchedulingReminder = true

        Task {
            do {
                let scheduled = try await ReminderNotificationService.enableDailyReminders(
                    hour: reminderHour,
                    minute: reminderMinute,
                    sound: ReminderSoundOption(rawValue: reminderSoundOptionRaw) ?? .system
                )

                isSchedulingReminder = false

                if scheduled {
                    dailyReminderEnabled = true
                    onComplete()
                } else {
                    dailyReminderEnabled = false
                    reminderAlertMessage = "Notifications are disabled for InterviewOS. You can finish onboarding now and enable reminders later in Settings."
                }
            } catch {
                dailyReminderEnabled = false
                isSchedulingReminder = false
                reminderAlertMessage = "InterviewOS couldn't schedule the reminder. Please try again."
            }
        }
    }

    private func skipReminder() {
        dailyReminderEnabled = false
        ReminderNotificationService.disableDailyReminders()
        onComplete()
    }

    private static func makeReminderDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }
}

#Preview {
    ReminderSetupView(onComplete: { })
}
