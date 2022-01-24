//
//  NearByViewController.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 24/01/22.
//

import UIKit

struct sectionData{
    
    var placeData : GooglePlace!
    var isOpened : Bool = false
}

class NearByViewController: UIViewController {

    @IBOutlet weak var NearByTableView : UITableView!
    @IBOutlet weak var adressLabel: UILabel!
    
    var nearByData : [GooglePlace]!
    var sectionDatas : [sectionData]!
    var locationAdress : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NearByTableView.delegate = self
        NearByTableView.dataSource = self
        
        if locationAdress != nil{
            adressLabel.text = locationAdress
        }
        //creatig formatted data for colapsable tableview
        if nearByData != nil{
            
            sectionDatas = [sectionData]()
            for i in 0...nearByData.count - 1{
                sectionDatas.append(sectionData(placeData: nearByData[i], isOpened: false))
            }
        }
    }
    

}
extension NearByViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDatas.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = sectionDatas[section]
        
        if sec.isOpened{
            return 2
        }
        else{
            return 1
        }
//        return nearByData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NearByTableViewCell") as? NearByTableViewCell
//
//        cell?.configure(data: nearByData[indexPath.item])
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearByTableViewCell") as? NearByTableViewCell
            cell?.configure(data: sectionDatas[indexPath.section].placeData)
            return cell!
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdressTableViewCell") as? AdressTableViewCell
            
            let adress = sectionDatas[indexPath.section].placeData.address
            let type = sectionDatas[indexPath.section].placeData.placeType
            
            cell?.adressLabel.text =  "\(adress) , \(type)"
            
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        sectionDatas[indexPath.section].isOpened = !sectionDatas[indexPath.section].isOpened
        tableView.reloadSections([indexPath.section], with: .none)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 120
        }
        else{
            return UITableView.automaticDimension
        }
    }
    
}
