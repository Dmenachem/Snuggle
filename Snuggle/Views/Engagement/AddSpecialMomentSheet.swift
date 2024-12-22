import SwiftUI
import PhotosUI

struct AddSpecialMomentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var babyTracker: BabyTracker
    
    @State private var selectedType: SpecialMoment.MomentType = .firstSmile
    @State private var notes = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photosData: [Data] = []
    
    var body: some View {
        NavigationStack {
            Form {
                MomentTypeSection(selectedType: $selectedType)
                PhotosSection(selectedPhotos: $selectedPhotos, photosData: $photosData)
                NotesSection(notes: $notes)
                SaveButtonSection(action: saveMoment)
            }
            .navigationTitle("Add Special Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveMoment() {
        let moment = SpecialMoment(
            id: UUID(),
            type: selectedType,
            date: Date(),
            notes: notes.isEmpty ? nil : notes,
            photos: photosData.isEmpty ? nil : photosData
        )
        babyTracker.addSpecialMoment(moment)
        dismiss()
    }
}

// MARK: - Subviews
private struct MomentTypeSection: View {
    @Binding var selectedType: SpecialMoment.MomentType
    
    var body: some View {
        Section {
            Picker("Type", selection: $selectedType) {
                ForEach(SpecialMoment.MomentType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

private struct PhotosSection: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var photosData: [Data]
    
    var body: some View {
        Section("Photos") {
            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                Label("Select Photos", systemImage: "photo.on.rectangle.angled")
            }
            
            if !photosData.isEmpty {
                PhotosPreviewGrid(photosData: photosData)
            }
        }
        .onChange(of: selectedPhotos) { oldValue, newValue in
            loadPhotos()
        }
    }
    
    private func loadPhotos() {
        Task {
            photosData = []
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    photosData.append(data)
                }
            }
        }
    }
}

private struct PhotosPreviewGrid: View {
    let photosData: [Data]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(photosData, id: \.self) { data in
                    if let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

private struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        Section("Notes") {
            TextEditor(text: $notes)
                .frame(height: 100)
        }
    }
}

private struct SaveButtonSection: View {
    let action: () -> Void
    
    var body: some View {
        Section {
            Button("Save Moment", action: action)
                .frame(maxWidth: .infinity)
        }
    }
} 