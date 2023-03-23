//
//  ProductDetailViewModel.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/22.
//

import Combine

protocol ProductDetailViewModelInputInterface {
    func getMarketItem(_ id: Int)
    func pushToModificationView()
}

protocol ProductDetailViewModelOutputInterface {
    var detailMarketItem: Just<MarketItem>? { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
}

protocol ProductDetailViewModelInterface {
    var input: ProductDetailViewModelInputInterface { get }
    var output: ProductDetailViewModelOutputInterface { get }
}

final class ProductDetailViewModel: ProductDetailViewModelInterface, ProductDetailViewModelOutputInterface {
    var detailMarketItem: Just<MarketItem>?
    
    var input: ProductDetailViewModelInputInterface { self }
    var output: ProductDetailViewModelOutputInterface { self }
    
    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    
    private var marketItem: MarketItem?
    private let networkManager = NetworkManager()
    private let alertSubject = PassthroughSubject<String, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    private func getProductDetail(id: Int) {
        guard let request = try? ProductRequest.item(id).createURLRequest() else { return }
        
        networkManager.requestToServer(type: MarketItem.self, request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    print("❤️")
                case .failure(let error):
                    print("❤️❤️")
                    self.alertSubject.send(error.message)
                }
        } receiveValue: { [weak self] marketItem in
            self?.marketItem = marketItem
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
