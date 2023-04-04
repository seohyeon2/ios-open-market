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
    
    func requestToServer(request: URLRequest) -> AnyPublisher<Data, NetworkError> {
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

            return requestToServer(request: request)
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

        requestToServer(request: request)
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
        guard let postData = OpenMarketRequest.createJson(params: modifiedInformation as [String : Any]) else { return }
        
        request.httpBody = postData
        
        requestToServer(request: request)
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

    func deleteProduct(productId: Int?) {
        guard let productId = productId else { return }
        guard var request = try? ProductRequest.deleteURL(productId).createURLRequest() else {
            return
        }
        
        request.httpBody = OpenMarketRequest.createJson(params: [Params.secret: APIConstants.secret])
        
        requestToServer(request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    print("url 가져오기 성공")
                    return
                case .failure(let error):
                    print(error)
                    return
                }
            } receiveValue: { [weak self] urlData in
                guard let url = String(data: urlData, encoding: .utf8) else { return }
                self?.delete(url: url)
            }
            .store(in: &cancellable)
    }
    
    private func delete(url: String) {
        guard let request = try? ProductRequest.delete(url: url).createURLRequest() else {
            return
        }
        
        requestToServer(request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    print("delete 성공")
                    return
                case .failure(let error):
                    print(error)
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellable)
    }
}
