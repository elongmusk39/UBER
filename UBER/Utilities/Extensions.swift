//
//  Extensions.swift
//  UBER
//
//  Created by Long Nguyen on 4/17/21.
//

import UIKit
import CoreLocation
import MapKit

//MARK: - Layouts

extension UIView {
    
    //make top, left, bottom, right, width, height optional so we dont have to pass them in whenever we call this func (we can pass them in if needed)
    //The top, left, bottom, right are anchors, which indicate where to aim our constraints, the padding is to set the number (how wide or short the constraints are)
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        //this shit is crucial
        translatesAutoresizingMaskIntoConstraints = false
      
        
        //in case we pass some optionals above in, then gotta make them active
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
   
    
    
    //those 2 func below allow us to set up center X and Y
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    //those func below allow us to set up width and height
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    
    //MARK: - InputContainerView
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentedControl: UISegmentedControl? = nil ) -> UIView {
        let vw = UIView()
        
        let iv = UIImageView()
        iv.image = image
        iv.tintColor = .white
        iv.alpha = 0.87
        vw.addSubview(iv)
        
        
        //the textField is optional so gotta check it
        if let tf = textField {
            iv.anchor(left: vw.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            iv.centerY(inView: vw)
            
            vw.addSubview(tf)
            tf.anchor(left: iv.rightAnchor, right: vw.rightAnchor, paddingLeft: 8, paddingRight: 4)
            tf.centerY(inView: vw)
        }
        
        //if we have segmented control, then we modify the anchor of iv
        if let sc = segmentedControl {
            iv.anchor(top: vw.topAnchor, left: vw.leftAnchor, paddingTop: 2, paddingLeft: 8, width: 24, height: 24)
            vw.addSubview(sc)
            sc.anchor(top: iv.bottomAnchor, left: vw.leftAnchor, right: vw.rightAnchor, paddingTop: 10, paddingLeft: 8, paddingRight: 8)
        }
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = .white
        vw.addSubview(separatorView)
        separatorView.anchor(left: vw.leftAnchor, bottom: vw.bottomAnchor, right: vw.rightAnchor, paddingLeft: 2, paddingRight: 2, height: 1)
        
        return vw
    }
    
//MARK: - Add shadow
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
    }
    
}


//MARK: - Navigation VC

extension UIViewController {
    
    //let's customize the navigation bar
    func configureNavigationBar (hideOrNot: Bool, title: String, preferLargeTitle: Bool, backgroundColor: UIColor) {
        
        navigationController?.navigationBar.isHidden = hideOrNot
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() //just call it
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] //enables us to set our big titleColor to black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = backgroundColor
        
        //just call it for the sake of calling it
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance //when you scroll down, the nav bar just shrinks
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        //specify what show be showing up on the nav bar
        navigationController?.navigationBar.prefersLargeTitles = preferLargeTitle
        navigationItem.title = title
        navigationController?.navigationBar.tintColor = .red //enables us to set the color for the image or any nav bar button
        navigationController?.navigationBar.isTranslucent = true
        
        //this line below specifies the status bar (battery, wifi display) to white, this line of code is only valid for large title nav bar
        navigationController?.navigationBar.overrideUserInterfaceStyle = .light
    }
}


//MARK: - TextField

extension UITextField {
    
    func textField(withPlaceHolder holder: String, isSecure: Bool) -> UITextField {
        
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecure
        tf.attributedPlaceholder = NSAttributedString(string: holder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return tf
    }
}


//MARK: - extension MKPlacemark

extension MKPlacemark {
    
    //let's construct the addres
    var address: String? {
        get {
            guard let subThoroughFare = subThoroughfare else { return nil}
            guard let thoroughFare = thoroughfare else { return nil}
            guard let locality = locality else { return nil}
            guard let adminArea = administrativeArea else { return nil}
            
            let addressContruct = "\(subThoroughFare), \(thoroughFare), \(locality), \(adminArea)"
            return addressContruct
        }
    }
}


//MARK: - extension MKMapView

extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { anno in
            let annotationPoint = MKMapPoint(anno.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
            
        }
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 250, right: 100)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    
}

//let's show the loadingView of "finding driver"
extension UIViewController {
    //writing " = nil" to to provide default value equal nil
    func showPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let vw = UIView()
            vw.frame = self.view.frame
            vw.backgroundColor = .black
            vw.alpha = 0
            vw.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.center = vw.center
            
            let lb = UILabel()
            lb.text = message
            lb.font = UIFont.systemFont(ofSize: 20)
            lb.textColor = .white
            lb.textAlignment = .center
            lb.alpha = 0.87
            
            view.addSubview(vw)
            vw.addSubview(indicator)
            vw.addSubview(lb)
            
            lb.centerX(inView: view)
            lb.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                vw.alpha = 0.7
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }

                }
            }
        }
        
        
    }
    
    
    func presentAlertController(withMessage text: String, withTitle: String) {
        let alert = UIAlertController(title: withTitle, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
}
