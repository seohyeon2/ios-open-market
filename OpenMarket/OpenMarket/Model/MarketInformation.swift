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
    let pages: [SaleInformation]
    let lastPage: Int
    let hasNext: Bool
    let hasPrev: Bool
    
    enum CodingKeys: String, CodingKey {
        case pageNo = "page_no"
        case itemsPerPage = "items_per_page"
        case totalCount = "total_count"
        case offset
        case limit
        case pages
        case lastPage = "last_page"
        case hasNext = "has_next"
        case hasPrev = "has_prev"
    }
}

struct SaleInformation: Decodable, Hashable {
    let id: Int
    let vendorId: Int
    let name: String
    let thumbnail: String
    let currency: String
    let price: Double
    let description: String?
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String
    let issuedAt: String
    let images: [Images]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case vendorId = "vendor_id"
        case name
        case thumbnail
        case currency
        case price
        case description
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

