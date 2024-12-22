import SwiftUI

struct FamilySharingView: View {
    @EnvironmentObject private var babyTracker: BabyTracker
    @State private var isAddingMember = false
    @State private var newMemberEmail = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            Section {
                ForEach(babyTracker.familyMembers, id: \.self) { member in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(member)
                                .font(.headline)
                            Text(member == "currentUser" ? "Owner" : "Family Member")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if member != "currentUser" {
                            Button(role: .destructive) {
                                removeMember(member)
                            } label: {
                                Image(systemName: "person.fill.xmark")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            } header: {
                Text("Family Members")
            } footer: {
                Text("Family members can view and add tracking data for all babies in the family.")
            }
            
            Section {
                Button(action: { isAddingMember = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus.fill")
                            .foregroundStyle(.blue)
                        Text("Invite Family Member")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle("Family Sharing")
        .sheet(isPresented: $isAddingMember) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Email Address", text: $newMemberEmail)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    } footer: {
                        Text("An invitation will be sent to this email address.")
                    }
                    
                    Section {
                        Button("Send Invitation") {
                            sendInvitation()
                        }
                        .disabled(!isValidEmail(newMemberEmail))
                    }
                }
                .navigationTitle("Invite Member")
                .navigationBarItems(
                    trailing: Button("Cancel") {
                        isAddingMember = false
                    }
                )
            }
        }
        .alert("Family Sharing", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func sendInvitation() {
        // TODO: Implement actual invitation sending logic
        babyTracker.familyMembers.append(newMemberEmail)
        newMemberEmail = ""
        isAddingMember = false
        alertMessage = "Invitation sent successfully!"
        showingAlert = true
    }
    
    private func removeMember(_ member: String) {
        if let index = babyTracker.familyMembers.firstIndex(of: member) {
            babyTracker.familyMembers.remove(at: index)
            alertMessage = "Family member removed successfully."
            showingAlert = true
        }
    }
}

struct FamilySharingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FamilySharingView()
                .environmentObject(BabyTracker())
        }
    }
} 