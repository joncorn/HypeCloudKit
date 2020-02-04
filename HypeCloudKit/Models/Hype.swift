//
//  Hype.swift
//  HypeCloudKit
//
//  Created by Jon Corn on 2/4/20.
//  Copyright © 2020 Jon Corn. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - String helpers
struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}
// MARK: - Hype model
class Hype {
    
    var body: String
    var timestamp: Date
    
    init(body: String, timestamp: Date = Date()) {
        self.body = body
        self.timestamp = timestamp
    }
}

// MARK: - Create record
// Hype -> CKRecord
extension CKRecord {
    
    convenience init(hype: Hype) {
        
        self.init(recordType: HypeStrings.recordTypeKey)
        
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
    }
}

// MARK: - Fetch record
// CKRecord -> Hype
extension Hype {
    
    convenience init?(ckRecord: CKRecord) {
        // turns record data into Hype object
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
            let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
            else { return nil }
        
        self.init(body: body, timestamp: timestamp)
    }
}

