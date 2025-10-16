import SwiftUI
import UserNotifications

struct StudentHomeViewNew: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel = StudentHomeViewModel()
    @StateObject private var campusManager = CampusSelectionManager.shared
    @State private var availableCampuses: [Campus] = []
    @State private var showCampusPicker: Bool = false
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if campusManager.selectedCampus == nil {
                        noCampusSelected
                    } else if viewModel.events.isEmpty {
                        noEventsView
                    } else {
                        eventsList
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadCampuses()
                checkNotificationPermissions()
            }
            .sheet(isPresented: $showCampusPicker) {
                campusPickerSheet
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome!")
                        .customFont(AppFonts.title)
                        .foregroundColor(AppColors.primaryText)
                    
                    if let profile = sessionViewModel.userProfile {
                        Text(profile.email)
                            .customFont(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                notificationBellIcon
            }
            
            campusSwitcher
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var notificationBellIcon: some View {
        Button(action: {
            handleNotificationTap()
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: notificationPermissionStatus == .authorized ? "bell.fill" : "bell.slash.fill")
                    .font(.system(size: 24))
                    .foregroundColor(notificationPermissionStatus == .authorized ? AppColors.primaryBlue : AppColors.secondaryText)
                
                if notificationPermissionStatus == .denied {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
    
    private var campusSwitcher: some View {
        Button(action: {
            showCampusPicker = true
        }) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(AppColors.primaryBlue)
                
                if let campus = campusManager.selectedCampus {
                    Text(campus.name)
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.primaryText)
                        .fontWeight(.medium)
                } else {
                    Text("Select Campus")
                        .customFont(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding()
            .background(AppColors.lightGrey)
            .cornerRadius(12)
        }
    }
    
    private var campusPickerSheet: some View {
        NavigationView {
            List(availableCampuses) { campus in
                Button(action: {
                    Task {
                        try? await campusManager.selectCampus(campus)
                        showCampusPicker = false
                    }
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
                        
                        if campusManager.selectedCampusId == campus.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primaryBlue)
                        }
                    }
                }
            }
            .navigationTitle("Select Campus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showCampusPicker = false
                    }
                }
            }
        }
    }
    
    private var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.events) { event in
                    EventCardView(
                        event: event,
                        remainingTime: viewModel.getRemainingTime(for: event),
                        statusBadgeColor: viewModel.getStatusBadgeColor(for: event.status)
                    )
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.refreshEvents()
        }
    }
    
    private var noCampusSelected: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.primaryBlue.opacity(0.5))
            
            Text("Select Your Campus")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
            
            Text("Choose your campus to see available events")
                .customFont(AppFonts.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showCampusPicker = true
            }) {
                Text("Choose Campus")
                    .customFont(AppFonts.body)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryBlue)
                    .cornerRadius(12)
            }
        }
    }
    
    private var noEventsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.primaryBlue.opacity(0.5))
            
            Text("No Events Available")
                .customFont(AppFonts.headline)
                .foregroundColor(AppColors.primaryText)
            
            Text("Check back later for upcoming events")
                .customFont(AppFonts.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func loadCampuses() {
        Task {
            do {
                availableCampuses = try await CampusRepository.shared.getActiveCampuses()
            } catch {
                print("Error loading campuses: \(error)")
            }
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    private func handleNotificationTap() {
        switch notificationPermissionStatus {
        case .notDetermined:
            requestNotificationPermission()
        case .denied:
            openSettings()
        case .authorized:
            break
        default:
            break
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                checkNotificationPermissions()
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct StudentHomeViewNew_Previews: PreviewProvider {
    static var previews: some View {
        StudentHomeViewNew()
            .environmentObject(SessionViewModel())
    }
}
