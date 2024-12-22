import SwiftUI
import Foundation

struct PredefinedMedication: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let commonDosages: [String]
    let icon: String
    let category: Category
    
    enum Category: String, Codable, CaseIterable {
        case vitamins
        case supplements
        case painRelief
        case fever
        case other
        
        var icon: String {
            switch self {
            case .vitamins: return "pill.circle"
            case .supplements: return "cross.circle"
            case .painRelief: return "heart.circle"
            case .fever: return "thermometer"
            case .other: return "pills.circle"
            }
        }
    }
    
    static let predefined: [PredefinedMedication] = [
        // Vitamins
        PredefinedMedication(
            id: UUID(),
            name: "Vitamin D",
            commonDosages: ["400 IU", "800 IU", "1000 IU"],
            icon: "sun.max.circle",
            category: .vitamins
        ),
        PredefinedMedication(
            id: UUID(),
            name: "Iron Supplement",
            commonDosages: ["7.5 mg", "10 mg", "15 mg"],
            icon: "bolt.circle",
            category: .supplements
        ),
        
        // Supplements
        PredefinedMedication(
            id: UUID(),
            name: "Multivitamin",
            commonDosages: ["0.3 ml", "0.5 ml", "1 ml"],
            icon: "cross.circle",
            category: .supplements
        ),
        
        // Pain Relief
        PredefinedMedication(
            id: UUID(),
            name: "Paracetamol",
            commonDosages: ["2.5 ml", "5 ml", "7.5 ml"],
            icon: "heart.circle",
            category: .painRelief
        ),
        PredefinedMedication(
            id: UUID(),
            name: "Ibuprofen",
            commonDosages: ["2.5 ml", "5 ml", "7.5 ml"],
            icon: "bandage",
            category: .painRelief
        ),
        
        // Fever
        PredefinedMedication(
            id: UUID(),
            name: "Nurofen",
            commonDosages: ["2.5 ml", "5 ml", "7.5 ml"],
            icon: "thermometer",
            category: .fever
        )
    ]
    
    // Implement Equatable
    static func == (lhs: PredefinedMedication, rhs: PredefinedMedication) -> Bool {
        lhs.id == rhs.id
    }
} 