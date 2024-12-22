import SwiftUI

struct TrackingView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    
    var body: some View {
        NavigationStack {
            List {
                if let baby = babyTracker.selectedBaby {
                    // Baby Info Section with softer design
                    VStack(alignment: .leading, spacing: 6) {
                        Text(baby.name)
                            .font(.system(.title2, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(formatAge(from: baby.dateOfBirth))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .padding(.vertical, -8)
                    )
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    
                    // Quick Actions with pastel colors
                    Section("track.quick.actions".localized) {
                        NavigationLink {
                            FeedingTrackingView()
                        } label: {
                            QuickActionRow(
                                title: "quick.action.feeding".localized,
                                subtitle: "track.feeding.subtitle".localized,
                                icon: "drop.fill",
                                color: Color(red: 0.3, green: 0.6, blue: 0.9), // Soft blue
                                summary: formatLastFeeding(baby.feedingRecords)
                            )
                        }
                        
                        NavigationLink {
                            SleepTrackingView()
                        } label: {
                            QuickActionRow(
                                title: "quick.action.sleep".localized,
                                subtitle: "track.sleep.subtitle".localized,
                                icon: "moon.fill",
                                color: Color(red: 0.5, green: 0.4, blue: 0.9), // Soft purple
                                summary: formatLastSleep(baby.sleepRecords)
                            )
                        }
                        
                        NavigationLink {
                            GrowthTrackingView()
                        } label: {
                            QuickActionRow(
                                title: "quick.action.growth".localized,
                                subtitle: "track.growth.subtitle".localized,
                                icon: "chart.line.uptrend.xyaxis",
                                color: Color(red: 0.4, green: 0.8, blue: 0.5), // Soft green
                                summary: formatLastGrowth(baby.growthMeasurements)
                            )
                        }
                        
                        NavigationLink {
                            MedicationTrackingView()
                        } label: {
                            QuickActionRow(
                                title: "quick.action.medication".localized,
                                subtitle: "track.medication.subtitle".localized,
                                icon: "pills.fill",
                                color: Color(red: 0.9, green: 0.5, blue: 0.5), // Soft red
                                summary: formatLastMedication(baby.medicationRecords)
                            )
                        }
                    }
                    .listSectionSpacing(24)
                    
                    // Recent Activity with softer design
                    Section("track.recent.activity".localized) {
                        RecentActivityView(baby: baby)
                    }
                } else {
                    ContentUnavailableView(
                        "track.no.baby.title".localized,
                        systemImage: "person.crop.circle.badge.questionmark",
                        description: Text("track.no.baby.message".localized)
                    )
                }
            }
            .navigationTitle("tab.track".localized)
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.95, blue: 1.0),
                        Color(red: 1.0, green: 0.98, blue: 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private func formatAge(from birthDate: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthDate, to: now)
        
        if let years = ageComponents.year, years > 0 {
            if let months = ageComponents.month, months > 0 {
                return "\(years)y \(months)m"
            }
            return "\(years) years"
        } else if let months = ageComponents.month, months > 0 {
            if let days = ageComponents.day, days > 0 {
                return "\(months)m \(days)d"
            }
            return "\(months) months"
        } else if let days = ageComponents.day {
            return "\(days) days"
        }
        
        return "Just born"
    }
    
    private func formatLastFeeding(_ records: [FeedingRecord]) -> String? {
        let sortedRecords = records.sorted { $0.startTime > $1.startTime }.prefix(5)
        guard !sortedRecords.isEmpty else { return nil }
        
        let summaries = sortedRecords.compactMap { record -> String? in
            switch record.type {
            case .bottle:
                if let amount = record.amount {
                    return "💧 \(Int(amount))ml"
                }
            case .breastfeeding:
                if let duration = record.duration {
                    return "⏱ \(Int(duration))min"
                }
            case .solids:
                if let foods = record.foodTypes?.prefix(2) {
                    return foods.map { $0.rawValue.components(separatedBy: " ")[0] }.joined(separator: "")
                }
            }
            return nil
        }
        
        return summaries.joined(separator: "  •  ")
    }
    
    private func formatLastSleep(_ records: [SleepRecord]) -> String? {
        let sortedRecords = records.sorted { $0.startTime > $1.startTime }.prefix(5)
        guard !sortedRecords.isEmpty else { return nil }
        
        let summaries = sortedRecords.map { record -> String in
            let duration = record.endTime.timeIntervalSince(record.startTime)
            let hours = Int(duration) / 3600
            let minutes = Int(duration) / 60 % 60
            return "💤 \(hours)h \(minutes)m"
        }
        
        return summaries.joined(separator: "  •  ")
    }
    
    private func formatLastGrowth(_ records: [GrowthMeasurement]) -> String? {
        let sortedRecords = records.sorted { $0.date > $1.date }.prefix(5)
        guard !sortedRecords.isEmpty else { return nil }
        
        let summaries = sortedRecords.compactMap { record -> String? in
            if let weight = record.weight {
                return "⚖️ \(String(format: "%.1f", weight))kg"
            }
            return nil
        }
        
        return summaries.joined(separator: "  •  ")
    }
    
    private func formatLastMedication(_ records: [MedicationRecord]) -> String? {
        let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }.prefix(5)
        guard !sortedRecords.isEmpty else { return nil }
        
        let summaries = sortedRecords.map { "💊 \($0.medication)" }
        return summaries.joined(separator: "  •  ")
    }
    
    private func formatTimeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "time.yesterday".localized : "time.days.ago".localizedFormat(days)
        }
        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "time.hour.ago".localized : "time.hours.ago".localizedFormat(hours)
        }
        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "time.minute.ago".localized : "time.minutes.ago".localizedFormat(minutes)
        }
        return "time.just.now".localized
    }
}

