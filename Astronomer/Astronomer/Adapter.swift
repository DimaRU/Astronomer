//
//  Adapter.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

enum AdapterError: Error {
    case notImplemented
}

class Adapter<I, O> {
    
    private var input: I
    
    init(input: I) {
        self.input = input
    }
    
    func adapt() -> Result<O, AdapterError> {
        return Result.error(.notImplemented)
    }
    
}
