//
//  ViewController.swift
//  LiveMapApp
//
//  Created by SMIT iMac27 on 19/03/20.
//  Copyright © 2020 SMIT iMac27. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class ViewController: UIViewController, CLLocationManagerDelegate {
    var picLocation: CLLocationCoordinate2D?
    var dropLocation: CLLocationCoordinate2D?
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var locationImg: UIImageView!
    var isGesturePic = true
    @IBOutlet weak var dropLocTextField: UITextField!
    @IBOutlet weak var picLocTextField: UITextField!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initializeAuthentication()
        self.mapView.delegate = self
        picLocTextField.addTarget(self, action: #selector(picLocationPressed), for: .touchDown)
         dropLocTextField.addTarget(self, action: #selector(dropLocationPressed), for: .touchDown)
    }
    
    @objc func picLocationPressed(){
        isGesturePic = true
        let autoCompleteVC = GMSAutocompleteViewController()
        autoCompleteVC.delegate = self
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .noFilter
        autoCompleteVC.autocompleteFilter = addressFilter
        present(autoCompleteVC, animated: true, completion: nil)
    }
    @objc func dropLocationPressed() {
       isGesturePic = false
        let autoCompleteVC = GMSAutocompleteViewController()
            autoCompleteVC.delegate = self
            let addressFilter = GMSAutocompleteFilter()
            addressFilter.type = .noFilter
        autoCompleteVC.autocompleteFilter = addressFilter
               present(autoCompleteVC, animated: true, completion: nil)
    }
    
    func getlocalAddres(location: CLLocationCoordinate2D, textField: UITextField) {
     let geocoder = GMSGeocoder()
     
     geocoder.reverseGeocodeCoordinate(location) {response, error in
         if error == nil {
           if let places = response?.results() {
                  if let place = places.first {
                     if let line = place.lines {
                         let strArr = line.first?.components(separatedBy: ",")
                    
                    
                         textField.text = "\(strArr![0]), \(strArr![1])"
                
                     }
                 
                     
                 } }
            }
     }
    }
    func initializeAuthentication(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 15
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.mapView.isMyLocationEnabled = true
        picLocation = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        draggedToMapOnLoc(location: picLocation!, isPic: true)
        getlocalAddres(location: picLocation!, textField: picLocTextField)
        
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func draggedToMapOnLoc(location: CLLocationCoordinate2D,isPic: Bool) {
        if isPic{
            locationImg.image = UIImage(named: "picloc1.png")
        }
        else {
             locationImg.image = UIImage(named: "droploc1.png")
        }
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 18)
                   self.mapView.camera = camera
                   self.mapView.animate(to: camera)
    }
    

}
//MARK: GMSMapViewDelegate
extension ViewController:GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    //GMSAutocompleteViewControllerDelegate Mthods
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if isGesturePic {
            
            picLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            draggedToMapOnLoc(location: picLocation!, isPic: true)
            
           
        }
        else {
              dropLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            draggedToMapOnLoc(location: dropLocation!, isPic: false)
        }
         dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
        // dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        if isGesturePic {
            picLocTextField.attributedText = prediction.attributedPrimaryText
        }
        else {
            dropLocTextField.attributedText = prediction.attributedPrimaryText
        }
        return true
    }
    //GMSMapViewDelegate Methods
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        switch isGesturePic {
        case true:
            picLocation = position.target
            draggedToMapOnLoc(location: picLocation!, isPic: true)
            getlocalAddres(location: picLocation!, textField: picLocTextField)
            break
        case false:
            dropLocation = position.target
             draggedToMapOnLoc(location: dropLocation!, isPic: true)
             getlocalAddres(location: dropLocation!, textField: dropLocTextField)
          }
            
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("gesture=\(gesture)")
        if gesture {
            if isGesturePic {
                picLocTextField.text = "Pic location is searching.."
            }
            else {
                dropLocTextField.text = "Drop location is searching.."
            }
        }
    }
}

