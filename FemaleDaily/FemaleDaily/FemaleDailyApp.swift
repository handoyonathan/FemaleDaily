//
//  FemaleDailyApp.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 21/07/25.
//

import SwiftUI
import UIKit
import CloudKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization failed: \(error.localizedDescription)")
            } else {
                print("Notification authorization granted: \(granted)")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for push notifications with token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received notification at \(Date().formatted()) with userInfo: \(userInfo)")
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print("Received CloudKit notification at \(Date().formatted()): \(notification)")
            NotificationCenter.default.post(name: NSNotification.Name("QueueUpdated"), object: nil)
            completionHandler(.newData)
        } else {
            print("Received non-CloudKit notification at \(Date().formatted())")
            completionHandler(.noData)
        }
    }
}

@main
struct FemaleDailyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var queueService = QueueService.shared

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(queueService)
                .onChange(of: LoginViewModel.shared.isLoggedIn) { isLoggedIn in
                    if isLoggedIn {
                        queueService.fetchQueue {
                            print("Initial queue fetch completed after login")
                        }
                    }
                }
        }
    }
}
