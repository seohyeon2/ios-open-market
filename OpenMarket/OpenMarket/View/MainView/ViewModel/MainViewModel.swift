//
//  MainViewModel.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/13.
//

import Foundation
import Combine

protocol MainViewModelInputInterface {
    func getInformation(pageNumber: Int)
    func pushToDetailView(indexPath: IndexPath, id:Int)
    var didScrollSubject: PassthroughSubject<Bool, Never> { get }
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
    
    var indexPath: IndexPath?

    private var cancellable = Set<AnyCancellable>()
    private let marketInformationSubject = PassthroughSubject<MarketInformation, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let marketItemIdSubject = PassthroughSubject<Int, Never>()
    let didScrollSubject = PassthroughSubject<Bool, Never>()
    
    private var productPageNumber = 1
    
    private var didScrollPublisher: AnyPublisher<Bool, Never> {
        return didScrollSubject.eraseToAnyPublisher()
    }
    
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

    private let networkManager = NetworkManager()

    
    private func bind() {
        didScrollPublisher
            .sink { [weak self] isScroll in
                guard let self = self else {
                    return
                }
                if isScroll {
                    self.productPageNumber += 1
                } else {
                    self.productPageNumber = 1
                }
                
                self.getProductList(pageNumber: self.productPageNumber)
            }
            .store(in: &cancellable)
    }
    
    private func getProductList(pageNumber: Int) {

        networkManager.getProductInquiry(pageNumber: pageNumber)?
            .decode(type: MarketInformation.self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    guard let error = error as? NetworkError else { return }
                    self?.alertSubject.send(error.message)
                }
            } receiveValue: { [weak self] productList in
                guard let self = self else { return }
                self.isLoadingSubject.send(true)
                self.marketInformationSubject.send(productList)
                self.isLoadingSubject.send(false)
            }
            .store(in: &cancellable)
    }
}

extension MainViewModel: MainViewModelInputInterface {
    func getInformation(pageNumber: Int) {
        
        getProductList(pageNumber: pageNumber)

    }

    func pushToDetailView(indexPath: IndexPath, id:Int) {
        marketItemIdSubject.send(id)
    }
}
