//
//  AuthService.swift
//  DeliveryApp
//
//  Created by raven on 12/12/25.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func saveUser(_ user: User)
    func getSavedUser() -> User?
}

final class AuthService: AuthServiceProtocol {
    private let keychainHelper = KeychainHelper()
    
    func login(email: String, password: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let user = User(
            id: UUID().uuidString,
            email: email,
            name: email.components(separatedBy: "@").first,
            avatarURL: nil,
            authProvider: .email
        )
        
        saveUser(user)
        return user
    }
    
    func logout() async throws {
        keychainHelper.delete(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    func getSavedUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
            case .invalidCredentials:
                return "Please enter valid email and password"
        }
    }
}
