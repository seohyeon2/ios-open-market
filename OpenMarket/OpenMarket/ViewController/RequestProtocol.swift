//
//  RequestProtocol.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import Foundation

protocol RequestProtocol {
    var path: String { get }
    var queries: [String: String] { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String] { get }
    var needsIdentifier: Bool { get }
    
    func createURLRequest(identifier: String) throws -> URLRequest
}

protocol Occupiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

extension RequestProtocol {
    var host: String {
        return APIConstants.host
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var needsIdentifier: Bool {
        return true
    }
    
    func createURLRequest(identifier: String) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host

        if queries.isNotEmpty {
            components.queryItems = queries.map(URLQueryItem.init(name:value:))
        }

        guard let url = components.url else { throw NetworkError.noneData }

        var urlRequest = URLRequest(url: url, httpMethod: httpMethod)

        if headers.isNotEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }

        if needsIdentifier {
            urlRequest.setValue(identifier, forHTTPHeaderField: "identifier")
        }
        return urlRequest
    }
}

extension Occupiable {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Dictionary: Occupiable {}

extension URLRequest {
    init(
        url: URL,
        httpMethod: HTTPMethod
    ) {
        self.init(url: url)
        self.httpMethod = httpMethod.rawValue
    }
}
