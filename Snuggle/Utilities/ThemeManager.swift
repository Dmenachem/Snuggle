import SwiftUI

enum ColorSchemePreference: String {
    case light, dark, system
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("app.colorScheme") private var preference = ColorSchemePreference.system.rawValue
    
    var colorSchemePreference: ColorSchemePreference {
        get { ColorSchemePreference(rawValue: preference) ?? .system }
        set { preference = newValue.rawValue }
    }
    
    var colorScheme: ColorScheme? {
        colorSchemePreference.colorScheme
    }
} 