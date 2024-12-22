import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @AppStorage("app.language") private var language = "en"
    @State private var showingAddBaby = false
    @State private var selectedBabyForSettings: Baby?
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        List {
            Section("profile.babies".localized) {
                ForEach(babyTracker.babies) { baby in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(baby.name)
                                .font(.headline)
                            Text(formatBabyAge(birthDate: baby.dateOfBirth))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if baby.id == babyTracker.selectedBabyId {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if baby.id == babyTracker.selectedBabyId {
                            selectedBabyForSettings = baby
                        } else {
                            babyTracker.selectedBabyId = baby.id
                        }
                    }
                }
            }
            
            Button {
                showingAddBaby = true
            } label: {
                Label("profile.add.baby".localized, systemImage: "plus")
            }
            
            Section("settings.preferences".localized) {
                Menu {
                    Button("English") {
                        setLanguage("en")
                    }
                    Button("עברית") {
                        setLanguage("he")
                    }
                } label: {
                    HStack {
                        Text("settings.language".localized)
                        Spacer()
                        Text(language == "en" ? "English" : "עברית")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Picker("settings.theme".localized, selection: $themeManager.colorSchemePreference) {
                    Text("theme.light".localized).tag(ColorSchemePreference.light)
                    Text("theme.dark".localized).tag(ColorSchemePreference.dark)
                    Text("theme.system".localized).tag(ColorSchemePreference.system)
                }
            }
            
            Section("profile.account".localized) {
                NavigationLink("profile.family.sharing".localized) {
                    FamilySharingView()
                }
                NavigationLink("profile.notifications".localized) {
                    NotificationsView()
                }
                NavigationLink("profile.data.privacy".localized) {
                    PrivacyView()
                }
            }
            
            Section("profile.about".localized) {
                NavigationLink("profile.help.support".localized) {
                    HelpSupportView()
                }
                NavigationLink("profile.privacy.policy".localized) {
                    PrivacyPolicyView()
                }
                Text("profile.version".localizedFormat("1.0.0"))
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingAddBaby) {
            AddBabyView()
        }
        .sheet(item: $selectedBabyForSettings) { baby in
            NavigationStack {
                BabySettingsView(baby: baby)
            }
        }
    }
    
    private func setLanguage(_ code: String) {
        guard language != code else { return }
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.set(code, forKey: "app.language")
        NotificationCenter.default.post(name: NSNotification.Name("RestartApp"), object: nil)
    }
    
    private func formatBabyAge(birthDate: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthDate, to: now)
        
        if let years = ageComponents.year, years > 0 {
            return "\(years) " + (years == 1 ? "year.single" : "year.plural").localized
        }
        
        if let months = ageComponents.month, months > 0 {
            return "\(months) " + (months == 1 ? "month.single" : "month.plural").localized
        }
        
        if let days = ageComponents.day {
            return "\(days) " + (days == 1 ? "day.single" : "day.plural").localized
        }
        
        return "0 " + "day.plural".localized
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(BabyTracker())
    }
} 