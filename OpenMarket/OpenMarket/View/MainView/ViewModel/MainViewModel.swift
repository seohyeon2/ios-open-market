//
//  MainViewModel.swift
//  OpenMarket
//
//  Created by unchain on 2023/03/13.
//

import Foundation
import Combine
import UIKit.NSDiffableDataSourceSectionSnapshot

protocol MainViewModelInputInterface {
    func getInformation(pageNumber: Int)
    func pushToDetailView(snapshot: NSDiffableDataSourceSnapshot<Section, MarketItem>, indexPath: IndexPath)
}

protocol MainViewModelOutputInterface {
    var marketInformationPublisher: AnyPublisher<MarketInformation, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var marketItemPublisher: AnyPublisher<MarketItem, Never> { get }
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
    private let marketItemSubject = PassthroughSubject<MarketItem, Never>()

    var marketInformationPublisher: AnyPublisher<MarketInformation, Never> {
        return marketInformationSubject.eraseToAnyPublisher()
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }

    var marketItemPublisher: AnyPublisher<MarketItem, Never> {
        return marketItemSubject.eraseToAnyPublisher()
    }

    private let networkManager = NetworkManager()

    private func getProductList(pageNumber: Int) {

        networkManager.getProductInquiry2(pageNumber: pageNumber)?
            .sink { completion in
                switch completion {
                case .finished:
                    print("성공")
                case .failure(let error):
                    self.alertSubject.send(error.message)
                }
            } receiveValue: { productList in
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

    func pushToDetailView(snapshot: NSDiffableDataSourceSnapshot<Section, MarketItem>, indexPath: IndexPath) {
        let product = snapshot.itemIdentifiers[indexPath.item]
        marketItemSubject.send(product)
    }
}
