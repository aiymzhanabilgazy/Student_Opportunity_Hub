import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab){
            HomeView()
                .tabItem {Label("Home", systemImage: "house.fill")}.tag(0)
            SearchView()
                .tabItem {Label("Search", systemImage: "magnifyingglass")}.tag(1)
            DeadlinesView()
                .tabItem {Label("Deadlines", systemImage: "clock.fill")}.tag(2)
            AddOpportunityView()
                .tabItem {Label("Add", systemImage: "plus.circle.fill")}.tag(3)
            ProfileView()
                .tabItem {Label("Profile", systemImage: "person.fill")}.tag(4)
        }
        .tint(.white)

    }
}
