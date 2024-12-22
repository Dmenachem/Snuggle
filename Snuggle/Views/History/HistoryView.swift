import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedTab: DataType = .feeding
    
    enum TimePeriod: String, CaseIterable {
        case week = "Last Week"
        case month = "Last Month"
        case threeMonths = "3 Months"
    }
    
    enum DataType: String, CaseIterable {
        case feeding = "Feeding"
        case sleep = "Sleep"
        case growth = "Growth"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Data Type Selector
                Picker("Data Type", selection: $selectedTab) {
                    ForEach(DataType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if let baby = babyTracker.selectedBaby {
                    switch selectedTab {
                    case .feeding:
                        FeedingHistoryChartView(records: baby.feedingRecords, period: selectedPeriod)
                    case .sleep:
                        SleepHistoryChartView(records: baby.sleepRecords, period: selectedPeriod)
                    case .growth:
                        GrowthHistoryChartView(measurements: baby.growthMeasurements, period: selectedPeriod)
                    }
                } else {
                    ContentUnavailableView(
                        "No Baby Selected",
                        systemImage: "person.crop.circle.badge.questionmark",
                        description: Text("Select a baby in the Profile tab to view history")
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

struct FeedingHistoryChartView: View {
    let records: [FeedingRecord]
    let period: HistoryView.TimePeriod
    
    private var filteredRecords: [FeedingRecord] {
        let calendar = Calendar.current
        let cutoffDate: Date
        switch period {
        case .week:
            cutoffDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .threeMonths:
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        }
        return records.filter { $0.startTime >= cutoffDate }
    }
    
    private var dailyFeedingCounts: [DailyCount] {
        let calendar = Calendar.current
        var counts: [Date: Int] = [:]
        
        // Group records by day
        for record in filteredRecords {
            let day = calendar.startOfDay(for: record.startTime)
            counts[day, default: 0] += 1
        }
        
        // Convert to array and sort by date
        return counts.map { DailyCount(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private var feedingTypeDistribution: [TypeCount] {
        var counts: [FeedingRecord.FeedingType: Int] = [:]
        
        // Count occurrences of each feeding type
        for record in filteredRecords {
            counts[record.type, default: 0] += 1
        }
        
        // Convert to array
        return counts.map { TypeCount(type: $0.key.rawValue, count: $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Daily Feeding Count Chart
            ChartCard(title: "Feedings per Day") {
                Chart(dailyFeedingCounts) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            
            // Feeding Types Distribution
            ChartCard(title: "Feeding Types") {
                Chart(feedingTypeDistribution) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Type", item.type))
                }
            }
            .frame(height: 200)
        }
        .padding()
    }
}

struct SleepHistoryChartView: View {
    let records: [SleepRecord]
    let period: HistoryView.TimePeriod
    
    private var filteredRecords: [SleepRecord] {
        let calendar = Calendar.current
        let cutoffDate: Date
        switch period {
        case .week:
            cutoffDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .threeMonths:
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        }
        return records.filter { $0.startTime >= cutoffDate }
    }
    
    private var dailySleepDuration: [DailySleep] {
        let calendar = Calendar.current
        var durations: [Date: Double] = [:]
        
        // Calculate total sleep duration for each day
        for record in filteredRecords {
            let day = calendar.startOfDay(for: record.startTime)
            let duration = record.endTime.timeIntervalSince(record.startTime) / 3600 // Convert to hours
            durations[day, default: 0] += duration
        }
        
        // Convert to array and sort by date
        return durations.map { DailySleep(date: $0.key, hours: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private var qualityDistribution: [QualityCount] {
        var counts: [SleepRecord.SleepQuality: Int] = [:]
        
        // Count occurrences of each quality level
        for record in filteredRecords {
            counts[record.quality, default: 0] += 1
        }
        
        // Convert to array
        return counts.map { QualityCount(quality: $0.key.rawValue, count: $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Daily Sleep Duration Chart
            ChartCard(title: "Sleep Duration") {
                Chart(dailySleepDuration) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(Color.indigo.gradient)
                }
            }
            
            // Sleep Quality Distribution
            ChartCard(title: "Sleep Quality") {
                Chart(qualityDistribution) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Quality", item.quality))
                }
            }
            .frame(height: 200)
        }
        .padding()
    }
}

struct GrowthHistoryChartView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    let measurements: [GrowthMeasurement]
    let period: HistoryView.TimePeriod
    
    private var filteredMeasurements: [GrowthMeasurement] {
        let calendar = Calendar.current
        let cutoffDate: Date
        switch period {
        case .week:
            cutoffDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .threeMonths:
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        }
        return measurements.filter { $0.date >= cutoffDate }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Percentile Charts
                if let baby = babyTracker.selectedBaby {
                    let gender: GrowthStandards.Gender = baby.gender ?? .male // Add gender property to Baby model
                    
                    GrowthPercentileChart(
                        measurements: filteredMeasurements,
                        gender: gender,
                        measurementType: .weight
                    )
                    
                    GrowthPercentileChart(
                        measurements: filteredMeasurements,
                        gender: gender,
                        measurementType: .height
                    )
                    
                    GrowthPercentileChart(
                        measurements: filteredMeasurements,
                        gender: gender,
                        measurementType: .headCircumference
                    )
                }
                
                // Raw measurement charts
                ChartCard(title: "Weight (kg)") {
                    Chart(filteredMeasurements) { measurement in
                        if let weight = measurement.weight {
                            LineMark(
                                x: .value("Date", measurement.date),
                                y: .value("Weight", weight)
                            )
                            .symbol(Circle())
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(date.formatted(.dateTime.month().day()))
                                }
                            }
                        }
                    }
                }
                
                ChartCard(title: "Height (cm)") {
                    Chart(filteredMeasurements) { measurement in
                        if let height = measurement.height {
                            LineMark(
                                x: .value("Date", measurement.date),
                                y: .value("Height", height)
                            )
                            .symbol(Circle())
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(date.formatted(.dateTime.month().day()))
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            content
                .frame(height: 180)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        )
    }
}

// Data Models for Charts
struct DailyCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct TypeCount: Identifiable {
    let id = UUID()
    let type: String
    let count: Int
}

struct DailySleep: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}

struct QualityCount: Identifiable {
    let id = UUID()
    let quality: String
    let count: Int
} 