import Foundation

struct ParentingTip: Identifiable {
    let id: UUID
    let content: String
    let source: String?
    let category: TipCategory
    
    enum TipCategory {
        case feeding
        case sleep
        case development
        case safety
        case health
        case general
    }
    
    static func generateDailyTips() -> [ParentingTip] {
        // Return a random selection of tips based on baby's age and recent activities
        []
    }
} 