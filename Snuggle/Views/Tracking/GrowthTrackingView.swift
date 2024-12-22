import SwiftUI

struct GrowthTrackingView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var headCircumference: String = ""
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section {
                DatePicker("growth.date".localized, selection: $date, displayedComponents: [.date])
                    .tint(.green)
                
                TextField("growth.weight".localized, text: $weight)
                    .keyboardType(.decimalPad)
                
                TextField("growth.height".localized, text: $height)
                    .keyboardType(.decimalPad)
                
                TextField("growth.head".localized, text: $headCircumference)
                    .keyboardType(.decimalPad)
            } header: {
                Text("growth.measurements".localized)
            } footer: {
                Text("growth.units".localized)
            }
            
            Section("common.notes".localized) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            Section {
                Button(action: saveGrowthRecord) {
                    HStack {
                        Spacer()
                        Text("growth.save".localized)
                            .font(.headline)
                        Spacer()
                    }
                }
                .listRowBackground(Color.green)
                .foregroundColor(.white)
                .buttonStyle(.borderless)
                .disabled(!isValidInput)
            }
        }
        .navigationTitle("track.growth".localized)
        .alert("common.error".localized, isPresented: $showingAlert) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isValidInput: Bool {
        let hasWeight = Double(weight) != nil
        let hasHeight = Double(height) != nil
        let hasHead = Double(headCircumference) != nil
        return hasWeight || hasHeight || hasHead
    }
    
    private func saveGrowthRecord() {
        guard let selectedBaby = babyTracker.selectedBaby else {
            alertMessage = "error.no.baby.selected".localized
            showingAlert = true
            return
        }
        
        let record = GrowthMeasurement(
            id: UUID(),
            date: date,
            weight: Double(weight),
            height: Double(height),
            headCircumference: Double(headCircumference)
        )
        
        babyTracker.addGrowthMeasurement(record, for: selectedBaby.id)
        dismiss()
    }
}

struct GrowthTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GrowthTrackingView()
        }
    }
} 