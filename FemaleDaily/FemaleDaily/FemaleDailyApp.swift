//
//  FemaleDailyApp.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 21/07/25.
//

import SwiftUI

@main
struct FemaleDailyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = LoginViewModel()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}
