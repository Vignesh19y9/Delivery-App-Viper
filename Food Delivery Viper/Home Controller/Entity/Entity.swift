//
//  Entity.swift
//  Food Delivery Viper
//
//  Created by VIGNESH on 22/01/22.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import GoogleMaps

struct LocationData: Codable{
    var latitude : Double
    var longitude : Double
    var adress : String = ""
}

struct GmsPlacesData{
    var placeName : String
    var id : String
}

struct GoogleRouteModel {
  
  var polyLine: GMSPolyline?
  var distance: String?
  var duration: String?
  var startAddress: String?
  var endAddress: String?
  
  var startLocationCoordinate: CLLocation?
  var endLocationCoordinate: CLLocation?
  
  init(routeAttributes: [String: AnyObject]) {
    
    if let legs = routeAttributes["legs"] as? [[String: AnyObject]] {
      distance = (legs[0]["distance"] as! [String: AnyObject])["text"] as? String
      duration = (legs[0]["duration"] as! [String: AnyObject])["text"] as? String
      if let start_address = legs[0]["start_address"] as? String {
        startAddress = start_address
      }
      
      if let end_address = legs[0]["end_address"] as? String {
        endAddress = end_address
      }
      
      if let end_location = legs[0]["end_location"] as? [String: AnyObject], let startLocation = legs[0]["start_location"] as? [String: AnyObject] {
        
        let startLat = startLocation["lat"] as! Double
        let startLong = startLocation["lng"] as! Double
        startLocationCoordinate = CLLocation(latitude: startLat, longitude: startLong)
        
        let endLat = end_location["lat"] as! Double
        let endLong = end_location["lng"] as! Double
        endLocationCoordinate = CLLocation(latitude: endLat, longitude: endLong)
        
      }
      
    }
    
    if let overview_polyline = routeAttributes["overview_polyline"] as? [String: AnyObject] {
      guard let encodedString = overview_polyline["points"] as? String else {return}
      polyLine = generatePolyline(encodedString: encodedString)
    }
    
  }
  
  func generatePolyline(encodedString: String)->GMSPolyline {
    
    let path = GMSMutablePath(fromEncodedPath: encodedString)
    let polyline = GMSPolyline(path: path)
    return polyline
    
  }
  
}


class GooglePlace {
  
  let name: String
  let address: String
  let coordinate: CLLocationCoordinate2D
  let placeType: String
  var photoReference: String?
  var photo: UIImage?
  
  init(dictionary: [String: Any], acceptedTypes: [String])
  {
    let json = JSON(dictionary)
    name = json["name"].stringValue
    address = json["vicinity"].stringValue
    
    let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
    let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
    coordinate = CLLocationCoordinate2DMake(lat, lng)
    
    photoReference = json["photos"][0]["photo_reference"].string
    
    var foundType = "restaurant"
    let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    
    if let types = json["types"].arrayObject as? [String] {
      for type in types {
        if possibleTypes.contains(type) {
          foundType = type
          break
        }
      }
    }
      placeType = foundType
  }
}

class PlaceMarker: GMSMarker {
  // 1
  let place: GooglePlace

  // 2
  init(place: GooglePlace) {
    self.place = place
    super.init()

    position = place.coordinate
    icon = UIImage(named: place.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = .pop
  }
}
