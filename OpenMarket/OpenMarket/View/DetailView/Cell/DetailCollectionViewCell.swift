//
//  DetailCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit
import Combine

final class DetailCollectionViewCell: UICollectionViewListCell {
    var cancellable = Set<AnyCancellable>()

    // MARK: Properties
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.isHidden = false
        pageControl.clipsToBounds = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = UIColor.primary
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let userStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 3
        label.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
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

    private let imageScrollView: UIScrollView = {
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
        stackView.alignment = .trailing
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
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

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        setDetailStackView()
        setDetailConstraints()
        
        imageScrollView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Configure UI Method (None Private)
    func configureCell(product: MarketItem) {
        product.images.enumerated().forEach { [weak self] index, itemImage in
            self?.configureImage(
                image: itemImage,
                index: index,
                total: product.images.count
            )
        }
        configureLabel(product: product)
        pageControl.numberOfPages = product.images.count
    }
    
    // MARK: Configure UI Method (Private)
    private func setDetailStackView() {
        contentView.addSubview(totalDetailStackView)
        contentView.addSubview(pageControl)
        totalDetailStackView.addArrangedSubview(imageScrollView)
        totalDetailStackView.addArrangedSubview(userStackView)
        totalDetailStackView.addArrangedSubview(labelStackView)
        totalDetailStackView.addArrangedSubview(descriptionScrollView)

        userStackView.addArrangedSubview(userImageView)
        userStackView.addArrangedSubview(userNameLabel)

        labelStackView.addArrangedSubview(productNameLabel)
        labelStackView.addArrangedSubview(stockPriceStackView)

        stockPriceStackView.addArrangedSubview(productStockQuantityLabel)
        stockPriceStackView.addArrangedSubview(productPriceLabel)
        stockPriceStackView.addArrangedSubview(bargainPriceLabel)
        
        descriptionScrollView.addSubview(descriptionLabel)
        descriptionScrollView.layer.addBorder(
            frame: CGRect(
                x: 0,
                y: 0,
                width: frame.width - 10,
                height: 1
            )
        )
    }

    private func setDetailConstraints() {
        NSLayoutConstraint.activate([
            totalDetailStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metric.gridPositiveConstant
            ),
            totalDetailStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: Metric.listNegativeConstant
            ),
            totalDetailStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Metric.listNegativeConstant
            ),
            totalDetailStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metric.gridPositiveConstant
            ),

            imageScrollView.widthAnchor.constraint(
                equalTo: totalDetailStackView.widthAnchor,
                multiplier: 1
            ),
            imageScrollView.heightAnchor.constraint(
                equalTo: totalDetailStackView.heightAnchor,
                multiplier: 0.4
            ),
            
            userImageView.widthAnchor.constraint(
                equalToConstant: 40
            ),
            userImageView.heightAnchor.constraint(
                equalToConstant: 40
            ),
            
            descriptionLabel.topAnchor.constraint(
                equalTo: descriptionScrollView.topAnchor,
                constant: Metric.gridPositiveConstant
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: Metric.listNegativeConstant
            ),
            descriptionLabel.bottomAnchor.constraint(
                equalTo: descriptionScrollView.bottomAnchor,
                constant: Metric.listNegativeConstant
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metric.gridPositiveConstant
            ),

            pageControl.centerXAnchor.constraint(
                equalTo: imageScrollView.centerXAnchor
            ),
            pageControl.topAnchor.constraint(
                equalTo: imageScrollView.topAnchor,
                constant: 250
            ),
            pageControl.bottomAnchor.constraint(
                equalTo: imageScrollView.bottomAnchor
            )
        ])
    }

    private func configureImage(
        image: ItemImage,
        index: Int,
        total: Int
    ) {
        guard let url = URL(string: image.url) else {
            return
        }
        
        ImageCache.shared.load(url: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    return
                }
            } receiveValue: { [weak self] image in
                let imageView = UIImageView()
                let positionX = (self?.imageScrollView.frame.width ?? 1) * CGFloat(index)
                
                imageView.frame = CGRect(
                    x: positionX,
                    y: 0,
                    width: self?.imageScrollView.frame.width ?? 1,
                    height: self?.imageScrollView.frame.height ?? 1
                )
                imageView.image = image
                self?.imageScrollView.addSubview(imageView)
                self?.imageScrollView.contentSize.width = (self?.imageScrollView.frame.width ?? 1) * CGFloat(total)
            }
            .store(in: &cancellable)
    }
    
    private func configureLabel(product: MarketItem) {
        self.userNameLabel.text = product.vendors.name
        self.productNameLabel.text = product.name
        self.descriptionLabel.text = product.description

        showPrice(
            priceLabel: self.productPriceLabel,
            bargainPriceLabel: self.bargainPriceLabel,
            product: product
        )
        showStockQuantity(
            productStockQuantity: self.productStockQuantityLabel,
            product: product
        )
    }

    private func showPrice(
        priceLabel: UILabel,
        bargainPriceLabel: UILabel,
        product: MarketItem
    ) {
        if product.currency == Currency.KRW.name {
            let price = Int(product.price)
            let bargainPrice = Int(product.bargainPrice)
            priceLabel.text = "\(product.currency) \(price)"
            bargainPriceLabel.text = "\(product.currency) \(bargainPrice)"
        } else {
            priceLabel.text = "\(product.currency) \(product.price)"
            bargainPriceLabel.text = "\(product.currency) \(product.bargainPrice)"
        }
        
        if product.discountedPrice == Metric.discountedPrice {
            bargainPriceLabel.isHidden = true
            priceLabel.textColor = .black
            priceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            priceLabel.attributedText = NSAttributedString(string: priceLabel.text  ?? "")
        } else {
            bargainPriceLabel.isHidden = false
            bargainPriceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            bargainPriceLabel.textColor = .tertiary
            priceLabel.textColor = .systemGray
            priceLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            priceLabel.attributedText = priceLabel.text?.strikeThrough()
        }
    }

    private func showStockQuantity(
        productStockQuantity: UILabel,
        product: MarketItem
    ) {
        if product.stock == Metric.stockZero {
            let attributedString = NSMutableAttributedString()
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: "soldOut")
            imageAttachment.bounds = CGRect(
                x: 0,
                y: 0,
                width: 42,
                height: 18
            )
            attributedString.append(
                NSAttributedString(attachment: imageAttachment)
            )
            productStockQuantity.attributedText = attributedString
            productStockQuantity.sizeToFit()
        } else {
            productStockQuantity.text = "\(CollectionViewNamespace.remainingQuantity.name) \(product.stock)"
            productStockQuantity.backgroundColor = .clear
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
