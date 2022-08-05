//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    private enum Section {
        case main
    }

    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, SaleInformation>

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
    private var productDetail: SaleInformation?
    private var dataSource: DiffableDataSource?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, SaleInformation>()
 
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
        
        self.snapshot.appendSections([.main])
        
        getProductDetail()
    }
    
    private func getProductDetail() {
        guard let productId = product?.id else { return }
        guard let request = try? ProductRequest.item(productId).createURLRequest() else { return }
        
        NetworkManager().networkPerform(for: request) { result in
            switch result {
            case .success(let data):
                guard let productInfo = try? JSONDecoder().decode(SaleInformation.self, from: data) else { return }
                
                self.snapshot.appendItems([productInfo])
                self.dataSource?.apply(self.snapshot, animatingDifferences: false)
                
                self.productDetail = productInfo
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showCustomAlert(title: nil, message: error.localizedDescription)
                }
            }
        }
    }
}
