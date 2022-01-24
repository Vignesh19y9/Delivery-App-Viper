//
//  Router.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import Foundation
import UIKit

class Router:AnyRouter{
    
    var presenter : AnyPresenter?
    
    static func start() -> AnyRouter {
        
        let router = Router()
//        var view : AnyView = HomeViewController()
//        var presenter : AnyPresenter = Presenter()
//        var interactor : AnyInteractor = Interactor()
//
//        view.presenter = presenter
//        interactor.presenter = presenter
//        presenter.router = router
//        presenter.view = view
        
        return router
    }
    func moveToNextPage(from vc : UIViewController , places : [GooglePlace] ,adress : String?){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nearbyvc = storyboard.instantiateViewController(withIdentifier: "NearByViewController") as! NearByViewController
        
        nearbyvc.nearByData = places
        nearbyvc.locationAdress = adress
        vc.present(nearbyvc, animated: true, completion: nil)
    }
}
