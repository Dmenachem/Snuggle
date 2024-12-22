import SwiftUI
import Foundation
import UserNotifications

@MainActor
class BabyTracker: ObservableObject {
    @Published private(set) var babies: [Baby]
    @Published var selectedBabyId: UUID?
    @AppStorage("last.feeding.type") private var lastFeedingType: FeedingRecord.FeedingType = .bottle
    
    @Published private(set) var dailyTips: [ParentingTip]
    @Published private(set) var dailyChallenges: [DailyChallenge]
    @Published private(set) var achievements: [Achievement]
    @Published private(set) var specialMoments: [SpecialMoment]
    @Published private(set) var parentingLevel: ParentingLevel
    @Published private(set) var currentPoints: Int
    
    // Family sharing
    @Published var familyMembers: [String]
    
    init() {
        // Initialize all stored properties
        self.babies = []
        self.dailyTips = []
        self.dailyChallenges = []
        self.achievements = []
        self.specialMoments = []
        self.parentingLevel = ParentingLevel(
            level: 1,
            title: "Rookie Parent",
            pointsRequired: 100,
            perks: []
        )
        self.currentPoints = 0
        self.familyMembers = ["currentUser"]
        
        // After all properties are initialized, we can call methods
        loadBabies()
    }
    
    var selectedBaby: Baby? {
        guard let selectedBabyId else { return nil }
        return babies.first { $0.id == selectedBabyId }
    }
    
    // Computed properties for engagement
    var nextLevelPoints: Int {
        parentingLevel.pointsRequired
    }
    
    var dailyStreak: Int {
        // Calculate streak from usage history
        UserDefaults.standard.integer(forKey: "daily.streak")
    }
    
    func loadBabies() {
        // Temporary test data
        let testBaby = Baby(
            name: "Test Baby",
            dateOfBirth: Date(),
            parentIDs: ["testParent"]
        )
        babies.append(testBaby)
        selectedBabyId = testBaby.id
    }
    
    func addBaby(_ baby: Baby) {
        babies.append(baby)
        saveBabies()
    }
    
    func addFeedingRecord(_ record: FeedingRecord, for babyId: UUID) {
        guard let baby = babies.first(where: { $0.id == babyId }) else { return }
        var updatedBaby = baby
        updatedBaby.addFeedingRecord(record)
        
        if let index = babies.firstIndex(where: { $0.id == babyId }) {
            babies[index] = updatedBaby
        }
        lastFeedingType = record.type
        saveBabies()
    }
    
    func addSleepRecord(_ record: SleepRecord, for babyId: UUID) {
        guard let baby = babies.first(where: { $0.id == babyId }) else { return }
        var updatedBaby = baby
        updatedBaby.addSleepRecord(record)
        
        if let index = babies.firstIndex(where: { $0.id == babyId }) {
            babies[index] = updatedBaby
        }
        saveBabies()
    }
    
    func addGrowthMeasurement(_ record: GrowthMeasurement, for babyId: UUID) {
        guard let baby = babies.first(where: { $0.id == babyId }) else { return }
        var updatedBaby = baby
        updatedBaby.addGrowthMeasurement(record)
        
        if let index = babies.firstIndex(where: { $0.id == babyId }) {
            babies[index] = updatedBaby
        }
        saveBabies()
    }
    
    func addMedicationRecord(_ record: MedicationRecord, for babyId: UUID) {
        guard let baby = babies.first(where: { $0.id == babyId }) else { return }
        var updatedBaby = baby
        updatedBaby.addMedicationRecord(record)
        
        if let index = babies.firstIndex(where: { $0.id == babyId }) {
            babies[index] = updatedBaby
        }
        saveBabies()
    }
    
    func updateBaby(_ updatedBaby: Baby) {
        if let index = babies.firstIndex(where: { $0.id == updatedBaby.id }) {
            babies[index] = updatedBaby
        }
        saveBabies()
    }
    
    func deleteBaby(_ id: UUID) {
        babies.removeAll { $0.id == id }
        if selectedBabyId == id {
            selectedBabyId = babies.first?.id
        }
        saveBabies()
    }
    
    func saveBabies() {
        // Implementation for saving babies to CloudKit
    }
    
    func recentBottleAmounts(for babyId: UUID, limit: Int = 5) -> [Double] {
        guard let baby = babies.first(where: { $0.id == babyId }) else { return [] }
        
        return baby.feedingRecords
            .filter { $0.type == .bottle && $0.amount != nil }
            .sorted { $0.startTime > $1.startTime }
            .prefix(limit)
            .compactMap { $0.amount }
    }
    
    var lastUsedFeedingType: FeedingRecord.FeedingType {
        lastFeedingType
    }
    
