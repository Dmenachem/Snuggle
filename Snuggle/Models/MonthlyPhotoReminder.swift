import Foundation

struct MonthlyPhotoReminder: Identifiable, Codable {
    let id: UUID
    let monthNumber: Int  // 1-12
    let dueDate: Date
    let isCompleted: Bool
    var photoData: Data?
    
    static func generateReminders(from birthDate: Date) -> [MonthlyPhotoReminder] {
        (1...12).map { month in
            let dueDate = Calendar.current.date(byAdding: .month, value: month, to: birthDate) ?? birthDate
            return MonthlyPhotoReminder(
                id: UUID(),
                monthNumber: month,
                dueDate: dueDate,
                isCompleted: false,
                photoData: nil
            )
        }
    }
} 