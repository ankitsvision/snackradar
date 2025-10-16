import SwiftUI

struct StudentTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StudentHomeViewNew()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            StudentPromosView()
                .tabItem {
                    Label("Promos", systemImage: "megaphone.fill")
                }
                .tag(1)
            
            StudentSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(AppColors.primaryBlue)
    }
}

struct StudentTabView_Previews: PreviewProvider {
    static var previews: some View {
        StudentTabView()
            .environmentObject(SessionViewModel())
    }
}
