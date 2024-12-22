import Foundation

struct Achievement: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let type: AchievementType
    let requirement: Int
    var isUnlocked: Bool
    
    enum AchievementType: CaseIterable {
        case feeding      // "Super Feeder" - Track 100 feedings
        case sleep       // "Sleep Whisperer" - Track 50 sleep sessions
        case consistency // "Dedicated Parent" - Use app for 30 days straight
        case growth      // "Growth Expert" - Track 12 growth measurements
        case sharing     // "Family Team" - Add family members
        case special    // "First Steps", "First Words", etc.
    }
} 