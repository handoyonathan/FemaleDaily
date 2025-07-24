//
//  LoginViewModel.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 24/07/25.
//

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
