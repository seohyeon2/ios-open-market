//
//  GridCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/20.
//

import UIKit

final class GridCollectionViewCell: ItemCollectionViewCell {
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(totalGridStackView)
        setGridStackView()
        setGridConstraints()
        
        self.layer.cornerRadius = Metric.cornerRadius
        self.layer.borderWidth = Metric.borderWidth
        self.layer.borderColor = UIColor.primary?.cgColor
        productThumbnailImageView.layer.borderWidth = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Properties
    
    private let totalGridStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Method
    
    private func setGridStackView() {
        totalGridStackView.addArrangedSubview(productThumbnailImageView)
        totalGridStackView.addArrangedSubview(productNameLabel)
        totalGridStackView.addArrangedSubview(productStockQuantityLabel)
        totalGridStackView.addArrangedSubview(productPriceLabel)
        totalGridStackView.addArrangedSubview(bargainPriceLabel)
    }
    
    private func setGridConstraints() {
        NSLayoutConstraint.activate([
            totalGridStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.gridPositiveConstant),
            totalGridStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Metric.listNegativeConstant),
            totalGridStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Metric.listNegativeConstant),
            totalGridStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.gridPositiveConstant)
        ])
    }
}
