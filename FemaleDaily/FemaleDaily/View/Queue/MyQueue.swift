//
//  MyQueue.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 23/07/25.
//

import SwiftUI
import CloudKit

struct MyQueueView: View {
    @EnvironmentObject var queueService: QueueService
    @Environment(\.presentationMode) var presentationMode

    var groupedItems: [String: [QueueEntry]] {
        let userQueue = queueService.queueList.filter { $0.username == LoginViewModel.shared.userName && $0.status.lowercased() == "queueing" }
        return Dictionary(grouping: userQueue) { item in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH.mm"
            return item.timestamp.map { dateFormatter.string(from: $0) } ?? "Unknown"
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if groupedItems.isEmpty {
                    VStack {
                        Spacer()
                        Text("No active queues")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(groupedItems.keys.sorted(), id: \.self) { time in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(time)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(groupedItems[time]!) { item in
                                        QueueCardView(item: item)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("My Queue")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                queueService.debugFetchAllRecords()
                queueService.fetchQueue {
                    print("MyQueueView queue fetch completed")
                }
            }
        }
    }
}

struct QueueCardView: View {
    let item: QueueEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.timestamp.map { DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .short) } ?? "Unknown")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Skintific") // Replace with actual brand name if available
                        .fontWeight(.semibold)
                    Text("Queueing for flash sale")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()

                Text("#\(item.number)")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    MyQueueView()
        .environmentObject(QueueService.shared)
}
