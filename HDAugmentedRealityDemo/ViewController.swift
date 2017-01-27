//
//  ViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 21/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
//import ASIHTTPRequest.h
//import ASIFormDataRequest.h
//import JSON.h

class ViewController: UIViewController, ARDataSource
{
    let locationManager = CLLocationManager()
    var arViewController : ARViewController! = ARViewController()
    
    @IBOutlet weak var latitudeInput: UITextField!
    @IBOutlet weak var longitudeInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var detailsInput: UITextField!
    
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
    }
    
    /// Creates random annotations around predefined center point and presents ARViewController modally
    func showARViewController()
    {
        // Check if device has hardware needed for augmented reality
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alertView = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
            return
        }
        
        // Create random annotations around center point    //@TODO
        //FIXME: set your initial position here, this is used to generate random POIs
        //        let lat = 30.2672
        //        let lon = -97.7431
        //        let delta = 0.05
        //        let count = 50
        //let dummyAnnotations = self.getDummyAnnotations(centerLatitude: lat, centerLongitude: lon, delta: delta, count: count)
        
        // Present ARViewController
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(getAnnotations())
        arViewController.uiOptions.debugEnabled = true
        arViewController.uiOptions.closeButtonEnabled = true
        //arViewController.interfaceOrientationMask = .landscape
        arViewController.onDidFailToFindLocation =
            {
                [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
                
                self?.handleLocationFailure(elapsedSeconds: elapsedSeconds, acquiredLocationBefore: acquiredLocationBefore, arViewController: arViewController)
        }
        self.present(arViewController, animated: true, completion: nil)
    }
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    fileprivate func getDummyAnnotations(centerLatitude: Double, centerLongitude: Double, delta: Double, count: Int) -> Array<ARAnnotation>
    {
        var annotations: [ARAnnotation] = []
        
        srand48(3)
        for i in stride(from: 0, to: count, by: 1)
        {
            let annotation = ARAnnotation()
            annotation.location = self.getRandomLocation(centerLatitude: centerLatitude, centerLongitude: centerLongitude, delta: delta)
            annotation.title = "POI \(i)"
            annotations.append(annotation)
        }
        return annotations
    }
    
    fileprivate func getRandomLocation(centerLatitude: Double, centerLongitude: Double, delta: Double) -> CLLocation
    {
        var lat = centerLatitude
        var lon = centerLongitude
        
        let latDelta = -(delta / 2) + drand48() * delta
        let lonDelta = -(delta / 2) + drand48() * delta
        lat = lat + latDelta
        lon = lon + lonDelta
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    @IBAction func buttonTap(_ sender: AnyObject)
    {
        showARViewController()
    }
    
    func handleLocationFailure(elapsedSeconds: TimeInterval, acquiredLocationBefore: Bool, arViewController: ARViewController?)
    {
        guard let arViewController = arViewController else { return }
        
        NSLog("Failed to find location after: \(elapsedSeconds) seconds, acquiredLocationBefore: \(acquiredLocationBefore)")
        
        // Example of handling location failure
        if elapsedSeconds >= 20 && !acquiredLocationBefore
        {
            // Stopped bcs we don't want multiple alerts
            arViewController.trackingManager.stopTracking()
            
            let alert = UIAlertController(title: "Problems", message: "Cannot find location, use Wi-Fi if possible!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Close", style: .cancel)
            {
                (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            
            self.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /* fileprivate func getAnnotations() -> Array<ARAnnotation>
     {
     var annotations: [ARAnnotation] = []
     
     let frostBank = ARAnnotation.newPOI(lat: 30.2664665, long: -97.7448811, title: "Frost Bank", message: "-$$$$")
     let marriott = ARAnnotation.newPOI(lat: 30.2642518, long: -97.7453102, title: "JW Marriott", message: "ZZZZZ")
     let capitalFactory = ARAnnotation.newPOI(lat: 30.2698765, long: -97.7413942, title: "Capital Factory", message: "Expensive parking")
     let texasCapitol = ARAnnotation.newPOI(lat: 30.2745279, long: -97.7416624, title: "Texas Capitol", message: "Fancy gardens")
     
     annotations = [frostBank, marriott, capitalFactory, texasCapitol]
     
     return annotations
     }*/
    
    fileprivate func getAnnotations() -> Array<ARAnnotation> {
        var annotations: [ARAnnotation] = []
        
        let url = "http://mbisaga.create.stedwards.edu/summit/summitAPIgetAnnotations.php"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! [NSDictionary]
                    for dict in JSON{
                        let lat = dict["latitude"] as! String
                        let long = dict["longitude"] as! String
                        let name = dict["name"] as! String
                        let details = dict["details"] as! String
                        let annotation = ARAnnotation.newPOI(lat: Double(lat)!, long: Double(long)!, title: name, message: details)
                        annotations.append(annotation)
                    }
                }
                
                self.arViewController.setAnnotations(annotations)
        }
        
        return annotations
    }
    
    
}
