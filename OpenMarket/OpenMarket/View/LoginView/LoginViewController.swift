//
//  LoginViewController.swift
//  OpenMarket
//
//  Created by seohyeon park on 12/18/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    // MARK: Properties
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = "OpenMarket"
        label.textColor = .black
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사용자 이메일"
        textField.text = "seohyeon2@test.com"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호"
        textField.text = APIConstants.secret
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = Metric.borderWidth
        button.layer.cornerRadius = Metric.cornerRadius
        button.setTitle("로그인", for: .normal)
        button.addTarget(
            self,
            action: #selector(loginButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        setCollectionViewConstraint()
    }
    
    // MARK: UI Method
    private func setView() {
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginButton)
    }
    
    private func setCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor, constant: -50
            ),
            stackView.widthAnchor.constraint(
                equalToConstant: 200
            ),
            
            emailTextField.widthAnchor.constraint(
                equalToConstant: 200
            ),
            
            passwordTextField.widthAnchor.constraint(
                equalToConstant: 200
            ),
            
            loginButton.widthAnchor.constraint(
                equalToConstant: 80
            )
        ])
    }
    
    // MARK: Action Method
    @objc 
    private func loginButtonTapped() {
        print("로그인 버튼이 눌렸습니다.")
        LoginWithFirebaseAuth()
    }
    
    private func LoginWithFirebaseAuth() {
        Auth.auth().signIn(
            withEmail: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        ) { [weak self] authResult, error in
            if authResult != nil {
                self?.showMainView()
            } else {
                print("로그인 실패")
                print(error.debugDescription)
                self?.showCustomAlert(
                    title: "로그인 실패",
                    message: "이메일 또는 비밀번호를 잘못 입력했습니다. \n입력하신 내용을 다시 확인해주세요."
                )
            }
        }
    }
    
    private func showMainView() {
        let mainViewController = MainViewController()
        navigationController?.setViewControllers(
            [mainViewController],
            animated: true
        )
    }
}
