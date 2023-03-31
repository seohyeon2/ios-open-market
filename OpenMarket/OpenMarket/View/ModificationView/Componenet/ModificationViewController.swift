//
//  ModificationViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/06.
//

import PhotosUI
import Combine

class ModificationViewController: UIViewController, PHPickerViewControllerDelegate {
    
    // MARK: Initializtion

    init(item: MarketItem) {
        self.viewModel.input.getMarketItem(item)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Properties
    
    private let viewModel =  ModificationViewModel()
    private var cancellable = Set<AnyCancellable>()
    
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
        button.addTarget(self, action: #selector(goBackDetailViewController), for: .touchUpInside)
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
        
        setUI()
        setInformation()
        setImage()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
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
    }
    
    @objc private func addImage() {
        present(imagePicker, animated: true)
    }
    
    private func setUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        self.title = "상품 수정"

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
    }
    
    @objc private func onClickDoneButton() {
        viewModel.patchProduct()
    }
    
    private func setInformation() {
        productNameTextField.text = viewModel.productName
        productPriceTextField.text = String(viewModel.productPrice)
        discountedPriceTextField.text = String(viewModel.discountedPrice)
        stockTextField.text = String(viewModel.stock)
        descriptionTextView.text = viewModel.productDescription
        imageAddButton.isHidden = true
    }
    
    private func setImage() {
//        guard let product = product else {
//            return
//        }
//
//        (0..<(product.images.count)).forEach { index in
//            let image = product.images[index]
//            guard let url = URL(string: image.url) else { return }
//
//            NetworkManager().networkPerform(for: URLRequest(url: url)) { result in
//                switch result {
//                case .success(let data):
//                    guard let image = UIImage(data: data) else { return }
//                    self.images.append(image)
//
//                    DispatchQueue.main.async {
//                        let imageView = UIImageView()
//
//                        imageView.image = image
//                        imageView.heightAnchor.constraint(equalToConstant: Registration.imageSize).isActive = true
//                        imageView.widthAnchor.constraint(equalToConstant: Registration.imageSize).isActive = true
//                        self.imageStackView.insertArrangedSubview(imageView, at: Registration.firstIndex)
//                    }
//                case .failure(let error):
//                    DispatchQueue.main.async {
//                        self.showCustomAlert(title: nil, message: error.localizedDescription)
//                    }
//                }
//            }
//        }
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
    
    @objc private func goBackDetailViewController() {
        navigationController?.popViewController(animated: true)
    }
}
