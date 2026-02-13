import SwiftUI
struct AuthView: View {
    @State private var showLogin = true
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                if showLogin {
                    LoginView()
                } else {
                    RegisterView()
                }
                
                Button {
                    showLogin.toggle()
                } label: {
                    Text(showLogin ?
                         "Don't have an account? Register" :
                         "Already have an account? Login")
                        .foregroundColor(.accentBlue)
                        .padding(.top, 15)
                }
            }
            .padding()
        }
    }
}
