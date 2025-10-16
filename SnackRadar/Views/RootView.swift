import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch sessionViewModel.sessionState {
            case .signedOut:
                LoginView()
            case .loading:
                LoadingView()
            case .studentHome:
                StudentHomeView()
            case .organizerHome:
                OrganizerHomeView()
            case .organizerPendingApproval:
                OrganizerPendingApprovalView()
            }
        }
        .overlay(loadingOverlay)
        .alert("Error", isPresented: .constant(sessionViewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                sessionViewModel.clearError()
            }
        } message: {
            if let error = sessionViewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if appState.isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryBlue))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(SessionViewModel())
            .environmentObject(AppState())
    }
}
