import SwiftUI

struct StudentSettingsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var notificationsEnabled: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
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
                        .disabled(isLoading)
                        .onChange(of: notificationsEnabled) { newValue in
                            handleNotificationToggle(enabled: newValue)
                        }
                    } header: {
                        Text("Notifications")
                            .customFont(AppFonts.caption)
                    } footer: {
                        Text("Receive notifications about new events on your campus")
                            .customFont(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if let profile = sessionViewModel.userProfile {
                    notificationsEnabled = profile.pushNotificationsEnabled
                }
            }
            .onChange(of: sessionViewModel.userProfile) { newProfile in
                if let profile = newProfile {
                    notificationsEnabled = profile.pushNotificationsEnabled
                }
            }
        }
    }
    
    private func handleNotificationToggle(enabled: Bool) {
        isLoading = true
        
        Task {
            do {
                try await sessionViewModel.updatePushNotifications(enabled: enabled)
            } catch {
                await MainActor.run {
                    notificationsEnabled = !enabled
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct StudentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StudentSettingsView()
            .environmentObject(SessionViewModel())
    }
}
