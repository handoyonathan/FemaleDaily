//
//  AdminViewModel.swift
//  FemaleDaily
//
//  Created by Yonathan Handoyo on 23/07/25.
//

import SwiftUI
import CloudKit

class AdminViewModel: ObservableObject {
    @Published var queueList: [QueueEntry] = []
    @Published var errorMessage: String?
    private var database = CKContainer.default().publicCloudDatabase
    private var authViewModel: LoginViewModel
    private let subscriptionID = "queueEntryChanges"

    init(authViewModel: LoginViewModel) {
        self.authViewModel = authViewModel
        setupSubscription()
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.queueList = newQueueList
                                print("Updated queue with \(newQueueList.count) entries at \(Date().formatted()) after 1s delay")
                            }
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

    func updateStatus(for entry: QueueEntry, to status: String, completion: (() -> Void)? = nil) {
        let recordID = entry.id
        database.fetch(withRecordID: recordID) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Failed to fetch record for update: \(error.localizedDescription)")
                    completion?()
                    return
                }
                guard let record = record else {
                    self.errorMessage = "Record not found"
                    print("Record not found for ID: \(recordID)")
                    completion?()
                    return
                }
                record["status"] = status as CKRecordValue
                self.database.save(record) { savedRecord, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            print("Failed to update status to \(status): \(error.localizedDescription)")
                        } else {
                            print("Successfully updated status to \(status) for \(entry.username) at \(Date().formatted())")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.fetchQueue(completion: completion)
                                print("fetchQueue triggered after 1s delay for status update")
                            }
                        }
                    }
                }
            }
        }
    }

    func setupSubscription() {
        database.fetch(withSubscriptionID: subscriptionID) { subscription, error in
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

    private func createSubscription(attempt: Int = 1) {
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
                    self.errorMessage = error.localizedDescription
                    print("Failed to save subscription (attempt \(attempt)): \(error.localizedDescription)")
                    if attempt <= 3 {
                        let delay = pow(2.0, Double(attempt)) * 2.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.createSubscription(attempt: attempt + 1)
                        }
                    }
                } else {
                    print("Subscription set up successfully at \(Date().formatted())")
                }
            }
        }
    }
}
