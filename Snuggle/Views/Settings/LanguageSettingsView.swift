import SwiftUI

struct LanguageSettingsView: View {
    @AppStorage("app.language") private var selectedLanguage = "en"
    @Environment(\.dismiss) private var dismiss
    
    let languages = [
        ("en", "English (US)", "🇺🇸"),
        ("he", "עברית", "🇮🇱")
    ]
    
    var body: some View {
        List {
            ForEach(languages, id: \.0) { code, name, flag in
                HStack {
                    Text(flag)
                    Text(name)
                    Spacer()
                    if selectedLanguage == code {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = code
                    UserDefaults.standard.set([code], forKey: "AppleLanguages")
                    dismiss()
                }
            }
        }
        .navigationTitle("settings.language".localized)
    }
} 