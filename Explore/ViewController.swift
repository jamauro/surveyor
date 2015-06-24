//
//  ViewController.swift
//  Explore
//
//  Created by John Mauro on 6/11/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import MapboxGL

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MapSelectionModalDelegate {

    @IBOutlet var compassImage: UIImageView!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var altitudeUnitsLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var pressureUnitsLabel: UILabel!
    
    var pressure: Double!
    var futurePressures = [Double]()
    // var pressureInHG: Double!
    
    @IBOutlet var pressureDirectionLabel: UIImageView!
    @IBOutlet var map: MGLMapView! 
    @IBOutlet var mapTouchView: UIView!
    
    @IBOutlet var shrink: UIButton!
    @IBOutlet var coordinatesBackground: UIView!
    @IBOutlet var coordinatesLabel: UILabel!
    
    @IBAction func coordinatesButton(sender: AnyObject) {
        print("coordinates button tapped")
        // let sender: UIButton
        // let textToShare: String! = sender.currentTitle
        // let image = takeScreenShot()
        let coordinates = (sender as! UIButton).currentTitle!
        let textToShare: String = "Here's my location: \(coordinates)"
        print(textToShare)
        

        if let mapURL = NSURL(string: "http://maps.apple.com/?q=\(userLocationData.lat),\(userLocationData.lon)") {
            print(mapURL)
            let objectsToShare = [textToShare, mapURL]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        
            
        }
        
    }
    
    
    @IBOutlet var coordinatesButton: UIButton!
    
    @IBOutlet var mapLayers: UIButton!
    
    
    @IBAction func mapLayersButton(sender: AnyObject) {
       
    }

    
    var originalMapFrame: CGRect!
    
    @IBAction func shrinkButton(sender: AnyObject) {
        
        mapIsFullScreen = false
        shrink.hidden = true
        mapLayers.hidden = true
        // coordinatesBackground.hidden = true
        // coordinatesLabel.hidden = true
        coordinatesButton.hidden = true
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            // self.map.frame = self.originalMapFrame
            self.map.frame = self.mapTouchView.frame
            self.map.layer.cornerRadius = self.mapCornerRadius
        })) { (complete) -> Void in
            self.map.resetNorth()
            self.map.userTrackingMode = MGLUserTrackingMode.Follow
            self.map.allowsScrolling = false
            self.map.allowsZooming = false
            self.map.allowsRotating = false
            
        }

    }
    
    
    
    /*testing LocUtils
    var locationManager = CLLocationManager()
    var lat: CLLocationDegrees!
    var lon: CLLocationDegrees!
    var dir = ""
    var altitude = ""
    */
    
    var latitude: CLLocationDegrees! = 32.752073
    var longitude: CLLocationDegrees! = -117.130324

    let mapCornerRadius: CGFloat = 10
    
    let userLocationData = LocUtils.sharedInstance
    
    var tap: UITapGestureRecognizer!
    
    var altimeter = CMAltimeter()
    
    var mapIsFullScreen = false
    
    

    deinit {
        
        // TODO: figure out if I need these
        /*
        if userLocationData.observationInfo != nil {
            userLocationData.removeObserver(self, forKeyPath: "heading")
            userLocationData.removeObserver(self, forKeyPath: "location")
            
            removeObserver(self, forKeyPath: "getWeatherConditions")
        }
        */
       

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLocationData.startTracking()
        print("initialLocation " + String(userLocationData.initialLocation))
        // Do any additional setup after loading the view, typically from a nib.
        print("main view loaded")

        /*testing LocUtils
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.headingOrientation = CLDeviceOrientation.Portrait
        locationManager.startUpdatingHeading()
        */
        view.layoutIfNeeded()
        /*
        originalMapFrame = map.frame
        print("initial original map frame: \(originalMapFrame)")
        // mapTouchView.frame = originalMapFrame
        // mapTouchView.bounds = originalMapFrame
        // map.autoresizesSubviews = true
        // mapTouchView.translatesAutoresizingMaskIntoConstraints = true
        
        print("initial mapTouch frame: \(mapTouchView.frame)")
        */
        
        coordinatesBackground.hidden = true
        coordinatesLabel.hidden = true
        coordinatesButton.hidden = true
        shrink.hidden = true
        mapLayers.hidden = true
        coordinatesButton.layer.cornerRadius = 8
        
        
        tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        tap.delegate = self
        print(mapTouchView)
        mapTouchView.addGestureRecognizer(tap)

        
        
        userLocationData.addObserver(self, forKeyPath: "heading", options: NSKeyValueObservingOptions(), context: nil)
        userLocationData.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions(), context: nil)
        
        // update weather data when app enters foreground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getWeatherConditions:", name: "getWeatherConditions", object: nil)
        
        
        map.layer.cornerRadius = mapCornerRadius
        
        // if user has stored map selection then use that, otherwise load the default
        let mapSelection = NSUserDefaults.standardUserDefaults().objectForKey("mapSelection")
        if mapSelection == nil {
            setMapStyle(0)
            // map.styleURL = NSURL(string: "asset://styles/dark-v7.json")
        } else {
            setMapStyle(mapSelection as! Int)
        }
        
        if userLocationData.initialLocation != nil {
            latitude = userLocationData.initialLocation.coordinate.latitude
            longitude = userLocationData.initialLocation.coordinate.longitude
            
        }
        
        print("lat and lon used: ")
        print(latitude)
        print(longitude)
        
        
        
        // set the map's center coordinate
        map.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 15, animated: true)
        map.allowsRotating = true
        map.userTrackingMode = MGLUserTrackingMode.Follow
        /*
        for subview in map.subviews {
            
            if subview.isKindOfClass(UIButton) {
    
                subview.removeFromSuperview()
                print("view constraints: " + String(subview.constraints))
                print("map constraints: " + String(map.constraints))
                //view.removeConstraints(map.constraints)
                
            }
            
        }
        print(self.map.subviews)
        */
        
        // TODO: why doesn't this work?
        // mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        
        // get pressure via forecast API
        // getWeatherConditions()
        
        /*
        // get the pressure with built-in barometer for iPhone 6
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                if error == nil {
                    self.pressureLabel.text = "\(data!.pressure)"
                } else {
                    
                    // TODO: figure out another way to get pressure data??
                
                }
            })
        } else {
            // get pressure data from an API?
        }
        */
        
        print("ending viewDidLoad")
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        /* this gets rid of info button but then app crashes when map is tapped
        for subview in map.subviews {
            
            if subview.isKindOfClass(UIButton) {
                
                subview.removeFromSuperview()
                // print("view constraints: " + String(subview.constraints))
                // print("map constraints: " + String(map.constraints))
                //view.removeConstraints(map.constraints)
                
            }
            
        }
        */
    }
    
    func setMapStyle(number: Int) {
        switch number {
            case 0:
            map.styleURL = NSURL(string: "asset://styles/outdoors-v7.json")!
            // return "asset://styles/dark-v7.json"
            
            case 1:
            map.styleURL = NSURL(string: "asset://styles/dark-v7.json")!
            // return "asset://styles/outdoors-v7.json"
            
            case 2:
            map.styleURL = NSURL(string: "asset://styles/satellite-v7.json")!
            // return "asset://styles/mapbox-streets-v7.json"
         
            default:
            map.styleURL = NSURL(string: "asset://styles/outdoors-v7.json")!
            // return "asset://styles/dark-v7.json"
            
        }
    }
    
    func modalDidFinish(controller: MapSelectionModalViewController, mapSelection: Int) {
        setMapStyle(mapSelection)
        controller.dismissViewControllerAnimated(true, completion: nil)
            
    }
    
    
    func getWeatherConditions(notification: NSNotification? = nil) {
        //will be called initially and any time app enters foreground
        
        let urlPath = "https://api.forecast.io/forecast/c84e4d9cf49c636a24795958ec4cce8b/" + String(latitude) + "," + String(longitude)
        
        let url = NSURL(string: urlPath)
        print(url!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print(jsonResult)
                let hourlyData = jsonResult["hourly"]!["data"]! as! NSArray
                
                for data in hourlyData {
                    
                    guard let pressureInFuture = data["pressure"]! else {
                        return
                    }
                    self.futurePressures.append(pressureInFuture as! Double)
                    
                }
                
                
                print(self.futurePressures)
                let pressureDirection = self.determinePressureDirection(self.futurePressures)
                
                guard let currentConditions = jsonResult["currently"] else {
                    return
                }
                guard let currentPressure = currentConditions["pressure"] else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.pressure = self.convertPressure(currentPressure as! Double)
                    self.pressureLabel.text = "\(self.pressure)"
                    self.pressureDirectionLabel.image = UIImage(named: pressureDirection)
                })
                
                
                
            } catch {
                print(error)
                self.pressureLabel.text = "N/A"
            }
            
        }
        
        task?.resume()
        
    }
    
    func convertPressure(pressureInMB: Double) -> Double {
        let pressureInHG = pressureInMB * 0.0295333727
        print(pressureInHG)
        return roundToDecimal(pressureInHG, numberOfPlaces: 1.0)
    }

    /*
    func takeScreenShot() -> UIImage {
        //Create the UIImage
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    */
    
    /* testing LocUtils
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        // TODO: figure out if this is right
        return true
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        var heading = newHeading.magneticHeading
        
        if newHeading.trueHeading < 0 {
            heading = newHeading.magneticHeading
        } else {
            heading = (newHeading.trueHeading)
        }
        
        /* let numberOfPlaces = 0.0
        let multiplier = pow(10.0, numberOfPlaces)
        
        let headingRounded = round(heading * multiplier) / multiplier
        */
        
        let headingRounded = Int(round(heading))
        
        courseLabel.text = "\(headingRounded)º"
        
        let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        dir = "N"
        for (i, card) in cards.enumerate() {
            if heading < 45.0/2.0 + 45.0*Double(i) {
                dir = card
                break
            }
        }
        if directionLabel.text != dir {
            directionLabel.text = dir
        }
        
        // rotate the compass
        
        let headingRadians = (-1.0 * heading * M_PI)/180.0
        compassImage.transform = CGAffineTransformMakeRotation(CGFloat(headingRadians))
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        
        let userLocation: CLLocation = locations[0] as! CLLocation
        
        lat = userLocation.coordinate.latitude
        lon = userLocation.coordinate.longitude
        
        altitude = String(format:"%.0f", userLocation.altitude)
        
        altitudeLabel.text = altitude
        
    }
    */
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "modalViewControllerSegue" {
            var destination = segue.destinationViewController as! MapSelectionModalViewController
            destination.delegate = self
            
        }
        
        /*
        if segue.identifier == "mapSegue" {
            let destinationVC = segue.destinationViewController as! MapViewController
            print(dir)
            destinationVC.directionData = dir
            print(altitude)
            destinationVC.altitudeData = altitude
            destinationVC.latitude = lat
            destinationVC.longitude = lon
        }
        */
    }

    
    /*

    override func viewWillAppear(animated: Bool) {
        mapTouchView.frame = map.frame
    }
    */
    
    func determinePressureDirection(pressures: Array <Double>) -> String {
        
        if pressures[3] < pressures[2] && pressures[2] < pressures[1] {
            print("falling")
            return "arrow-down.png"
        } else if pressures[3] > pressures[2] && pressures[2] > pressures[1] {
            print("rising")
            return "arrow-up.png"
        } else {
            print("steady")
            return "arrow-level.png"
        }
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // if mapIsFullScreen == false {
            
            if keyPath == "heading" {
                courseLabel.text = "\(userLocationData.headingRounded)º"
                compassImage.transform = CGAffineTransformMakeRotation(CGFloat(userLocationData.headingRadians))
                if directionLabel.text != userLocationData.dir {
                    directionLabel.text = userLocationData.dir
                }
            } else if keyPath == "location" {
                // mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 15, animated: true)
                // coordinatesLabel.text = self.coordinateString(self.userLocationData.lat, longitude: self.userLocationData.lon)
                UIView.performWithoutAnimation({ () -> Void in
                    self.coordinatesButton.setTitle(self.coordinateString(self.userLocationData.lat, longitude: self.userLocationData.lon), forState: .Normal)
                    self.coordinatesButton.layoutIfNeeded()
                })
                
                altitudeLabel.text = userLocationData.altitude
            }

            
        // }
        
    }
    
    func coordinateString(latitude:Double, longitude:Double) -> String {
        var latSeconds = Int(latitude * 3600)
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        return String(format:"%d°%d'%d\" %@  %d°%d'%d\" %@",
            abs(latDegrees),
            latMinutes,
            latSeconds,
            {return latDegrees >= 0 ? "N" : "S"}(),
            abs(longDegrees),
            longMinutes,
            longSeconds,
            {return longDegrees >= 0 ? "E" : "W"}() )
    }
    
    func handleTap(gesture: UIGestureRecognizer) {
        print("map tapped")
        print(mapTouchView.frame)
        mapIsFullScreen = true
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.map.frame = self.view.bounds
            self.map.layer.cornerRadius = 0
            // this makes the map's subviews align like they should when it expands.
            self.map.translatesAutoresizingMaskIntoConstraints = true
        })) { (complete) -> Void in
            
            
            
            for view in self.map.subviews {
                if view.isKindOfClass(UIButton) {
                    view.removeFromSuperview()
                }
            }
            print(self.map.subviews)
            print(self.userLocationData.lat)
            self.coordinatesButton.hidden = false
            self.coordinatesButton.setTitle(self.coordinateString(self.userLocationData.lat, longitude: self.userLocationData.lon), forState: .Normal)
            // self.coordinatesBackground.hidden = false
            // self.coordinatesLabel.hidden = false
            self.shrink.hidden = false
            self.mapLayers.hidden = false
            self.map.allowsScrolling = true
            self.map.allowsZooming = true
            self.map.userTrackingMode = MGLUserTrackingMode.FollowWithHeading
        }

        
        /*
        UIView.animateWithDuration(0.5) { () -> Void in
        
            self.map.frame = self.view.bounds
            self.map.layer.cornerRadius = 0
        
        }
        */
        
        // self.map.allowsRotating = true
        
        
        
        
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

