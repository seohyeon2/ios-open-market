//
//  ModificationViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/06.
//

import UIKit

class ModificationViewController: RegistrationViewController {

    var product: MarketItem?
    
    init(product: MarketItem) {
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(Registraion.done, for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(patchProduct), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func patchProduct() {
        guard let product = product else {
            return
        }

        let params: [String: Any?] = [
            "name": productNameTextField.text,
            "price": productPriceTextField.text,
            "discounted_price": discountedPriceTextField.text,
            "currency": choiceCurrency()?.name,
            "stock": stockTextField.text,
            "descriptions": descriptionTextView.text
        ]

        NetworkManager().patchProduct(productId: product.id, modifiedInfomation: params) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "🤩", message: "상품수정이 정상적으로 완료되었습니다!", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "확인", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(okButton)
                    
                    self.present(alertController, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showCustomAlert(title: "😢", message: error.localizedDescription)
                }
            }
        }
    }

    private func setInformation() {
        guard let product = product else {
            return
        }

        productNameTextField.text = product.name
        productPriceTextField.text = String(product.price)
        discountedPriceTextField.text = String(product.description)
        stockTextField.text = String(product.stock)
        descriptionTextView.text = product.description
        imageAddButton.isHidden = true
    }

    private func setImage() {
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
