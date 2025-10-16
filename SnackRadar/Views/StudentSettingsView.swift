import SwiftUI

struct StudentSettingsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var notificationsEnabled: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                List {
                    Section {
                        if let profile = sessionViewModel.userProfile {
                            HStack {
                                Text("Email")
                                    .customFont(AppFonts.body)
                                    .foregroundColor(AppColors.secondaryText)
                                Spacer()
                                Text(profile.email)
                                    .customFont(AppFonts.body)
                                    .foregroundColor(AppColors.primaryText)
                            }
                            
                            HStack {
                                Text("Role")
                                    .customFont(AppFonts.body)
                                    .foregroundColor(AppColors.secondaryText)
                                Spacer()
                                Text("Student")
                                    .customFont(AppFonts.body)
                                    .foregroundColor(AppColors.primaryText)
                            }
                        }
                    } header: {
                        Text("Account")
                            .customFont(AppFonts.caption)
                    }
                    
                    Section {
                        Toggle(isOn: $notificationsEnabled) {
                            Text("Push Notifications")
                                .customFont(AppFonts.body)
                        }
                        .tint(AppColors.primaryBlue)
                    } header: {
                        Text("Notifications")
                            .customFont(AppFonts.caption)
                    }
                    
                    Section {
                        Button(action: {
                            sessionViewModel.signOut()
                        }) {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .customFont(AppFonts.body)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StudentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StudentSettingsView()
            .environmentObject(SessionViewModel())
    }
}
