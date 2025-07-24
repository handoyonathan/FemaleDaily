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
