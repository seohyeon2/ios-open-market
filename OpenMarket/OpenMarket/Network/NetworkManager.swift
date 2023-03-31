//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//

import UIKit
import Combine

final class NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSessionProtocol
    private let identifier = NetworkNamespace.identifier.name
    private var cancellable = Set<AnyCancellable>()
    init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func requestToServer2(request: URLRequest) -> AnyPublisher<Data, NetworkError> {
        return URLSession.shared
          .dataTaskPublisher(for: request)
          .tryMap() { data, response in
             guard let httpResponse = response as? HTTPURLResponse else {
                 throw NetworkError.failToResponse
             }

             guard 200..<300 ~= httpResponse.statusCode else {
                 throw NetworkError.outOfRange
             }

             guard !data.isEmpty else {
                 throw NetworkError.noneData
             }

             return data
          }
          .mapError { error in
             if let error = error as? NetworkError {
                return error
             } else {
                 return NetworkError.noneData
             }
          }
          .eraseToAnyPublisher()
     }

    func getProductInquiry(pageNumber: Int) -> AnyPublisher<Data, NetworkError>? {
            guard let request = try? ProductRequest.list(page: pageNumber).createURLRequest() else { return nil }

            return requestToServer2(request: request)
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
    
    func postProduct(params: [String: Any?], imageData: [Data]) {

        guard var request = try? ProductRequest.registerItem.createURLRequest() else { return }

        let postData = OpenMarketRequest.createPostBody(params: params as [String: Any], imageData: imageData)

        request.httpBody = postData

        requestToServer2(request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    print("포스트성공")
                    return
                case .failure(let error):
                    print(error)
                    return
                }
            } receiveValue: { _ in }
            .store(in: &cancellable)
    }

    func patchProduct(productId: Int, modifiedInformation: [String: Any?]) {
        
        guard var request = try? ProductRequest.patchItem(productId).createURLRequest() else { return }
        
        let postData = OpenMarketRequest.createPostBody(params: modifiedInformation as [String: Any], imageData: nil)
        
        request.httpBody = postData
        
        requestToServer2(request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    print("수정성공")
                    return
                case .failure(let error):
                    print(error)
                    return
                }
            } receiveValue: { _ in }
            .store(in: &cancellable)

    }
    
//    func deleteProduct(productId: Int, productSecretId: Data) {
//        guard let secret = String(data: productSecretId, encoding: .utf8) else { return }
//
//        guard var request = try? ProductRequest.delete(id: productId, secret: secret).createURLRequest() else { return }
//
//        networkPerform(for: request) { _ in }
//    }
}
