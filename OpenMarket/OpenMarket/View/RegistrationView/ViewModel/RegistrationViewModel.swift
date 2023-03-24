//
//  RegistrationViewModel.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/23.
//

import Foundation
import Combine

class RegistrationViewModel {
    @Published var productName: String = ""
    @Published var productDescription: String = ""
    @Published var productPrice: String = ""
    @Published var currency: Int = 0
    @Published var discountedPrice: String = ""
    @Published var stock: String = ""
    @Published var images: Data?
    
    private let secret = "lk1erfg241t8ygh0"
    
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
        
        print(params)
    }
    
    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: currency)
    }
}
