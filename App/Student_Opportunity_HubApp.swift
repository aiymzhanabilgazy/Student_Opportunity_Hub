import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

@main
struct Student_Opportunity_HubApp: App {
    
    @StateObject private var appState = AppState()
    @StateObject private var authService = AuthService()
    
    init() {
        FirebaseApp.configure()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 11/255, green: 31/255, blue: 59/255, alpha: 1)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    var body: some Scene {
        WindowGroup {
            
            if authService.user != nil {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(authService)
            } else {
                AuthView()
                    .environmentObject(authService)
            }
        }
    }
}
