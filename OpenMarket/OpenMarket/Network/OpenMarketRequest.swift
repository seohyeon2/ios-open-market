//
//  OpenMarketRequest.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/18.
//

import UIKit

struct OpenMarketRequest {

    static func createPostBody(params: [String: Any], imageData: [Data]?) -> Data? {
        var postData = Data()
        let boundary = Multipart.boundaryValue

        guard let jsonData = createJson(params: params) else { return nil }

        postData.append(form: "--\(boundary)" + Multipart.lineFeed)
        postData.append(form: Multipart.paramContentDisposition + Multipart.lineFeed)
        postData.append(jsonData)
        postData.append(form: Multipart.lineFeed)

        if let imageData = imageData {
            imageData.forEach { image in
                postData.append(form: "--\(boundary)" + Multipart.lineFeed)
                postData.append(form: Multipart.imageContentDisposition + "\"\(image.description.hashValue)\"" + Multipart.lineFeed)
                postData.append(form: Multipart.paramContentType + Multipart.lineFeed + Multipart.lineFeed)
                postData.append(image)
                postData.append(form: Multipart.lineFeed + Multipart.lineFeed)
            }
        }
        
        postData.append(form: "--\(boundary)--")

        return postData
    }
    
    static func createJson(params: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
}
