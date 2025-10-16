import SwiftUI

struct OrganizerHomeView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if let profile = sessionViewModel.userProfile {
                        VStack(spacing: 8) {
                            Text("Welcome, Organizer!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text(profile.email)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                            
                            if profile.isApproved {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                    Text("Verified Organizer")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top, 40)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.secondaryYellow)
                        
                        Text("Create Events")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Organizer dashboard features coming soon")
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sessionViewModel.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
            }
        }
    }
}

struct OrganizerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizerHomeView()
            .environmentObject(SessionViewModel())
    }
}
