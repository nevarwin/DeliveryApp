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
import AuthenticationServices
import CryptoKit

@MainActor
final class AppViewModel: NSObject, ObservableObject {
    @Published var isOnboarded: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    private var currentNonce: String?
    
    override init() {
        if Auth.auth().currentUser != nil {
            self.isLoggedIn = true
        }
    }
    
    // MARK: - Apple Sign In Logic
    
    /// Prepares the nonce for the Apple Sign In request
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    /// Handles the result from the SignInWithAppleButton
    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.errorMessage = "Credential gathering failed."
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            signInToFirebase(with: credential)
            
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Firebase Sign In
    
    private func signInToFirebase(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] _, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isLoggedIn = true
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            self?.signInToFirebase(with: credential)
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
    
    // MARK: - Helpers
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
