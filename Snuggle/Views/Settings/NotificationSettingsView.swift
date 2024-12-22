import SwiftUI

struct NotificationSettingsView: View {
    @State private var feedingReminders = false
    @State private var sleepReminders = false
    @State private var medicationReminders = false
    @State private var growthReminders = false
    
    @State private var feedingInterval = 3.0 // hours
    @State private var sleepInterval = 2.0 // hours
    @State private var selectedMedicationTimes: Set<Date> = []
    @State private var growthCheckInterval = 1 // months
    
    @State private var showingTimePicker = false
    @State private var selectedTime = Date()
    
    let medicationTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable All Notifications", isOn: .constant(true))
                    .tint(.blue)
            }
            
            Section {
                Toggle("Feeding Reminders", isOn: $feedingReminders)
                    .tint(.blue)
                
                if feedingReminders {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remind every \(Int(feedingInterval)) hours")
                            .font(.subheadline)
                        
                        Slider(value: $feedingInterval, in: 1...6, step: 0.5)
                            .tint(.blue)
                    }
                }
            } header: {
                Text("Feeding")
            } footer: {
                Text("Get reminded when it's time for the next feeding.")
            }
            
            Section {
                Toggle("Sleep Tracking", isOn: $sleepReminders)
                    .tint(.blue)
                
                if sleepReminders {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Check sleep status every \(Int(sleepInterval)) hours")
                            .font(.subheadline)
                        
                        Slider(value: $sleepInterval, in: 1...4, step: 0.5)
                            .tint(.blue)
                    }
                }
            } header: {
                Text("Sleep")
            } footer: {
                Text("Get reminders to log sleep status.")
            }
            
            Section {
                Toggle("Medication Reminders", isOn: $medicationReminders)
                    .tint(.blue)
                
                if medicationReminders {
                    ForEach(Array(selectedMedicationTimes), id: \.self) { time in
                        HStack {
                            Text(medicationTimeFormatter.string(from: time))
                            Spacer()
                            Button(role: .destructive) {
                                selectedMedicationTimes.remove(time)
                            } label: {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    Button(action: { showingTimePicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Reminder Time")
                        }
                        .foregroundStyle(.blue)
                    }
                }
            } header: {
                Text("Medication")
            } footer: {
                Text("Set specific times for medication reminders.")
            }
            
            Section {
                Toggle("Growth Tracking", isOn: $growthReminders)
                    .tint(.blue)
                
                if growthReminders {
                    Picker("Reminder Frequency", selection: $growthCheckInterval) {
                        Text("Every month").tag(1)
                        Text("Every 2 months").tag(2)
                        Text("Every 3 months").tag(3)
                        Text("Every 6 months").tag(6)
                    }
                }
            } header: {
                Text("Growth")
            } footer: {
                Text("Get reminded to track growth measurements.")
            }
        }
        .navigationTitle("Notifications")
        .sheet(isPresented: $showingTimePicker) {
            NavigationStack {
                Form {
                    DatePicker(
                        "Reminder Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .navigationTitle("Add Reminder Time")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingTimePicker = false
                    },
                    trailing: Button("Add") {
                        selectedMedicationTimes.insert(selectedTime)
                        showingTimePicker = false
                    }
                )
            }
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationSettingsView()
        }
    }
} 