import SwiftUI

struct SleepTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var babyTracker: BabyTracker
    
    @State private var isTimerRunning = false
    @State private var startTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var quality: SleepRecord.SleepQuality = .good
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Text(formatElapsedTime())
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        Button {
                            if isTimerRunning {
                                stopTimer()
                            } else {
                                startTimer()
                            }
                        } label: {
                            Circle()
                                .fill(isTimerRunning ? .red : .blue)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                                        .foregroundStyle(.white)
                                        .font(.title)
                                }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                if isTimerRunning {
                    Section {
                        Picker("sleep.quality".localized, selection: $quality) {
                            ForEach(SleepRecord.SleepQuality.allCases, id: \.self) { quality in
                                Text("sleep.quality.\(quality.rawValue)".localized)
                                    .tag(quality)
                            }
                        }
                        
                        TextField("common.notes".localized, text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("sleep.timer".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isTimerRunning {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("baby.cancel".localized) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        startTime = Date()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        guard let selectedBaby = babyTracker.selectedBaby else { return }
        
        let record = SleepRecord(
            id: UUID(),
            startTime: startTime,
            endTime: Date(),
            quality: quality,
            notes: notes.isEmpty ? nil : notes
        )
        
        babyTracker.addSleepRecord(record, for: selectedBaby.id)
        dismiss()
    }
    
    private func formatElapsedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 