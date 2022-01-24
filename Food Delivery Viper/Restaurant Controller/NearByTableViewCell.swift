//
//  NearByTableViewCell.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 24/01/22.
//

import UIKit

class NearByTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NearByImageView : UIImageView!
    @IBOutlet weak var NearByLabel: UILabel!
    
    var isDetailShown : Bool!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        

        // Configure the view for the selected state
    }
    override func prepareForReuse(){
        NearByLabel.text = ""
//        NearByImageView.image = UIImage(named: "restaurant")
    }
    
    func configure(data : GooglePlace){
        NearByLabel.text = data.name
        NearByImageView.image = data.photo
    }

}
