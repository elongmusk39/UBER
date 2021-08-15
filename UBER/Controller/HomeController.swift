//
//  HomeController.swift
//  UBER
//
//  Created by Long Nguyen on 4/18/21.
//

import UIKit
import Firebase
import MapKit //import from default Xcode

private let reuseIdentifier = "locationCell"
private let annotationIdentifier = "driverAnnotation"

private enum actionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu //default value is ".showMenu"
    }
}

class HomeController: UIViewController {

//MARK: - Properties
    
    let currentEmail = Auth.auth().currentUser?.email ?? "no user"
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private var searchResults = [MKPlacemark]()
    
    private let rideActionView: RideActionView = {
        return RideActionView()
    }()
    
    private let inputActivationView: LocationInputActivationView = {
        return LocationInputActivationView()
    }()
    
    private let locationInputView: LocationInputView = {
        return LocationInputView()
    }()
    
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "gear")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.tintColor = .black
        //btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    private var actionButtonConfig = actionButtonConfiguration() //connect with the enum on the top
    
    private var route: MKRoute?
    
    //the 'didSet' got executed whenever it got modified. we can put it in the ViewDidLoad or func fetchData(). Now we pass in all data fetched back to 'userInfo' of 'locationInputView'
    private var userStuff: User? {
        didSet {
            locationInputView.userInfo = userStuff
            if userStuff?.accountType == .passenger {
                print("DEBUG: user is passenger")
                fetchDrivers()
                configureInputActView()
                observeNowTrip()
            } else {
                print("DEBUG: user is driver")
                observeTrips() //this func will observe the database, and fill in data for var "trip", which triggers its didSet function
            }
        }
    }
    
    //this var "trip" got filled up with fetched info in "func observeTrip". In the beginning, the "trip" is nil, then slowly filled with data and then triggers the "didSet"
    private var trip: Trip? {
        didSet {
            guard let user = userStuff else { return }
            if user.accountType == .driver {
                print("DEBUG: show pickup passenger controller")
                guard let tripStuff = trip else { return }
                let vc = PickupController(trip: tripStuff)
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            } else {
                print("DEBUG: show rideActionView for accepted trip")
            }
        }
    }
    
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfUserIsLoggedIn()
        enableLocationService()
        
        print("DEBUG: trip stuff is \(String(describing: trip))")
        //signOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tripState = trip?.state else { return }
        print("DEBUG: Trip state is \(tripState)")
    }
    
