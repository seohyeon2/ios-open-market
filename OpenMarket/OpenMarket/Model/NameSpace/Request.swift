//
//  Request.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/30.
//

import Foundation

enum Request {
    static let identifier = "identifier"
}

enum Multipart {
    static let boundaryForm = "multipart/form-data; boundary="
    static let boundaryValue = "Boundary-\(UUID().uuidString)"
    static let contentType = "Content-Type"
    static let jsonContentType = "application/json"
    static let paramContentDisposition = "Content-Disposition: form-data; name=\"params\"\r\n"
    static let paramContentType = "Content-Type: multipart/form-data"
    static let lineFeed = "\r\n"
    static let imageContentDisposition = "Content-Disposition: form-data; name=\"images\"; filename="
}

enum Params {
    static let productName = "name"
    static let productDescription = "description"
    static let productPrice = "price"
    static let currency = "currency"
    static let discountedPrice = "discountedPrice"
    static let stock = "stock"
    static let secret = "secret"
}
