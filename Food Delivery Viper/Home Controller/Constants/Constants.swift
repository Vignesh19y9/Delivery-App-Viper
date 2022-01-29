//
//  Constants.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 23/01/22.
//

import Foundation

let shouldREturn = false

enum GoogleAPIConstants {
    
    static let key = ""//Maps sdk key
    static let key2 = ""//Route key
    
    
}

struct GoogleUrls{
    
    func nearByUrl(lat : Double,long : Double ,radius : Double) -> String{
        
       return "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=\(radius)&rankby=prominence&sensor=true&key=\(GoogleAPIConstants.key)"
    }
    
    func routeUrl(start : LocationData,end : LocationData) -> String{
        
        return "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)&sensor=false&mode=driving&key=\(GoogleAPIConstants.key2)"
    }
    
    func geocdeCoordsUrl(place : String)-> String{
        
        return "https://maps.googleapis.com/maps/api/geocode/json?address=\(place)&sensor=false&key=\(GoogleAPIConstants.key)"
    }
    
    func geocdeAdresssUrl(place : LocationData)-> String{
        
        return "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(place.latitude),\(place.longitude)&key=\(GoogleAPIConstants.key)"
    }
    
}



//"AIzaSyCbUaNMEhxu11BmllfCa0Gg3AAZPz9ZjF0"
//"AIzaSyAT-uKygf9QKthNfe1TxZgGhTkpTp0htjg"
//"AIzaSyC95FSA6CwwcsplnZjflTEhwicltWzBwiQ"
//"AIzaSyAV5qoB2RRn3cwYAKLT6ot8aNbwi6Mzdao"
//"AIzaSyDt-hLUignc2P9lTLP-8x9C80kKyYtrQyM"
//"AIzaSyC95FSA6CwwcsplnZjflTEhwicltWzBwiQ"