//MARK: - Helpers

    func configureInputActView() {
        
        view.addSubview(inputActivationView)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 20, width: view.frame.width - 64, height: 50)
        inputActivationView.centerX(inView: view)
        inputActivationView.alpha = 0
        
        //let the inputActivationView appear slowly in 2 secs
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureUI() {
        view.backgroundColor = .yellow
        configureMapView()
        
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16, width: 30, height: 30)
        
        
        inputActivationView.delegate = self
        locationInputView.delegate = self
        
        //pre-load the location tableView here
        configureTableView()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        //mapView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        mapView.frame = view.frame //cover the entire screen
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow //detect when user is moving. in the simulator, go on the status bar on top, tap "Feature" -> "Location" -> "custom location", and change the lat/longtitude
        mapView.delegate = self //to enable all func in the extension "MKMapViewDelegate"
        
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
    
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight) //start at the bottom of the screen, then it comes up from it
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
    
    func configure() {
        configureUI()
        fetchData()
    }
    
    //let's deal with the actionButton based on the "enum"
    fileprivate func configureActionButton(config: actionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setBackgroundImage(UIImage(systemName: "gear")?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setBackgroundImage(UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
//MARK: - API
    
    func observeNowTrip() {
        Service.shared.observeCurrentTrip { tripInfo in
            self.trip = tripInfo //fill in the info from Database
            
            if tripInfo.state == .accepted {
                print("DEBUG: trip was accepted..")
                self.showPresentLoadingView(false)
                
                guard let driverUid = tripInfo.driverUid else { return }
                Service.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, userAcc: driver)
                }
                
                self.animateRideActionView(shouldShow: true, config: .tripAccepted)
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {

        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: user not logged in")
            presentLoginVC()
        } else {
            print("DEBUG: user logged in as \(currentEmail)")
            configure()
        }
    }
    
    //get user info from Firebase
    func fetchData() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        //Service().fetchUserData() //dont do this since everytime you call this func, we create a new Service(). So use the "shared"
        Service.shared.fetchUserData(uid: currentUID) { (userData) in
            self.userStuff = userData
        }
    }
    
    //fetch locations of drivers within a certain radius
    func fetchDrivers() {
        guard userStuff?.accountType == .passenger else { return }
        
        guard let locationC = locationManager?.location else { return }
        
        //this func gets executed whenever the location is changed in the DB
        Service.shared.fetchDriver(locationRider: locationC) { driverInfo in
            print("DEBUG: driver is \(driverInfo.fullname) at \(driverInfo.location)")
            
            //now we got the driver location, let's present them on the map
            guard let coordinateD = driverInfo.location?.coordinate else {
                return
            }
            
            //fix the duplicated bug whenever driver changes location
            let annotationDriver = DriverAnnotation(uidDriver: driverInfo.uid, coordinateDriver: coordinateD)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains {
                    driverAnnotation -> Bool in
                    
                    guard let driverAnno = driverAnnotation as? DriverAnnotation else { return false }
                    
                    if driverAnno.driverUid == driverInfo.uid {
                        //driver's location matches with driverAnno (drivers that are visible on map), so that driver is already visible
                        print("DEBUG: updating driver's position..")
                        driverAnno.updateAnnotationPosition(newCoordinate: coordinateD)
                        return true //driverIsVisible is true
                    }
                    
                    return false //driverIsVisible is false
                }
            }
            
            
            //if 'driverIsVisible' is false, then we add them to the map
            if !driverIsVisible {
                self.mapView.addAnnotation(annotationDriver) //show driver on map
            }
            
        }
    }
    
    func observeTrips() {
        Service.shared.observeTrips { tripInfo in
            self.trip = tripInfo
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
            presentLoginVC()
        } catch {
            print("DEBUG: error signing out")
        }
    }
    
    @objc func actionButtonPressed() {
        //since we have an enum on top, use switch
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: handle show menu..")
        case .dismissActionView:
            print("DEBUG: handle dismiss..")
            
            //let's remove the annotation of the searched place
            removeAnnotationAndOverlays()
            
            //let's zoom back out and center the current location
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            //let's slowly show up the inputActivationView
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
            
        }
    }
    
    func dismissLocationView(completionBlock: ((Bool) -> Void)? = nil) {
        print("DEBUG: dismissing locationInputView..")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height //slide down the tableView to dismiss it
            
            self.locationInputView.removeFromSuperview() //to enhance the performance of the app. we will add the "locationInputView" back in when we call it
            
        }, completion: completionBlock)
        
        
    }
    
    //let's slide up the rideActionView
    func animateRideActionView(shouldShow: Bool, arrive: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, userAcc: User? = nil) {
        
        if shouldShow {
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height - self.rideActionViewHeight
            }
            
            guard let conf = config else { return }
            
            //the "arrive" is assigned in the tableView Delegate
            if let destination = arrive {
                rideActionView.destination = destination //pass in the data to rideActionView
            }
            
            if let userStuff = userAcc {
                rideActionView.userInfo = userStuff
            }
            
            //now let's set the UI
//            rideActionView.configureUI(withConfig: conf) //if "configureUI" is not private, use this line
            rideActionView.config = conf //pass in the data

        } else {
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height //pre-load the rideActionView
            }
        }
    }
    
    
    
}

//MARK: - Extension Map helpers
//let's find some places nearby based on current location
private extension HomeController {
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        
        var results = [MKPlacemark]()
        
        let requestSearch = MKLocalSearch.Request()
        requestSearch.region = mapView.region
        requestSearch.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: requestSearch)
        search.start { (response, error) in
            guard let responseExist = response else { return }
            
            responseExist.mapItems.forEach { item in
                guard let placeNearBy = item.name else { return }
                let locationInfo = item.placemark

                print("DEBUG: item is \(placeNearBy)")
                results.append(locationInfo)
            }
            
            completion(results) //a big array that stores all searched locations nearby
        }
        
    }
    
    //now we make the polyline generated from current location to destination
    func generatePolyLine(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionResquest = MKDirections(request: request)
        directionResquest.calculate { (res, error) in
            guard let response = res else { return }
            self.route = response.routes[0] //there are many routes lead to a destination, we just take the first route
            print("DEBUG: we have \(response.routes.count) routes")
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline) //let's add the polyline
        }
    }
    
    
    //now we remove the polyline and annotation
    func removeAnnotationAndOverlays() {
        // we loop through all annotations of the searched places and remove them one by one
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        //remove the polyline
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
        
    }
    
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000) //we got 2000 meters around the current location
        mapView.setRegion(region, animated: true)
    }
    
    
    func setCustomRegion(withCoordinates loca: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: loca, radius: 25, identifier: "pickup")
        locationManager?.startMonitoring(for: region)
        print("DEBUG: did set region \(region)")
    }
    
    
}

