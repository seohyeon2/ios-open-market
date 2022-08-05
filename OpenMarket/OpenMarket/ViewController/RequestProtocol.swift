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
    
    func createURLRequest() throws -> URLRequest
}

protocol Occupiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

extension RequestProtocol {
    var scheme: String {
        return APIConstants.scheme
    }
    
    var host: String {
        return APIConstants.host
    }
    
    func createURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host

        components.path = path

        if queries.isNotEmpty {
            components.queryItems = queries.map(URLQueryItem.init(name:value:))
        }

        guard let url = components.url else { throw NetworkError.noneData }

        var urlRequest = URLRequest(url: url, httpMethod: httpMethod)

        if headers.isNotEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }

        if needsIdentifier {
            urlRequest.setValue(APIConstants.identifier, forHTTPHeaderField: "identifier")
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

protocol NetworkManagerProtocol {
    func networkPerform(for request: URLRequest, identifier: String?, completion: @escaping (Result<Data, Error>) -> Void)
}

enum ProductRequest: RequestProtocol {
    case list(page: Int, itemPerPage: Int = 20)
    case item(Int)
    case registerItem

    var headers: [String: String] {
        switch self {
        case .registerItem:
            return [Multipart.contentType: Multipart.boundaryForm + "\"\(Multipart.boundaryValue)\""]
        default:
            return [:]
        }
    }

    var needsIdentifier: Bool {
        switch self {
        case .list:
            return false
        default:
            return true
        }
    }

    var path: String {
        switch self {
        case let .item(id):
            return "/api/products/\(id)"
        default:
            return "/api/products"
        }
    }

    var queries: [String: String] {
        switch self {
        case let .list(page, itemPerPage):
            return [
                ModelNameSpace.pageNo.name: "\(page)",
                ModelNameSpace.itemsPerPage.name: "\(itemPerPage)"
            ]
        default:
            return [:]
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .list:
            return .get
        case .item:
            return .get
        case .registerItem:
            return .post
        }
    }
}
