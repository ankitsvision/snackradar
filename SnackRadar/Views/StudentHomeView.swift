import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if let profile = sessionViewModel.userProfile {
                        VStack(spacing: 8) {
                            Text("Welcome, Student!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text(profile.email)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(.top, 40)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "map.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primaryBlue)
                        
                        Text("Find Free Food")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Student home features coming soon")
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

struct StudentHomeView_Previews: PreviewProvider {
    static var previews: some View {
        StudentHomeView()
            .environmentObject(SessionViewModel())
    }
}
