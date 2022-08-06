//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//

import UIKit

final class NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSessionProtocol
    private let identifier = NetworkNamespace.identifier.name
    
    init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func networkPerform(for request: URLRequest, identifier: String? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(NetworkError.outOfRange))
            }
            
            guard let data = data else {
                return completion(.failure(NetworkError.noneData))
            }
            completion(.success(data))
        }
        dataTask.resume()
    }
    
    func getProductInquiry(pageNumber: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let request = try? ProductRequest.list(page: pageNumber).createURLRequest() else { return }
        
        networkPerform(for: request, identifier: nil, completion: completion)
    }

    func postProduct(params: [String: Any?], images: [UIImage], completion: @escaping (Result<Data, Error>) -> Void) {
        let passwordKey = NetworkNamespace.passwordKey.name
        let passwordValue = NetworkNamespace.passwordValue.name
        var newParms = params
        
        newParms[passwordKey] = passwordValue
        
        guard var request = try? ProductRequest.registerItem.createURLRequest() else { return }

        let postData = OpenMarketRequest.createPostBody(parms: newParms as [String: Any], images: images)

        request.httpBody = postData

        networkPerform(for: request) { result in
            switch result {
            case .success(let data):
                return completion(.success(data))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    
    func postSecret(productId: Int, completion: @escaping (Result<Data, Error>) -> Void) {
      
        guard var request = try? ProductRequest.productSecret(productId).createURLRequest() else { return }
        
        let parameters = "{\"\(NetworkNamespace.passwordKey.name)\": \"\(NetworkNamespace.passwordValue.name)\"}"
        let postData = parameters.data(using: .utf8)

        request.httpBody = postData
        networkPerform(for: request) { result in
                switch result {
                case .success(let data):
                    self.deleteProduct(productId: productId, productSecretId: data)
                    return completion(.success(data))
                case .failure(let error):
                    return completion(.failure(error))
                }
            }
        
    }

    func patchProduct(productId: Int, modifiedInfomation: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard var request = try? ProductRequest.patchItem(productId).createURLRequest() else { return }
        
        var params = modifiedInfomation
        params[NetworkNamespace.passwordKey.name] = NetworkNamespace.passwordValue.name

        guard let jsonData = OpenMarketRequest.createJson(params: params) else { return }
        request.httpBody = jsonData
        
        networkPerform(for: request) { result in
            switch result {
            case .success(let data):
                return completion(.success(data))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    
    func deleteProduct(productId: Int, productSecretId: Data) {
        guard let secret = String(data: productSecretId, encoding: .utf8) else { return }
        
        guard var request = try? ProductRequest.delete(id: productId, secret: secret).createURLRequest() else { return }

        networkPerform(for: request) { _ in }
    }
}
