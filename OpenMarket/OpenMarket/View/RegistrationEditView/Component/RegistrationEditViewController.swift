//
//  RegistrationEditViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/01.
//

import PhotosUI
import Combine

final class RegistrationEditViewController: UIViewController {
    // MARK: Properties
    private var viewModel: RegistrationEditViewModel = RegistrationEditViewModel(marketItem: nil)
    private var cancellable = Set<AnyCancellable>()

    private var imagePicker : PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            Registration.done,
            for: .normal
        )
        button.setTitleColor(
            UIColor.secondary,
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(onClickDoneButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            Registration.cancel,
            for: .normal
        )
        button.setTitleColor(
            UIColor.secondary,
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(goBackDetailViewController),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Registration.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var imageAddButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "camera.fill")
        button.addTarget(
            self,
            action: #selector(addImage),
            for: .touchUpInside
        )
        button.setImage(
            image,
            for: .normal
        )
        button.tintColor = .secondary
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.text = Registration.productName
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let productPriceLabel: UILabel = {
        let label = UILabel()
        label.text = Registration.productPrice
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let discountedPriceLabel: UILabel = {
        let label = UILabel()
        label.text = Registration.discountedPrice
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stockLabel: UILabel = {
        let label = UILabel()
        label.text = Registration.stock
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Registration.productDetails
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.productName
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let productPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.productPrice
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let discountedPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.discountedPrice
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let stockTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.stock
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(
            items: [
                Currency.KRW.name,
                Currency.USD.name
            ]
        )
        segment.selectedSegmentIndex = Registration.initialNumber
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }()

    private let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Registration.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Registration.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(viewModel: RegistrationEditViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel

        guard let item = viewModel.marketItem else {
            self.title = Registration.registrationProduct
            return
        }

        self.title = Registration.editProduct
        configureEditView(item: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        addSubViews()
        setConstraint()
        setViewGesture()
        registerForKeyboardNotification()
        
        bind()
    }
    
    // MARK: Common UI Method
    private func setView() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        imagePicker.delegate = self
    }
    
    private func addSubViews() {
        view.addSubview(imageScrollView)
        view.addSubview(textStackView)
        view.addSubview(imageAddButton)

        imageScrollView.addSubview(imageStackView)

        [
            productNameLabel,
            productNameTextField,
            productPriceLabel,
            priceStackView,
            discountedPriceLabel,
            discountedPriceTextField,
            stockLabel,
            stockTextField,
            descriptionLabel,
            descriptionTextView
        ].forEach {
            textStackView.addArrangedSubview($0)
        }

        priceStackView.addArrangedSubview(productPriceTextField)
        priceStackView.addArrangedSubview(segmentedControl)
    }

    private func setConstraint() {
        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 10
            ),
            imageScrollView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            imageScrollView.heightAnchor.constraint(
                equalToConstant: 120
            ),

            imageStackView.topAnchor.constraint(
                equalTo: imageScrollView.topAnchor
            ),
            imageStackView.trailingAnchor.constraint(
                equalTo: imageScrollView.trailingAnchor
            ),
            imageStackView.leadingAnchor.constraint(
                equalTo: imageScrollView.leadingAnchor
            ),
            imageStackView.bottomAnchor.constraint(
                equalTo: imageScrollView.bottomAnchor
            ),

            imageAddButton.heightAnchor.constraint(
                equalToConstant: 100
            ),
            imageAddButton.widthAnchor.constraint(
                equalToConstant: 100
            ),
            imageAddButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            imageAddButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            textStackView.topAnchor.constraint(
                equalTo: imageScrollView.bottomAnchor,
                constant: Registration.textStackViewPositiveSize
            ),
            textStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: Registration.textStackViewNegativeSize
            ),
            textStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Registration.textStackViewNegativeSize
            ),
            textStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Registration.textStackViewPositiveSize
            )
        ])
        
        imageScrollView.setContentHuggingPriority(
            .required,
            for: .vertical
        )
        descriptionTextView.setContentHuggingPriority(
            .defaultLow,
            for: .vertical
        )
    }
    
    private func setViewGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(keyboardDownAction)
        )
        view.addGestureRecognizer(tapGesture)
    }

    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    // MARK: Registration UI Method
    private func insertImageView(imageData: Data) {
        let containerView = createContainerView()
        let deleteButton = createDeleteButton()
        let imageView = createImageView(imageData: imageData)
        
        containerView.addSubview(imageView)
        containerView.addSubview(deleteButton)
        self.imageStackView.insertArrangedSubview(containerView, at: 0)
        
        setImagesConstraint(
            for: containerView,
            imageView: imageView,
            deleteButton: deleteButton
        )
    }
    
    private func createContainerView() -> UIView {
        let containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 100,
                height: 100
            )
        )
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }

    private func createDeleteButton() -> UIButton {
        let deleteButton = UIButton(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 30,
                height: 30
            )
        )
        deleteButton.setImage(
            UIImage(systemName: "xmark.circle.fill"),
            for: .normal
        )
        deleteButton.tintColor = .systemGray3
        deleteButton.backgroundColor = .black
        deleteButton.layer.cornerRadius = 20
        deleteButton.addTarget(
            self,
            action: #selector(tappedXMarkButton),
            for: .touchUpInside
        )
        deleteButton.tag = viewModel.output.getDeleteButtonTagNumber()
        viewModel.input.increaseDeleteButtonTagNumber()
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        return deleteButton
    }

    private func createImageView(imageData: Data) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(data: imageData)
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func setImagesConstraint(
        for containerView: UIView,
        imageView: UIImageView,
        deleteButton: UIButton
    ) {
        NSLayoutConstraint.activate([
            imageScrollView.leadingAnchor.constraint(
                equalTo: imageAddButton.trailingAnchor,
                constant: 10
            ),
            
            containerView.heightAnchor.constraint(
                equalToConstant: 110
            ),
            containerView.widthAnchor.constraint(
                equalToConstant: 110
            ),
            
            imageView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: 10),
            imageView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -10
            ),
            imageView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            
            deleteButton.trailingAnchor.constraint(
                equalTo: imageView.trailingAnchor,
                constant: 10
            ),
            deleteButton.topAnchor.constraint(
                equalTo: imageView.topAnchor,
                constant: -10
            )
        ])
    }

    // MARK: Edit UI Method
    private func configureEditView(item: MarketItem) {
        configureEditViewProductInfoFields(item: item)
        configureEditViewImages(images: item.images)
    }
    
    private func configureEditViewProductInfoFields(item: MarketItem) {
        if item.currency == Currency.KRW.name {
            productPriceTextField.text = String(Int(item.price))
            discountedPriceTextField.text = String(Int(item.discountedPrice))
            segmentedControl.selectedSegmentIndex = Currency.KRW.rawValue
        } else {
            productPriceTextField.text = String(item.price)
            discountedPriceTextField.text = String(item.discountedPrice)
            segmentedControl.selectedSegmentIndex = Currency.USD.rawValue
        }

        productNameTextField.text = item.name
        stockTextField.text = String(item.stock)
        descriptionTextView.text = item.description
    }

    private func configureEditViewImages(images: [ItemImage]) {
        images.forEach { image in
            guard let url = URL(string: image.url) else {
                return
            }
            
            ImageCache.shared.load(url: url)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure:
                        return
                    }
                } receiveValue: { [weak self] image in
                    self?.addConfiguredImageView(with: image)
                }
                .store(in: &cancellable)
        }
    }

    private func addConfiguredImageView(with image: UIImage) {
        let imageView = UIImageView()
        imageView.image = image
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(
                equalToConstant: Registration.imageSize
            ),
            imageView.widthAnchor.constraint(
                equalToConstant: Registration.imageSize
            ),
            
            imageScrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            )
        ])

        imageAddButton.isHidden = true
        imageStackView.insertArrangedSubview(
            imageView,
            at: 0
        )
    }
    
    // MARK: Bind Method
    private func bind() {
        productNameTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.productName,
                    on: viewModel)
            .store(in: &cancellable)
        
        descriptionTextView.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.productDescription,
                    on: viewModel)
            .store(in: &cancellable)
        
        productPriceTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.productPrice,
                    on: viewModel)
            .store(in: &cancellable)
        
        discountedPriceTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.discountedPrice,
                    on: viewModel)
            .store(in: &cancellable)
        
        stockTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.stock,
                    on: viewModel)
            .store(in: &cancellable)

        segmentedControl
            .publisher(for: \.selectedSegmentIndex)
            .receive(on: DispatchQueue.main)
            .assign(to: \.currency,
                    on: viewModel)
            .store(in: &cancellable)
        
        viewModel.output.imageDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageData in
                guard let self = self else { return }
                self.insertImageView(imageData: imageData)
            }
            .store(in: &cancellable)
        
        viewModel.output.alertPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showCustomAlert(title: nil,
                                      message: error)
            }
            .store(in: &cancellable)
        
        viewModel.output.movementPublisher
            .receive(on: DispatchQueue.main)
            .sink { itemId in
                guard let navigationController = self.navigationController else {
                    return
                }
                
                let viewController = ProductDetailViewController(id: itemId)
                navigationController.pushViewController(viewController,
                                                        animated: true)
                
                guard let rootView = navigationController.viewControllers.first,
                      let lastView = navigationController.viewControllers.last else {
                    return
                }
                
                navigationController.viewControllers = [rootView,lastView]

            }
            .store(in: &cancellable)
    }

    // MARK: Action Method
    @objc
    private func addImage() {
        present(
            imagePicker,
            animated: true
        )
    }

    @objc
    private func keyboardDownAction(_ sender: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        descriptionTextView.contentInset.bottom = Registration.descriptionTextViewInset
    }

    @objc
    private func keyBoardShow(notification: NSNotification) {
        guard let userInfo: NSDictionary = notification.userInfo as? NSDictionary else {
            return
        }
        
        guard let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else {
            return
        }
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        descriptionTextView.contentInset.bottom = keyboardHeight
    }

    @objc
    private func onClickDoneButton() {
        viewModel.input.tappedDoneButton()
    }

    @objc
    private func goBackDetailViewController() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func tappedXMarkButton(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()

        viewModel.input.tappedXMarkButton(sender.tag)
    }
}

// MARK: Extension
extension RegistrationEditViewController: PHPickerViewControllerDelegate {
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult])
    {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        
        for selectedImage in results {
            let itemProvider = selectedImage.itemProvider
            itemProvider.canLoadObject(ofClass: UIImage.self)
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (picture, error) in
                guard let self = self,
                      let addedImage = picture as? UIImage,
                      let imageData = addedImage.compress() else {
                    return
                }
                self.viewModel.input.getProductImageData(imageData)
            }
        }
        
        picker.dismiss(animated: true)
        
        imagePicker = PHPickerViewController(configuration: configuration)
    }
}
