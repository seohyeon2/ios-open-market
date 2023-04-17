//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit
import Combine

final class ProductDetailViewController: UIViewController {

    private enum Section {
        case main
    }

    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, MarketItem>

    // MARK: Initializtion

    init(id: Int) {
        self.viewModel.input.getMarketItem(id)
        super.init(nibName: nil, bundle: nil)
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
        button.setImage(image, for: .normal)
        button.tintColor = .secondary
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = createDetailLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return collectionView
    }()

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        navigationController?.navigationBar.tintColor = .secondary
        collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: "detail")
        dataSource = configureDataSource(id: "detail")
        self.snapshot.appendSections([.main])

        view.addSubview(collectionView)
        setCollectionViewConstraint()
        
        bind()
    }

    // MARK: Method

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
            }.store(in: &cancellable)
        
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
    
    @objc private func showActionSheet() {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let actionModify = UIAlertAction(title: "수정", style: .default, handler: { [weak self] _ in
            let editViewController = RegistrationEditViewController(viewModel: RegistrationEditViewModel(marketItem: self?.viewModel.marketItem))
            self?.navigationController?.pushViewController(editViewController, animated: true)
        })

        let actionDelete = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.viewModel.output.deleteProduct()
        })

        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        actionSheetController.addAction(actionModify)
        actionSheetController.addAction(actionDelete)
        actionSheetController.addAction(actionCancel)

        self.present(actionSheetController, animated: true, completion: nil)
    }

    private func createDetailLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: Metric.padding, leading: Metric.padding, bottom: Metric.padding, trailing: Metric.padding)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func setCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }

    private func configureDataSource(id: String) -> DiffableDataSource? {
        dataSource = DiffableDataSource(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, product: MarketItem) -> UICollectionViewCell? in

            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detail", for: indexPath) as? DetailCollectionViewCell else { return DetailCollectionViewCell() }

            let publishers = self.viewModel.output.getImagePublisher()

            publishers?.enumerated().forEach({ index, myPublisher in
                myPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            return
                        case .failure(let error):
                            print(error)
                        }
                    }, receiveValue: { imageData in
                        cell.configureImage(imageData: imageData, index: index, total: (publishers?.count ?? 1))
                    })
                    .store(in: &self.cancellable)
            })
            cell.configureLabel(product: product)
            cell.pageControl.numberOfPages = publishers?.count ?? 1

            return cell
        }
        return dataSource
    }
}
