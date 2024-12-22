import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        List {
            Section {
                Text("Privacy Policy content will be implemented here")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("profile.privacy.policy".localized)
    }
} 