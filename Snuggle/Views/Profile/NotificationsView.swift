import SwiftUI

struct NotificationsView: View {
    @State private var enableAllNotifications = false
    @State private var feedingReminders = false
    @State private var sleepTracking = false
    @State private var medicationReminders = false
    @State private var growthTracking = false
    
    var body: some View {
        Form {
            Section {
                Toggle("notifications.enable.all".localized, isOn: $enableAllNotifications)
            }
            
            Section {
                Toggle("notifications.feeding".localized, isOn: $feedingReminders)
                Toggle("notifications.sleep".localized, isOn: $sleepTracking)
                Toggle("notifications.medication".localized, isOn: $medicationReminders)
                Toggle("notifications.growth".localized, isOn: $growthTracking)
            }
        }
        .navigationTitle("profile.notifications".localized)
    }
} 