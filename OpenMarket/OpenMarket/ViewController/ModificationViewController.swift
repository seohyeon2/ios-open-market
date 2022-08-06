//
//  ModificationViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/06.
//

import UIKit

class ModificationViewController: RegistrationViewController {

    var product: SaleInformation?

    init(product: SaleInformation) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "상품 수정"
        setInformation()
        setImage()
    }

    func setInformation() {
        guard let product = product else {
            return
        }

        productNameTextField.text = product.name
        productPriceTextField.text = String(product.price)
        discountedPriceTextField.text = String(product.discountedPrice)
        stockTextField.text = String(product.stock)
        descriptionTextView.text = product.description
        imageAddButton.isHidden = true
    }

    func setImage() {
        guard let product = product else {
            return
        }

        (0..<(product.images?.count ?? 0)).forEach { index in
            guard let image = product.images?[index] else { return }
            guard let url = URL(string: image.url) else { return }

            NetworkManager().networkPerform(for: URLRequest(url: url)) { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else { return }
                    self.images.append(image)

                    DispatchQueue.main.async {
                        let imageView = UIImageView()

                        imageView.image = image
                        imageView.heightAnchor.constraint(equalToConstant: Registraion.imageSize).isActive = true
                        imageView.widthAnchor.constraint(equalToConstant: Registraion.imageSize).isActive = true
                        self.imageStackView.insertArrangedSubview(imageView, at: Registraion.firstIndex)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showCustomAlert(title: nil, message: error.localizedDescription)
                    }
                }
            }
        }
    }
}
