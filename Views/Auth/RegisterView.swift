import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var authService: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textContentType(.none)
                        .autocorrectionDisabled(true)

                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        register()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Register")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentBlue)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func register() {
        
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill all fields"
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        errorMessage = ""
        isLoading = true
        
        authService.signUp(email: email, password: password) { error in
            
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

