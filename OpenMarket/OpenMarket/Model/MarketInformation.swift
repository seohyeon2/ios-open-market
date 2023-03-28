//
//  MarketInformation.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//

import Foundation

struct MarketInformation: Decodable {
    let pageNo: Int
    let itemsPerPage: Int
    let totalCount: Int
    let offset: Int
    let limit: Int
    let pages: [PageInformation]
    let lastPage: Int
    let hasNext: Bool
    let hasPrev: Bool
}

struct PageInformation: Decodable, Hashable {
    let hashID = UUID()

    let id: Int
    let vendorId: Int
    let vendorName: String
    let name: String
    let description: String
    let thumbnail: String
    let currency: String
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String
    let issuedAt: String

    enum CodingKeys: String, CodingKey {
        case id,
             name,
             description,
             thumbnail,
             currency,
             price,
             stock,
             vendorName
        case vendorId = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}

enum Currency: Int {
    case KRW
    case USD

    var name: String {
        switch self {
        case .KRW:
            return "KRW"
        case .USD:
            return "USD"
        }
    }
}
