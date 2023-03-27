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
    func pushToModificationView()
}

protocol ProductDetailViewModelOutputInterface {
    var detailMarketItem: Just<MarketItem>? { get }
    var detailMarketItemPublisher: AnyPublisher<MarketItem, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
}

protocol ProductDetailViewModelInterface {
    var input: ProductDetailViewModelInputInterface { get }
    var output: ProductDetailViewModelOutputInterface { get }
}

final class ProductDetailViewModel: ProductDetailViewModelInterface, ProductDetailViewModelOutputInterface {
    var detailMarketItem: Just<MarketItem>?
    
    var detailMarketItemPublisher: AnyPublisher<MarketItem, Never> {
        return detailMarketItemSubject.eraseToAnyPublisher()
    }
    
    var input: ProductDetailViewModelInputInterface { self }
    var output: ProductDetailViewModelOutputInterface { self }
    
    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }

    private let networkManager = NetworkManager()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let detailMarketItemSubject = PassthroughSubject<MarketItem, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    private func getProductDetail(id: Int) {
        guard let request = try? ProductRequest.detailItem(id).createURLRequest() else { return }
        
//        networkManager.requestToServer(type: MarketItem.self, request: request)
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    return
//                case .failure(let error):
//                    self.alertSubject.send(error.message)
//                }
//        } receiveValue: { [weak self] marketItem in
//            self?.detailMarketItemSubject.send(marketItem)
//        }
//        .store(in: &cancellable)
        
        networkManager.requestToServer2(request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self.alertSubject.send(error.message)
                }
            } receiveValue: { [weak self] data in
                guard let marketItem = try? JSONDecoder().decode(MarketItem.self, from: data) else {
                    return
                }
                
                self?.detailMarketItemSubject.send(marketItem)
                
            }
            .store(in: &cancellable)
    }
}

extension ProductDetailViewModel: ProductDetailViewModelInputInterface {
    func getMarketItem(_ id: Int) {
        getProductDetail(id: id)
    }
    
    func pushToModificationView() {
        
    }
}
