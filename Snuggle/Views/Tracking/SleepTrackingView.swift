import SwiftUI

struct SleepTrackingView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var quality: SleepRecord.SleepQuality = .good
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSleepTimer = false
    
    var body: some View {
        Form {
            Section {
                Button {
                    showingSleepTimer = true
                } label: {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(.blue)
                        Text("sleep.start.timer".localized)
                    }
                }
                
                NavigationLink {
                    ManualSleepEntryView()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundStyle(.blue)
                        Text("sleep.manual.entry".localized)
                    }
                }
            }
        }
        .navigationTitle("track.sleep".localized)
        .alert("common.error".localized, isPresented: $showingAlert) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSleepTimer) {
            SleepTimerView()
        }
    }
    
    private func saveSleepRecord() {
        guard let selectedBaby = babyTracker.selectedBaby else {
            alertMessage = "error.no.baby.selected".localized
            showingAlert = true
            return
        }
        
        let record = SleepRecord(
            id: UUID(),
            startTime: startTime,
            endTime: endTime,
            quality: quality,
            notes: notes.isEmpty ? nil : notes
        )
        
        babyTracker.addSleepRecord(record, for: selectedBaby.id)
        dismiss()
    }
}

private struct SleepTrackingForm: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var quality: SleepRecord.SleepQuality
    @Binding var notes: String
    let onSave: () -> Void
    
    var body: some View {
        Form {
            Section {
                DatePicker("sleep.start.time".localized, selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    .tint(.indigo)
                
                DatePicker("sleep.end.time".localized, selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                    .tint(.indigo)
                
                Picker("sleep.quality".localized, selection: $quality) {
                    ForEach(SleepRecord.SleepQuality.allCases, id: \.self) { quality in
                        Text("sleep.quality.\(quality.rawValue)".localized)
                            .tag(quality)
                    }
                }
            } header: {
                Text("sleep.details".localized)
            } footer: {
                Text("sleep.duration".localizedFormat(formatDuration(from: startTime, to: endTime)))
            }
            
            Section("common.notes".localized) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            Section {
                Button(action: onSave) {
                    HStack {
                        Spacer()
                        Text("sleep.save".localized)
                            .font(.headline)
                        Spacer()
                    }
                }
                .listRowBackground(Color.indigo)
                .foregroundColor(.white)
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "time.duration".localizedFormat(hours, minutes)
    }
}

struct SleepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SleepTrackingView()
                .environmentObject(BabyTracker())
        }
    }
} 