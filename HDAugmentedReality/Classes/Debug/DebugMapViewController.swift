//
//  MapViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 20/06/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit
import MapKit

/// Called from ARViewController for debugging purposes
open class DebugMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var annotations: [ARAnnotation]?
    fileprivate var locationManager = CLLocationManager()
    fileprivate var heading: Double = 0
    fileprivate var interactionInProgress = false
    fileprivate var currentLocation : CLLocationCoordinate2D?
    
    @IBAction func addNewLocationTapped(_ sender: AnyObject) {
        
        //show alert form
        let alertController = UIAlertController(title: "Add new location", message: "Enter a name and description", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let nameTextField = alertController.textFields![0] as UITextField
            let detailsTextField = alertController.textFields![1] as UITextField
            self.setAnnotation(name: nameTextField.text!, details: detailsTextField.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            //textField.keyboardType = .EmailAddress
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Description"
           // textField.secureTextEntry = true
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)

    }
    
    
     func setAnnotation(name: String, details: String) {
        /*var url: NSURL = NSURL(string: "http://mbisaga.create.stedwards.edu/summit/summitAPI.php")!
         var request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
         var bodyData = "data=latutudeInput.text, data=longitudeInput.text, nameInput.text, detailsInput.text"
         request.httpMethod = "POST"
         print(bodyData)
         //encapsulate and send
         request.httpBody = bodyData.data(using: String.Encoding.utf8);
         NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main)
         {
         (response, data, error) in
         print(response)
         
         }*/
        
        //extract lat and long
        let latitude = currentLocation?.latitude
        let longitude = currentLocation?.longitude

        var request = URLRequest(url: URL(string: "http://mbisaga.create.stedwards.edu/summit/summitAPI.php")!)
        request.httpMethod = "POST"
        let postString = "latitude=\(latitude!)&longitude=\(longitude!)&name=\(name)&details=\(details)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        self.mapView.isRotateEnabled = false
        
        if let annotations = self.annotations
        {
            addAnnotationsOnMap(annotations)
        }
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        locationManager.startUpdatingHeading()
    }
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingHeading()
    }

    
    open func addAnnotations(_ annotations: [ARAnnotation])
    {
        self.annotations = annotations
        
        if self.isViewLoaded
        {
            addAnnotationsOnMap(annotations)
        }
    }
    
    fileprivate func addAnnotationsOnMap(_ annotations: [ARAnnotation])
    {
        var mapAnnotations: [MKPointAnnotation] = []
        for annotation in annotations
        {
            if let coordinate = annotation.location?.coordinate
            {
                let mapAnnotation = MKPointAnnotation()
                mapAnnotation.coordinate = coordinate
                let text = String(format: "%@, AZ: %.0f, VL: %i, %.0fm", annotation.title != nil ? annotation.title! : "", annotation.azimuth, annotation.verticalLevel, annotation.distanceFromUser)
                mapAnnotation.title = text
                mapAnnotations.append(mapAnnotation)
            }
        }
        mapView.addAnnotations(mapAnnotations)
        mapView.showAnnotations(mapAnnotations, animated: false)
    }
    
    
    @IBAction func longTap(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.began
        {
            let point = sender.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let userInfo: [AnyHashable: Any] = ["location" : location]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotificationLocationSet"), object: nil, userInfo: userInfo)
        }
    }
    
    @IBAction func closeButtonTap(_ sender: AnyObject)
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    open func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        heading = newHeading.trueHeading
        
        // Rotate map
        if(!self.interactionInProgress && CLLocationCoordinate2DIsValid(mapView.centerCoordinate))
        {
            let camera = mapView.camera.copy() as! MKMapCamera
            camera.heading = CLLocationDirection(heading);
            self.mapView.setCamera(camera, animated: false)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
    }
    
    open func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        self.interactionInProgress = true
    }
    
    open func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        self.interactionInProgress = false
    }
}
