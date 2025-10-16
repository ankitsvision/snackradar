import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel: ProfileViewModel
    @State private var showCampusPicker = false
    @State private var showSocialLinksEditor = false
    @State private var showRoleRequestConfirmation = false
    
    init(sessionViewModel: SessionViewModel) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(sessionViewModel: sessionViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let profile = sessionViewModel.userProfile {
                            profileSection(profile: profile)
                            campusSection(profile: profile)
                            notificationSection()
                            
                            if profile.userRole == .student && !profile.roleUpgradeRequested {
                                roleUpgradeSection()
                            } else if profile.userRole == .organizer && !profile.isApproved {
                                pendingApprovalSection()
                            }
                            
                            socialLinksSection()
                            logoutSection()
                        }
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryBlue))
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let profile = sessionViewModel.userProfile {
                    viewModel.loadProfile(profile)
                }
            }
            .sheet(isPresented: $showCampusPicker) {
                CampusPickerSheet(
                    campuses: viewModel.availableCampuses,
                    selectedCampus: viewModel.selectedCampus
                ) { campus in
                    Task {
                        await viewModel.updateCampus(campus)
                        showCampusPicker = false
                    }
                }
            }
            .sheet(isPresented: $showSocialLinksEditor) {
                SocialLinksEditorSheet(
                    socialLinks: $viewModel.socialLinks
                ) {
                    Task {
                        await viewModel.updateSocialLinks()
                        showSocialLinksEditor = false
                    }
                }
            }
            .alert("Request Organizer Role", isPresented: $showRoleRequestConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Request") {
                    Task {
                        await viewModel.requestOrganizerRole()
                    }
                }
            } message: {
                Text("Your request will be reviewed by an administrator. You'll be notified once approved.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let success = viewModel.successMessage {
                    Text(success)
                }
            }
        }
    }
    
    private func profileSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Email")
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                    Spacer()
                    Text(profile.email)
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.primaryText)
                }
                .padding()
                .background(Color.white)
                
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Role")
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                    Spacer()
                    Text(profile.userRole.displayName)
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.primaryText)
                    
                    if profile.userRole == .organizer && profile.isApproved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
                .padding()
                .background(Color.white)
            }
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private func campusSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Campus")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal)
            
            Button(action: {
                showCampusPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected Campus")
                            .customFont(AppFonts.body)
                            .foregroundColor(AppColors.secondaryText)
                        
                        if let campus = viewModel.selectedCampus {
                            Text(campus.name)
                                .customFont(AppFonts.body)
                                .foregroundColor(AppColors.primaryText)
                        } else {
                            Text("No campus selected")
                                .customFont(AppFonts.body)
                                .foregroundColor(AppColors.secondaryText.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.secondaryText)
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func notificationSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                Button(action: {
                    Task {
                        await viewModel.toggleNotifications()
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Push Notifications")
                                .customFont(AppFonts.body)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("Get notified about new events")
                                .customFont(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.notificationsEnabled)
                            .labelsHidden()
                            .tint(AppColors.primaryBlue)
                            .disabled(true)
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                }
                
                if PushNotificationManager.shared.permissionStatus == .denied {
                    Divider()
                        .padding(.leading)
                    
                    Button(action: {
                        viewModel.openNotificationSettings()
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            Text("Open Settings to enable notifications")
                                .customFont(AppFonts.caption)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(AppColors.primaryBlue)
                        }
                        .padding()
                        .background(Color.white)
                    }
                }
            }
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private func roleUpgradeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Role Management")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal)
            
            Button(action: {
                showRoleRequestConfirmation = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Request Organizer Role")
                            .customFont(AppFonts.body)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Submit a request to become an event organizer")
                            .customFont(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(AppColors.primaryBlue)
                        .font(.system(size: 24))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func pendingApprovalSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Role Status")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Organizer Request Pending")
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Your request is under review by an administrator")
                        .customFont(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(10)
        }
    }
    
    private func socialLinksSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Social Links")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal)
            
            Button(action: {
                showSocialLinksEditor = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manage Social Links")
                            .customFont(AppFonts.body)
                            .foregroundColor(AppColors.primaryText)
                        
                        if !viewModel.socialLinks.isEmpty {
                            Text("\(socialLinksCount()) link(s) added")
                                .customFont(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        } else {
                            Text("Add your social media profiles")
                                .customFont(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(AppColors.primaryBlue)
                        .font(.system(size: 24))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func logoutSection() -> some View {
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
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private func socialLinksCount() -> Int {
        var count = 0
        if viewModel.socialLinks.instagram != nil { count += 1 }
        if viewModel.socialLinks.twitter != nil { count += 1 }
        if viewModel.socialLinks.facebook != nil { count += 1 }
        if viewModel.socialLinks.linkedIn != nil { count += 1 }
        if viewModel.socialLinks.website != nil { count += 1 }
        return count
    }
}

struct CampusPickerSheet: View {
    let campuses: [Campus]
    let selectedCampus: Campus?
    let onSelect: (Campus) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(campuses) { campus in
                Button(action: {
                    onSelect(campus)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(campus.name)
                                .customFont(AppFonts.body)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text(campus.city + ", " + campus.state)
                                .customFont(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        if selectedCampus?.id == campus.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.primaryBlue)
                        }
                    }
                }
            }
            .navigationTitle("Select Campus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SocialLinksEditorSheet: View {
    @Binding var socialLinks: SocialLinks
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Social Media")) {
                    HStack {
                        Image(systemName: "photo.circle.fill")
                            .foregroundColor(.pink)
                        TextField("Instagram", text: Binding(
                            get: { socialLinks.instagram ?? "" },
                            set: { socialLinks.instagram = $0.isEmpty ? nil : $0 }
                        ))
                    }
                    
                    HStack {
                        Image(systemName: "bird.circle.fill")
                            .foregroundColor(.blue)
                        TextField("Twitter", text: Binding(
                            get: { socialLinks.twitter ?? "" },
                            set: { socialLinks.twitter = $0.isEmpty ? nil : $0 }
                        ))
                    }
                    
                    HStack {
                        Image(systemName: "f.circle.fill")
                            .foregroundColor(.blue)
                        TextField("Facebook", text: Binding(
                            get: { socialLinks.facebook ?? "" },
                            set: { socialLinks.facebook = $0.isEmpty ? nil : $0 }
                        ))
                    }
                    
                    HStack {
                        Image(systemName: "l.circle.fill")
                            .foregroundColor(.blue)
                        TextField("LinkedIn", text: Binding(
                            get: { socialLinks.linkedIn ?? "" },
                            set: { socialLinks.linkedIn = $0.isEmpty ? nil : $0 }
                        ))
                    }
                }
                
                Section(header: Text("Website")) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.gray)
                        TextField("Website URL", text: Binding(
                            get: { socialLinks.website ?? "" },
                            set: { socialLinks.website = $0.isEmpty ? nil : $0 }
                        ))
                    }
                }
            }
            .navigationTitle("Social Links")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
