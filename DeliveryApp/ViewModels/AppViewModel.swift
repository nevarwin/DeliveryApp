//
//  AppViewModel.swift
//  DeliveryApp
//
//  Owns top-level onboarding and auth state for the app shell.
//

import SwiftUI
internal import Combine
import FirebaseAuth
import GoogleSignIn

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isOnboarded: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    
    init() {
        if Auth.auth().currentUser != nil {
            self.isLoggedIn = true
        }
    }
    
    func signInWithGoogle() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth Error: \(error.localizedDescription)")
                    return
                }
                self?.isLoggedIn = true
            }
        }
    }
    
    func completeOnboarding() {
        isOnboarded = true
    }
    
    func authenticate(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter an email and password."
            return
        }

        // 1. Always attempt Sign In first
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                
                self?.attemptSignUp(email: email, password: password, originalError: error)
                return
            }
            
            // Success: User logged in
            DispatchQueue.main.async {
                self?.isLoggedIn = true
            }
        }
    }

    private func attemptSignUp(email: String, password: String, originalError: NSError) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    print(error)

                    if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        self?.errorMessage = "Incorrect password for this account."
                    } else if error.code == AuthErrorCode.invalidCredential.rawValue {
                        self?.errorMessage = "Invalid email or password. Please check your details."
                    } else {
                        print("else")
                        self?.errorMessage = error.localizedDescription
                    }
                    return
                }
                
                // Success: Account created and logged in
                self?.isLoggedIn = true
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
