//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit

final class ProductDetailViewController: UIViewController {
    
    // MARK: Initializtion
    
    init(product: SaleInformation) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.product = nil
        super.init(coder: coder)
    }
    
    // MARK: Properties
    
    let product: SaleInformation?

    private let actionButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "square.and.arrow.up")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationItem.title = product?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
}
