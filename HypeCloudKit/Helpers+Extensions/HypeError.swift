//
//  HypeError.swift
//  HypeCloudKit
//
//  Created by Jon Corn on 2/4/20.
//  Copyright © 2020 Jon Corn. All rights reserved.
//

import Foundation

enum HypeError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get this Hype."
        }
    }
}
