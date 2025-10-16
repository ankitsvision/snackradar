import SwiftUI

struct OrganizerPendingApprovalView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.secondaryYellow)
                
                VStack(spacing: 12) {
                    Text("Approval Pending")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Your organizer account is being reviewed by our team. You'll be notified once it's approved.")
                        .font(.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(spacing: 16) {
                    infoCard(
                        icon: "checkmark.circle",
                        title: "Application Received",
                        description: "We've received your organizer registration"
                    )
                    
                    infoCard(
                        icon: "magnifyingglass.circle",
                        title: "Under Review",
                        description: "Our team is verifying your information"
                    )
                    
                    infoCard(
                        icon: "bell.circle",
                        title: "You'll Be Notified",
                        description: "We'll send you an email once approved"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Button {
                    sessionViewModel.signOut()
                } label: {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryBlue)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.primaryBlue, lineWidth: 2)
                        )
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func infoCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(AppColors.primaryBlue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct OrganizerPendingApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizerPendingApprovalView()
            .environmentObject(SessionViewModel())
    }
}
