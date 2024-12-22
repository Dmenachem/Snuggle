import Foundation

struct Baby: Identifiable, Codable {
    let id: UUID
    var name: String
    var dateOfBirth: Date
    var parentIDs: [String]
    var gender: GrowthStandards.Gender?
    
    // Growth tracking
    private(set) var growthMeasurements: [GrowthMeasurement]
    private(set) var feedingRecords: [FeedingRecord]
    private(set) var sleepRecords: [SleepRecord]
    private(set) var medicationRecords: [MedicationRecord]
    
    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date,
        parentIDs: [String],
        gender: GrowthStandards.Gender? = nil
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.parentIDs = parentIDs
        self.gender = gender
        self.growthMeasurements = []
        self.feedingRecords = []
        self.sleepRecords = []
        self.medicationRecords = []
    }
    
    mutating func addFeedingRecord(_ record: FeedingRecord) {
        var records = feedingRecords
        records.append(record)
        feedingRecords = records
    }
    
    mutating func addSleepRecord(_ record: SleepRecord) {
        sleepRecords.append(record)
    }
    
    mutating func addGrowthMeasurement(_ record: GrowthMeasurement) {
        growthMeasurements.append(record)
    }
    
    mutating func addMedicationRecord(_ record: MedicationRecord) {
        medicationRecords.append(record)
    }
}

struct GrowthMeasurement: Identifiable, Codable {
    let id: UUID
    let date: Date
    let weight: Double? // in kg
    let height: Double? // in cm
    let headCircumference: Double? // in cm
}

struct FeedingRecord: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let duration: TimeInterval?
    let type: FeedingType
    let amount: Double? // in ml if bottle
    let foodTypes: [FoodType]? // for solids
    let notes: String?
    
    enum FeedingType: String, Codable, CaseIterable {
        case breastfeeding
        case bottle
        case solids
    }
}

struct SleepRecord: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let quality: SleepQuality
    let notes: String?
    
    enum SleepQuality: String, Codable, CaseIterable {
        case poor
        case fair
        case good
        case excellent
    }
}

struct MedicationRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let medication: String
    let dosage: String
    let notes: String?
}

// Make GrowthStandards.Gender Codable
extension GrowthStandards.Gender: Codable {
    enum CodingKeys: String, CodingKey {
        case male, female
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self == .male ? "male" : "female")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = value == "male" ? .male : .female
    }
} 