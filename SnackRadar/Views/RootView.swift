import SwiftUI

struct RootView: View {
    @EnvironmentObject var appSession: AppSession
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appSession.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .overlay(loadingOverlay)
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

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Main Experience")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
        }
        .accentColor(AppColors.primaryBlue)
    }
}

struct AuthenticationView: View {
    var body: some View {
        ZStack {
            AppColors.lightGrey
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("SnackRadar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryBlue)
                
                Text("Welcome! Authentication flow placeholder")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppSession())
            .environmentObject(AppState())
    }
}
