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
    @Published var isLoggedIn = false
    @Published var userName: String?
    @Published var errorMessage: String?

    func login(email: String, password: String) {
        let emailLowercased = email.lowercased()
        if emailLowercased == password.lowercased(), emailLowercased.hasPrefix("user") {
            self.userName = emailLowercased
            self.isLoggedIn = true
            self.errorMessage = nil
            print("Login success: \(emailLowercased)")
        } else {
            self.errorMessage = "Invalid credentials"
            self.isLoggedIn = false
            print("Login failed for: \(emailLowercased)")
        }
    }
}


struct LoginView: View {
    @EnvironmentObject private var authViewModel: LoginViewModel
    @State private var email = ""
    @State private var password = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login to JxB")
                    .font(.title)
                    .fontWeight(.bold)

                if let errorMessage = authViewModel.errorMessage {
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
                    authViewModel.login(email: email, password: password)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationDestination(isPresented: $authViewModel.isLoggedIn) {
                HomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
}



struct BrandQueueView: View {
    @StateObject private var viewModel: BrandQueueViewModel
    @EnvironmentObject private var authViewModel: LoginViewModel
    @State private var isLoading = false

    init(authViewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: BrandQueueViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                Color.gray.overlay(Text("Catalognya").foregroundColor(.white))
                Color.gray
                Color.gray
            }
            .frame(height: 200)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))

            HStack {
                Text("Queue")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.queueList.count) org")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .padding()

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            if isLoading && viewModel.queueList.isEmpty {
                ProgressView()
                    .padding()
            } else if viewModel.queueList.isEmpty {
                Text("No Queue")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.queueList) { entry in
                            let isCurrentUser = entry.username == authViewModel.userName
                            let cardBackgroundColor = {
                                if isCurrentUser {
                                    switch entry.status.lowercased() {
                                    case "in store": return Color.green.opacity(0.2)
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
                    .onChange(of: viewModel.queueList) { newQueueList in
                        print("UI rendering queueList with \(newQueueList.count) entries: \(newQueueList.map { "\($0.number): \($0.username)" })")
                        isLoading = false // Reset loading after queueList updates
                    }
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Button(viewModel.hasJoinedQueue ? "Cancel Queue" : "Join Queue") {
                    guard !isLoading else { return } // Prevent button spam
                    isLoading = true // Show loading immediately
                    if viewModel.hasJoinedQueue {
                        viewModel.cancelQueue {
                            print("Cancel queue completed, waiting for queueList update")
                        }
                    } else {
                        viewModel.joinQueue {
                            print("Join queue completed, waiting for queueList update")
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.hasJoinedQueue ? Color.gray : Color.red)
                .cornerRadius(10)
                .disabled(!authViewModel.isLoggedIn || isLoading)

                Text("Disclaimer: After 3 missed calls, your turn will be passed.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Skintific")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isLoading = true
            viewModel.fetchQueue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isLoading = false
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("QueueUpdated"))) { _ in
            print("QueueUpdated notification received at \(Date().formatted())")
            isLoading = true
            viewModel.fetchQueue {
                print("fetchQueue completed after QueueUpdated, queueList count: \(viewModel.queueList.count)")
            }
        }
    }
}

// Home View
struct HomeView: View {
    @EnvironmentObject private var authViewModel: LoginViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to JxB, \(authViewModel.userName ?? "User")!")
                    .font(.title2)
                NavigationLink("Go to Skintific Queue", destination: BrandQueueView(authViewModel: authViewModel))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .navigationTitle("Home")
        }
    }
}

// AppDelegate untuk notifikasi CloudKit
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
//
//
//#Preview {
//    LoginView()
//        .environmentObject(LoginViewModel())
//}
