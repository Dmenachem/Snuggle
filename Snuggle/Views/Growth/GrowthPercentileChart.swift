import SwiftUI
import Charts

struct GrowthPercentileChart: View {
    let measurements: [GrowthMeasurement]
    let gender: GrowthStandards.Gender
    let measurementType: GrowthStandards.Measurement
    
    private var standardData: [GrowthStandards.StandardPoint] {
        GrowthStandards.getStandardData(for: measurementType, gender: gender)
    }
    
    private var chartData: [PercentilePoint] {
        measurements.compactMap { measurement in
            let ageMonths = Calendar.current.dateComponents(
                [.month],
                from: measurement.date
            ).month ?? 0
            
            let value: Double? = {
                switch measurementType {
                case .weight: return measurement.weight
                case .height: return measurement.height
                case .headCircumference: return measurement.headCircumference
                }
            }()
            
            // Return nil if no value exists
            guard let measurementValue = value else { return nil }
            
            // Calculate percentile
            let percentile = GrowthStandards.calculatePercentile(
                value: measurementValue,
                ageMonths: ageMonths,
                gender: gender,
                measurement: measurementType
            )
            
            // Return the PercentilePoint
            return PercentilePoint(
                date: measurement.date,
                value: measurementValue,
                percentile: percentile
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(chartTitle)
                .font(.headline)
            
            Chart {
                // Draw percentile curves
                ForEach(standardData, id: \.ageMonths) { point in
                    ForEach(GrowthStandards.percentiles, id: \.self) { percentile in
                        if let value = point.values[percentile] {
                            LineMark(
                                x: .value("Age (months)", point.ageMonths),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(.gray.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            
                            // Add percentile labels at the end of each line
                            if point.ageMonths == standardData.last?.ageMonths {
                                PointMark(
                                    x: .value("Age (months)", point.ageMonths),
                                    y: .value("Value", value)
                                )
                                .annotation(position: .trailing) {
                                    Text("\(percentile)%")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Baby's measurements
                ForEach(chartData) { point in
                    LineMark(
                        x: .value("Age (months)", Calendar.current.dateComponents([.month], from: point.date).month ?? 0),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Age (months)", Calendar.current.dateComponents([.month], from: point.date).month ?? 0),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(.blue)
                    .annotation {
                        Text(String(format: "%.1f", point.value))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(position: .bottom) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            
            // Legend
            HStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
                Text("Your baby")
                    .font(.caption)
                
                Spacer()
                
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 20, height: 2)
                Text("WHO standards")
                    .font(.caption)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
    }
    
    private var chartTitle: String {
        switch measurementType {
        case .weight:
            return "Weight-for-age Percentiles"
        case .height:
            return "Length-for-age Percentiles"
        case .headCircumference:
            return "Head Circumference-for-age Percentiles"
        }
    }
}

struct PercentilePoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let percentile: Double
} 