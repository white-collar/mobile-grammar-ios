import SwiftUI

/// Asks for a time and schedules a notification to study a lesson or group.
struct ReminderSheet: View {
    let title: String
    let message: String
    @Environment(\.dismiss) private var dismiss
    @State private var date = Reminder.defaultDate()
    @State private var denied = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Time", selection: $date, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                } footer: {
                    Text(message)
                }
                if denied {
                    Section {
                        Text("Notifications are turned off for Mobile Grammar. You can allow them in Settings.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Setup reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Remind me") {
                        Task { await schedule() }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func schedule() async {
        if (try? await Reminder.schedule(title: title, body: message, date: date)) == true {
            dismiss()
        } else {
            denied = true
        }
    }
}
