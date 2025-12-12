//
//  NotificationManager.swift
//  SwiftUINotifiApp
//
//  Created by rico on 11.12.2025.
//

import Foundation
import UserNotifications
import UIKit


class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var permissionGranted: Bool = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    
    // [1] User'dan izin isteme ve ardindan Kayit Yapma.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                self.permissionGranted = success
                if success {
                    print("User izin verdi. APNs'e Kayit yapiliyor. . .")
                    UIApplication.shared.registerForRemoteNotifications() // UIApplication kullanmak icin UIKit import sart.
                    
                } else if let error = error {
                    print("Hata var: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // [2] Local Notifi Gonderme
    func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Title Lorem"
        content.subtitle = "Yerel bildirim ."
        content.body = "lorem ipsum dolar sit amet...."
        content.sound = .defaultRingtone
        
        let myTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: myTrigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // [3] Uygulamada gezinirken de bildirim gelirse gorelim.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
