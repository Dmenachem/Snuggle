import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .main, comment: "")
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        String(format: self.localized, arguments)
    }
} 