//
//  DetailCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit

class DetailCollectionViewCell: ItemCollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setDetailStackView()
        setDetailConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Properties

    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let descriptionScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Method

    private func setDetailConstraints() {
        NSLayoutConstraint.activate([
            totalDetailStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.gridPositiveConstant),
            totalDetailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Metric.listNegativeConstant),
            totalDetailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Metric.listNegativeConstant),
            totalDetailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.gridPositiveConstant)
        ])
    }
    
    private func setDetailStackView() {
        contentView.addSubview(totalDetailStackView)
        totalDetailStackView.addArrangedSubview(imageScrollView)
        totalDetailStackView.addArrangedSubview(labelStackView)
        totalDetailStackView.addArrangedSubview(descriptionScrollView)
        
        labelStackView.addArrangedSubview(productNameLabel)
        labelStackView.addArrangedSubview(stockPriceStackView)
        
        stockPriceStackView.addArrangedSubview(productStockQuntityLabel)
        stockPriceStackView.addArrangedSubview(productPriceLabel)
        stockPriceStackView.addArrangedSubview(bargainPriceLabel)
    }
}
