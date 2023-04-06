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
    var alertPublisher: AnyPublisher<String, Never> { get }
    var movementPublisher: AnyPublisher<Int, Never> { get }
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
    
    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    var movementPublisher: AnyPublisher<Int, Never> {
        return movementSubject.eraseToAnyPublisher()
    }
    private let alertSubject = PassthroughSubject<String, Never>()
    private let movementSubject = PassthroughSubject<Int, Never>()
    
    
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
    private var cancellable = Set<AnyCancellable>()
    
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
        
        var request: URLRequest?
        if marketItem == nil {
            request = networkManager.getPostRequest(params: params,
                                                 imageData: imagesData)
        } else {
            request = networkManager.getPatchRequest(productId: marketItem?.id ?? 0, modifiedInformation: params)
        }
        
        guard let request = request else {
            return
        }
        
        networkManager.registerEditProduct(request: request)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("생성 및 수정성공")
                    return
                case .failure(let error):
                    self?.alertSubject.send(error.message)
                    return
                }
            } receiveValue: { [weak self] response in
                
                guard let marketItem = try? JSONDecoder().decode(MarketItem.self, from: response) else { return }
                
                self?.movementSubject.send(marketItem.id)
            }
            .store(in: &cancellable)
    }
    
    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: currency)
    }
}

extension RegistrationEditViewModel: RegistrationEditViewModelInputInterface {
    func getProductImageData(_ data: Data) {
        guard imagesData.count < 5 else { return }

        imageDataSubject.send(data)
        imagesData.append(data)
    }
}