//MARK: - MapViewDelegate

extension HomeController: MKMapViewDelegate {
    //let's add a picture to describe the annotation of driver
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationDriver = annotation as? DriverAnnotation {
            let vw = MKAnnotationView(annotation: annotationDriver, reuseIdentifier: annotationIdentifier)
            vw.backgroundColor = .white
            vw.image = UIImage(systemName: "car.circle")
            vw.layer.cornerRadius = 40/2
            vw.setDimensions(height: 40, width: 40)
            return vw
        }
        return nil
    }
    
    //let's construct the polyline from current location to destination
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    //this func gets called when a driver changes his location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("DEBUG: did update user location..")
        guard let user = self.userStuff else { return }
        guard user.accountType == .driver else { return }
        guard let driverLocation = userLocation.location else { return }
        Service.shared.updateDriverLocation(locationDriver: driverLocation)
    }
    
}


//MARK: - Location Manager

//remember to modify the info.plist (go to NOTE to see details) before writing these codes, otherwise it crashes
extension HomeController {
    
    //this func will check the location status of the app. Now we have "requestWhenInUseAuthorization" will ask users 3 things (allow once, allow when using the app, and dont allow). click on one then proceed to other cases. if user allows, then we got case "whenInUse"
    func enableLocationService() {
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        //this case is the default case
        case .notDetermined:
            print("DEBUG: location notDetermined")
            locationManager?.requestWhenInUseAuthorization() //ask user to access location, when user allows to access, we hit case "whenInUse"
        case .restricted: //this case is trash
            print("DEBUG: location restricted")
            break
        case .denied:
            print("DEBUG: location denied")
            break
        case .authorizedAlways: //so this app only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG: location always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        case .authorizedWhenInUse:
            print("DEBUG: location whenInUse")
            locationManager?.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        @unknown default:
            print("DEBUG: location default")
            break
        }
    }
    
}

//set a custom region around the passenger for the driver to see. This func gets called when driver accepts the trip
extension HomeController: CLLocationManagerDelegate {
    //remember to write "locationManager.delegate = self" in enableLocationService
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("DEBUG: starting to monitor the region \(region)")
    }
    
    //this gets called when driver enter passenger region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEBUG: driver has entered passenger region with r = 25m")
        self.rideActionView.config = .pickupPassenger
    }
    
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

//MARK: - locationInputViewDelegate
//remember to set .delegate = self
extension HomeController: LocationInputViewDelegate {
    
    func dismissLocationInputView() {
        
        dismissLocationView { _ in
            //let's slowly show up the inputActivationView
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
        }

    }//end of func
    
    
    func executeSearch(searchFor: String) {
        print("DEBUG: query is \(searchFor)")
        searchBy(naturalLanguageQuery: searchFor) { (results) in
            //'results' is a huge array of locations
            //print("DEBUG: search did complete with placemark \(placeMarks)") //this will bring bunch of location nearby (with all info like distance and address) based on current location.
            
            self.searchResults = results //append to the array
            self.view.endEditing(true) //dismiss the keyboard
            self.tableView.reloadData() //re-call all datasource and delegate of the tableView
            
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
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        //cell.textLabel?.text = "location cell"
        
        if indexPath.section == 1 {
            cell.placeMark = searchResults[indexPath.row] //let's fill in the array 'placemark' of the cell with info searched
        }
        
        return cell
    }
    
    
}


//MARK: - tableView Delegate

extension HomeController: UITableViewDelegate {
    
