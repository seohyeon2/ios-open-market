//
//  MarketInformation.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//
struct MarketInformation: Decodable {
    let pageNo: Int
    let itemsPerPage: Int
    let totalCount: Int
    let offset: Int
    let limit: Int
    let pages: [MarketItem]
    let lastPage: Int
    let hasNext: Bool
    let hasPrev: Bool
}

struct MarketItem: Decodable, Hashable {
    let id: Int
    let vendorId: Int
    let vendorName: String
    let name: String
    let description: String
    let thumbnail: String
    let currency: String
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double?
    let stock: Int
    let createdAt: String
    let issuedAt: String
    let images: [Images]?

    enum CodingKeys: String, CodingKey {
        case id
        case vendorId = "vendor_id"
        case vendorName
        case name
        case description
        case thumbnail
        case currency
        case price
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case stock
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case images
    }
}

struct Images: Decodable, Hashable {
    let id: Int
    let url: String
    let thumbnailUrl: String
    let succeed: Bool
    let issuedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnailUrl = "thumbnail_url"
        case succeed
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
