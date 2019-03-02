//
//  Result.swift
//  LDSiOSKit
//
//  Created by Luke Street on 2/16/19.
//

import Foundation

public enum Result<Success> {
    case success(_ success: Success)
    case failure(_ error: Error)
    
    public init(throwingExpression: () throws -> Success) {
        do {
            let result = try throwingExpression()
            self = .success(result)
        } catch {
            self = .failure(error)
        }
    }
    
    public func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

public typealias ResultClosure<T> = (Result<T>) -> Void
