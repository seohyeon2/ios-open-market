//
//  RegistrationViewModel.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/23.
//

import Foundation
import Combine

protocol RegistrationViewModelInputInterface {
    func getProductImageData(_ data: Data)
}

protocol RegistrationViewModelOutputInterface {
    var imageDataPublisher: AnyPublisher<Data, Never> { get }
}

protocol RegistrationViewModelInterface {
    var input: RegistrationViewModelInputInterface { get }
    var output: RegistrationViewModelOutputInterface { get }
}

class RegistrationViewModel: RegistrationViewModelInterface, RegistrationViewModelOutputInterface {
    var input: RegistrationViewModelInputInterface { self }
    var output: RegistrationViewModelOutputInterface { self }
    
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
    }
    
    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: currency)
    }
}

extension RegistrationViewModel: RegistrationViewModelInputInterface {
    func getProductImageData(_ data: Data) {
        imageDataSubject.send(data)
    }
}
