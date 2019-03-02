//
//  Request.swift
//  LDSiOSKit
//
//  Created by Luke Street on 2/16/19.
//

import Foundation

public enum RequestError: Error {
    case invalidURL(path: String)
    case non200(URLResponse)
}

public enum HTTPMethod {
    case get
    case post(body: [String: String])
    
    public var value: String {
        switch self {
        case .get: return "GET"
        case .post(_): return "POST"
        }
    }
}

extension Data {
    public func decoded<T: Codable>(as type: T.Type, decode: (T.Type, Data) throws -> T = JSONDecoder().decode) throws -> T {
        return try decode(type, self)
    }
}

extension Encodable {
    public func encode(encode: (Self) throws -> Data = JSONEncoder().encode) throws -> Data {
        return try encode(self)
    }
}

extension Encodable {
    public var post: HTTPMethod {
        return .post(body: try! encode().decoded(as: [String: String].self))
    }
}

public struct ServerError: Codable, LocalizedError {
    let error: Bool
    let reason: String
    public var localizedDescription: String {
        return reason
    }
    
}

public final class Request<Env: EnvironmentProvider, Model: Codable>  {
    
    private let environment: Env
    private let path: String
    private let session: URLSession
    private let method: HTTPMethod
    private let headers: [String: String]
    
    public init(using environment: Env, path: String, method: HTTPMethod = .get, headers: [String: String] = [:], session: URLSession = .shared) {
        self.environment = environment
        self.path = path
        self.method = method
        self.headers = headers
        self.session = session
    }
    
    public func send(_ result: @escaping ResultClosure<Model>) -> Void {
        let url = self.environment.url.appendingPathComponent(self.path)
        var request = URLRequest(url: url)
        request.httpMethod = self.method.value
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        request.allHTTPHeaderFields = self.headers
        switch self.method {
        case .get: break
        case .post(let body):
            let bodyData = try? body.encode()
            request.httpBody = bodyData
            request.setValue("\(bodyData?.count ?? 0)", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let task = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                result(.failure(error))
            } else if let data = data {
                guard Model.self != Data.self else {
                    result(.success(data as! Model))
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let error = try? decoder.decode(ServerError.self, from: data) {
                    result(.failure(error))
                    return
                }
                result(.init { try decoder.decode(Model.self, from: data) })
            }
        }
        task.resume()
    }
}
