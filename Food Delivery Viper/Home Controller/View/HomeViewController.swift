//
//  HomeViewController.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import UIKit
import GoogleMaps

class HomeViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var topViewHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var popUpViewBottomConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var endLocationTextField: UITextField!
    @IBOutlet weak var adressTableView: UITableView!
    
    @IBOutlet weak var nearByLocationLabel: UILabel!
    @IBOutlet weak var findRouteLabel: UILabel!
    
    @IBOutlet weak var showButton: UIButton!
    var adressList : [String] = [String]()
    
    var mapView : GMSMapView!
    var presenter: AnyPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Presentor
        topViewHeightConstrain.constant = 0
        presenter = Presenter()
        presenter?.viewDidLoad(with: self)
        presenter?.getMyLocation()
        
        GMSServices.provideAPIKey(GoogleAPIConstants.key2)
        self.setMap()
        
        
        //delegates
        self.endLocationTextField.delegate = self
        self.adressTableView.delegate = self
        self.adressTableView.dataSource = self
        
        self.navigationController?.isNavigationBarHidden = true
        self.hideKeyboardWhenTappedAround()
        self.showButton.isHidden = true
        
        //Adding gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        findRouteLabel.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(nearBy(_:)))
        nearByLocationLabel.addGestureRecognizer(tap1)
        
        
    }
 
    //Adding intial map view
    func setMap(){
        // center of india
        let camera = GMSCameraPosition.camera(withLatitude: 20.5937, longitude:  78.9629, zoom: 4.0)
        mapView = GMSMapView.map(withFrame: self.bottomView.bounds, camera: camera)
        self.bottomView.addSubview(mapView)
        mapView.delegate = self
    }
    //show adress from presentor on tableview
    func updatePlacesList(with adressList : [String]){
        self.adressList = adressList
        self.adressTableView.reloadData()
        
    }
    func updateNearBy(nearBy : [GooglePlace]){
        nearBy.forEach {places in
            let marker = PlaceMarker(place: places)
            // 4
            marker.map = self.mapView
        }
        self.showButton.isHidden = false
    }
    //Switch back and forth between table view and map
    func switchMapView(front : Bool){
        if(front){
            self.bottomView.sendSubviewToBack(self.adressTableView)
            self.bottomView.bringSubviewToFront(self.mapView)
        }else{
            self.bottomView.sendSubviewToBack(self.mapView)
            self.bottomView.bringSubviewToFront(self.adressTableView)
        }
    }
    //Label tap functions
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if topViewHeightConstrain.constant == 0{
            toggleTopBar(show: true)
            return
        }
        toggleTopBar(show: false)
        
    }
    @objc func nearBy(_ sender: UITapGestureRecognizer? = nil) {
        self.presenter?.getNearbyPlaces()
       
        
    }
    //top bar hide and show with animation
    private func toggleTopBar(show : Bool){
        if (show){
            UIView.animate(withDuration: 0.5 ) {

                self.topViewHeightConstrain.constant = 110
                self.popUpViewBottomConstrain.constant = 0
                self.view.layoutIfNeeded()

            }
        }else{
            UIView.animate(withDuration: 0.5 ) {
                self.topViewHeightConstrain.constant = 0
                self.popUpViewBottomConstrain.constant = -70
                self.view.layoutIfNeeded()
            }
        }
    }
    func showAlert(withMessage : String){
        
        let alertController = UIAlertController(title: title, message: withMessage, preferredStyle:.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default)
           { action -> Void in
             // Put your code here
            alertController.dismiss(animated: true, completion: nil)
           })
           self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func locationAction(_ sender: Any) {

        if endLocationTextField.text! == "" {        
            self.showAlert(withMessage: "Enter destination")
          return
        }
        
        presenter!.getRouteBetweenCoords()
        self.toggleTopBar(show: false)

        }
    
    @IBAction func nearByListAction(_ sender: Any) {
        self.presenter?.moveToNextPage(from: self)
    }
    

    //show route from presentor on the map
    func setUpMapRoute(routeToDisplay : GoogleRouteModel?){
        DispatchQueue.main.async {
            
      let startMarker = GMSMarker(position: CLLocationCoordinate2DMake((routeToDisplay?.startLocationCoordinate?.coordinate.latitude)!, (routeToDisplay?.startLocationCoordinate?.coordinate.longitude)!))
            startMarker.map = self.mapView
      
      let endMarker = GMSMarker(position: CLLocationCoordinate2DMake((routeToDisplay?.endLocationCoordinate?.coordinate.latitude)!, (routeToDisplay?.endLocationCoordinate?.coordinate.longitude)!))
            endMarker.map = self.mapView
      
      routeToDisplay?.polyLine?.strokeColor = .blue
      routeToDisplay?.polyLine?.strokeWidth = 5.0
            routeToDisplay?.polyLine?.map = self.mapView
      
            self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake((routeToDisplay?.startLocationCoordinate?.coordinate.latitude)!, (routeToDisplay?.startLocationCoordinate?.coordinate.longitude)!), zoom: 8.0, bearing: 5.0, viewingAngle: 5.0)
        
        let distance = routeToDisplay?.distance
        let time = routeToDisplay?.duration
            
            self.showAlert(withMessage: "Distance " + (distance ?? "0") + " ETA : " + (time ?? "0"))
        }
    }
    
    
     
    
}
extension HomeViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AdressTableViewCell") as? AdressTableViewCell
        cell?.adressLabel.text = adressList[indexPath.item]
        
        return cell!
    }
    //when user click the place
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        endLocationTextField.text = self.adressList[indexPath.item]
        presenter?.userSelectedPlace(place : self.adressList[indexPath.item])
    }
    
    
}
extension HomeViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(shouldREturn){
            presenter?.getPlaces(forText: self.endLocationTextField.text!)
        }
        
        return true
    }

    //Getting text from textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var searchText = ""
        if string.isEmpty {
            searchText = self.endLocationTextField.text!
            searchText = String(searchText.dropLast())// last character will remain
        }else{
            searchText=self.endLocationTextField.text!+string
        }
        //search on return for reducing api limit
        if(!shouldREturn){
            presenter?.getPlaces(forText: searchText)
        }
        
        return true
    }
    
    //switch views when text editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switchMapView(front: false)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switchMapView(front: true)
    }
}

extension HomeViewController : AnyView{
    
    func openSettings(withMessage: String) {
        DispatchQueue.main.async {
         
            let alertController = UIAlertController(title: "Open Settings", message: withMessage, preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                 }
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:  {[weak self]_ in
            
                self?.presenter?.getMyLocation()
            })

            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)

            // check the permission status
            
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    
    
    func updateWithCurrentLocation(data : LocationData) {
        
        mapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: data.latitude, longitude: data.longitude, zoom: 10.0)

        self.mapView?.animate(to: camera)
        
        toggleTopBar(show: true)
        
    }
    
}


// Hide keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension HomeViewController : GMSMapViewDelegate{
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
      // 1
      guard let placeMarker = marker as? PlaceMarker else {
        return nil
      }
        
      // 2
      guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
        return nil
      }
        
      // 3
      infoView.nameLabel.text = placeMarker.place.name
        
      // 4
      if let photo = placeMarker.place.photo {
        infoView.placePhoto.image = photo
      } else {
        infoView.placePhoto.image = UIImage(named: "generic")
      }
        
      return infoView
    }
    
    
}
extension UIView {
    class func viewFromNibName(_ name: String) -> UIView? {
      let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
      return views?.first as? UIView
    }
}

extension UIActivityIndicatorView {
     func dismissLoader() {
        DispatchQueue.main.async {
        
            self.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
 }


