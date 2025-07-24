//
//  Login.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 24/07/25.
//

import CloudKit
import SwiftUI

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
