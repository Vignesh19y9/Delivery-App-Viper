//
//  Protocols.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import Foundation
import UIKit

protocol AnyView{
    
    var presenter : AnyPresenter? {get set}
    
    func updateWithCurrentLocation(data : LocationData)
    func openSettings(withMessage : String)
    func updatePlacesList(with adressList : [String])
    func setUpMapRoute(routeToDisplay : GoogleRouteModel?)
    func updateNearBy(nearBy : [GooglePlace])
    func showAlert(withMessage : String)
    
    
}
protocol AnyInteractor{
    
    var presenter : AnyPresenter? {get set}
    
    var userCoord : LocationData! {get set}
    var currentCoord : LocationData! {get set}
    var currentNearByPlace : [GooglePlace]! {get set}
    
    func getUserCurrentLocation()
    func findPlaceFromSearch(forText text : String)
    func getRouteForSelectedCoordinates()
    func gecodeAdressToCoord(for place : String)
    func requestNearByPlaces()
    
    
}
protocol AnyPresenter{
    
    var router : AnyRouter? {get set}
    var interactor : AnyInteractor? {get set}
    var view : AnyView? {get set}
    
    func viewDidLoad(with ViewController : AnyView)
    func getMyLocation()
    
    func interactorDidFetchLocation(withResult : Result<LocationData , NetworkError>)
    func getPlaces(forText text : String)
    
    func getRouteBetweenCoords()
    func userSelectedPlace(place : String)
    func routeDetailFetched(route: GoogleRouteModel?,errorMessage: String?)
    
    func receivedSearchPlaces(places : [String])
    
    func getNearbyPlaces()
    func fetchedNearByPlaces(nearBy : [GooglePlace])
    
    func moveToNextPage(from vc : UIViewController)
    
    
}

protocol AnyRouter{
    var presenter : AnyPresenter? {get set}
    
    static func start() -> AnyRouter
    func moveToNextPage(from vc : UIViewController , places : [GooglePlace] ,adress : String?)
}
