//
//  DeliveryAppApp.swift
//  DeliveryApp
//
//  Created by raven on 11/18/25.
//

internal import SwiftUI

@main
struct DeliveryAppApp: App {
    @StateObject private var appState = AppStateController()
    @StateObject private var menuController = MenuController()
    @StateObject private var cartController = CartController()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(menuController)
                .environmentObject(cartController)
        }
    }
}
