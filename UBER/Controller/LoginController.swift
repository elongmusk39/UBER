//
//  LoginController.swift
//  UBER
//
//  Created by Long Nguyen on 4/17/21.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
//MARK: - Properties
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "UBER"
        lb.font = UIFont(name: "Avenir-Light", size: 36)
        lb.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.8)
        
        return lb
    }()
    
    //make it "lazy var" since we need to add the textField, which is not declared by default
    private lazy var emailContainerView: UIView = {
        let imagePict = UIImage(systemName: "envelope")
        return UIView().inputContainerView(image: imagePict!, textField: emailTextField)
    }()
    
    //if it crashed by launching, then the name of the image is the problem
    private lazy var passwordContainerView: UIView = {
        let imagePict = UIImage(systemName: "lock")
        return UIView().inputContainerView(image: imagePict!, textField: passwordTextField)
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Email", isSecure: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecure: true)
    }()
    
    private let loginButton: AuthButton = {
        let btn = AuthButton(type: .system)
        btn.setTitle("Log in", for: .normal)
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return btn
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        let color: UIColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        let attributedTitle = NSMutableAttributedString (string: "Don't have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 20), .foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign up", attributes: [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: color]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return btn
    }()
    
//MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
    }
    
    //this will dictate the status bar (the battery and time and wifi UI) but it cannot work if it is NavigationController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        emailContainerView.setHeight(height: 50)
        passwordContainerView.setHeight(height: 50)
        loginButton.setHeight(height: 50)
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 10)
        dontHaveAccountButton.centerX(inView: view)
    }
    
//MARK: - Actions
    
    @objc func handleShowSignUp() {
        let vc = SignUpController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleLogin() {
        guard let emailText = emailTextField.text else { return }
        guard let passText = passwordTextField.text else { return }

        Auth.auth().signIn(withEmail: emailText, password: passText) { (result, error) in
            if let e = error?.localizedDescription {
                print("DEBUG: fail to log user in - \(e)")
                return
            }
            
            print("DEBUG: successfully log user \(emailText) in")
            
            //call out the func configure() to load the map view and fetch all the data when we dismiss this VC
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
            controller.configure()
            self.dismiss(animated: true, completion: nil)
        }
    }

}
