import Foundation

struct ParentingLevel {
    let level: Int
    let title: String       // "Rookie Parent", "Expert Caregiver", "Master Nurturer"
    let pointsRequired: Int
    let perks: [Perk]
    
    struct Perk {
        let title: String
        let description: String
        let icon: String
    }
} 