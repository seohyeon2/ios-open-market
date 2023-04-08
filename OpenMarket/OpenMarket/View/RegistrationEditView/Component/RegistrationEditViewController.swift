//
//  RegistrationEditViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/01.
//

import PhotosUI
import Combine

final class RegistrationEditViewController: UIViewController, PHPickerViewControllerDelegate {
    // MARK: Properties
    
    private var viewModel: RegistrationEditViewModel = RegistrationEditViewModel(marketItem: nil)
    private var cancellable = Set<AnyCancellable>()

    private var imageCount = Registration.initialNumber
    var images = [UIImage]()

    private var imagePicker : PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(Registration.done, for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(onClickDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(Registration.cancel, for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(goBackDetailViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = Registration.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var imageAddButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "camera.fill")
        button.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray3
        button.backgroundColor = .gray
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let productNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.productName
        textField.borderStyle = .roundedRect
        return textField
    }()

    let productPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.productPrice
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()

    let discountedPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.discountedPrice
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()

    let stockTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Registration.stock
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()

    lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: [Currency.KRW.name, Currency.USD.name])
        segment.selectedSegmentIndex = Registration.initialNumber
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    let descriptionTextView: UITextView = {
        let textView = UITextView()
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
        configure(choose: item)
        self.title = Registration.editProduct
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)

        imagePicker.delegate = self

        addSubViews()
        setConstraint()
        setViewGesture()
        registerForKeyboardNotification()
        
        bind()
    }
    
    // MARK: Method

    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5

