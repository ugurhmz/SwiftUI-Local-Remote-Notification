//
//  SwiftUINotifiAppApp.swift
//  SwiftUINotifiApp
//
//  Created by rico on 11.12.2025.
//

import SwiftUI

@main
struct SwiftUINotifiAppApp: App {
    
    // AppDelegate'i SwiftUI life-cycle'a baglamak icin
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
