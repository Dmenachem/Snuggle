import Foundation

struct SpecialMoment: Identifiable, Codable {
    let id: UUID
    let type: MomentType
    let date: Date
    let notes: String?
    let photos: [Data]?
    
    enum MomentType: String, Codable, CaseIterable {
        case firstSmile
        case firstLaugh
        case firstWord
        case firstStep
        case firstTooth
        case firstHaircut
        case firstFood
        // ... more milestones
    }
} 