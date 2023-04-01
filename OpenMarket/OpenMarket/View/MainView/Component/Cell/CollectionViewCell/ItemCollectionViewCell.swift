//
//  ItemCollectionViewCell.swift
//  OpenMarket
//
//  Created by seohyeon park on 2022/07/22.
//

import UIKit
import Combine

class ItemCollectionViewCell: UICollectionViewListCell {
    var cancellable = Set<AnyCancellable>()

    // MARK: Properties

    let productThumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let productPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let productStockQuantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func showPrice(priceLabel: UILabel, bargainPriceLabel: UILabel, product: PageInformation) {
        priceLabel.text = "\(product.currency) \(product.price)"
        if product.discountedPrice == Metric.discountedPrice {
            priceLabel.textColor = .systemGray
            bargainPriceLabel.isHidden = true
        } else {
            bargainPriceLabel.isHidden = false
            priceLabel.textColor = .systemRed
            priceLabel.attributedText = priceLabel.text?.strikeThrough()
            bargainPriceLabel.text = "\(product.currency) \(product.bargainPrice)"
            bargainPriceLabel.textColor = .systemGray
        }
    }

    func showSoldOut(productStockQuantity: UILabel, product: PageInformation) {
        if product.stock == Metric.stock {
            productStockQuantity.text = CollectionViewNamespace.soldOut.name
            productStockQuantity.textColor = .systemOrange
        } else {
            productStockQuantity.text = "\(CollectionViewNamespace.remainingQuantity.name) \(product.stock)"
            productStockQuantity.textColor = .systemGray
        }
    }

    func configureCell(product: PageInformation) {
        guard let url = URL(string: product.thumbnail) else { return }

        ImageCache.shared.load(url: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    return
                }
            } receiveValue: { thumbnailImage in
                self.productThumbnailImageView.image = thumbnailImage
            }.store(in: &cancellable)

        self.productNameLabel.text = product.name

        showPrice(priceLabel: self.productPriceLabel, bargainPriceLabel: self.bargainPriceLabel, product: product)
        showSoldOut(productStockQuantity: self.productStockQuantityLabel, product: product)
    }
}
