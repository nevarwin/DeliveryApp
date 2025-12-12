//
//  AppViewModel.swift
//  DeliveryApp
//
//  Owns top-level onboarding and auth state for the app shell.
//

import SwiftUI
internal import Combine
import AuthenticationServices

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isOnboarded: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    private let oauthService: OAuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService(),
         oauthService: OAuthServiceProtocol = OAuthService()) {
        self.authService = authService
        self.oauthService = oauthService
        
        // Check if user was previously logged in
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        if let user = authService.getSavedUser() {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    func completeOnboarding() {
        isOnboarded = true
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
    }
    
    // MARK: - Email/Password Login
    
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        Task {
            do {
                let user = try await authService.login(email: email, password: password)
                self.currentUser = user
                self.isLoggedIn = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - OAuth Google
    
    func signInWithGoogle() {
        Task {
            do {
                let user = try await oauthService.signInWithGoogle()
                self.currentUser = user
                self.isLoggedIn = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - OAuth Apple
    
    func signInWithApple(_ authorization: ASAuthorization) {
        Task {
            do {
                let user = try await oauthService.signInWithApple(authorization)
                self.currentUser = user
                self.isLoggedIn = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        Task {
            do {
                try await authService.logout()
                oauthService.logout()
                self.isLoggedIn = false
                self.currentUser = nil
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
