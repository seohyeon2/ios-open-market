//
//  ProductDetailViewModel.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/22.
//

import Combine
import Foundation
import Alamofire

protocol ProductDetailViewModelInputInterface {
    func getMarketItem(_ id: Int)
    func deleteProduct()
    func isLoggedInUserItem() -> Bool
}

protocol ProductDetailViewModelOutputInterface {
    var detailMarketItemPublisher: AnyPublisher<MarketItem, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var movementPublisher: AnyPublisher<Bool, Never> { get }
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
        guard let request = try? ProductRequest.detailItem(id).createURLRequest() else {
            alertSubject.send("해당 상품에 대한 정보를 불러올 수 없습니다.😭")
            return
        }
        
        AF.request(request)
            .responseDecodable(of: MarketItem.self) { [weak self] response in
                if let marketItem = response.value {
                    self?.detailMarketItemSubject.send(marketItem)
                    self?.marketItem = marketItem
                } else {
                    self?.alertSubject.send(
                        response.error?.localizedDescription ??
                        "해당 상품에 대한 정보를 불러올 수 없습니다.😭"
                    )
                }
            }
    }
}

extension ProductDetailViewModel: ProductDetailViewModelInputInterface {
    func getMarketItem(_ id: Int) {
        getProductDetail(id: id)
    }

    func deleteProduct() {
        networkManager.deleteProduct(productId: marketItem?.id)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
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
    
    func isLoggedInUserItem() -> Bool {
        if let loggedInUserName = UserDefaults.standard.string(forKey: "loggedInUserName"),
           marketItem?.vendors.name == loggedInUserName {
            return true
        }
        
        return false
    }
}
