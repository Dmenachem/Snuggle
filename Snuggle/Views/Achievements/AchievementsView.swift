import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var selectedCategory: Achievement.AchievementType?
    
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Level Progress
                LevelProgressView()
                
                // Daily Challenges
                DailyChallengesView()
                
                // Recent Achievements
                RecentAchievementsView()
                
                // Achievement Categories
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(Achievement.AchievementType.allCases, id: \.self) { category in
                        AchievementCategoryCard(category: category)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Achievements")
    }
}

struct LevelProgressView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(babyTracker.parentingLevel)")
                    .font(.title2.bold())
                Spacer()
                Text("\(babyTracker.currentPoints)/\(babyTracker.nextLevelPoints)")
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: Double(babyTracker.currentPoints),
                        total: Double(babyTracker.nextLevelPoints))
                .tint(.blue)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
    }
} 