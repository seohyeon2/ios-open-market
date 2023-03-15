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
}

protocol MainViewModelOutputInterface {
    var marketInformationPublisher: PassthroughSubject<MarketInformation, Never> { get }
    var isLoadingPublisher: PassthroughSubject<Bool, Never> { get }
    var alertPublisher: PassthroughSubject<String, Never> { get }
}

protocol MainViewModelInterface {
    var input: MainViewModelInputInterface { get }
    var output: MainViewModelOutputInterface { get }
}

final class MainViewModel: MainViewModelInterface, MainViewModelOutputInterface {
    var input: MainViewModelInputInterface { self }
    var output: MainViewModelOutputInterface { self }

    var marketInformationPublisher = PassthroughSubject<MarketInformation, Never>()
    var isLoadingPublisher = PassthroughSubject<Bool, Never>()
    var alertPublisher = PassthroughSubject<String, Never>()


    private let networkManager = NetworkManager()

    private func getProductList(pageNumber: Int) {
        networkManager.getProductInquiry(pageNumber: pageNumber) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                guard let productList = try? JSONDecoder().decode(MarketInformation.self, from: data) else { return }
                self.isLoadingPublisher.send(true)
                self.marketInformationPublisher
                    .send(productList)
                self.isLoadingPublisher.send(false)
            case .failure(let error):
                print(error.localizedDescription)
                self.alertPublisher.send(error.localizedDescription)
            }
        }
    }
}

extension MainViewModel: MainViewModelInputInterface {
    func getInformation(pageNumber: Int) {
        getProductList(pageNumber: pageNumber)
    }
}
