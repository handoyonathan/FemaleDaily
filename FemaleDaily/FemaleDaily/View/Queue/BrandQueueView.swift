//
//  BrandQueue.swift
//
//
//  Created by Yonathan Handoyo on 21/07/25.
//

import SwiftUI
import AuthenticationServices
import CloudKit
import UserNotifications

class LoginViewModel: ObservableObject {
    static let shared = LoginViewModel()
    
    @Published var isLoggedIn = false
    @Published var userName: String?
    @Published var errorMessage: String?
    @Published var isAdmin = false
    
    private init() {}
    
    func login(email: String, password: String) {
        let emailLowercased = email.lowercased()
        if emailLowercased == password.lowercased(), (emailLowercased.hasPrefix("user") || emailLowercased.hasPrefix("admin")) {
            self.userName = emailLowercased
            self.isAdmin = emailLowercased.hasPrefix("admin")
            self.isLoggedIn = true
            self.errorMessage = nil
            print("Login success: \(emailLowercased), isAdmin: \(self.isAdmin)")
        } else {
            self.errorMessage = "Invalid credentials. Username must start with 'user' or 'admin' and match password."
            self.isLoggedIn = false
            self.isAdmin = false
            print("Login failed for: \(emailLowercased)")
        }
    }}


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login to JxB")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let errorMessage = LoginViewModel.shared.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                
                TextField("Username", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                Button("Login") {
                    LoginViewModel.shared.login(email: email, password: password)
                    print("Login button pressed, isLoggedIn: \(LoginViewModel.shared.isLoggedIn), isAdmin: \(LoginViewModel.shared.isAdmin)")
                    isLoggedIn = LoginViewModel.shared.isLoggedIn
                    print("Set isLoggedIn to \(isLoggedIn)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                if LoginViewModel.shared.isAdmin {
                    AdminView()
                        .environmentObject(QueueService.shared)
                        .onAppear {
                            print("Navigated to AdminView")
                        }
                } else {
                    FlashSaleView()
                        .environmentObject(QueueService.shared)
                        .onAppear {
                            print("Navigated to FlashSaleView")
                        }
                }
            }
        }
    }
}

struct BrandQueueView: View {
    @EnvironmentObject private var queueService: QueueService
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                Color.gray.overlay(Text("Catalog 1").foregroundColor(.white))
                Color.gray.overlay(Text("Catalog 2").foregroundColor(.white))
                Color.gray.overlay(Text("Catalog 3").foregroundColor(.white))
            }
            .frame(height: 200)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            HStack {
                Text("Queue")
                    .font(.headline)
                Spacer()
                Text("\(queueService.queueList.count) org")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .padding()
            
            if let errorMessage = queueService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            if isLoading && queueService.queueList.isEmpty {
                ProgressView()
                    .padding()
            } else if queueService.queueList.isEmpty {
                Text("No Queue")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(queueService.queueList) { entry in
                            let isCurrentUser = entry.username == LoginViewModel.shared.userName
                            let cardBackgroundColor = {
                                if entry.status.lowercased() == "done" {
                                    return Color.gray.opacity(0.3)
                                } else if isCurrentUser {
                                    switch entry.status.lowercased() {
                                    case "queueing": return Color.orange.opacity(0.2)
                                    case "skipped": return Color.red.opacity(0.2)
                                    default: return Color.white
                                    }
                                }
                                return Color.white
                            }()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.username)
                                        .fontWeight(.semibold)
                                    Text(entry.status)
                                        .foregroundColor(entry.statusColor)
                                        .font(.subheadline)
                                }
                                Spacer()
                                Text("#\(entry.number)")
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .disabled(entry.status.lowercased() == "done")
                        }
                    }
                    .padding()
                    .onChange(of: queueService.queueList) { newQueueList in
                        print("UI rendering queueList with \(newQueueList.count) entries: \(newQueueList.map { "\($0.number): \($0.username)" })")
                        isLoading = false
                    }
                }
            }
            
            Spacer()
            
            if !isCurrentUserDone {
                VStack(spacing: 8) {
                    Button(isCurrentUserQueueing ? "Cancel Queue" : "Join Queue") {
                        guard !isLoading else { return }
                        isLoading = true
                        if isCurrentUserQueueing {
                            queueService.cancelQueue {
                                print("Cancel queue completed, waiting for queueList update")
                                isLoading = false
                            }
                        } else {
                            queueService.joinQueue(allowRejoin: true) {
                                print("Join queue completed, waiting for queueList update")
                                isLoading = false
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCurrentUserQueueing ? Color.gray : Color.red)
                    .cornerRadius(10)
                    .disabled(!LoginViewModel.shared.isLoggedIn || isLoading)
                    
                    Text("Disclaimer: After 3 missed calls, your turn will be passed.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Skintific")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isLoading = true
            queueService.fetchQueue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isLoading = false
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("QueueUpdated"))) { _ in
            print("QueueUpdated notification received at \(Date().formatted())")
            isLoading = true
            queueService.fetchQueue {
                print("fetchQueue completed after QueueUpdated, queueList count: \(queueService.queueList.count)")
                isLoading = false
            }
        }
    }
    
    private var isCurrentUserDone: Bool {
        guard let username = LoginViewModel.shared.userName else { return false }
        return queueService.queueList.contains { $0.username == username && $0.status.lowercased() == "done" }
    }
    
    private var isCurrentUserQueueing: Bool {
        guard let username = LoginViewModel.shared.userName else { return false }
        return queueService.queueList.contains { $0.username == username && $0.status.lowercased() == "queueing" }
    }
}

//// Home View
//struct HomeView: View {
//    @EnvironmentObject private var authViewModel: LoginViewModel
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Text("Welcome to JxB, \(authViewModel.userName ?? "User")!")
//                    .font(.title2)
//                NavigationLink("Go to Skintific Queue", destination: BrandQueueView(authViewModel: authViewModel))
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .navigationTitle("Home")
//        }
//    }
//}

// AppDelegate untuk notifikasi CloudKit
//class AppDelegate: NSObject, UIApplicationDelegate {
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
//            if let error = error {
//                print("Notification authorization failed: \(error.localizedDescription)")
//            } else {
//                print("Notification authorization granted: \(granted)")
//            }
//        }
//        UIApplication.shared.registerForRemoteNotifications()
//        return true
//    }
//    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("Registered for push notifications with token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
//    }
//    
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for push notifications: \(error.localizedDescription)")
//    }
//    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print("Received notification at \(Date().formatted()) with userInfo: \(userInfo)")
//        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
//            print("Received CloudKit notification at \(Date().formatted()): \(notification)")
//            NotificationCenter.default.post(name: NSNotification.Name("QueueUpdated"), object: nil)
//            completionHandler(.newData)
//        } else {
//            print("Received non-CloudKit notification at \(Date().formatted())")
//            completionHandler(.noData)
//        }
//    }
//}

//
//#Preview {
//    LoginView()
//        .environmentObject(LoginViewModel())
//}
