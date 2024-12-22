import SwiftUI
import Charts

enum TimeRange: String, CaseIterable {
    case day = "24 Hours"
    case week = "Week"
    case month = "Month"
    
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        }
    }
}

struct HistoryChartsView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var selectedTimeRange: TimeRange = .day
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack {
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                FeedingChartView(timeRange: selectedTimeRange)
                    .tag(0)
                    .tabItem {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                            Text("Feeding")
                        }
                    }
                
                SleepChartView(timeRange: selectedTimeRange)
                    .tag(1)
                    .tabItem {
                        HStack {
                            Image(systemName: "moon.fill")
                            Text("Sleep")
                        }
                    }
                
                MedicationChartView(timeRange: selectedTimeRange)
                    .tag(2)
                    .tabItem {
                        HStack {
                            Image(systemName: "pills.fill")
                            Text("Medication")
                        }
                    }
            }
        }
    }
}

struct FeedingChartView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    let timeRange: TimeRange
    
    var filteredRecords: [FeedingRecord] {
        guard let baby = babyTracker.selectedBaby else { return [] }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        return baby.feedingRecords.filter { $0.startTime >= cutoffDate }
    }
    
    var groupedRecords: [(date: Date, bottleAmount: Double, breastfeedingDuration: Double, solidsCount: Int)] {
        let calendar = Calendar.current
        var result: [Date: (bottleAmount: Double, breastfeedingDuration: Double, solidsCount: Int)] = [:]
        
        // Create date components for grouping
        let dateComponents: Set<Calendar.Component> = timeRange == .day ? [.hour] : [.day]
        
        for record in filteredRecords {
            let dateComponent = calendar.date(from: calendar.dateComponents(dateComponents, from: record.startTime)) ?? record.startTime
            var current = result[dateComponent] ?? (0, 0, 0)
            
            switch record.type {
            case .bottle:
                current.bottleAmount += record.amount ?? 0
            case .breastfeeding:
                current.breastfeedingDuration += record.duration ?? 0
            case .solids:
                current.solidsCount += 1
            }
            
            result[dateComponent] = current
        }
        
        return result.map { ($0.key, $0.value.bottleAmount, $0.value.breastfeedingDuration, $0.value.solidsCount) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Chart {
            ForEach(groupedRecords, id: \.date) { record in
                BarMark(
                    x: .value("Time", record.date),
                    y: .value("Bottle (ml)", record.bottleAmount)
                )
                .foregroundStyle(.blue)
                
                BarMark(
                    x: .value("Time", record.date),
                    y: .value("Breastfeeding (min)", record.breastfeedingDuration / 60)
                )
                .foregroundStyle(.green)
                
                BarMark(
                    x: .value("Time", record.date),
                    y: .value("Solids", Double(record.solidsCount) * 50) // Scaled for visibility
                )
                .foregroundStyle(.orange)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        if timeRange == .day {
                            Text(date.formatted(.dateTime.hour()))
                        } else {
                            Text(date.formatted(.dateTime.month().day()))
                        }
                    }
                }
            }
        }
        .chartLegend(position: .bottom)
        .padding()
    }
}

struct SleepChartView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    let timeRange: TimeRange
    
    var filteredRecords: [SleepRecord] {
        guard let baby = babyTracker.selectedBaby else { return [] }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        return baby.sleepRecords.filter { $0.startTime >= cutoffDate }
    }
    
    var groupedRecords: [(date: Date, duration: Double, quality: Double)] {
        let calendar = Calendar.current
        var result: [Date: (duration: Double, quality: Double, count: Int)] = [:]
        
        let dateComponents: Set<Calendar.Component> = timeRange == .day ? [.hour] : [.day]
        
        for record in filteredRecords {
            let dateComponent = calendar.date(from: calendar.dateComponents(dateComponents, from: record.startTime)) ?? record.startTime
            var current = result[dateComponent] ?? (0, 0, 0)
            
            let duration = record.endTime.timeIntervalSince(record.startTime) / 3600 // Hours
            let quality: Double = switch record.quality {
                case .poor: 1
                case .fair: 2
                case .good: 3
                case .excellent: 4
            }
            
            current.duration += duration
            current.quality += quality
            current.count += 1
            
            result[dateComponent] = current
        }
        
        return result.map { ($0.key, $0.value.duration, $0.value.quality / Double($0.value.count)) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Chart {
            ForEach(groupedRecords, id: \.date) { record in
                BarMark(
                    x: .value("Time", record.date),
                    y: .value("Sleep Duration (hours)", record.duration)
                )
                .foregroundStyle(.blue)
                
                LineMark(
                    x: .value("Time", record.date),
                    y: .value("Quality", record.quality)
                )
                .foregroundStyle(.red)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
            AxisMarks(position: .trailing) {
                AxisValueLabel { Text("Quality") }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        if timeRange == .day {
                            Text(date.formatted(.dateTime.hour()))
                        } else {
                            Text(date.formatted(.dateTime.month().day()))
                        }
                    }
                }
            }
        }
        .chartLegend(position: .bottom)
        .padding()
    }
}

struct MedicationChartView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    let timeRange: TimeRange
    
    var filteredRecords: [MedicationRecord] {
        guard let baby = babyTracker.selectedBaby else { return [] }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        return baby.medicationRecords.filter { $0.timestamp >= cutoffDate }
    }
    
    var groupedRecords: [(date: Date, medications: [String: Int])] {
        let calendar = Calendar.current
        var result: [Date: [String: Int]] = [:]
        
        let dateComponents: Set<Calendar.Component> = timeRange == .day ? [.hour] : [.day]
        
        for record in filteredRecords {
            let dateComponent = calendar.date(from: calendar.dateComponents(dateComponents, from: record.timestamp)) ?? record.timestamp
            var current = result[dateComponent] ?? [:]
            current[record.medication, default: 0] += 1
            result[dateComponent] = current
        }
        
        return result.map { ($0.key, $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Chart {
            ForEach(groupedRecords, id: \.date) { record in
                ForEach(Array(record.medications.keys), id: \.self) { medication in
                    BarMark(
                        x: .value("Time", record.date),
                        y: .value("Count", record.medications[medication] ?? 0)
                    )
                    .foregroundStyle(by: .value("Medication", medication))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        if timeRange == .day {
                            Text(date.formatted(.dateTime.hour()))
                        } else {
                            Text(date.formatted(.dateTime.month().day()))
                        }
                    }
                }
            }
        }
        .chartLegend(position: .bottom)
        .padding()
    }
} 
