//
//  RegistrationEditViewModel.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/31.
//

import Foundation
import Combine

protocol RegistrationEditViewModelInputInterface {
    func getProductImageData(_ data: Data)
}

protocol RegistrationEditViewModelOutputInterface {
    var imageDataPublisher: AnyPublisher<Data, Never> { get }
}

protocol RegistrationEditViewModelInterface {
    var input: RegistrationEditViewModelInputInterface { get }
    var output: RegistrationEditViewModelOutputInterface { get }
}

final class RegistrationEditViewModel: RegistrationEditViewModelInterface,
                                 RegistrationEditViewModelOutputInterface {
    var input: RegistrationEditViewModelInputInterface { self }
    var output: RegistrationEditViewModelOutputInterface { self }
    var marketItem: MarketItem?
    private var imagesData = [Data]()


    init(marketItem: MarketItem?) {
        self.marketItem = marketItem
    }

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
    
    func registerProduct() {
        let params: [String: Any?] = [
            Params.productName: productName,
            Params.productDescription: productDescription,
            Params.productPrice: Int(productPrice) ?? 0,
            Params.currency: choiceCurrency()?.name,
            Params.discountedPrice: Int(discountedPrice) ?? 0,
            Params.stock: Int(stock) ?? 0,
            Params.secret: secret
        ]

        networkManager.postProduct(params: params,
                                   imageData: imagesData)
    }
    
    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: currency)
    }
}

extension RegistrationEditViewModel: RegistrationEditViewModelInputInterface {
    func getProductImageData(_ data: Data) {
        imageDataSubject.send(data)
        imagesData.append(data)
    }
}
