//
//  LocationInputView.swift
//  UBER
//
//  Created by Long Nguyen on 4/19/21.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismissLocationInputView()
}

class LocationInputView: UIView {

    weak var delegate: LocationInputViewDelegate?
    
//MARK: - Properties
    
    //the 'didSet' got executed whenever "userInfo" got modified. we can put it in the ViewDidLoad. We dont put "private" since we need to access it from the HomeVC
    var userInfo: User? {
        didSet { titleLabel.text = userInfo?.fullname }
    }
    
    //not 'private' since we need to access it in HomeVC
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "..."
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .darkGray
        
        return lb
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        //btn.setImage(imageLiteral.withRenderingMode(.alwaysOriginal), for: .normal) //this is for image literal
        btn.tintColor = .black
        
        btn.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let startLocationIndicatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        vw.setDimensions(height: 8, width: 8)
        vw.layer.cornerRadius = 8 / 2
        return vw
    }()
    
    private let linkingView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .lightGray
        vw.setWidth(width: 2)
        return vw
    }()
    
    private let destinationIndicatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        vw.setDimensions(height: 8, width: 8)
        return vw
    }()
    
    //MARK: - TextField
    
    //in order for the text not slushed to the left, we add a padding view, this is why we need it as "lazy var", since the paading view is not availble by default, gotta add it
    private lazy var startingLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current location"
        tf.backgroundColor = .groupTableViewBackground
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.isEnabled = false //we can modify it in our real app
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private lazy var destinationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 16)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
//MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 46, paddingLeft: 12, width: 24, height: 24)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: backButton.rightAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12, height: 26)
        
        addSubview(destinationTextField)
        destinationTextField.anchor(top: startingLocationTextField.bottomAnchor, left: startingLocationTextField.leftAnchor, right: startingLocationTextField.rightAnchor, paddingTop: 20, height: 26)
        
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerX(inView: backButton)
        startLocationIndicatorView.centerY(inView: startingLocationTextField)
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerX(inView: backButton)
        destinationIndicatorView.centerY(inView: destinationTextField)
        
        addSubview(linkingView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor, paddingTop: 4, paddingBottom: 4)
        linkingView.centerX(inView: destinationIndicatorView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Helpers
    
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
    
    
}