    //either use this func (loop through stuff) or the one below
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        var annotationZoom = [MKAnnotation]()
//
//        let selectedPlacemark = searchResults[indexPath.row]
//
//        configureActionButton(config: .dismissActionView)
//
//        let destination = MKMapItem(placemark: selectedPlacemark)
//        generatePolyLine(toDestination: destination)
//
//        dismissLocationView { _ in
//            guard let addressClicked = selectedPlacemark.address else {
//                return
//            }
//            print("DEBUG: adding annotation of clicked location at: \(addressClicked)")
//
//            //let's deal with the annotation when we click on a cell
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = selectedPlacemark.coordinate
//            self.mapView.addAnnotation(annotation) //add the annotation on the map
//            self.mapView.selectAnnotation(annotation, animated: true) //make the annotation big and stand out
//
//            //let's zoom in the region that has current and selected location
//            self.mapView.annotations.forEach { annotation in
//                if let anno1 = annotation as? MKUserLocation {
//                    annotationZoom.append(anno1)
//                }
//
//                if let anno2 = annotation as? MKPointAnnotation {
//                    annotationZoom.append(anno2)
//                }
//            }
//
//            self.mapView.showAnnotations(annotationZoom, animated: true)
//        }
//
//
//    }
    
    //either use this func (filter) or the one above (loop through)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPlacemark = searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyLine(toDestination: destination)
        
        dismissLocationView { _ in
            guard let addressClicked = selectedPlacemark.address else {
                return
            }
            print("DEBUG: adding annotation of clicked location at: \(addressClicked)")
            
            //let's deal with the annotation when we click on a cell
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation) //add the annotation on the map
            self.mapView.selectAnnotation(annotation, animated: true) //make the annotation big and stand out
            
            //let's zoom in the region that has current and selected location
            let annotationZoom = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) }) //this line will eliminate all driver annotations, leaving only current + selected annotation on the map
            
            self.mapView.showAnnotations(annotationZoom, animated: true) //this line zooms in the 2 annotations
            
            //show rideActionView and pass the data to it
            self.animateRideActionView(shouldShow: true, arrive: selectedPlacemark, config: .requestRide)
            
            //zoom in or out so that rideActionView dont cover the selected and current location
            self.mapView.zoomToFit(annotations: annotationZoom)
        }
        
        
    }
    
    
}

//MARK: - Protocol RideActionView
//remember to write "rideActionView.delegate = self" in ViewDidLoad
extension HomeController: RideActionViewDelegate {
    func uploadTripProtocol(_ vw: RideActionView) {
        
        guard let pickupC = locationManager?.location?.coordinate else { return }
        guard let destinationC = vw.destination?.coordinate else { return }
        
        showPresentLoadingView(true, message: "Finding you a driver..")
        
        Service.shared.uploadTrip(pickupCoor: pickupC, destinationCoor: destinationC) { (err, ref) in
            if let e = err?.localizedDescription {
                print("DEBUG: fail to upload trip \(e)")
            }
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            print("DEBUG: successfully upload trip, finding an UBER..")
        }
    }
    
    //this func configure UI on the passenger side
    func cancelTrip() {
        Service.shared.cancelRide { (error, ref) in
            if let e = error?.localizedDescription {
                print("DEBUG: error deleting trip \(e)")
                return
            }
            
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationAndOverlays()
            
            //let's set the actionButton to be the menu
            self.actionButton.setBackgroundImage(UIImage(systemName: "gear")?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
            //add the inputActivationView back
            self.inputActivationView.alpha = 1
        }
        
    }
    
    
    
}

//MARK: - Protocol pickup accepted
//remember to write ".delegate = self" in the didSet. This is from driver's app
extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ tripStuff: Trip) {
        
        //let's add annotation to the passenger position
        let anno = MKPointAnnotation()
        anno.coordinate = tripStuff.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true) //make anno big
        
        //now set custom region to know if the driver has enter it
        setCustomRegion(withCoordinates: tripStuff.pickupCoordinates)
        
        //let's generate a polyline to passenger's location
        let placemark = MKPlacemark(coordinate: tripStuff.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyLine(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        animateRideActionView(shouldShow: true)
        
        //let's listen to DB if the trip is canceled. Let's do something after we done observing if the trip got canceled
        Service.shared.observeTripCanceled(trip: tripStuff) {
            print("DEBUG: passenger has canceled the trip..")
            self.removeAnnotationAndOverlays()
            self.animateRideActionView(shouldShow: false)
            //self.mapView.zoomToFit(annotations: self.mapView.annotations) //zoom very close to the current location of current user
            self.centerMapOnUserLocation()
            self.presentAlertController(withMessage: "The passenger has canceled the trip", withTitle: "Oops! Trips canceled!")
            
        }
        
        //dismiss from driver's app
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: tripStuff.passengerUid) { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, userAcc: passenger)
            }
            
        }
    }
    
    
}
