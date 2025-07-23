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
    let statusColor: Color

    init(record: CKRecord) {
            id = record.recordID
            username = record["username"] as? String ?? "Unknown"
            status = record["status"] as? String ?? "Queueing"
            number = record["number"] as? Int ?? 0
            timestamp = record["timestamp"] as? Date
            switch status.lowercased() {
            case "queueing":
                statusColor = .orange
            case "skipped":
                statusColor = .red
            case "done":
                statusColor = .gray
            default:
                statusColor = .orange
            }
        }
    
    static func == (lhs: QueueEntry, rhs: QueueEntry) -> Bool {
        return lhs.id == rhs.id &&
               lhs.username == rhs.username &&
               lhs.status == rhs.status &&
               lhs.number == rhs.number
        // Exclude timestamp from comparison to avoid millisecond differences
    }
}
