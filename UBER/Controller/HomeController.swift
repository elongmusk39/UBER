//
//  HomeController.swift
//  UBER
//
//  Created by Long Nguyen on 4/18/21.
//

import UIKit
import Firebase
import MapKit //import from external module

private let reuseIdentifier = "locationCell"

class HomeController: UIViewController {

//MARK: - Properties
    
    let currentEmail = Auth.auth().currentUser?.email ?? "no user"
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    private let inputActivationView: LocationInputActivationView = {
        return LocationInputActivationView()
    }()
    
    private let locationInputView: LocationInputView = {
        return LocationInputView()
    }()
    
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200
    
    //the 'didSet' got executed whenever "fullname" got modified. we can put it in the ViewDidLoad or func fetchData(). Now we pass in all data fetched back to 'userInfo' of 'locationInputView'
    private var userStuff: User? {
        didSet { locationInputView.userInfo = userStuff }
    }
    
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfUserIsLoggedIn()
        enableLocationService()
        fetchData()
        //signOut()
    }
    
    
//MARK: - Helpers

    func configureUI() {
        view.backgroundColor = .yellow
        configureMapView()
        
        view.addSubview(inputActivationView)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: view.frame.width - 64, height: 50)
        inputActivationView.centerX(inView: view)
        inputActivationView.alpha = 0
        
        inputActivationView.delegate = self
        locationInputView.delegate = self
        
        //let the inputActivatioView appear slowly in 2 secs
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        //pre-load the location tableView here
        configureTableView()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        //mapView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        mapView.frame = view.frame //cover the entire screen
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow //detect when user is moving. in the simulator, go on the status bar on top, tap "Feature" -> "Location" -> "custom location", and change the lat/longtitude
        
    }
    
    //everytime this func gets called (in the protocol), we add a new subview into the main thread, so remember to remove it when we dismiss it, otherwise your app cant perform well
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        
        //according to the completion block, the animation happens in order
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            print("DEBUG: presenting the tableVIew")
            
            //let's slide up the tableView
            UIView.animate(withDuration: 0.5) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }

    }
    
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView() //remove the abundant lines
        
        let tableViewheight = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: tableViewheight) //start at the bottom of the screen, then it comes up from it
        
        view.addSubview(tableView)
    }
    
    
//MARK: - API
    
    func checkIfUserIsLoggedIn() {

        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: user not logged in")
            presentLoginVC()
        } else {
            print("DEBUG: user logged in as \(currentEmail)")
            configureUI()
        }
    }
    
    func fetchData() {
        //Service().fetchUserData() //dont do this since everytime you call this func, we create a new Service(). So use the "shared"
        Service.shared.fetchUserData { (userData) in
            self.userStuff = userData
        }
    }
    
//MARK: - Actions
    
    //remember to do this shit on the main thread (if normal way dont work, then just throw in the "DispatchQueue")
    func presentLoginVC() {
        DispatchQueue.main.async {
            let vc = LoginController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalTransitionStyle = .coverVertical
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: signing user out..")
        } catch {
            print("DEBUG: error signing out")
        }
    }
    
}


//MARK: - Location Manager

//remember to modify the info.plist (go to NOTE to see details) before writing these codes, otherwise it crashes
extension HomeController: CLLocationManagerDelegate {
    
    //this func will check the location status of the app. Now we have "requestWhenInUseAuthorization" will ask users 3 things (allow once, allow when using the app, and dont allow). click on one then proceed to other cases. if user allows, then we got case "whenInUse"
    func enableLocationService() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        //this case is the default case
        case .notDetermined:
            print("DEBUG: location notDetermined")
            locationManager.requestWhenInUseAuthorization() //ask user to access location, when user allows to access, we hit case "whenInUse"
        case .restricted: //this case is trash
            print("DEBUG: location restricted")
            break
        case .denied:
            print("DEBUG: location denied")
            break
        case .authorizedAlways: //so this app only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG: location always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        case .authorizedWhenInUse:
            print("DEBUG: location whenInUse")
            locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        @unknown default:
            print("DEBUG: location default")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG: current status is whenInUse, requesting always")
            locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        } else if status == .authorizedAlways {
            print("DEBUG: current status is always")
        }
    }
    
}


//MARK: - tableView Datasource

extension HomeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "title section"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        //cell.textLabel?.text = "location cell"
        return cell
    }
    
    
}


//MARK: - tableView Delegate

extension HomeController: UITableViewDelegate {
    
    
    
}


//MARK: - Show locationInputView
//this protocol was created in LocationInputActivatioView, remember to write .delegate = self
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        print("DEBUG: show input view..")
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
}

//MARK: - Dismiss locationInputView
//remember to set .delegate = self
extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        print("DEBUG: dismissing locationInputView..")
        
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height //slide down the tableView
            
        } completion: { _ in
            self.locationInputView.removeFromSuperview() //to enhance the performance of the app. we will add the "locationInputView" back in when we call it
            
            //let's slowly show up the inputActivationView
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

    }//end of func
    
    
}
