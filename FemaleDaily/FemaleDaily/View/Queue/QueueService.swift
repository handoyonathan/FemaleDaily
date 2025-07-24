//
//  QueueService.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 24/07/25.
//

import SwiftUI
import CloudKit

class QueueService: ObservableObject {
    static let shared = QueueService()
    
    @Published var queueList: [QueueEntry] = []
    @Published var errorMessage: String?
    private var database = CKContainer.default().publicCloudDatabase
    private let subscriptionID = "queueEntryChanges"
    private var isFetching = false
    
    private init() {
        setupSubscription()
    }
    
    var hasJoinedQueue: Bool {
        guard let username = LoginViewModel.shared.userName else { return false }
        let isQueueing = queueList.contains { $0.username == username && $0.status.lowercased() == "queueing" }
        print("Debug - QueueService hasJoinedQueue checked for \(username ?? "unknown"): \(isQueueing)")
        return isQueueing
    }
    
    func fetchQueue(completion: (() -> Void)? = nil) {
        guard !isFetching else {
            print("Debug - Skipped fetchQueue due to ongoing fetch")
            completion?()
            return
        }
        
        isFetching = true
        let query = CKQuery(recordType: "QueueEntry", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        
        print("Debug - Fetching QueueEntry records from CloudKit at \(Date().formatted())")
        database.fetch(withQuery: query, inZoneWith: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            DispatchQueue.main.async {
                self.isFetching = false
                
                switch result {
                case .success(let queryResult):
                    do {
                        let records = try queryResult.matchResults.map { try $0.1.get() }
                        let newQueueList = records.map { QueueEntry(record: $0) }
                        print("Debug - Fetched \(records.count) records: \(newQueueList.map { "\($0.number): \($0.username), status: \($0.status)" })")
                        
                        if self.queueList != newQueueList {
                            self.queueList = newQueueList
                            print("Debug - Updated queueList with \(newQueueList.count) entries")
                            NotificationCenter.default.post(name: NSNotification.Name("QueueUpdated"), object: nil)
                        } else {
                            print("Debug - No changes in queueList, current count: \(self.queueList.count)")
                        }
                        self.errorMessage = nil
                    } catch {
                        self.errorMessage = "Failed to process records: \(error.localizedDescription)"
                        print("Debug - Error processing records: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self.errorMessage = "Fetch failed: \(error.localizedDescription)"
                    print("Debug - Fetch failed: \(error.localizedDescription)")
                }
                completion?()
            }
        }
    }
    
    func joinQueue(allowRejoin: Bool = false, completion: (() -> Void)? = nil, attempt: Int = 1, maxAttempts: Int = 3) {
        guard let username = LoginViewModel.shared.userName else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in"
                print("Debug - Join queue failed: User not logged in")
                completion?()
            }
            return
        }
        if hasJoinedQueue && !allowRejoin {
            DispatchQueue.main.async {
                self.errorMessage = "You have already joined the queue"
                print("Debug - Join queue failed: User \(username) already in queue")
                completion?()
            }
            return
        }
        let query = CKQuery(recordType: "QueueEntry", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "number", ascending: false)]
        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: ["number"], resultsLimit: 1) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let queryResult):
                    do {
                        let records = try queryResult.matchResults.map { try $0.1.get() }
                        let nextNumber = (records.first?["number"] as? Int ?? 0) + 1
                        let record = CKRecord(recordType: "QueueEntry")
                        record["username"] = username as CKRecordValue
                        record["status"] = "Queueing" as CKRecordValue
                        record["number"] = nextNumber as CKRecordValue
                        record["timestamp"] = Date() as CKRecordValue

                        let numberCheckPredicate = NSPredicate(format: "number == %ld", nextNumber)
                        let numberCheckQuery = CKQuery(recordType: "QueueEntry", predicate: numberCheckPredicate)
                        self.database.fetch(withQuery: numberCheckQuery, inZoneWith: nil, resultsLimit: 1) { checkResult in
                            switch checkResult {
                            case .success(let checkQueryResult):
                                do {
                                    let existingRecords = try checkQueryResult.matchResults.map { try $0.1.get() }
                                    if !existingRecords.isEmpty && attempt <= maxAttempts {
                                        print("Debug - Number \(nextNumber) already taken, retrying attempt \(attempt)")
                                        self.joinQueue(allowRejoin: allowRejoin, completion: completion, attempt: attempt + 1, maxAttempts: maxAttempts)
                                        return
                                    }
                                    self.database.save(record) { savedRecord, error in
                                        DispatchQueue.main.async {
                                            if let error = error {
                                                self.errorMessage = error.localizedDescription
                                                print("Debug - Failed to save record: \(error.localizedDescription)")
                                                completion?()
                                            } else {
                                                print("Debug - Successfully joined queue with number \(nextNumber) for \(username)")
                                                self.fetchQueue(completion: completion)
                                            }
                                        }
                                    }
                                } catch {
                                    self.errorMessage = error.localizedDescription
                                    print("Debug - Error checking number: \(error.localizedDescription)")
                                    completion?()
                                }
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                                print("Debug - Error checking number: \(error.localizedDescription)")
                                completion?()
                            }
                        }
                    } catch {
                        self.errorMessage = error.localizedDescription
                        print("Debug - Error processing join queue results: \(error.localizedDescription)")
                        completion?()
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Debug - Error fetching queue for join: \(error.localizedDescription)")
                    completion?()
                }
            }
        }
    }
    
    func cancelQueue(completion: (() -> Void)? = nil) {
        guard let username = LoginViewModel.shared.userName else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in"
                print("Debug - Cancel queue failed: User not logged in")
                completion?()
            }
            return
        }
        guard let userEntry = queueList
            .filter({ $0.username == username })
            .max(by: { ($0.number, $0.timestamp ?? Date.distantPast) < ($1.number, $1.timestamp ?? Date.distantPast) }) else {
            DispatchQueue.main.async {
                self.errorMessage = "User not found in queue"
                print("Debug - Cancel queue failed: User \(username) not in queue")
                completion?()
            }
            return
        }
        database.delete(withRecordID: userEntry.id) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Debug - Failed to delete record: \(error.localizedDescription)")
                    completion?()
                } else {
                    print("Debug - Successfully canceled queue for user \(username) with number \(userEntry.number)")
                    self.fetchQueue(completion: completion)
                }
            }
        }
    }
    
    func updateStatus(for entry: QueueEntry, to status: String, completion: (() -> Void)? = nil) {
        let recordID = entry.id
        database.fetch(withRecordID: recordID) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Debug - Failed to fetch record for status update: \(error.localizedDescription)")
                    completion?()
                    return
                }
                guard let record = record else {
                    self.errorMessage = "Record not found"
                    print("Debug - Record not found for status update")
                    completion?()
                    return
                }
                record["status"] = status.capitalized as CKRecordValue
                self.database.save(record) { savedRecord, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            print("Debug - Failed to update status: \(error.localizedDescription)")
                            completion?()
                        } else {
                            print("Debug - Successfully updated status for \(entry.username) to \(status)")
                            self.fetchQueue(completion: completion)
                        }
                    }
                }
            }
        }
    }
    
    private func setupSubscription() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                if status != .available {
                    self.errorMessage = "Please sign in to iCloud to enable queue updates"
                    print("Debug - iCloud account not available: \(status.rawValue), error: \(error?.localizedDescription ?? "None")")
                    return
                }
                self.database.fetch(withSubscriptionID: self.subscriptionID) { subscription, error in
                    if subscription != nil {
                        print("Debug - Subscription already exists: \(self.subscriptionID)")
                        return
                    }
                    if let error = error {
                        self.errorMessage = "Failed to check subscription: \(error.localizedDescription)"
                        print("Debug - Failed to check subscription: \(error.localizedDescription)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.createSubscription(attempt: 1)
                        }
                        return
                    }
                    self.createSubscription(attempt: 1)
                }
            }
        }
    }
    
    private func createSubscription(attempt: Int = 1, maxAttempts: Int = 5) {
        let subscription = CKQuerySubscription(
            recordType: "QueueEntry",
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "Queue updated!"
        subscription.notificationInfo = notificationInfo

        database.save(subscription) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to save subscription (attempt \(attempt)): \(error.localizedDescription)"
                    print("Debug - Failed to save subscription (attempt \(attempt)): \(error.localizedDescription)")
                    if attempt <= maxAttempts {
                        let delay = pow(2.0, Double(attempt)) * 2.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.createSubscription(attempt: attempt + 1, maxAttempts: maxAttempts)
                        }
                    }
                } else {
                    print("Debug - Subscription set up successfully")
                }
            }
        }
    }
    
    // Debug method to verify CloudKit data
    func debugFetchAllRecords() {
        let query = CKQuery(recordType: "QueueEntry", predicate: NSPredicate(value: true))
        database.fetch(withQuery: query, inZoneWith: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let queryResult):
                    do {
                        let records = try queryResult.matchResults.map { try $0.1.get() }
                        print("Debug - Raw CloudKit records: \(records.map { "ID: \($0.recordID.recordName), username: \($0["username"] as? String ?? ""), status: \($0["status"] as? String ?? ""), number: \($0["number"] as? Int ?? 0)" })")
                    } catch {
                        print("Debug - Error processing raw records: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Debug - Debug fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
