//
//  DeliveryAppApp.swift
//  DeliveryApp
//
//  Created by raven on 11/18/25.
//

import SwiftUI

@main
struct DeliveryAppApp: App {
    @StateObject private var menuController = MenuController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(menuController)
        }
    }
}
