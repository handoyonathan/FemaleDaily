//
//  AdminView.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 23/07/25.
//

import SwiftUI
import CloudKit

struct AdminView: View {
    @EnvironmentObject private var queueService: QueueService
    @State private var isLoading = false
    @State private var showConfirmation = false
    @State private var selectedEntry: QueueEntry?
    @State private var actionType: String = ""

    var body: some View {
        VStack(spacing: 0) {
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
                            let cardBackgroundColor = {
                                switch entry.status.lowercased() {
                                case "done": return Color.green.opacity(0.2) // Pastel green for done
                                case "skipped": return Color.red.opacity(0.2) // Red for skipped
                                case "queueing": return Color.white // White for queueing
                                default: return Color.white
                                }
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
                                if entry.status.lowercased() != "done" && entry.status.lowercased() != "skipped" {
                                    Button("Done") {
                                        selectedEntry = entry
                                        actionType = "done"
                                        showConfirmation = true
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.green)
                                    .cornerRadius(6)
                                    
                                    Button("Skip") {
                                        selectedEntry = entry
                                        actionType = "skipped"
                                        showConfirmation = true
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.red)
                                    .cornerRadius(6)
                                }
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
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Skintific")
//        .navigationBarBackButtonHidden(true)
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
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Confirm Action"),
                message: Text("Are you sure you want to mark \(selectedEntry?.username ?? "") as \(actionType)?"),
                primaryButton: .default(Text("Confirm")) {
                    if let entry = selectedEntry {
                        queueService.updateStatus(for: entry, to: actionType) {
                            isLoading = true
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    AdminView()
        .environmentObject(QueueService.shared)
}
