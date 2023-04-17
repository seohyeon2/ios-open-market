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

        var urlRequest = URLRequest(url: url,
                                    httpMethod: httpMethod)

        if headers.isNotEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }

        if needsIdentifier {
            urlRequest.setValue(APIConstants.identifier,
                                forHTTPHeaderField: Request.identifier)
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

enum ProductRequest: RequestProtocol {
    case list(page: Int, itemPerPage: Int = 20)
    case detailItem(Int)
    case registerItem
    case patchItem(Int)
    case deleteURL(Int)
    case delete(url: String)

    var headers: [String: String] {
        switch self {
        case .registerItem:
            return [Multipart.contentType: Multipart.boundaryForm + "\"\(Multipart.boundaryValue)\""]
        case .patchItem,
             .deleteURL:
            return [Multipart.contentType: Multipart.jsonContentType]
        default:
            return [:]
        }
    }

    var needsIdentifier: Bool {
        switch self {
        case .list,
             .detailItem:
            return false
        default:
            return true
        }
    }

    var path: String {
        switch self {
        case .detailItem(let id),
             .patchItem(let id):
            return "/api/products/\(id)"
        case .deleteURL(let id):
            return "/api/products/\(id)/archived"
        case .delete(let url):
            return url
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
        case .detailItem:
            return .get
        case .registerItem:
            return .post
        case .patchItem:
            return .patch
        case .deleteURL:
            return .post
        case .delete:
            return .del
        }
    }
}
