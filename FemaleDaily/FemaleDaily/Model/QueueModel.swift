//
//  QueueModel.swift
//  
//
//  Created by Yonathan Handoyo on 21/07/25.
//

import SwiftUI
import CloudKit

struct QueueEntry: Identifiable, Equatable {
    let id: CKRecord.ID
    let username: String
    let status: String
    let number: Int
    let timestamp: Date?
    
    init(record: CKRecord) {
        self.id = record.recordID
        self.username = record["username"] as? String ?? ""
        self.status = record["status"] as? String ?? ""
        self.number = record["number"] as? Int ?? 0
        self.timestamp = record["timestamp"] as? Date
    }
    
    var statusColor: Color {
        switch status.lowercased() {
        case "done": return .green
        case "skipped": return .red
        case "queueing": return .orange
        default: return .gray
        }
    }
    
    static func ==(lhs: QueueEntry, rhs: QueueEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.username == rhs.username &&
        lhs.status == rhs.status &&
        lhs.number == rhs.number &&
        lhs.timestamp == rhs.timestamp
    }
}
