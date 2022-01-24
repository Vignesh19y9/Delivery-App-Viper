//
//  GoogleDataProvider.swift


import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import GooglePlaces

typealias NearbyPlacesCompletion = ([GooglePlace]) -> Void
typealias RouteCompletion = (GoogleRouteModel?) -> Void
typealias PlacesCompletion = ([GmsPlacesData]?) -> Void
typealias GeocodeCompletion = (LocationData?) -> Void
typealias GeocodeCompletion2 = (String?) -> Void

typealias PhotoCompletion = (UIImage?) -> Void

class GoogleDataProvider {
    
  private var photoCache: [String: UIImage] = [:]
  private var placesTask: URLSessionDataTask?
  private var session: URLSession {
    return URLSession.shared
  }
    
    func fetchPlacesfromKey(key : String , completion : @escaping PlacesCompletion){
        
        let placesClient = GMSPlacesClient()
        let token = GMSAutocompleteSessionToken.init()
        // Create a type filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        //filter.locationBias = GMSPlaceRectangularLocationOption( northEastBounds,southWestBounds);
        //geo bounds set for bengaluru region
        //let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 13.001356, longitude: 75.174399), coordinate: CLLocationCoordinate2D(latitude: 13.343668, longitude: 80.272055))
        
        //Find Places using google places client
        placesClient.findAutocompletePredictions(fromQuery: key,
                                                      filter: filter,
                                                      sessionToken: token,
                                                      callback: { (results, error) in
                if let error = error {
                  print("Autocomplete error: \(error)")
                  completion(nil)
                  return
                }
                if let results = results {
                  print("Autocomplete Result: \(results)")
                  var PlacesList = [GmsPlacesData]()
                  for result in results {
                      
                      PlacesList.append(GmsPlacesData(placeName: result.attributedFullText.string, id: result.placeID))
                  }
                  completion(PlacesList)
                }
        })
    }
    
    func geoCodePlaces(place : String , completeion : @escaping GeocodeCompletion){
      
      let geocodeUrl = GoogleUrls().geocdeCoordsUrl(place: place)
        
      WebServiceManager.sharedService.requestApi(url: geocodeUrl, parameter: nil, httpMethodType: .GET) { (response, error) in
          
          guard let data = response else {
              completeion(nil)
            return
          }
                                                                                              
          if let result = data["results"] as? NSArray {
              if let geometry = result[0] as? NSDictionary {
                  if let geometry1 = geometry["geometry"] as? NSDictionary{
                      if let location = geometry1["location"] as? NSDictionary {

                           let latitude = location["lat"] as! Double
                           let longitude = location["lng"] as! Double

                           completeion(LocationData(latitude: latitude, longitude: longitude))
                       }
                  }
              }
          }
        }
      }
    func geoCodeCoords(place : LocationData , completeion : @escaping GeocodeCompletion2){
      
      let geocodeUrl = GoogleUrls().geocdeAdresssUrl(place: place)
        
      WebServiceManager.sharedService.requestApi(url: geocodeUrl, parameter: nil, httpMethodType: .GET) { (response, error) in
          
          guard let data = response else {
              completeion(nil)
            return
          }
          //"formatted_address"
          if let result = data["results"] as? NSArray {
              if let result1 = result[0] as? NSDictionary {
                  if let adress = result1["formatted_address"] as? String{
                      completeion(adress)
                  }
              }
          }
        }
      }
    
    func getRouteBetweenPlaces(startCoord : LocationData , endCoord : LocationData, completion: @escaping RouteCompletion){

        let googleDirectionsURL =  GoogleUrls().routeUrl(start: startCoord, end: endCoord)
        
        WebServiceManager.sharedService.requestApi(url: googleDirectionsURL, parameter: nil, httpMethodType: .GET) { (response, error) in
            guard let data = response else {
                completion(nil)
              return
            }
            let routeList = data["routes"] as! [[String: AnyObject]]
            
            if routeList.count > 0 {
                completion(GoogleRouteModel(routeAttributes: routeList[0]))
                   
            } else {
                completion(nil)
            }
        }
    }

  func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types: [String], completion: @escaping NearbyPlacesCompletion) -> Void {
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key=\(GoogleAPIConstants.key)"
    let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? urlString
    
    guard let url = URL(string: urlString) else {
      completion([])
      return
    }
    
    if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
      task.cancel()
    }
    
    DispatchQueue.main.async {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    placesTask = session.dataTask(with: url) { data, response, error in
      var placesArray: [GooglePlace] = []
      defer {
        DispatchQueue.main.async {
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
          completion(placesArray)
        }
      }
      guard let data = data,
        let json = try? JSON(data: data, options: .mutableContainers),
        let results = json["results"].arrayObject as? [[String: Any]] else {
          return
      }
      results.forEach {
        let place = GooglePlace(dictionary: $0, acceptedTypes: types)
        placesArray.append(place)
        if let reference = place.photoReference {
          self.fetchPhotoFromReference(reference) { image in
            place.photo = image
          }
        }
      }
    }
    placesTask?.resume()
  }
  
  
  func fetchPhotoFromReference(_ reference: String, completion: @escaping PhotoCompletion) -> Void {
    if let photo = photoCache[reference] {
      completion(photo)
    } else {
      let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=\(GoogleAPIConstants.key)"
      guard let url = URL(string: urlString) else {
        completion(nil)
        return
      }

      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      }

      session.downloadTask(with: url) { url, response, error in
        var downloadedPhoto: UIImage? = nil
        defer {
          DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(downloadedPhoto)
          }
        }
        guard let url = url else {
          return
        }
        guard let imageData = try? Data(contentsOf: url) else {
          return
        }
        downloadedPhoto = UIImage(data: imageData)
        self.photoCache[reference] = downloadedPhoto
      }
        .resume()
    }
  }

}
