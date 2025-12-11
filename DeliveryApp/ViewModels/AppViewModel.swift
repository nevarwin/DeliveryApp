//
//  AppViewModel.swift
//  DeliveryApp
//
//  Owns top-level onboarding and auth state for the app shell.
//

import SwiftUI
internal import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isOnboarded: Bool = false
    @Published var isLoggedIn: Bool = false
    
    func completeOnboarding() {
        isOnboarded = true
    }
    
    func login(email: String, password: String) {
        // Demo login: accept any credentials. Replace with your auth provider.
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
    }
}
