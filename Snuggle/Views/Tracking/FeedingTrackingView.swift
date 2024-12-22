import SwiftUI

struct FeedingTrackingView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedingType: FeedingRecord.FeedingType
    @State private var startTime = Date()
    @State private var duration: TimeInterval = 0
    @State private var amount: Double = 0
    @State private var notes = ""
    @State private var selectedFoods: Set<FoodType> = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init() {
        // Initialize with the last used feeding type
        _feedingType = State(initialValue: BabyTracker().lastUsedFeedingType)
    }
    
    private var suggestedAmounts: [Double] {
        guard let selectedBaby = babyTracker.selectedBaby else { return [] }
        return babyTracker.recentBottleAmounts(for: selectedBaby.id)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("feeding.type".localized, selection: $feedingType) {
                        ForEach(FeedingRecord.FeedingType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: feedingIcon(for: type))
                                    .foregroundStyle(feedingColor(for: type))
                                Text("feeding.type.\(type.rawValue)".localized)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    DatePicker("feeding.start.time".localized, selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                        .tint(.blue)
                    
                    if feedingType == .breastfeeding {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("feeding.duration".localizedFormat(Int(duration)))
                                .font(.headline)
                            
                            HStack {
                                ForEach([5, 10, 15, 20, 30], id: \.self) { value in
                                    Button("\(value)m") {
                                        duration = Double(value)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(duration == Double(value) ? .blue : .secondary)
                                }
                            }
                            
                            Slider(value: $duration, in: 0...120, step: 5)
                                .tint(.blue)
                        }
                    }
                    
                    if feedingType == .bottle {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("feeding.amount".localizedFormat(Int(amount)))
                                .font(.headline)
                            
                            if !suggestedAmounts.isEmpty {
                                Text("feeding.recent.amounts".localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(suggestedAmounts, id: \.self) { suggestion in
                                            Button("\(Int(suggestion))") {
                                                amount = suggestion
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(amount == suggestion ? .blue : .secondary)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                ForEach([30, 60, 90, 120, 150], id: \.self) { value in
                                    Button("\(value)") {
                                        amount = Double(value)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(amount == Double(value) ? .blue : .secondary)
                                }
                            }
                            
                            Slider(value: $amount, in: 0...500, step: 10)
                                .tint(.blue)
                        }
                    }
                    
                    if feedingType == .solids {
                        Section(header: Text("feeding.solids.selected".localized)) {
                            if selectedFoods.isEmpty {
                                Text("feeding.solids.none".localized)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(Array(selectedFoods), id: \.self) { food in
                                    Text(food.rawValue)
                                }
                            }
                            
                            NavigationLink("feeding.solids.select".localized) {
                                FoodSelectionView(selectedFoods: $selectedFoods)
                            }
                        }
                    }
                }
                
                Section("common.notes".localized) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: saveFeedingRecord) {
                        HStack {
                            Spacer()
                            Text("feeding.save".localized)
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.blue)
                    .foregroundColor(.white)
                    .buttonStyle(.borderless)
                }
            }
            .navigationTitle("track.feeding".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("baby.cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("common.error".localized, isPresented: $showingAlert) {
                Button("common.ok".localized, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func feedingIcon(for type: FeedingRecord.FeedingType) -> String {
        switch type {
        case .bottle: return "baby.bottle"
        case .breastfeeding: return "heart.fill"
        case .solids: return "fork.knife"
        }
    }
    
    private func feedingColor(for type: FeedingRecord.FeedingType) -> Color {
        switch type {
        case .bottle: return .blue
        case .breastfeeding: return .pink
        case .solids: return .orange
        }
    }
    
    private func saveFeedingRecord() {
        guard let selectedBaby = babyTracker.selectedBaby else {
            alertMessage = "error.no.baby.selected".localized
            showingAlert = true
            return
        }
        
        let record = FeedingRecord(
            id: UUID(),
            startTime: startTime,
            duration: duration > 0 ? duration : nil,
            type: feedingType,
            amount: feedingType == .bottle ? amount : nil,
            foodTypes: feedingType == .solids ? Array(selectedFoods) : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        babyTracker.addFeedingRecord(record, for: selectedBaby.id)
        dismiss()
    }
}

// New view for food selection
struct FoodSelectionView: View {
    @Binding var selectedFoods: Set<FoodType>
    
    var body: some View {
        List {
            ForEach(FoodCategory.allCases, id: \.self) { category in
                Section(header: Text("food.category.\(category.rawValue.lowercased())".localized)) {
                    let foodsInCategory = FoodType.allCases.filter { $0.category == category }
                    ForEach(foodsInCategory, id: \.self) { food in
                        Button {
                            if selectedFoods.contains(food) {
                                selectedFoods.remove(food)
                            } else {
                                selectedFoods.insert(food)
                            }
                        } label: {
                            HStack {
                                Text(food.rawValue)
                                Spacer()
                                if selectedFoods.contains(food) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationTitle("feeding.solids.select".localized)
    }
}

struct FeedingTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeedingTrackingView()
        }
    }
} 