        for selectedImage in results {
            let itemProvider = selectedImage.itemProvider
            itemProvider.canLoadObject(ofClass: UIImage.self)
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (picture, error) in
                guard let self = self,
                      let addedImage = picture as? UIImage,
                      let imageData = addedImage.compress() else { return }
                self.viewModel.input.getProductImageData(imageData)
            }
        }

        picker.dismiss(animated: true)

        imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
    }
    
    private func bind() {
        productNameTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.productName, on: viewModel)
            .store(in: &cancellable)
        
        descriptionTextView.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.productDescription, on: viewModel)
            .store(in: &cancellable)
        
        productPriceTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.productPrice, on: viewModel)
            .store(in: &cancellable)
        
        discountedPriceTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.discountedPrice, on: viewModel)
            .store(in: &cancellable)
        
        stockTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.stock, on: viewModel)
            .store(in: &cancellable)

        segmentedControl
            .publisher(for: \.selectedSegmentIndex)
            .receive(on: DispatchQueue.main)
            .assign(to: \.currency, on: viewModel)
            .store(in: &cancellable)
        
        viewModel.output.imageDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageData in
                guard let self = self else { return }
                self.insertImage(imageData: imageData)

            }.store(in: &cancellable)
        
        viewModel.output.alertPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showCustomAlert(title: nil, message: error)
            }.store(in: &cancellable)
        
        viewModel.output.movementPublisher
            .receive(on: DispatchQueue.main)
            .sink { itemId in
                guard let navigationController = self.navigationController else {
                    return
                }
                
                let viewController = ProductDetailViewController(id: itemId)
                navigationController.pushViewController(viewController, animated: true)
                
                guard let rootView = navigationController.viewControllers.first,
                      let lastView = navigationController.viewControllers.last else {
                    return
                }
                
                navigationController.viewControllers = [rootView,lastView]

            }.store(in: &cancellable)
    }

    private func insertImage(imageData: Data) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.2
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addGestureRecognizer(longPressGesture)
        containerView.isUserInteractionEnabled = true

        let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemGray3
        deleteButton.backgroundColor = .black
        deleteButton.layer.cornerRadius = 20
        deleteButton.addTarget(self, action: #selector(tappedXMarkButton), for: .touchUpInside)
        deleteButton.tag = viewModel.tagNumber
        viewModel.tagNumber += 1
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.image = UIImage(data: imageData)
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(imageView)
        containerView.addSubview(deleteButton)
        imageStackView.insertArrangedSubview(containerView, at: 0)

        NSLayoutConstraint.activate([
            imageScrollView.leadingAnchor.constraint(equalTo: imageAddButton.trailingAnchor, constant: 10),

            containerView.heightAnchor.constraint(equalToConstant: 110),
            containerView.widthAnchor.constraint(equalToConstant: 110),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -10)
        ])
    }

    private func configure(choose item: MarketItem) {
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

        item.images.forEach { image in
            guard let url = URL(string: image.url) else { return }
            NetworkManager().requestToServer(request: URLRequest(url: url, httpMethod: .get))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("성공")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] image in
                    guard let self = self else { return }
                    let imageView = UIImageView()
                    imageView.image = UIImage(data: image)
                    imageView.heightAnchor.constraint(equalToConstant: Registration.imageSize).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: Registration.imageSize).isActive = true
                    self.imageAddButton.isHidden = true
                    self.imageScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
                    self.imageStackView.insertArrangedSubview(imageView, at: 0)
                }
                .store(in: &cancellable)
        }
    }

    private func resetRegistrationPage() {
        images = []
        imageCount = Registration.initialNumber
        imageStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        imageStackView.addArrangedSubview(imageAddButton)
        productNameTextField.text = Registration.textClear
        productPriceTextField.text = Registration.textClear
        discountedPriceTextField.text = Registration.textClear
        stockTextField.text = Registration.textClear
        descriptionTextView.text = Registration.textClear
        segmentedControl.selectedSegmentIndex = Registration.initialNumber
    }

    private func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: segmentedControl.selectedSegmentIndex)
    }

    private func addSubViews() {
        view.addSubview(imageScrollView)
        view.addSubview(textStackView)
        view.addSubview(imageAddButton)

        imageScrollView.addSubview(imageStackView)

        textStackView.addArrangedSubview(productNameTextField)
        textStackView.addArrangedSubview(priceStackView)
        textStackView.addArrangedSubview(discountedPriceTextField)
        textStackView.addArrangedSubview(stockTextField)
        textStackView.addArrangedSubview(descriptionTextView)

        priceStackView.addArrangedSubview(productPriceTextField)
        priceStackView.addArrangedSubview(segmentedControl)
    }

    private func setConstraint() {
        NSLayoutConstraint.activate([
            //MARK: imageScrollViewConstraint
            imageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageScrollView.heightAnchor.constraint(equalToConstant: 120),

            //MARK: imageStackViewConstraint
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),

            //MARK: imageAddButtonConstraint
            imageAddButton.heightAnchor.constraint(equalToConstant: 100),
            imageAddButton.widthAnchor.constraint(equalToConstant: 100),
            imageAddButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageAddButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            //MARK: textStackViewConstraint
            textStackView.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: Registration.textStackViewPositiveSize),
            textStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Registration.textStackViewNegativeSize),
            textStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Registration.textStackViewNegativeSize),
            textStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Registration.textStackViewPositiveSize)
        ])
        
        imageScrollView.setContentHuggingPriority(.required, for: .vertical)
        descriptionTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    private func setViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDownAction))
        view.addGestureRecognizer(tapGesture)
    }

    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc
    private func addImage() {
        present(imagePicker, animated: true)
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

    @objc
    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let draggedView = gestureRecognizer.view else { return }
        let point = gestureRecognizer.location(in: imageScrollView)
        switch gestureRecognizer.state {
        case .ended:
            for subview in imageStackView.subviews {
                if subview != draggedView {
                    if draggedView.center.x < subview.center.x {
                        imageStackView.insertSubview(draggedView, belowSubview: subview)
                        return
                    }
                }
            }
            imageStackView.addArrangedSubview(draggedView)
        case .changed:
            draggedView.center = point
        default:
            break
        }
    }
}
