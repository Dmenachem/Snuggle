import Foundation

struct DailyChallenge: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let target: Int
    var progress: Int
    
    enum ChallengeType: CaseIterable {
        case feedingCount    // Complete 6 feedings today
        case sleepDuration   // Track 12 hours of sleep
        case medicationTime  // Give medications on time
        case photoCapture    // Take a daily photo
        case notesTaking     // Add detailed notes
        
        var icon: String {
            switch self {
            case .feedingCount: return "bottle.fill"
            case .sleepDuration: return "moon.fill"
            case .medicationTime: return "pills.fill"
            case .photoCapture: return "camera.fill"
            case .notesTaking: return "note.text"
            }
        }
        
        var defaultTarget: Int {
            switch self {
            case .feedingCount: return 6
            case .sleepDuration: return 12
            case .medicationTime: return 3
            case .photoCapture: return 1
            case .notesTaking: return 3
            }
        }
        
        var title: String {
            switch self {
            case .feedingCount: return "Track Feedings"
            case .sleepDuration: return "Track Sleep"
            case .medicationTime: return "Track Medications"
            case .photoCapture: return "Capture Moments"
            case .notesTaking: return "Add Notes"
            }
        }
        
        var description: String {
            switch self {
            case .feedingCount: return "Complete \(defaultTarget) feedings today"
            case .sleepDuration: return "Track \(defaultTarget) hours of sleep"
            case .medicationTime: return "Give \(defaultTarget) medications on time"
            case .photoCapture: return "Take a daily photo"
            case .notesTaking: return "Add \(defaultTarget) detailed notes"
            }
        }
    }
    
    static func generateDailyChallenges() -> [DailyChallenge] {
        // Select 3 random challenges for the day
        let selectedTypes = Array(ChallengeType.allCases.shuffled().prefix(3))
        
        return selectedTypes.map { type in
            DailyChallenge(
                id: UUID(),
                title: type.title,
                description: type.description,
                type: type,
                target: type.defaultTarget,
                progress: 0
            )
        }
    }
} 