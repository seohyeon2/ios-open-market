//
//  RegistrationEditViewModel.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/31.
//

import Foundation
import Combine
import Alamofire

protocol RegistrationEditViewModelInputInterface {
    func tappedDoneButton()
    func increaseDeleteButtonTagNumber()
    func getProductImageData(_ data: Data)
    func tappedXMarkButton(_ sender: Int)
}

protocol RegistrationEditViewModelOutputInterface {
    var imageDataPublisher: AnyPublisher<Data, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var movementPublisher: AnyPublisher<Int, Never> { get }
    
    func getDeleteButtonTagNumber() -> Int
}

protocol RegistrationEditViewModelInterface {
    var input: RegistrationEditViewModelInputInterface { get }
    var output: RegistrationEditViewModelOutputInterface { get }
}

final class RegistrationEditViewModel: RegistrationEditViewModelInterface, RegistrationEditViewModelOutputInterface {
    @Published var productName: String
    @Published var productDescription: String
    @Published var productPrice: String
    @Published var currency: Int
    @Published var discountedPrice: String
    @Published var stock: String
    
    var input: RegistrationEditViewModelInputInterface { self }
    var output: RegistrationEditViewModelOutputInterface { self }
    
    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    var movementPublisher: AnyPublisher<Int, Never> {
        return movementSubject.eraseToAnyPublisher()
    }
    var imageDataPublisher: AnyPublisher<Data, Never> {
        return imageDataSubject.eraseToAnyPublisher()
    }
    
    private(set) var marketItem: MarketItem?
    private var imagesData = [Data]()
    private var tagNumber = 0
    private var cancellable = Set<AnyCancellable>()
    
    private let alertSubject = PassthroughSubject<String, Never>()
    private let movementSubject = PassthroughSubject<Int, Never>()
    private let imageDataSubject = PassthroughSubject <Data, Never>()
    private let networkManager = NetworkManager()
    
    init(marketItem: MarketItem?) {
        self.marketItem = marketItem
        
        productName = marketItem?.name ?? ""
        productDescription = marketItem?.description ?? ""
        productPrice = String(marketItem?.price ?? 0)
        currency = 0
        discountedPrice = String(marketItem?.discountedPrice ?? 0)
        stock = String(marketItem?.stock ?? 0)
    }
    
    func getDeleteButtonTagNumber() -> Int {
        return tagNumber
    }

    private func performProductRegistration() {
        let params = createParams()
        
        guard let request = createRequest(params: params) else {
            alertSubject.send("상품 등록에 실패했습니다.😭")
            return
        }

        AF.request(request)
            .validate()
            .responseDecodable(of: MarketItem.self) { [weak self] response in
                switch response.result {
                case .success(let marketItem):
                    self?.movementSubject.send(marketItem.id)
                case .failure(let error):
                    self?.alertSubject.send(error.localizedDescription)
                }
            }
    }
    
    private func createParams() -> [String: Any?] {
        return [
            Params.productName: productName,
            Params.productDescription: productDescription,
            Params.productPrice: Double(productPrice) ?? 0,
            Params.currency: choiceCurrency()?.name,
            Params.discountedPrice: Double(discountedPrice) ?? 0,
            Params.stock: Int(stock) ?? 0,
            Params.secret: APIConstants.secret
        ]
    }
    
    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: currency)
    }

    private func createRequest(params: [String: Any?]) -> URLRequest? {
        if marketItem == nil {
            return networkManager.getPostRequest(
                params: params,
                imageData: imagesData
            )
        } else {
            return networkManager.getPatchRequest(
                productId: marketItem?.id ?? 0,
                modifiedInformation: params
            )
        }
    }
}

extension RegistrationEditViewModel: RegistrationEditViewModelInputInterface {
    func tappedDoneButton() {
        performProductRegistration()
    }
    
    func increaseDeleteButtonTagNumber() {
        tagNumber += 1
    }
    
    func getProductImageData(_ data: Data) {
        guard imagesData.count < 5 else { return }

        imageDataSubject.send(data)
        imagesData.append(data)
    }

    func tappedXMarkButton(_ sender: Int) {
        imagesData.remove(at: sender)
        tagNumber -= 1
    }
}