struct QuickActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let summary: String?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(color.gradient)
                            .shadow(color: color.opacity(0.3), radius: 5, y: 2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            if let summary = summary {
                HStack {
                    Spacer()
                    Text(summary)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct RecentActivityView: View {
    let baby: Baby
    
    var body: some View {
        ForEach(recentActivities) { activity in
            VStack(alignment: .leading, spacing: 4) {
                Text(formatRelativeTime(activity.timestamp))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    activity.icon
                        .foregroundStyle(activity.color)
                    Text(activity.description)
                        .font(.body)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "time.yesterday".localized : "time.days.ago".localizedFormat(day)
        }
        
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "time.hour.ago".localized : "time.hours.ago".localizedFormat(hour)
        }
        
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "time.minute.ago".localized : "time.minutes.ago".localizedFormat(minute)
        }
        
        return "time.just.now".localized
    }
    
    private var recentActivities: [RecentActivity] {
        var activities: [RecentActivity] = []
        
        // Add recent feedings
        activities += baby.feedingRecords.prefix(2).map { record in
            RecentActivity(
                id: record.id,
                timestamp: record.startTime,
                description: formatFeedingDescription(record),
                icon: Image(systemName: "drop.fill"),
                color: Color(red: 0.3, green: 0.6, blue: 0.9)
            )
        }
        
        // Add recent sleep
        activities += baby.sleepRecords.prefix(2).map { record in
            RecentActivity(
                id: record.id,
                timestamp: record.startTime,
                description: "track.activity.sleep".localizedFormat(formatDuration(from: record.startTime, to: record.endTime)),
                icon: Image(systemName: "moon.fill"),
                color: .indigo
            )
        }
        
        return activities.sorted { $0.timestamp > $1.timestamp }.prefix(3).map { $0 }
    }
    
    private func formatFeedingDescription(_ record: FeedingRecord) -> String {
        let type = "feeding.type.\(record.type.rawValue)".localized
        if let amount = record.amount {
            return "track.activity.feeding.amount".localizedFormat(type, amount)
        }
        return type
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "time.duration".localizedFormat(hours, minutes)
    }
}

struct RecentActivity: Identifiable {
    let id: UUID
    let timestamp: Date
    let description: String
    let icon: Image
    let color: Color
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
}
