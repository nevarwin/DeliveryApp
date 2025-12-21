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
    
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
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
