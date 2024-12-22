import SwiftUI
import PhotosUI

struct MonthlyPhotoView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingPhotoPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Monthly Milestone Photos")
                .font(.title2)
                .bold()
            
            if let baby = babyTracker.selectedBaby {
                let ageInMonths = Calendar.current.dateComponents(
                    [.month],
                    from: baby.dateOfBirth,
                    to: Date()
                ).month ?? 0
                
                Text("\(baby.name) is \(ageInMonths) months old")
                    .font(.headline)
                
                // Monthly photo grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(1...12, id: \.self) { month in
                        MonthlyPhotoCell(
                            month: month,
                            isCurrentMonth: month == ageInMonths,
                            isDue: month <= ageInMonths
                        )
                    }
                }
                .padding()
            }
        }
    }
}

struct MonthlyPhotoCell: View {
    let month: Int
    let isCurrentMonth: Bool
    let isDue: Bool
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                
                if isCurrentMonth {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                } else if !isDue {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                // Show photo if available
            }
            .frame(height: 150)
            
            Text("Month \(month)")
                .font(.caption)
                .foregroundStyle(isCurrentMonth ? .primary : .secondary)
        }
    }
    
    private var backgroundColor: Color {
        if isCurrentMonth {
            return .blue
        } else if isDue {
            return .gray.opacity(0.3)
        } else {
            return .gray.opacity(0.1)
        }
    }
} 