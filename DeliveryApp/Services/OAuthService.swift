//
//  OAuthService.swift
//  DeliveryApp
//
//  Created by XOO_Raven on 12/12/25.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import UIKit

protocol OAuthServiceProtocol {
    func signInWithGoogle() async throws -> User
    func signInWithApple(_ authorization: ASAuthorization) async throws -> User
    func logout()
}

final class OAuthService: OAuthServiceProtocol {
    private let keychainHelper = KeychainHelper()
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async throws -> User {
        guard let presentingViewController = await getRootViewController() else {
            throw OAuthError.noViewController
        }
        
        guard let clientID = getGoogleClientID() else {
            throw OAuthError.configurationError
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController
            ) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result else {
                    continuation.resume(throwing: OAuthError.noToken)
                    return
                }
                
                guard let idToken = result.user.idToken?.tokenString else {
                    continuation.resume(throwing: OAuthError.noToken)
                    return
                }
                
                let user = User(
                    id: result.user.userID ?? UUID().uuidString,
                    email: result.user.profile?.email ?? "",
                    name: result.user.profile?.name,
                    avatarURL: result.user.profile?.imageURL(withDimension: 200)?.absoluteString,
                    authProvider: .google
                )
                
                self.saveUser(user)
                self.keychainHelper.save(idToken, forKey: "accessToken")
                
                continuation.resume(returning: user)
            }
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(_ authorization: ASAuthorization) async throws -> User {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw OAuthError.invalidCredential
        }
        
        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw OAuthError.noToken
        }
        
        let fullName = [
            appleIDCredential.fullName?.givenName,
            appleIDCredential.fullName?.familyName
        ].compactMap { $0 }.joined(separator: " ")
        
        let user = User(
            id: appleIDCredential.user,
            email: appleIDCredential.email ?? "",
            name: fullName.isEmpty ? nil : fullName,
            avatarURL: nil,
            authProvider: .apple
        )
        
        saveUser(user)
        keychainHelper.save(tokenString, forKey: "accessToken")
        
        return user
    }
    
    // MARK: - Logout
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
        keychainHelper.delete(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - Helpers
    
    private func getGoogleClientID() -> String? {
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String {
            return clientID
        }
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let clientID = dict["CLIENT_ID"] as? String {
            return clientID
        }
        
        return nil
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    @MainActor
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        return topController
    }
}

enum OAuthError: LocalizedError {
    case noViewController
    case noToken
    case invalidCredential
    case configurationError
    
    var errorDescription: String? {
        switch self {
            case .noViewController:
                return "View controller not found"
            case .noToken:
                return "Failed to get authentication token"
            case .invalidCredential:
                return "Invalid credentials received"
            case .configurationError:
                return "Google Sign In not configured. Check Info.plist for GIDClientID"
        }
    }
}
