import SwiftUI
import PhotosUI

struct EngagementView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingMomentSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Daily Streak
                StreakCard()
                
                // Daily Tip
                if let tip = babyTracker.dailyTips.first {
                    DailyTipCard(tip: tip)
                }
                
                // Daily Challenges
                DailyChallengesGrid()
                
                // Special Moments
                SpecialMomentsTimeline()
                
                // Add Moment Button
                Button {
                    showingMomentSheet = true
                } label: {
                    Label("Add Special Moment", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .sheet(isPresented: $showingMomentSheet) {
            AddSpecialMomentSheet()
        }
    }
}

struct StreakCard: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(babyTracker.dailyStreak)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Text("Day Streak!")
                .font(.headline)
            Text("Keep up the great work!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(radius: 5)
        )
    }
}

struct DailyTipCard: View {
    let tip: ParentingTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily Tip", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(.yellow)
            
            Text(tip.content)
                .font(.body)
            
            if let source = tip.source {
                Text(source)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(radius: 5)
        )
    }
}

struct DailyChallengesGrid: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Challenges")
                .font(.headline)
            
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
                ForEach(babyTracker.dailyChallenges) { challenge in
                    ChallengeCard(challenge: challenge)
                }
            }
        }
    }
}

struct ChallengeCard: View {
    let challenge: DailyChallenge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: challenge.type.icon)
                .font(.title)
            Text(challenge.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            ProgressView(value: Double(challenge.progress), total: Double(challenge.target))
                .tint(.blue)
            Text("\(challenge.progress)/\(challenge.target)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(radius: 3)
        )
    }
}

struct SpecialMomentsTimeline: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Special Moments")
                .font(.headline)
            
            ForEach(babyTracker.specialMoments.sorted { $0.date > $1.date }) { moment in
                MomentCard(moment: moment)
            }
        }
    }
} 