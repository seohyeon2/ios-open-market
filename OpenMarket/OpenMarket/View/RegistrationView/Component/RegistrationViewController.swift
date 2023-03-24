//
//  RegistrationViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/01.
//

import PhotosUI
import Combine

class RegistrationViewController: UIViewController, PHPickerViewControllerDelegate {
    // MARK: Properties
    
    private let viewModel =  RegistrationViewModel()
    private var cancellable = Set<AnyCancellable>()

    private var imageCount = Registration.initialNumber
    var images = [UIImage]()

    private let imagePicker : PHPickerViewController = {
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
        button.addTarget(self, action: #selector(goBackMainViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: Registration.scrollViewInset, left: Registration.scrollViewInset, bottom: Registration.scrollViewInset, right: Registration.scrollViewInset)
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
        let image = UIImage(systemName: CollectionViewNamespace.plus.name)
        button.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemGray5
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
    
    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        self.title = Registration.registrationProduct
        
        view.addSubview(imageScrollView)
        view.addSubview(textStackView)
        
        imageScrollView.addSubview(imageStackView)
        imageStackView.addArrangedSubview(imageAddButton)

        imagePicker.delegate = self
        
        textStackView.addArrangedSubview(productNameTextField)
        textStackView.addArrangedSubview(priceStackView)
        textStackView.addArrangedSubview(discountedPriceTextField)
        textStackView.addArrangedSubview(stockTextField)
        textStackView.addArrangedSubview(descriptionTextView)
        
        priceStackView.addArrangedSubview(productPriceTextField)
        priceStackView.addArrangedSubview(segmentedControl)
        
        setConstraint()
        setViewGesture()
        registerForKeyboardNotification()
        
        bindViewToViewModel()
    }
    
    // MARK: Method
    
    @objc private func onClickDoneButton() {
        viewModel.registerProduct()
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for selectedImage in results {
            let imageView = UIImageView()
            let itemProvider = selectedImage.itemProvider
            itemProvider.canLoadObject(ofClass: UIImage.self)
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (picture, error) in
                guard let self = self,
                      let addedImage = picture as? UIImage else { return }
                self.images.append(addedImage)

                DispatchQueue.main.async {
                    
                    imageView.image = picture as? UIImage
                    imageView.heightAnchor.constraint(equalToConstant: Registration.imageSize).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: Registration.imageSize).isActive = true
                    self.imageStackView.insertArrangedSubview(imageView, at: 0)
                }
            }
        }
        picker.dismiss(animated: true)
    }
    
    func bindViewToViewModel() {
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
    }
    
    @objc private func goBackMainViewController() {
        navigationController?.popViewController(animated: true)
    }

//    @objc private func registerProduct() {
//
//        let params: [String: Any?] = [
//            Params.productName: productNameTextField.text,
//            Params.productDescription: descriptionTextView.text,
//            Params.productPrice: Int(productPriceTextField.text ?? "0") ?? 0,
//            Params.currency: choiceCurrency()?.name,
//            Params.discountedPrice: Int(discountedPriceTextField.text ?? "0") ?? 0,
//            Params.stock: Int(stockTextField.text ?? "0") ?? 0,
//            Params.secret: "lk1erfg241t8ygh0"
//        ]
//
//        NetworkManager().postProduct(params: params, images: images) { result in
//            switch result {
//            case .success(_):
//                DispatchQueue.main.async {
//                    self.showCustomAlert(title: "🥳", message: "상품등록이 정상적으로 완료되었습니다!")
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.showCustomAlert(title: "🤔", message: error.localizedDescription)
//                }
//            }
//        }
//        resetRegistrationPage()
//    }

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

    func choiceCurrency() -> Currency? {
        return Currency.init(rawValue: segmentedControl.selectedSegmentIndex)
    }

    @objc private func addImage() {
        present(imagePicker, animated: true)
    }

    private func setConstraint() {
        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageScrollView.heightAnchor.constraint(equalToConstant: Registration.imageSize)
        ])
        
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageAddButton.heightAnchor.constraint(equalToConstant: Registration.imageSize),
            imageAddButton.widthAnchor.constraint(equalToConstant: Registration.imageSize)
        ])
        
        NSLayoutConstraint.activate([
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

    @objc private func keyboardDownAction(_ sender: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        descriptionTextView.contentInset.bottom = Registration.descriptionTextViewInset
    }

    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc private func keyBoardShow(notification: NSNotification) {
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
}
