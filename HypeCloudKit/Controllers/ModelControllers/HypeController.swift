//
//  HypeController.swift
//  HypeCloudKit
//
//  Created by Jon Corn on 2/4/20.
//  Copyright © 2020 Jon Corn. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    
    // MARK: - Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    static let shared = HypeController()
    var hypes = [Hype]()
    
    // MARK: - CRUD Functions
    func saveHype(with bodyText: String, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        
        let newHype = Hype(body: bodyText)
        let hypeRecord = CKRecord(hype: newHype)
        
        // saving to the cloud
        publicDB.save(hypeRecord) { (record, error) in
            // handle error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // handle data
            guard let record = record,
                let savedHype = Hype(ckRecord: record)
                else {return completion(.failure(.couldNotUnwrap))}
            print("Saved Hype successfully")
            
            return completion(.success(savedHype))
        }
    }
    
    func fetchAllHypes(completion: @escaping (Result<[Hype], HypeError>) -> Void) {
        
        let queryAllPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: queryAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            // handle error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // handle data
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            
            // converting records to hype objects
            let hypes = records.compactMap( {Hype(ckRecord: $0)})
            
            return completion(.success(hypes))
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        // create a ckrecord from the passed in hype
        let record = CKRecord(hype: hype)
        // Create an operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        // when you're saving things only save things that have changed
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            // handle error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // handle records
            guard let record = records?.first,
                let updatedHype = Hype(ckRecord: record)
                else {return completion(.failure(.couldNotUnwrap))}
            completion(.success(updatedHype))
        }
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                completion(.success(true))
            } else {
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(operation)
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) -> Void) {
        // Create the needed predicate to pass into the subscription
        let predicate = NSPredicate(value: true)
        // Create the CKQuerySubscription object
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        // Set the notification properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't stop the Hype Train!!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        // save the subscription to the database
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(error)
            }
            completion(nil)
        }
    }
}
