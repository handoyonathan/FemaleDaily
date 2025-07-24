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
    @ObservedObject private var viewModel = LoginViewModel.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login to JxB")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let errorMessage = viewModel.errorMessage {
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
                    viewModel.login(email: email, password: password)
                    print("Login button pressed, isLoggedIn: \(viewModel.isLoggedIn), isAdmin: \(viewModel.isAdmin)")
                    isLoggedIn = viewModel.isLoggedIn
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
                destinationView()
            }
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if viewModel.isAdmin {
            AdminView()
                .environmentObject(QueueService.shared)
                .onAppear {
                    print("Navigated to AdminView")
                }
        } else {
            StaticMapView()
        }
    }
}
