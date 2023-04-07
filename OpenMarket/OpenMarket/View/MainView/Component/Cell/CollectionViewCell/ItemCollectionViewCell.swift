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
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.primary?.cgColor
        imageView.layer.borderWidth = Metric.borderWidth
        imageView.layer.cornerRadius = Metric.cornerRadius
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
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
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func showPrice(priceLabel: UILabel, bargainPriceLabel: UILabel, product: PageInformation) {
        priceLabel.text = "\(product.currency) \(product.price)"
        if product.discountedPrice == Metric.discountedPrice {
            bargainPriceLabel.isHidden = true
            priceLabel.textColor = .black
            priceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            priceLabel.attributedText = NSAttributedString(string: priceLabel.text  ?? "")
        } else {
            bargainPriceLabel.isHidden = false
            priceLabel.textColor = .systemGray
            priceLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            priceLabel.attributedText = priceLabel.text?.strikeThrough()
            bargainPriceLabel.text = "\(product.currency) \(product.bargainPrice)"
            bargainPriceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            bargainPriceLabel.textColor = .tertiary
        }
    }

    func showSoldOut(productStockQuantity: UILabel, product: PageInformation) {
        if product.stock == Metric.stock {
            productStockQuantity.text = CollectionViewNamespace.soldOut.name
            productStockQuantity.backgroundColor = .primary
        } else {
            productStockQuantity.text = "\(CollectionViewNamespace.remainingQuantity.name) \(product.stock)"
            productStockQuantity.backgroundColor = .clear
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
            } receiveValue: { [weak self] thumbnailImage in
                self?.productThumbnailImageView.image = thumbnailImage
            }.store(in: &cancellable)

        productNameLabel.text = product.name

        showPrice(priceLabel: productPriceLabel, bargainPriceLabel: bargainPriceLabel, product: product)
        showSoldOut(productStockQuantity: productStockQuantityLabel, product: product)
    }
}
