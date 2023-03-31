//
//  ModificationViewModel.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/29.
//

import Foundation
import Combine

protocol ModificationViewModelInputInterface {
    func getMarketItem(_ item: MarketItem)
    func getProductImageData(_ data: Data)
}

protocol ModificationViewModelOutputInterface {
    var imageDataPublisher: AnyPublisher<Data, Never> { get }
}

protocol ModificationViewModelInterface {
    var input: ModificationViewModelInputInterface { get }
    var output: ModificationViewModelOutputInterface { get }
}

class ModificationViewModel: ModificationViewModelInterface, ModificationViewModelOutputInterface {
    var input: ModificationViewModelInputInterface { self }
    var output: ModificationViewModelOutputInterface { self }
    private var marketItem: MarketItem?
    private var imagesData = [Data]()

    @Published var productName: String = ""
    @Published var productDescription: String = ""
    @Published var productPrice: String = ""
    @Published var currency: Int = 0
    @Published var discountedPrice: String = ""
    @Published var stock: String = ""
   
    var imageDataPublisher: AnyPublisher<Data, Never> {
        return imageDataSubject.eraseToAnyPublisher()
    }
    
    private let imageDataSubject = PassthroughSubject <Data, Never>()
    private let secret = "lk1erfg241t8ygh0"
    private let networkManager = NetworkManager()
    
    func patchProduct() {
        guard let id = marketItem?.id else { return }
        let params: [String: Any?] = [
            Params.productName: productName,
            Params.productDescription: productDescription,
            Params.productPrice: Int(productPrice) ?? 0,
            Params.currency: choiceCurrency()?.name,
            Params.discountedPrice: Int(discountedPrice) ?? 0,
            Params.stock: Int(stock) ?? 0,
            Params.secret: secret
        ]
        
        networkManager.patchProduct(productId: id, modifiedInformation: params)
    }
    
    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: currency)
    }
}

extension ModificationViewModel: ModificationViewModelInputInterface {
    func getMarketItem(_ item: MarketItem) {
        marketItem = item
    }
    
    func getProductImageData(_ data: Data) {
        imageDataSubject.send(data)
        imagesData.append(data)
    }
}
