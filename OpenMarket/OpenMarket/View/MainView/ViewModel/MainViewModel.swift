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

    private var cancellable = Set<AnyCancellable>()
    private let marketInformationSubject = PassthroughSubject<MarketInformation, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let marketItemIdSubject = PassthroughSubject<Int, Never>()

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

    private func getProductList(pageNumber: Int) {

        networkManager.getProductInquiry(pageNumber: pageNumber)?
            .decode(type: MarketInformation.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    guard let error = error as? NetworkError else { return }
                    self.alertSubject.send(error.message)
                }
            } receiveValue: { [weak self] productList in
                guard let self else { return }
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
