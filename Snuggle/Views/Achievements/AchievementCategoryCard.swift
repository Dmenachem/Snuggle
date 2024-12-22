import SwiftUI

struct AchievementCategoryCard: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    let category: Achievement.AchievementType
    
    var achievements: [Achievement] {
        babyTracker.achievements.filter { $0.type == category }
    }
    
    var body: some View {
        VStack {
            Image(systemName: iconForCategory)
                .font(.title)
                .foregroundStyle(colorForCategory)
            
            Text(titleForCategory)
                .font(.headline)
            
            Text("\(achievements.count) Unlocked")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
    }
    
    private var iconForCategory: String {
        switch category {
        case .feeding: return "cup.and.saucer.fill"
        case .sleep: return "moon.fill"
        case .consistency: return "star.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .sharing: return "person.2.fill"
        case .special: return "heart.fill"
        }
    }
    
    private var colorForCategory: Color {
        switch category {
        case .feeding: return .blue
        case .sleep: return .indigo
        case .consistency: return .yellow
        case .growth: return .green
        case .sharing: return .purple
        case .special: return .red
        }
    }
    
    private var titleForCategory: String {
        switch category {
        case .feeding: return "Feeding"
        case .sleep: return "Sleep"
        case .consistency: return "Consistency"
        case .growth: return "Growth"
        case .sharing: return "Sharing"
        case .special: return "Special"
        }
    }
} 