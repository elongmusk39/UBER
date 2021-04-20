//
//  SignUpController.swift
//  UBER
//
//  Created by Long Nguyen on 4/18/21.
//

import UIKit
import Firebase
import GeoFire //external module

class SignUpController: UIViewController {
    
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
    
    private lazy var fullnameContainerView: UIView = {
        let imagePict = UIImage(systemName: "person")
        return UIView().inputContainerView(image: imagePict!, textField: fullnameTextField)
    }()
    
    //if it crashed by launching, then the name of the image is the problem
    private lazy var passwordContainerView: UIView = {
        let imagePict = UIImage(systemName: "lock")
        return UIView().inputContainerView(image: imagePict!, textField: passwordTextField)
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let imagePict = UIImage(systemName: "person.crop.square")
        return UIView().inputContainerView(image: imagePict!, segmentedControl: segment)
    }()
    
    
    
    
    
    private let segment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Passenger", "driver"])
        sc.backgroundColor = .clear
        
        //set the text color for the text of the sc
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor(white: 1, alpha: 0.87)
        sc.layer.borderWidth = 1
        sc.layer.borderColor = UIColor(white: 1, alpha: 0.87).cgColor
        return sc
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Email", isSecure: false)
    }()
    
    private let fullnameTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Fullname", isSecure: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceHolder: "Password", isSecure: true)
    }()
    
    
    
    private let signUpButton: AuthButton = {
        let btn = AuthButton(type: .system)
        btn.setTitle("Sign up", for: .normal)
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return btn
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        let color: UIColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        let attributedTitle = NSMutableAttributedString (string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 20), .foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign in", attributes: [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: color]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    
//MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, fullnameContainerView, passwordContainerView, accountTypeContainerView, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        emailContainerView.setHeight(height: 50)
        fullnameContainerView.setHeight(height: 50)
        passwordContainerView.setHeight(height: 50)
        accountTypeContainerView.setHeight(height: 90)
        signUpButton.setHeight(height: 50)
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 10)
        dontHaveAccountButton.centerX(inView: view)
    }
    
//MARK: - Actions
    
    @objc func handleShowLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        guard let emailText = emailTextField.text else { return }
        guard let passText = passwordTextField.text else { return }
        guard let fullnameText = fullnameTextField.text else { return }
        let accountTypeIndex = segment.selectedSegmentIndex
        
        var nameAccountType = ""
        if accountTypeIndex == 0 {
            nameAccountType = "Passenger"
        } else if accountTypeIndex == 1 {
            nameAccountType = "Driver"
        }
        
        //so we are using Realtime Database, which means that we need the "databaseURL". go on to "GoogleService-Info.plit", add "DATABASE_URL" and paste its value of url from realtime database
        Auth.auth().createUser(withEmail: emailText, password: passText) { (result, error) in
            
            if let e = error?.localizedDescription {
                print("DEBUG: fail to create user - \(e)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            
            //if user is a driver, we need to get his location
            if accountTypeIndex == 1 {
                var geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
//                geoFire.setLocation(location, forKey: uid) { error in
//                    <#code#>
//                }
            }
            
            
            let values = ["email": emailText,
                          "fullname": fullnameText,
                          "password": passText,
                          "accountType": nameAccountType]
            
            //after the code run smoothly, then the completion block executes
            REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
                
                guard error == nil else {
                    print("DEBUG: we got error signing up")
                    return
                }
                
                print("DEBUG: successfully register user \(emailText)")
                
                //call out the func configureUI to load the map view when we dismiss this VC
                guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
                controller.configureUI()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
}
