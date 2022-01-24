//
//  ViewController.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view.
    }


    @IBAction func loginAction(_ sender: Any) {
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let mapsController = mainStoryBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//        mapsController.routeToDisplay = route
//        guard let sourceNavigationController = classRef.navigationController else {
//          classRef.present(mapsController, animated: true, completion: nil)
//          return
//        }
        self.navigationController?.pushViewController(mapsController, animated: true)
        
    }
}

