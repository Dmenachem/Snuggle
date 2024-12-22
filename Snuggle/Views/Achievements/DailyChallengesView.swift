import SwiftUI

struct DailyChallengesView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Challenges")
                .font(.headline)
            
            ForEach(babyTracker.dailyChallenges) { challenge in
                HStack {
                    Image(systemName: challenge.type.icon)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(challenge.title)
                            .font(.subheadline)
                        ProgressView(value: Double(challenge.progress), total: Double(challenge.target))
                            .tint(.blue)
                    }
                    
                    Spacer()
                    
                    Text("\(challenge.progress)/\(challenge.target)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.background))
            }
        }
    }
} 