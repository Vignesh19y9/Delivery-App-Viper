//
//  Interactor.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import Foundation
import CoreLocation
import Network

import GooglePlaces

enum NetworkError: Error {
    case permission
    case network
}

class Interactor : NSObject, AnyInteractor{

    var presenter: AnyPresenter?
    var locationManager: CLLocationManager?
    var notificationCenter: UNUserNotificationCenter?
    
    let monitor = NWPathMonitor()
    
    var userCoord : LocationData!
    var currentCoord : LocationData!
    var currentNearByPlace : [GooglePlace]!
    
    let dataProvider = GoogleDataProvider()
    
    
    func getUserCurrentLocation() {
        checkLocationPermission()
        checkNetworkConnectivity()
        checkNotificationPermission()

    }
    
    //Finds the possible places on search and returns to presenter
    func findPlaceFromSearch(forText text : String){
        
        dataProvider.fetchPlacesfromKey(key: text){[weak self] placeData in
            
            if placeData != nil && placeData!.count > 0{
                var placesString = [String]()
                //Converts to list of strings
                for p in 0...placeData!.count - 1{
                    placesString.append(placeData![p].placeName)
                }
                
                self?.presenter?.receivedSearchPlaces(places : placesString)
            }
        }
    }
    //Maps places to coordinates in map
    func gecodeAdressToCoord(for place : String){
        dataProvider.geoCodePlaces(place: place){[weak self] coordData in
            //save Data
            if coordData != nil{
                print("\(place) converted to coordinates \(coordData)")
                self?.currentCoord = coordData
            }
        }
    }
    //Maps places to coordinates in map
    func gecodeCoordToAdress(for place : LocationData){
        dataProvider.geoCodeCoords(place: place){[weak self] adress in
            //save Data
            if adress != nil{
                print("\(place) converted to Adress \(adress)")
                self?.userCoord.adress = adress!
            }
        }
    }
   //Route between coordinates
    func getRouteForSelectedCoordinates() {
        if(currentCoord != nil && userCoord != nil){
            
        dataProvider.getRouteBetweenPlaces(startCoord: userCoord, endCoord: currentCoord){routeData in
            if(routeData != nil){
                self.presenter?.routeDetailFetched(route: routeData, errorMessage: nil)
                //Start region monitoring
                self.activateGeofencing()
            }
        }
        }
    }

// MARK: Private Functions
    
    //Ask location permission
    private func checkLocationPermission(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
    //Ask Notification permission
    private func checkNotificationPermission(){
        self.notificationCenter = UNUserNotificationCenter.current()
                    
            // register as it's delegate
            notificationCenter?.delegate = self

            // define what do you need permission to use
            let options: UNAuthorizationOptions = [.alert, .sound]
      
            // request permission
            notificationCenter?.requestAuthorization(options: options) { [weak self](granted, error) in
                if !granted {
                    print("Permission not granted")
                    self?.presenter?.interactorDidFetchLocation(withResult: .failure(.permission))
                }
            }

    }
    //Check for internet connection
    private func checkNetworkConnectivity(){
        
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                print("connected!")
                self?.requestCurrentLocation()
            } else {
                print("No connection.")
                self?.presenter?.interactorDidFetchLocation(withResult: .failure(.network))
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
    }
    //Request current coordinates
    private func requestCurrentLocation(){
        //Location Manager code to fetch current location
        
        locationManager?.startUpdatingLocation()
        
    }
    //Start monitoring the destination location
    private func activateGeofencing(){
        let geofenceRegionCenter = CLLocationCoordinate2DMake(8.8932, 76.6141)

        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: 100,
                                              identifier: "UniqueIdentifier")
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        locationManager?.startMonitoring(for: geofenceRegion)
        
    }
    //Handle notification for geo fencing
    private func handleEvent(forRegion region: CLRegion!, status : String) {

        // customize your notification content
        let content = UNMutableNotificationContent()
        content.title = "Destination " + status
        content.body = ""
        content.sound = UNNotificationSound.default

        // when the notification will be triggered
        var timeInSeconds: TimeInterval = 1//(60 * 15) // 60s * 15 = 15min
        // the actual trigger object
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                        repeats: false)

        // notification unique identifier, for this example, same as the region to avoid duplicate notifications
        let identifier = region.identifier

        // the notification request object
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        // trying to add the notification request to notification center
        notificationCenter?.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
    
    
    
    func requestNearByPlaces(){
        
         print("Finding near by")
         let dataProvider = GoogleDataProvider()
         let searchRadius: Double = 1000

//        dataProvider.
        let coords = CLLocationCoordinate2D(latitude: 8.478467391328868 ,longitude: 76.96231550523025)
        dataProvider.fetchPlacesNearCoordinate(coords, radius:searchRadius, types: ["restaurant"]) { places in
//            places.forEach {places in
//
//                if(places != nil){
//                    print(places)
//                    self.currentNearByPlace = places
//                    self.presenter?.fetchedNearByPlaces(nearBy: places)
//                }
//          }
            if(places != nil && places.count > 0){
                self.currentNearByPlace = places
                self.presenter?.fetchedNearByPlaces(nearBy: places)
            }
        }
    }

}
// Mark : Location Manager Delegates
extension Interactor : CLLocationManagerDelegate{
// Location Permission delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            print("notDetermined")
            locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            self.requestCurrentLocation()
            // If authorized when in use
//            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            print("authorizedAlways")
            self.requestCurrentLocation()
            // If always authorized
//            manager.startUpdatingLocation()
            break
        case .restricted:
            print("restricted")
            
            presenter?.interactorDidFetchLocation(withResult: .failure(.permission))
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            print("denied")
            
            presenter?.interactorDidFetchLocation(withResult: .failure(.permission))
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
        }
// Users current Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        let location = locations.last
        let locData = LocationData(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        print(locData)
        
        //Storing user coordinates
        
        userCoord = locData
        gecodeCoordToAdress(for: userCoord)
        presenter?.interactorDidFetchLocation(withResult: .success(locData))
        
        locationManager?.stopUpdatingLocation()
        
//        let camera = GMSCameraPosition.cameraWithLatitude((location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
//
//        self.mapView?.animateToCameraPosition(camera)
//
//        //Finally stop updating location otherwise it will come again and again in this delegate
//        self.locationManager.stopUpdatingLocation()

    }
//Region Monitoring Delegates
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
//            self.handleEvent(forRegion: region)
            print("Location exit 000000")
            handleEvent(forRegion: region, status: "Exited")
        }
    }
    
    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
//            self.handleEvent(forRegion: region)
            print("Location enterd 000000")
            handleEvent(forRegion: region, status: "Entered")
        }
    }
    
}
//Notification Delegates
extension Interactor : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        print("Notification")
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // get the notification identifier to respond accordingly
        print("Notification")
        let identifier = response.notification.request.identifier
        
        // do what you need to do
      
        // ...
    }
    
}

