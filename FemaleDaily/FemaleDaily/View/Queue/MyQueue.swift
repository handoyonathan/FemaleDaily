//
//  MyQueue.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 23/07/25.
//

import SwiftUI

struct QueueItem: Identifiable {
    let id = UUID()
    let startTime: String
    let timeRange: String
    let brandName: String
    let description: String
    let queueNumber: String
}

struct MyQueueView: View {
    // Sample data
    let queueItems: [QueueItem] = [
        QueueItem(startTime: "12:00", timeRange: "12:00 - 13:30", brandName: "Brand X", description: "Description. Lorem ipsum dolor sir amet, consectetur adipiscing elit.", queueNumber: "#456"),
        QueueItem(startTime: "12:00", timeRange: "12:00 - 13:30", brandName: "Brand Y", description: "Description. Lorem ipsum dolor sir amet, consectetur adipiscing elit.", queueNumber: "#456"),
        QueueItem(startTime: "12:00", timeRange: "12:00 - 13:30", brandName: "Brand Z", description: "Description. Lorem ipsum dolor sir amet, consectetur adipiscing elit.", queueNumber: "#456"),
        QueueItem(startTime: "14:00", timeRange: "14:30 - 15:00", brandName: "Brand A", description: "Another brand queue.", queueNumber: "#789"),
        QueueItem(startTime: "14:00", timeRange: "14:30 - 15:00", brandName: "Brand B", description: "Another brand queue.", queueNumber: "#790")
    ]
    
    var groupedItems: [String: [QueueItem]] {
        Dictionary(grouping: queueItems) { $0.startTime }
    }
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("My Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Handle back action
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct QueueCardView: View {
    let item: QueueItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.timeRange)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.brandName)
                        .fontWeight(.semibold)

                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()

                Text(item.queueNumber)
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
}
