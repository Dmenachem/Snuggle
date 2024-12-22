import SwiftUI

struct AddBabyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var babyTracker: BabyTracker
    
    @State private var name = ""
    @State private var dateOfBirth = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("baby.name".localized, text: $name)
                    DatePicker("baby.birth.date".localized, selection: $dateOfBirth, in: ...Date(), displayedComponents: [.date])
                }
                
                Section {
                    Button("baby.add".localized) {
                        let baby = Baby(
                            name: name,
                            dateOfBirth: dateOfBirth,
                            parentIDs: [babyTracker.familyMembers[0]]
                        )
                        babyTracker.addBaby(baby)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("profile.add.baby".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("baby.cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
} 