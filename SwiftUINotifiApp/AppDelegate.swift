//
//  AppDelegate.swift
//  SwiftUINotifiApp
//
//  Created by rico on 11.12.2025.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // [ Basarili ise ] Uyg APNs'e kaydoldugunda calisan
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in
            String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Test icin Device Token: \(token)")
    }
    
    // [Basarisiz ise] Kayit
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Remote notifi kayit basarisiz: \(error.localizedDescription)")
    }
}
