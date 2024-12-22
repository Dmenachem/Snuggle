import SwiftUI

struct MedicationTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var showingPredefinedPicker = false
    @State private var selectedMedication: PredefinedMedication?
    @State private var timestamp = Date()
    @State private var medication = ""
    @State private var dosage = ""
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("medication.time".localized, selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                        .tint(.purple)
                    
                    if let selected = selectedMedication {
                        HStack {
                            Label {
                                Text(selected.name)
                                    .foregroundStyle(.primary)
                            } icon: {
                                Image(systemName: selected.icon)
                                    .foregroundStyle(.purple)
                            }
                            
                            Spacer()
                            
                            Button("medication.change".localized) {
                                showingPredefinedPicker = true
                            }
                            .font(.callout)
                            .foregroundStyle(.purple)
                        }
                    } else {
                        Button {
                            showingPredefinedPicker = true
                        } label: {
                            Label("medication.select".localized, systemImage: "pills")
                                .foregroundStyle(.purple)
                        }
                    }
                    
                    if let selected = selectedMedication {
                        Picker("medication.dosage".localized, selection: $dosage) {
                            ForEach(selected.commonDosages, id: \.self) { dose in
                                Text(dose).tag(dose)
                            }
                            Text("medication.dosage.custom".localized).tag("")
                        }
                        
                        if dosage.isEmpty {
                            TextField("medication.dosage.hint".localized, text: $dosage)
                        }
                    } else {
                        TextField("medication.name".localized, text: $medication)
                        TextField("medication.dosage.hint".localized, text: $dosage)
                    }
                } header: {
                    Text("medication.details".localized)
                }
                
                Section("common.notes".localized) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: saveMedicationRecord) {
                        HStack {
                            Spacer()
                            Text("medication.save".localized)
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.purple)
                    .foregroundColor(.white)
                    .buttonStyle(.borderless)
                }
            }
            .navigationTitle("track.medication".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("baby.cancel".localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPredefinedPicker) {
                PredefinedMedicationPicker(selectedMedication: $selectedMedication)
            }
            .alert("common.error".localized, isPresented: $showingAlert) {
                Button("common.ok".localized, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: selectedMedication) {
                if let med = selectedMedication {
                    medication = med.name
                    if !med.commonDosages.isEmpty {
                        dosage = med.commonDosages[0]
                    }
                }
            }
        }
    }
    
    private func saveMedicationRecord() {
        guard let selectedBaby = babyTracker.selectedBaby else {
            alertMessage = "error.no.baby.selected".localized
            showingAlert = true
            return
        }
        
        guard !medication.isEmpty else {
            alertMessage = "error.medication.name.required".localized
            showingAlert = true
            return
        }
        
        guard !dosage.isEmpty else {
            alertMessage = "error.medication.dosage.required".localized
            showingAlert = true
            return
        }
        
        let record = MedicationRecord(
            id: UUID(),
            timestamp: timestamp,
            medication: medication,
            dosage: dosage,
            notes: notes.isEmpty ? nil : notes
        )
        
        babyTracker.addMedicationRecord(record, for: selectedBaby.id)
        dismiss()
    }
}

struct PredefinedMedicationPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMedication: PredefinedMedication?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(PredefinedMedication.Category.allCases, id: \.self) { category in
                    Section {
                        let medications = PredefinedMedication.predefined.filter { $0.category == category }
                        ForEach(medications) { medication in
                            Button {
                                selectedMedication = medication
                                dismiss()
                            } label: {
                                HStack {
                                    Label {
                                        Text(medication.name)
                                    } icon: {
                                        Image(systemName: medication.icon)
                                            .foregroundStyle(.purple)
                                    }
                                    
                                    Spacer()
                                    
                                    if medication.id == selectedMedication?.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.purple)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    } header: {
                        Text("medication.category.\(category.rawValue)".localized)
                    }
                }
            }
            .navigationTitle("medication.select".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("baby.cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
} 