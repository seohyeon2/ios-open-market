//
//  ImageCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain on 2023/04/15.
//

import UIKit
import Combine

final class ImageCollectionViewCell: UICollectionViewCell {

    // MARK: init

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("셀")

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        setNeedsLayout()
    }

    // MARK: Properties
    var viewModel: RegistrationEditViewModel?

    private var cancellable: AnyCancellable?

    // MARK: Method

    func setGridStackView(imageData: Data) {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemGray3
        deleteButton.backgroundColor = .black
        deleteButton.layer.cornerRadius = 20
        deleteButton.addTarget(self, action: #selector(tappedXMarkButton), for: .touchUpInside)
        deleteButton.tag = viewModel?.tagNumber ?? 0
        viewModel?.tagNumber += 1
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.image = UIImage(data: imageData)
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(imageView)
        containerView.addSubview(deleteButton)

        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.gridPositiveConstant),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Metric.listNegativeConstant),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Metric.listNegativeConstant),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.gridPositiveConstant),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -10)
        ])
        
    }

    @objc
    private func tappedXMarkButton(_ sender: UIButton) {
        sender.superview?.superview?.superview?.removeFromSuperview()

        viewModel?.input.tappedXMarkButton(sender.tag)
    }
}
