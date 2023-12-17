//
//  MainViewModel.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/13.
//

import Foundation
import Combine
import Alamofire

protocol MainViewModelInputInterface {
    func getInformation()
    func increaseProductPageNumber()
    func initializeProductPageNumber()
    func pushToDetailView(indexPath: IndexPath, id:Int)
}

protocol MainViewModelOutputInterface {
    var marketInformationPublisher: AnyPublisher<MarketInformation, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var marketItemIdPublisher: AnyPublisher<Int, Never> { get }
}

protocol MainViewModelInterface {
    var input: MainViewModelInputInterface { get }
    var output: MainViewModelOutputInterface { get }
}

final class MainViewModel: MainViewModelInterface, MainViewModelOutputInterface {
    var input: MainViewModelInputInterface { self }
    var output: MainViewModelOutputInterface { self }

    var marketInformationPublisher: AnyPublisher<MarketInformation, Never> {
        return marketInformationSubject.eraseToAnyPublisher()
    }
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }
    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    var marketItemIdPublisher: AnyPublisher<Int, Never> {
        return marketItemIdSubject.eraseToAnyPublisher()
    }

    private var productPageNumber = Metric.firstPage
    private let marketInformationSubject = PassthroughSubject<MarketInformation, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let marketItemIdSubject = PassthroughSubject<Int, Never>()

    private func getProductList(pageNumber: Int) {
        guard let request = try? ProductRequest.list(page: pageNumber).createURLRequest() else {
            alertSubject.send("상품을 불러올 수 없습니다.😭")
            return
        }
        
        AF.request(request)
            .responseDecodable(of: MarketInformation.self) { [weak self] response in
                
                if let productList = response.value {
                    self?.isLoadingSubject.send(true)
                    self?.marketInformationSubject.send(productList)
                    self?.isLoadingSubject.send(false)
                } else {
                    self?.alertSubject.send(response.error?.localizedDescription ?? "상품을 불러올 수 없습니다.😭")
                }
            }
    }
}

extension MainViewModel: MainViewModelInputInterface {
    func getInformation() {
        getProductList(pageNumber: productPageNumber)
    }
    
    func increaseProductPageNumber() {
        productPageNumber += 1
    }
    
    func initializeProductPageNumber() {
        productPageNumber = 1
    }
    
    func pushToDetailView(indexPath: IndexPath, id:Int) {
        marketItemIdSubject.send(id)
    }
}
