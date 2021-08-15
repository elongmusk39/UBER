//
//  PickupController.swift
//  UBER
//
//  Created by Long Nguyen on 4/25/21.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: class {
    func didAcceptTrip(_ tripStuff: Trip)
}

class PickupController: UIViewController {

    weak var delegate: PickupControllerDelegate?
    
//MARK: - Properties
    
    private let mapView = MKMapView()
    
    let tripInfo: Trip //this is called in the "init" section
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        //btn.setTitle("hello", for: .normal)
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return btn
    }()
    
    private let pickupLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Would you like to pick up this passenger?"
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .white
        
        return lb
    }()
    
    private let acceptTripButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .black
        btn.setTitle("ACCEPT TRIP", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - Lifecycle
    
    init(trip: Trip) {
        self.tripInfo = trip //got filled up with fetched info from HomeVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureMapView()
    }
    
    //let's hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

//MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleAcceptTrip() {
        print("DEBUG: driver accepts the trip")
        Service.shared.acceptTrip(trip: tripInfo) { (error, ref) in
            //we gonna dismiss the VC in the HomeVC, through this delegate
            self.delegate?.didAcceptTrip(self.tripInfo)
        }
    }
    
//MARK: - API
    
    
    
//MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        cancelButton.setDimensions(height: 24, width: 22)
        
        view.addSubview(mapView)
        mapView.layer.cornerRadius = 270 / 2
        mapView.centerX(inView: view)
        mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: 270, height: 270)
        
        view.addSubview(pickupLabel)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        pickupLabel.centerX(inView: view)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: tripInfo.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000) //make 1000m distance around the center
        mapView.setRegion(region, animated: false)
        
        //let's add annotation to configure the center
        let placemark = MKPlacemark(coordinate: tripInfo.pickupCoordinates)
        let anno = MKPointAnnotation()
        anno.coordinate = tripInfo.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
    
}
