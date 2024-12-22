import SwiftUI

struct RecentAchievementsView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.headline)
            
            ForEach(babyTracker.achievements.prefix(3)) { achievement in
                HStack {
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading) {
                        Text(achievement.title)
                            .font(.subheadline)
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(.background))
            }
        }
    }
} 