//
//  DeliveryAppApp.swift
//  DeliveryApp
//
//  Entry point that wires up shared view models for MVVM.
//

import SwiftUI

@main
struct DeliveryAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
        }
    }
}
