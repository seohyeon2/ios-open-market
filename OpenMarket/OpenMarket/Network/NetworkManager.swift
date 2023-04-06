//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//

import UIKit
import Combine

final class NetworkManager {
    
    private let session: URLSessionProtocol
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

    func deleteProduct(productId: Int?) -> AnyPublisher<Data, NetworkError> {
        guard let productId = productId,
              var request = try? ProductRequest.deleteURL(productId).createURLRequest() else {
            return Fail<Data, NetworkError>(error: .failToResponse)
                .eraseToAnyPublisher()
        }

        request.httpBody = OpenMarketRequest.createJson(params: [Params.secret: APIConstants.secret])

        return requestToServer(request: request)
            .flatMap({ urlData -> AnyPublisher<Data, NetworkError> in

                guard let url = String(data: urlData, encoding: .utf8),
                      let deleteRequest = try? ProductRequest.delete(url: url).createURLRequest() else {
                    return Fail(error: NetworkError.noneData).eraseToAnyPublisher()
                              }
                return self.requestToServer(request: deleteRequest)
            })
            .eraseToAnyPublisher()
    }
}
