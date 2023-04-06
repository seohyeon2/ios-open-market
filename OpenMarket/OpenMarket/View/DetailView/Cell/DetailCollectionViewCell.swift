//
//  DetailCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit

final class DetailCollectionViewCell: UICollectionViewListCell {

    // MARK: Properties
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.isHidden = false
        pageControl.clipsToBounds = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let productPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let productStockQuantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = UIScreen.main.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let descriptionScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stockPriceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let totalDetailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: Method
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setDetailStackView()
        setDetailConstraints()
        
        imageScrollView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setDetailConstraints() {
        NSLayoutConstraint.activate([
            totalDetailStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.gridPositiveConstant),
            totalDetailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Metric.listNegativeConstant),
            totalDetailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Metric.listNegativeConstant),
            totalDetailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.gridPositiveConstant),

            imageScrollView.widthAnchor.constraint(equalTo: totalDetailStackView.widthAnchor, multiplier: 1),
            imageScrollView.heightAnchor.constraint(equalTo: totalDetailStackView.heightAnchor, multiplier: 0.4),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionScrollView.topAnchor, constant: Metric.gridPositiveConstant),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Metric.listNegativeConstant),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionScrollView.bottomAnchor, constant: Metric.listNegativeConstant),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.gridPositiveConstant),

            pageControl.centerXAnchor.constraint(equalTo: imageScrollView.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: imageScrollView.topAnchor, constant: 250),
            pageControl.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor)
        ])
    }

    private func setDetailStackView() {
        contentView.addSubview(totalDetailStackView)
        contentView.addSubview(pageControl)
        totalDetailStackView.addArrangedSubview(imageScrollView)
        totalDetailStackView.addArrangedSubview(labelStackView)
        totalDetailStackView.addArrangedSubview(descriptionScrollView)

        descriptionScrollView.addSubview(descriptionLabel)

        labelStackView.addArrangedSubview(productNameLabel)
        labelStackView.addArrangedSubview(stockPriceStackView)

        stockPriceStackView.addArrangedSubview(productStockQuantityLabel)
        stockPriceStackView.addArrangedSubview(productPriceLabel)
        stockPriceStackView.addArrangedSubview(bargainPriceLabel)
    }

   func configureLabel(product: MarketItem) {
        self.productNameLabel.text = product.name
        self.descriptionLabel.text = product.description
        showPrice(priceLabel: self.productPriceLabel, bargainPriceLabel: self.bargainPriceLabel, product: product)
        showSoldOut(productStockQuantity: self.productStockQuantityLabel, product: product)
    }
    
    func configureImage(imageData: Data, index: Int, total: Int) {
        let imageView = UIImageView()
        let positionX = (imageScrollView.frame.width) * CGFloat(index)

        imageView.frame = CGRect(
            x: positionX,
            y: 0,
            width: imageScrollView.frame.width,
            height: imageScrollView.frame.height
        )
        imageView.image = UIImage(data: imageData)
        imageScrollView.addSubview(imageView)
        imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(total)
    }

    func showPrice(priceLabel: UILabel, bargainPriceLabel: UILabel, product: MarketItem) {
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

    func showSoldOut(productStockQuantity: UILabel, product: MarketItem) {
        if product.stock == Metric.stock {
            productStockQuantity.text = CollectionViewNamespace.soldOut.name
            productStockQuantity.textColor = .systemOrange
        } else {
            productStockQuantity.text = "\(CollectionViewNamespace.remainingQuantity.name) \(product.stock)"
            productStockQuantity.textColor = .systemGray
        }
    }
}

extension DetailCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let totalWidth = scrollView.contentSize.width
        let currentScrollPosition = scrollView.contentOffset.x
        
        pageControl.currentPage = Int((currentScrollPosition / totalWidth) * CGFloat(pageControl.numberOfPages))
    }
}
