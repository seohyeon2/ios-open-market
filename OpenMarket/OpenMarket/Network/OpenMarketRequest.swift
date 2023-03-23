//
//  OpenMarketRequest.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/18.
//

import UIKit

struct OpenMarketRequest {
    static let address = NetworkNamespace.url.name
    
    static func createQuery(of pageNo: String = String(Metric.firstPage), with itemsPerPage: String = String(Metric.itemCount)) -> [URLQueryItem] {
        let pageNo = URLQueryItem(name: ModelNameSpace.pageNo.name, value: pageNo)
        let itemsPerPage = URLQueryItem(name: ModelNameSpace.itemsPerPage.name, value: itemsPerPage)
        return [pageNo, itemsPerPage]
    }
    
    static func requestProductList(queryItems: [URLQueryItem]) -> URLRequest? {
        var components = URLComponents(string: address)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    static func requestProductDetail(of productId: String) -> URLRequest? {
        let components = URLComponents(string: address)
        
        guard var url = components?.url else {
            return nil
        }
        
        url.appendPathComponent(productId)
        return URLRequest(url: url)
    }
    
//    static func createPostRequest(identifier: String) -> URLRequest? {
//        guard let url = URL(string: NetworkNamespace.url.name) else { return nil }
//        var request = URLRequest(url: url)
//        request.httpMethod = NetworkNamespace.post.name
//
//        request.addValue(Multipart.boundaryForm + "\"\(Multipart.boundaryValue)\"", forHTTPHeaderField: Multipart.contentType)
//        request.addValue(identifier, forHTTPHeaderField: Request.identifier)
//        return request
//    }
    
    static func createPostBody(params: [String: Any], images: [UIImage]) -> Data? {
        var postData = Data()
        let boundary = Multipart.boundaryValue

        guard let jsonData = createJson(params: params) else { return nil }

        postData.append(form: "--\(boundary)" + Multipart.lineFeed)
        postData.append(form: Multipart.paramContentDisposition + Multipart.lineFeed)
        postData.append(jsonData)
        postData.append(form: Multipart.lineFeed)

        for image in images {
            guard let imageData = OpenMarketRequest().createPostImage(image: image) else { return nil }
            postData.append(form: "--\(boundary)" + Multipart.lineFeed)
            postData.append(form: Multipart.imageContentDisposition + "\"\(images.description.hashValue)\"" + Multipart.lineFeed)
            postData.append(form: Multipart.paramContentType + Multipart.lineFeed + Multipart.lineFeed)
            postData.append(imageData)
            postData.append(form: Multipart.lineFeed + Multipart.lineFeed)
        }
        
        postData.append(form: "--\(boundary)--")

        return postData
    }
    
    static func createJson(params: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
    
    private func createPostImage(image: UIImage) -> Data? {
        let image = image
        
        guard let imageData = image.compress() else { return nil }
        return imageData
    }
}
