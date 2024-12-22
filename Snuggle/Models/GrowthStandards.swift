import Foundation

struct GrowthStandards {
    enum Gender {
        case male, female
    }
    
    enum Measurement {
        case weight    // kg
        case height   // cm
        case headCircumference // cm
    }
    
    // Percentile lines (3rd, 15th, 50th, 85th, 97th)
    static let percentiles = [3, 15, 50, 85, 97]
    
    // WHO standards data structure
    struct StandardPoint {
        let ageMonths: Int
        let values: [Int: Double] // percentile: value
    }
    
    // WHO data for weight-for-age (kg) - Boys 0-24 months
    static let weightForAgeBoys: [StandardPoint] = [
        StandardPoint(ageMonths: 0, values: [3: 2.9, 15: 3.2, 50: 3.5, 85: 3.9, 97: 4.2]),
        StandardPoint(ageMonths: 3, values: [3: 5.0, 15: 5.6, 50: 6.4, 85: 7.2, 97: 7.9]),
        StandardPoint(ageMonths: 6, values: [3: 6.4, 15: 7.0, 50: 7.9, 85: 8.8, 97: 9.5]),
        StandardPoint(ageMonths: 9, values: [3: 7.1, 15: 7.9, 50: 8.9, 85: 9.9, 97: 10.7]),
        StandardPoint(ageMonths: 12, values: [3: 7.7, 15: 8.6, 50: 9.6, 85: 10.8, 97: 11.7])
    ]
    
    // WHO data for height-for-age (cm) - Boys 0-24 months
    static let heightForAgeBoys: [StandardPoint] = [
        StandardPoint(ageMonths: 0, values: [3: 47.0, 15: 48.5, 50: 49.9, 85: 51.3, 97: 52.5]),
        StandardPoint(ageMonths: 3, values: [3: 57.2, 15: 58.8, 50: 61.4, 85: 63.0, 97: 64.4]),
        StandardPoint(ageMonths: 6, values: [3: 63.4, 15: 65.1, 50: 67.6, 85: 70.1, 97: 71.6]),
        StandardPoint(ageMonths: 9, values: [3: 67.7, 15: 69.5, 50: 72.0, 85: 74.5, 97: 76.2]),
        StandardPoint(ageMonths: 12, values: [3: 71.0, 15: 72.9, 50: 75.7, 85: 78.4, 97: 80.1])
    ]
    
    // WHO data for head circumference-for-age (cm) - Boys 0-24 months
    static let headCircumferenceForAgeBoys: [StandardPoint] = [
        StandardPoint(ageMonths: 0, values: [3: 32.1, 15: 33.1, 50: 34.5, 85: 35.7, 97: 36.6]),
        StandardPoint(ageMonths: 3, values: [3: 37.2, 15: 38.3, 50: 40.1, 85: 41.7, 97: 42.7]),
        StandardPoint(ageMonths: 6, values: [3: 40.2, 15: 41.4, 50: 43.3, 85: 44.9, 97: 45.8]),
        StandardPoint(ageMonths: 9, values: [3: 42.0, 15: 43.2, 50: 45.2, 85: 46.8, 97: 47.8]),
        StandardPoint(ageMonths: 12, values: [3: 43.2, 15: 44.4, 50: 46.3, 85: 47.9, 97: 48.9])
    ]
    
    static func getStandardData(for measurement: Measurement, gender: Gender) -> [StandardPoint] {
        switch (measurement, gender) {
        case (.weight, .male):
            return weightForAgeBoys
        case (.height, .male):
            return heightForAgeBoys
        case (.headCircumference, .male):
            return headCircumferenceForAgeBoys
        default:
            return weightForAgeBoys // Replace with girls data when available
        }
    }
    
    static func calculatePercentile(
        value: Double,
        ageMonths: Int,
        gender: Gender,
        measurement: Measurement
    ) -> Double {
        let standards = getStandardData(for: measurement, gender: gender)
        
        guard let ageData = standards.first(where: { $0.ageMonths == ageMonths }) else {
            return 50 // Default to 50th percentile if age not found
        }
        
        // Find where the value falls between percentiles
        for (index, percentile) in percentiles.enumerated() {
            if index < percentiles.count - 1 {
                let currentValue = ageData.values[percentile] ?? 0
                let nextValue = ageData.values[percentiles[index + 1]] ?? 0
                
                if value >= currentValue && value <= nextValue {
                    let percentileRange = Double(percentiles[index + 1] - percentile)
                    let valueRange = nextValue - currentValue
                    let valuePosition = value - currentValue
                    
                    return Double(percentile) + (valuePosition / valueRange) * percentileRange
                }
            }
        }
        
        return 50
    }
} 