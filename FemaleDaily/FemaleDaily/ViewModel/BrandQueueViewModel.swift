//
//  BrandQueueViewModel.swift
//  
//
//  Created by Yonathan Handoyo on 21/07/25.
//

import SwiftUI
import CloudKit

class BrandQueueViewModel: ObservableObject {
    @Published var queueList: [QueueEntry] = []
    @Published var errorMessage: String?
    private var database = CKContainer.default().publicCloudDatabase
    private var authViewModel: LoginViewModel
    private let subscriptionID = "queueEntryChanges"

    init(authViewModel: LoginViewModel) {
        self.authViewModel = authViewModel
        setupSubscription()
    }

    var hasJoinedQueue: Bool {
        guard let username = authViewModel.userName else { return false }
        return queueList.contains { $0.username == username && $0.status.lowercased() == "queueing" }
    }

    func fetchQueue(completion: (() -> Void)? = nil) {
        let query = CKQuery(recordType: "QueueEntry", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        database.fetch(withQuery: query, inZoneWith: nil, resultsLimit: 100) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let queryResult):
                    do {
                        let records = try queryResult.matchResults.map { try $0.1.get() }
                        let newQueueList = records.map { QueueEntry(record: $0) }
                        print("Fetched records: \(newQueueList.map { "\($0.number): \($0.username), status: \($0.status)" })")
                        if self.queueList != newQueueList {
                            self.queueList = newQueueList
                            print("Updated queue with \(newQueueList.count) entries at \(Date().formatted())")
                            NotificationCenter.default.post(name: NSNotification.Name("QueueUpdated"), object: nil)
                        } else {
                            print("No changes in queue data at \(Date().formatted()), current count: \(self.queueList.count)")
                        }
                        self.errorMessage = nil
                    } catch {
                        self.errorMessage = error.localizedDescription
                        print("Error processing query results: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error fetching queue: \(error.localizedDescription)")
                }
                completion?()
            }
        }
    }

    func joinQueue(allowRejoin: Bool = false, completion: (() -> Void)? = nil, attempt: Int = 1, maxAttempts: Int = 3) {
        guard let username = authViewModel.userName else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in"
                print("Join queue failed: User not logged in")
                completion?()
            }
            return
        }
        if hasJoinedQueue && !allowRejoin {
            DispatchQueue.main.async {
                self.errorMessage = "You have already joined the queue"
                print("Join queue failed: User \(username) already in queue")
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

                        // Check for duplicate number before saving
                        let numberCheckPredicate = NSPredicate(format: "number == %ld", nextNumber)
                        let numberCheckQuery = CKQuery(recordType: "QueueEntry", predicate: numberCheckPredicate)
                        self.database.fetch(withQuery: numberCheckQuery, inZoneWith: nil, resultsLimit: 1) { checkResult in
                            switch checkResult {
                            case .success(let checkQueryResult):
                                do {
                                    let existingRecords = try checkQueryResult.matchResults.map { try $0.1.get() }
                                    if !existingRecords.isEmpty && attempt <= maxAttempts {
                                        print("Number \(nextNumber) already taken, retrying attempt \(attempt)")
                                        self.joinQueue(allowRejoin: allowRejoin, completion: completion, attempt: attempt + 1, maxAttempts: maxAttempts)
                                        return
                                    }
                                    self.database.save(record) { savedRecord, error in
                                        DispatchQueue.main.async {
                                            if let error = error {
                                                self.errorMessage = error.localizedDescription
                                                print("Failed to save record: \(error.localizedDescription)")
                                                completion?()
                                            } else {
                                                print("Successfully joined queue with number \(nextNumber) at \(Date().formatted())")
                                                self.fetchQueue(completion: completion)
                                            }
                                        }
                                    }
                                } catch {
                                    self.errorMessage = error.localizedDescription
                                    print("Error checking number: \(error.localizedDescription)")
                                    completion?()
                                }
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                                print("Error checking number: \(error.localizedDescription)")
                                completion?()
                            }
                        }
                    } catch {
                        self.errorMessage = error.localizedDescription
                        print("Error processing join queue results: \(error.localizedDescription)")
                        completion?()
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error fetching queue for join: \(error.localizedDescription)")
                    completion?()
                }
            }
        }
    }

    func cancelQueue(completion: (() -> Void)? = nil) {
        guard let username = authViewModel.userName else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in"
                print("Cancel queue failed: User not logged in")
                completion?()
            }
            return
        }
        guard let userEntry = queueList
            .filter({ $0.username == username })
            .max(by: { ($0.number, $0.timestamp ?? Date.distantPast) < ($1.number, $1.timestamp ?? Date.distantPast) }) else {
            DispatchQueue.main.async {
                self.errorMessage = "User not found in queue"
                print("Cancel queue failed: User \(username) not in queue")
                completion?()
            }
            return
        }
        database.delete(withRecordID: userEntry.id) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Failed to delete record: \(error.localizedDescription)")
                    completion?()
                } else {
                    print("Successfully canceled queue for user \(username) with number \(userEntry.number) at \(Date().formatted())")
                    self.fetchQueue(completion: completion)
                }
            }
        }
    }

    func setupSubscription() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                if status != .available {
                    self.errorMessage = "Please sign in to iCloud to enable queue updates"
                    print("iCloud account not available: \(status.rawValue), error: \(error?.localizedDescription ?? "None")")
                    return
                }
                self.database.fetch(withSubscriptionID: self.subscriptionID) { subscription, error in
                    if subscription != nil {
                        DispatchQueue.main.async {
                            print("Subscription already exists: \(self.subscriptionID)")
                        }
                        return
                    }
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to check subscription: \(error.localizedDescription)"
                            print("Failed to check subscription: \(error.localizedDescription)")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.createSubscription(attempt: 1)
                            }
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
                    print("Failed to save subscription (attempt \(attempt)): \(error.localizedDescription)")
                    if attempt <= maxAttempts {
                        let delay = pow(2.0, Double(attempt)) * 2.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.createSubscription(attempt: attempt + 1, maxAttempts: maxAttempts)
                        }
                    }
                } else {
                    print("Subscription set up successfully at \(Date().formatted())")
                }
            }
        }
    }
}
