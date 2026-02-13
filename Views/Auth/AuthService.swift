import Foundation
import FirebaseAuth
import Combine

final class AuthService: ObservableObject {

    @Published var user: FirebaseAuth.User?

    init() {
        self.user = Auth.auth().currentUser
    }

    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            self?.user = result?.user
            completion(error)
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            self?.user = result?.user
            completion(error)
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }
}
