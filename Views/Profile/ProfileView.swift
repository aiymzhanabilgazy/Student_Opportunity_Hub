import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    
    private func statView(title: String, value: Int) -> some View {
        VStack {
            Text("\(value)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .foregroundColor(.gray)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    profileHeader
                    
                    statView(title: "Saved", value: appState.favorites.count)
                    
                    statView(title: "Applied", value: appState.appliedIds.count)
                    
                    statView(title: "Created", value: appState.customOpportunities.count)
                    
                    Button("Logout") {
                        authService.signOut()
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
        .preferredColorScheme(.dark)
    }
}
extension ProfileView {
    
    var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 15) {
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    )
                
                VStack(alignment: .leading) {
                    Text("Student Name")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("student@email.com")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}
