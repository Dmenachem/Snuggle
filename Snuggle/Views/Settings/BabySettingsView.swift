import SwiftUI

struct BabySettingsView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @Environment(\.dismiss) private var dismiss
    
    let baby: Baby
    @State private var name: String
    @State private var dateOfBirth: Date
    @State private var showingDeleteAlert = false
    
    init(baby: Baby) {
        self.baby = baby
        _name = State(initialValue: baby.name)
        _dateOfBirth = State(initialValue: baby.dateOfBirth)
    }
    
    var body: some View {
        Form {
            Section {
                // Baby Details
                TextField("baby.name".localized, text: $name)
                DatePicker("baby.birth.date".localized, selection: $dateOfBirth, in: ...Date(), displayedComponents: [.date])
            }
            
            Section {
                Button("baby.settings.save".localized) {
                    saveBaby()
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Text("baby.settings.delete".localized)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("baby.settings".localized)
        .alert("baby.settings.delete.title".localized, isPresented: $showingDeleteAlert) {
            Button("baby.settings.delete.confirm".localized, role: .destructive) {
                babyTracker.deleteBaby(baby.id)
                dismiss()
            }
            Button("common.cancel".localized, role: .cancel) { }
        } message: {
            Text("baby.settings.delete.message".localized)
        }
    }
    
    private func saveBaby() {
        let updatedBaby = Baby(
            id: baby.id,
            name: name,
            dateOfBirth: dateOfBirth,
            parentIDs: baby.parentIDs
        )
        babyTracker.updateBaby(updatedBaby)
        dismiss()
    }
} 