    // Track app opens to maintain streak
    func trackAppOpen() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastOpen = UserDefaults.standard.object(forKey: "last.app.open") as? Date {
            let lastOpenDay = calendar.startOfDay(for: lastOpen)
            
            if calendar.isDate(lastOpenDay, inSameDayAs: today) {
                // Already opened today
                return
            } else if let daysBetween = calendar.dateComponents([.day], from: lastOpenDay, to: today).day,
                      daysBetween == 1 {
                // Consecutive day
                let streak = UserDefaults.standard.integer(forKey: "daily.streak")
                UserDefaults.standard.set(streak + 1, forKey: "daily.streak")
                checkStreakAchievements(streak + 1)
            } else {
                // Streak broken
                UserDefaults.standard.set(1, forKey: "daily.streak")
            }
        } else {
            // First open
            UserDefaults.standard.set(1, forKey: "daily.streak")
        }
        
        UserDefaults.standard.set(today, forKey: "last.app.open")
        generateDailyContent()
    }
    
    private func generateDailyContent() {
        dailyTips = ParentingTip.generateDailyTips()
        dailyChallenges = DailyChallenge.generateDailyChallenges()
    }
    
    // Achievement handling
    func awardPoints(_ points: Int) {
        currentPoints += points
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        if currentPoints >= parentingLevel.pointsRequired {
            levelUp()
        }
    }
    
    private func levelUp() {
        // Implement level up logic
    }
    
    // Special moments handling
    func addSpecialMoment(_ moment: SpecialMoment) {
        specialMoments.append(moment)
        checkMilestoneAchievements(moment)
        saveBabies() // Assuming this saves all data
    }
    
    private func checkStreakAchievements(_ streak: Int) {
        // Define streak-based achievements
        let streakAchievements: [(days: Int, achievement: Achievement)] = [
            (3, Achievement(
                id: UUID(),
                title: "Getting Started",
                description: "Used the app for 3 days in a row",
                icon: "star.fill",
                type: .consistency,
                requirement: 3,
                isUnlocked: false
            )),
            (7, Achievement(
                id: UUID(),
                title: "Week Warrior",
                description: "Used the app for a full week",
                icon: "star.circle.fill",
                type: .consistency,
                requirement: 7,
                isUnlocked: false
            )),
            (30, Achievement(
                id: UUID(),
                title: "Dedicated Parent",
                description: "Used the app for 30 days straight",
                icon: "star.square.fill",
                type: .consistency,
                requirement: 30,
                isUnlocked: false
            )),
            (100, Achievement(
                id: UUID(),
                title: "Super Parent",
                description: "Used the app for 100 days straight",
                icon: "star.square.on.square.fill",
                type: .consistency,
                requirement: 100,
                isUnlocked: false
            ))
        ]
        
        // Check and award achievements
        for (days, achievement) in streakAchievements {
            if streak >= days {
                if !achievements.contains(where: { $0.id == achievement.id }) {
                    achievements.append(achievement)
                    // Could trigger a notification or celebration animation here
                    awardPoints(50) // Award points for unlocking achievement
                }
            }
        }
    }
    
    private func checkMilestoneAchievements(_ moment: SpecialMoment) {
        // Define milestone achievements
        let milestoneAchievement = Achievement(
            id: UUID(),
            title: "Memory Keeper",
            description: "Captured a special milestone",
            icon: "heart.fill",
            type: .special,
            requirement: 1,
            isUnlocked: false
        )
        
        if !achievements.contains(where: { $0.type == .special }) {
            achievements.append(milestoneAchievement)
            awardPoints(100) // Award more points for special moments
        }
    }
    
    private func checkMonthlyPhotoAchievements() {
        guard let selectedBaby = selectedBaby else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let ageInMonths = calendar.dateComponents([.month], from: selectedBaby.dateOfBirth, to: now).month ?? 0
        
        if ageInMonths <= 12 && ageInMonths > 0 {
            let monthlyPhotoAchievement = Achievement(
                id: UUID(),
                title: "Month \(ageInMonths) Milestone",
                description: "Captured your baby's \(ageInMonths) month photo",
                icon: "camera.fill",
                type: .special,
                requirement: 1,
                isUnlocked: false
            )
            
            if !achievements.contains(where: { $0.id == monthlyPhotoAchievement.id }) {
                achievements.append(monthlyPhotoAchievement)
                awardPoints(50)
                
                // Schedule next month reminder
                scheduleMonthlyPhotoReminder(forMonth: ageInMonths + 1)
            }
        }
    }
    
    private func scheduleMonthlyPhotoReminder(forMonth month: Int) {
        guard let baby = selectedBaby, month <= 12 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Monthly Photo Reminder"
        content.body = "Time to take \(baby.name)'s \(month) month photo!"
        content.sound = .default
        
        // Calculate next photo date
        let nextPhotoDate = Calendar.current.date(
            byAdding: .month,
            value: month,
            to: baby.dateOfBirth
        ) ?? Date()
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: nextPhotoDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "monthlyPhoto-\(month)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
} 