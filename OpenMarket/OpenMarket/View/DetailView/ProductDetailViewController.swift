//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit
import Combine

final class ProductDetailViewController: UIViewController {
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, MarketItem>

    // MARK: Initialization
    init(id: Int) {
        self.viewModel.input.getMarketItem(id)
        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Properties
    private let viewModel = ProductDetailViewModel()
    private var cancellable = Set<AnyCancellable>()
    private var dataSource: DiffableDataSource?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, MarketItem>()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "ellipsis")
        button.setImage(
            image,
            for: .normal
        )
        button.tintColor = .secondary
        button.addTarget(
            self,
            action: #selector(showActionSheet),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = createDetailLayout()
        let collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: layout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        return collectionView
    }()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setCollectionViewConstraint()
        setCollectionView()
        setSnapshot()

        bind()
    }
    
    // MARK: Configure UI Method
    private func setView() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: actionButton
        )
        navigationController?.navigationBar.tintColor = .secondary
        
        view.addSubview(collectionView)
    }
    
    private func setCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            )
        ])
    }
    
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.register(
            DetailCollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewNamespace.detail.name
        )
        dataSource = configureDataSource(
            id: CollectionViewNamespace.detail.name
        )
    }
    
    private func configureDataSource(id: String) -> DiffableDataSource? {
        dataSource = DiffableDataSource(collectionView: collectionView) {(
            collectionView: UICollectionView,
            indexPath: IndexPath,
            product: MarketItem) -> UICollectionViewCell? in

            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CollectionViewNamespace.detail.name,
                    for: indexPath
                  ) as? DetailCollectionViewCell else { return DetailCollectionViewCell()
            }
            cell.configureCell(product: product)

            return cell
        }
        return dataSource
    }
    
    private func setSnapshot() {
        snapshot.appendSections([.main])
    }
    
    private func createDetailLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item, count: 1
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.padding,
            leading: Metric.padding,
            bottom: Metric.padding,
            trailing: Metric.padding
        )

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
    
    // MARK: Bind Method
    private func bind() {
        viewModel.output.detailMarketItemPublisher
            .receive(on: DispatchQueue.main)
            .sink (receiveValue: {  [weak self] marketItem in
                guard let self = self else { return }
                    self.navigationItem.title = marketItem.name
                
                self.snapshot.appendItems([marketItem])
                self.dataSource?.apply(self.snapshot)
            })
            .store(in: &cancellable)
        
        viewModel.output.alertPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showCustomAlert(title: nil, message: error)
            }
            .store(in: &cancellable)
        
        viewModel.output.movementPublisher
            .receive(on: DispatchQueue.main)
            .filter({ isMove in
                return isMove == true
            })
            .sink(receiveValue: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .store(in: &cancellable)
    }
    
    // MARK: Action Method
    @objc private func showActionSheet() {
        let actionSheetController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        let actionModify = UIAlertAction(
            title: "수정",
            style: .default,
            handler: { [weak self] _ in
            let editViewController = RegistrationEditViewController(
                viewModel: RegistrationEditViewModel(
                    marketItem: self?.viewModel.marketItem
                )
            )
            self?.navigationController?.pushViewController(
                editViewController,
                animated: true
            )
        })

        let actionDelete = UIAlertAction(
            title: "삭제",
            style: .destructive,
            handler: { _ in
            self.viewModel.output.deleteProduct()
        })

        let actionCancel = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )

        actionSheetController.addAction(actionModify)
        actionSheetController.addAction(actionDelete)
        actionSheetController.addAction(actionCancel)

        self.present(
            actionSheetController,
            animated: true,
            completion: nil
        )
    }
}

extension ProductDetailViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        return false
    }
}
