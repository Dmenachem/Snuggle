import SwiftUI

struct ManualSleepEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var babyTracker: BabyTracker
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var quality: SleepRecord.SleepQuality = .good
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                Button(action: saveSleepRecord) {
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
        .navigationTitle("sleep.manual.entry".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("common.error".localized, isPresented: $showingAlert) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
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
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "time.duration".localizedFormat(hours, minutes)
    }
} 