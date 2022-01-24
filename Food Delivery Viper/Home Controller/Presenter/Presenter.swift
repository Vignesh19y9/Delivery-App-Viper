//
//  Presenter.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import Foundation
import UIKit


class Presenter : AnyPresenter{
 
    var view: AnyView?
    
    var router: AnyRouter?
    
    var interactor: AnyInteractor?
    
    
    func viewDidLoad(with ViewController: AnyView) {
        //setting reference and intializing interactor
        view = ViewController
        interactor = Interactor()
        interactor?.presenter = self
        router = Router()
        router?.presenter = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getMyLocation), name: Notification.Name("App Active"), object: nil)
    }
    //Request current Location
    @objc func getMyLocation() {
        interactor?.getUserCurrentLocation()
    }
    
    func interactorDidFetchLocation(withResult: Result<LocationData, NetworkError>) {
        
        switch (withResult){
        case .success(let data):
            view?.updateWithCurrentLocation(data: data)
            
            break
        case .failure(let error) :
            switch(error){
                
            case .permission:
                view?.openSettings(withMessage: "Location Acess needed for google maps")
                break
            case .network:
                view?.openSettings(withMessage: "No Internet")
                break
            }
            break
        }
    }
    //Called when the route detail has been fetched from the server
    func routeDetailFetched(route: GoogleRouteModel?,errorMessage: String?) {
//      guard let sourceController = viewRef, let routeToBeshown = route else {
        if errorMessage != nil {
            view?.showAlert(withMessage: "There is a problem in fetching route. Please try again.")
        }
//        return
        view?.setUpMapRoute(routeToDisplay: route)
      }
    //Request to Find route
    func getRouteBetweenCoords() {
        interactor?.getRouteForSelectedCoordinates()
    }
    
    //Request to find places
    func getPlaces(forText text: String) {
        print("Searching Text \(text)")
        interactor?.findPlaceFromSearch(forText: text)
    }
    //Gives view the places from interactor
    func receivedSearchPlaces(places : [String]){
        if(places.count > 0){
            view?.updatePlacesList(with: places)
        }else{
            view?.showAlert(withMessage: "There is a problem in fetching Places. Please try again.")
        }
        
    }
    //Request to convert place name to lat and long
    func userSelectedPlace(place : String){
        print("Selected Place \(place )")
        interactor?.gecodeAdressToCoord(for: place)
    }
    func getNearbyPlaces(){
        interactor?.requestNearByPlaces()
    }
    //Gives view the nearby from interactor
    func fetchedNearByPlaces(nearBy : [GooglePlace]){
        if(nearBy.count > 0){
            view?.updateNearBy(nearBy: nearBy)
        }else{
            view?.showAlert(withMessage: "There is a problem in fetching nearby Places. Please try again.")
        }
       
    }
    func moveToNextPage(from vc : UIViewController) {
        
        if(interactor?.currentNearByPlace != nil){
            router?.moveToNextPage(from: vc, places: (interactor?.currentNearByPlace)!,adress: interactor?.userCoord.adress)
        }       
    }
    
}
