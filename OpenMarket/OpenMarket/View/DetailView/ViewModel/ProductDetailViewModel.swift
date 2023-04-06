//
//  ProductDetailViewModel.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/22.
//

import Combine
import Foundation

protocol ProductDetailViewModelInputInterface {
    func getMarketItem(_ id: Int)
}

protocol ProductDetailViewModelOutputInterface {
    var detailMarketItemPublisher: AnyPublisher<MarketItem, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var movementPublisher: AnyPublisher<Bool, Never> { get }
    
    func getImagePublisher() -> [AnyPublisher<Data, NetworkError>]?
    func deleteProduct()
}

protocol ProductDetailViewModelInterface {
    var input: ProductDetailViewModelInputInterface { get }
    var output: ProductDetailViewModelOutputInterface { get }
}

final class ProductDetailViewModel: ProductDetailViewModelInterface, ProductDetailViewModelOutputInterface {

    var detailMarketItemPublisher: AnyPublisher<MarketItem, Never> {
        return detailMarketItemSubject.eraseToAnyPublisher()
    }
    
    var input: ProductDetailViewModelInputInterface { self }
    var output: ProductDetailViewModelOutputInterface { self }
    
    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    var movementPublisher: AnyPublisher<Bool, Never> {
        return movementSubject.eraseToAnyPublisher()
    }

    private let networkManager = NetworkManager()
    private let detailMarketItemSubject = PassthroughSubject<MarketItem, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let movementSubject = PassthroughSubject<Bool, Never>()
    private var cancellable = Set<AnyCancellable>()
    var marketItem : MarketItem?

    private func getProductDetail(id: Int) {
        guard let request = try? ProductRequest.detailItem(id).createURLRequest() else { return }

        networkManager.requestToServer(request: request)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.alertSubject.send(error.message)
                }
            } receiveValue: { [weak self] data in
                guard let self = self,
                      let marketItem = try? JSONDecoder().decode(MarketItem.self, from: data) else {
                    return
                }
                self.detailMarketItemSubject.send(marketItem)
                self.marketItem = marketItem
            }
            .store(in: &cancellable)
    }
    
    func getImagePublisher() -> [AnyPublisher<Data, NetworkError>]? {
        guard let images = marketItem?.images else {
            return nil
        }
        
        return images.map { image -> AnyPublisher<Data, NetworkError> in
           let url = URL(string: image.url)
                return networkManager.requestToServer(request: URLRequest(url: url!, httpMethod: .get))
        }
    }
    
    func deleteProduct() {
        networkManager.deleteProduct(productId: marketItem?.id)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("delete 성공")
                    return
                case .failure(let error):
                    self?.alertSubject.send(error.message)
                    return
                }
            } receiveValue: { [weak self] _ in
                self?.movementSubject.send(true)
            }
            .store(in: &cancellable)
    }
}

extension ProductDetailViewModel: ProductDetailViewModelInputInterface {
    func getMarketItem(_ id: Int) {
        getProductDetail(id: id)
    }
}
