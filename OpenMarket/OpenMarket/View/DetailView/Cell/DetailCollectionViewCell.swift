//
//  DetailCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit

class DetailCollectionViewCell: ItemCollectionViewCell, UIScrollViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageScrollView.delegate = self
        setDetailStackView()
        setDetailConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Properties
    var productImages = [UIImage]()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.backgroundColor = .yellow
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = UIScreen.main.bounds
        scrollView.backgroundColor = .orange
        scrollView.contentSize = CGSize(width: 500, height: 500)
        scrollView.showsHorizontalScrollIndicator = true
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
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.gridPositiveConstant)
        ])
    }
    
    private func setDetailStackView() {
        contentView.addSubview(totalDetailStackView)
        totalDetailStackView.addArrangedSubview(imageScrollView)
        totalDetailStackView.addArrangedSubview(labelStackView)
        totalDetailStackView.addArrangedSubview(descriptionScrollView)
        
        descriptionScrollView.addSubview(descriptionLabel)
        
        imageScrollView.addSubview(productThumbnailImageView)
        imageScrollView.addSubview(pageControl)
        
        labelStackView.addArrangedSubview(productNameLabel)
        labelStackView.addArrangedSubview(stockPriceStackView)
        
        stockPriceStackView.addArrangedSubview(productStockQuntityLabel)
        stockPriceStackView.addArrangedSubview(productPriceLabel)
        stockPriceStackView.addArrangedSubview(bargainPriceLabel)
    }
    
    override func configureCell(product: MarketItem, completion: @escaping (Result<Data, Error>) -> Void) {
        (0..<(product.images?.count ?? 0)).forEach { index in
            guard let image = product.images?[index] else { return }
            guard let url = URL(string: image.url) else { return }
            
            NetworkManager().networkPerform(for: URLRequest(url: url)) { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else { return }
                    self.productImages.append(image)
                    
                    DispatchQueue.main.async {
                        self.productThumbnailImageView.image = image
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        self.productNameLabel.text = product.name
        self.descriptionLabel.text = product.description
        showPrice(priceLabel: self.productPriceLabel, bargainPriceLabel: self.bargainPriceLabel, product: product)
        showSoldOut(productStockQuntity: self.productStockQuntityLabel, product: product)
        
    }
}
