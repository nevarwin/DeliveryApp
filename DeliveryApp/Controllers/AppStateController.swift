//
//  AppStateController.swift
//  DeliveryApp
//
//  Simple app-level state for onboarding and login flow.
//

import Foundation
import Combine

final class AppStateController: ObservableObject {
    @Published var isOnboarded: Bool = false
    @Published var isLoggedIn: Bool = false
}


