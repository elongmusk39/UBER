//
//  LocationInputActivationView.swift
//  UBER
//
//  Created by Long Nguyen on 4/18/21.
//

import UIKit

protocol LocationInputActivationViewDelegate: class {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    
//MARK: - Properties
    
    weak var delegate: LocationInputActivationViewDelegate?
    
    private let indicatorView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    private let placeHolderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Where to?"
        lb.font = UIFont.systemFont(ofSize: 18)
        lb.textColor = .darkGray
        
        return lb
    }()
    
//MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 6
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.anchor(left: leftAnchor, paddingLeft: 16, width: 8, height: 8)
        indicatorView.centerY(inView: self)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.anchor(left: indicatorView.rightAnchor, paddingLeft: 20)
        placeHolderLabel.centerY(inView: indicatorView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Selectors
    
    @objc func showLocationInputView()  {
        delegate?.presentLocationInputView()
    }
    
    
    
    
}
