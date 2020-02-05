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
    
    func delete(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        let record = CKRecord(hype: hype)
        let operation = CKModifyRecordsOperation(reco)
    }
}
