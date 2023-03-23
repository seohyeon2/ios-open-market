//
//  MarketItem.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/22.
//

import Foundation

struct MarketItem: Decodable, Hashable {
    let id: Int
    let vendorId: Int
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
    let images: [Images]
    let vendors: VendorDTO

    enum CodingKeys: String, CodingKey {
        case id, name, description, thumbnail, currency, price, stock, images, vendors
        case vendorId = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}

struct Images: Decodable, Hashable {
    let id: Int
    let url: String
    let thumbnailUrl: String
    let issuedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnailUrl = "thumbnail_url"
        case issuedAt = "issued_at"
    }
}

struct VendorDTO: Decodable, Hashable {
    let id: Int
    let name: String
}
