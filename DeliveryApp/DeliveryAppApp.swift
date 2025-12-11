//
//  DeliveryAppApp.swift
//  DeliveryApp
//
//  Entry point that wires up shared view models for MVVM.
//

import SwiftUI

@main
struct DeliveryAppApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var menuViewModel = MenuViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environmentObject(menuViewModel)
                .environmentObject(cartViewModel)
        }
    }
}
