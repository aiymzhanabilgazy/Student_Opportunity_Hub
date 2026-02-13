import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            TextField("", text: $email, prompt: Text("Email").foregroundColor(.white))
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)
                .foregroundColor(.white)
            
            SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white))
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)
                .foregroundColor(.white)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: validateAndLogin) {
                Text("Login")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentBlue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
    
    private func validateAndLogin() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill all fields"
            return
        }
        
        errorMessage = ""
        
        authService.signIn(email: email, password: password) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}
