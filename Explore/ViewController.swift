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
    @IBOutlet var northMarksImage: UIImageView!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var altitudeUnitsLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var pressureUnitsLabel: UILabel!
    @IBOutlet var altitudeWindSwitchView: UIView!
    @IBOutlet var baroTempSwitchView: UIView!
    @IBOutlet var altWindLabel: UILabel!
    @IBOutlet var baroTempLabel: UILabel!
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var windDirImage: UIImageView!
    @IBOutlet var windDirLabel: UILabel!
  
    var windSpeed: Double = 0.0
    var windDir: String! = "-"
    var windBearing: Double!
    var windBearingRadians: Double! = 0.0
    var temp: Double!
    var pressure: Double!
    var futurePressures = [Double]()
    // var pressureInHG: Double!
    // var initialMapConstraints = [AnyObject]()
  
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
    
    // var latitude: CLLocationDegrees! = 32.752073
    // var longitude: CLLocationDegrees! = -117.130324

    let mapCornerRadius: CGFloat = 10
    
    let userLocationData = LocUtils.sharedInstance
    
    var tap: UITapGestureRecognizer!
    var switchAltWind: UITapGestureRecognizer!
    var switchBaroTemp: UITapGestureRecognizer!
  
    var altitudeShowing: Bool = true
    var baroShowing: Bool = true
  
    var altimeter = CMAltimeter()
    
    var mapIsFullScreen = false
  
    var weatherAlertVC: WeatherAlertViewController!
    var alertTitle: String!
    var alertLocalExpireTime: String!
    var alertDescription: String!
  
  

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
  
        print("initialLocation " + toString(userLocationData.initialLocation))
        // Do any additional setup after loading the view, typically from a nib.
        print("main view loaded")
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)

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
        map.attributionButton.hidden = true
        map.logoView.hidden = true
        coordinatesBackground.hidden = true
        coordinatesLabel.hidden = true
        coordinatesButton.hidden = true
        shrink.hidden = true
        mapLayers.hidden = true
        coordinatesButton.layer.cornerRadius = 8
      
        windDirImage.hidden = true
        windDirLabel.hidden = true
        
        
        tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        tap.delegate = self
        print(mapTouchView)
        mapTouchView.addGestureRecognizer(tap)
      
        switchAltWind = UITapGestureRecognizer(target: self, action: "handleSwitch:")
        switchAltWind.delegate = self
        altitudeWindSwitchView.addGestureRecognizer(switchAltWind)
      
        switchBaroTemp = UITapGestureRecognizer(target: self, action: "handleSwitch:")
        switchBaroTemp.delegate = self
        baroTempSwitchView.addGestureRecognizer(switchBaroTemp)
        
        
        userLocationData.addObserver(self, forKeyPath: "heading", options: NSKeyValueObservingOptions(), context: nil)
        userLocationData.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions(), context: nil)
        
        // update weather data when app enters foreground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData:", name: "refreshData", object: nil)
        
        print(" map in viewDidLoad: \(map) ")
        map.layer.cornerRadius = mapCornerRadius
        
        // if user has stored map selection then use that, otherwise load the default
        let mapSelection = NSUserDefaults.standardUserDefaults().objectForKey("mapSelection")
        if mapSelection == nil {
            setMapStyle(0)
            // map.styleURL = NSURL(string: "asset://styles/dark-v7.json")
        } else {
            setMapStyle(mapSelection as! Int)
        }
      
      
      
        // set the map's center coordinate and get weather data
        print(" userLocation lon in viewDidLoad: \(userLocationData.lon) ")
        // if userLocationData.initialLocation != nil {
          // latitude = userLocationData.initialLocation.coordinate.latitude
          // longitude = userLocationData.initialLocation.coordinate.longitude
      
          // map.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 15, animated: true)
      if userLocationData.lat != nil {
        print(" lon before centering map: \(userLocationData.lon) ")
        map.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocationData.lat, longitude: userLocationData.lon), zoomLevel: 15, animated: true)
      }
          map.allowsRotating = true
          map.userTrackingMode = MGLUserTrackingMode.Follow
          
          // get weather data via forecast API
          // getWeatherConditions(latitude, longitude: longitude)
        // }
      
      
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
        print(" finishing viewDidLoad")
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
  
    // this func will be called initially and any time app enters foreground
    // swift 2 can have notification: NSNotification? = nil
    func refreshData(notification: NSNotification?) {
      print(" lat in refreshData is: \(userLocationData.lat) ")
      getWeatherConditions(userLocationData.lat, longitude: userLocationData.lon)
    }
  
  
    func getWeatherConditions(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
      
      // print(" initialLocation lat: \(userLocationData.initialLocation.coordinate.latitude) ")
      print(" lon: \(longitude) ")
      
  
      
        let forecastID = valueForAPIKey(keyname: "API_CLIENT_ID")
        // let urlPath = "https://api.forecast.io/forecast/\(forecastID)/37.6783,-92.6617"
      
        let urlPath = "https://api.forecast.io/forecast/\(forecastID)/" + toString(latitude) + "," + toString(longitude)
        
        let url = NSURL(string: urlPath)
        print(url!)
  
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
          if error == nil {

              let jsonResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
              
              print(jsonResult)
              
              let hourlyData = jsonResult["hourly"]!["data"]! as! NSArray
              
              for data in hourlyData {
                let pressureInFuture: Double = data["pressure"] as! Double
                self.futurePressures.append(pressureInFuture)
              }
              
              
              // print(self.futurePressures)
              let pressureDirection = self.determinePressureDirection(self.futurePressures)
              
              let currentConditions = jsonResult["currently"]
              let currentPressure = currentConditions?["pressure"]
              self.windSpeed = roundToDecimal(currentConditions?["windSpeed"] as! Double, 1.0)
              self.windBearing = currentConditions?["windBearing"] as! Double
              self.windDir = self.getWindDirection(self.windBearing)
              self.windBearingRadians = (-1.0 * self.windBearing * M_PI)/180.0
              self.temp = roundToDecimal(currentConditions?["temperature"] as! Double, 1.0)
              
              if let alerts: NSArray = jsonResult["alerts"] as? NSArray {
                let lastAlert: AnyObject = alerts.lastObject!
                print("last alert is: \(lastAlert)")
                if let alertTitle = lastAlert["title"] as? String {
                  self.alertTitle = alertTitle.trimUpTo("for").uppercaseString
                }
                if let expires: NSTimeInterval = lastAlert["expires"] as? NSTimeInterval {
                  self.alertLocalExpireTime = self.formatDate(expires)
                }
                
                if let description = lastAlert["description"] as? String {
                  self.alertDescription = self.formatDescription(description)
                  print("description is: \(description)")
                }
                
                // WEATHER ALERTS!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                  self.showWeatherAlert()
                })
                
      
                
              }
              
              
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.pressure = self.convertPressure(currentPressure as! Double)
                if !self.altitudeShowing {
                  self.altitudeLabel.text = "\(self.windSpeed)"
                  self.windDirLabel.text = "\(self.windDir)"
                }
                if self.baroShowing {
                  self.pressureLabel.text = "\(self.pressure)"
                } else {
                  self.pressureLabel.text = "\(self.temp)"
                }
                self.pressureDirectionLabel.image = UIImage(named: pressureDirection)
                self.windDirImage.image = UIImage(named: "windsock-dir.png")
              })


          } else {
            print(error)
            self.pressureLabel.text = "N/A"
          }
          /* swift 2.0
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
            */
        }
        
        task.resume()
        
    }
    
  func convertPressure(pressureInMB: Double) -> Double {
      let pressureInHG = pressureInMB * 0.0295333727
      print(pressureInHG)
      return roundToDecimal(pressureInHG, 1.0)
  }
  
  func getWindDirection(bearing: Double) -> String {
    let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    var dir = "N"
    for (i, card) in enumerate(cards) {
      if bearing < 45.0/2.0 + 45.0*Double(i) {
        dir = card
        break
      }
    }
    print( "wind dir is: \(dir)")
    return dir
    
  }
  
  func formatDescription(var description: String) -> String {
    
    description = description.stringByReplacingOccurrencesOfString("\n", withString: " ")
    description = description.stringByReplacingOccurrencesOfString(". ", withString: ". \n\n").capitalizedString

    return description
  }
  
  func formatDate(time: NSTimeInterval) -> String {
    let expiresAt = NSDate(timeIntervalSince1970: time)
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.timeZone = NSTimeZone()
    
    let today = NSCalendar.currentCalendar().isDateInToday(expiresAt)
    let tomorrow = NSCalendar.currentCalendar().isDateInTomorrow(expiresAt)
    
    var expiresFormatted: String = "Expires: "
    
    if today == true {
      expiresFormatted = expiresFormatted + "\(dateFormatter.stringFromDate(expiresAt))"
    } else if tomorrow == true {
      expiresFormatted = expiresFormatted + "Tomorrow at \(dateFormatter.stringFromDate(expiresAt))"
    } else {
      dateFormatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
      expiresFormatted = expiresFormatted + "\(dateFormatter.stringFromDate(expiresAt))"
    }
      
    return expiresFormatted.uppercaseString
  }
  
  func showWeatherAlert() {
    if self.childViewControllers.count == 0 {
    
      weatherAlertVC = storyboard?.instantiateViewControllerWithIdentifier("WeatherAlertViewController") as! WeatherAlertViewController
      self.addChildViewController(weatherAlertVC)
    
      // pass data
      weatherAlertVC.alertTitle = self.alertTitle
      weatherAlertVC.alertExpiresAt = self.alertLocalExpireTime
      print(self.alertLocalExpireTime)
      weatherAlertVC.alertDescription = self.alertDescription
      weatherAlertVC.prefersStatusBarHidden() == true
    
      weatherAlertVC.view.frame = CGRectMake(0, -weatherAlertVC.view.frame.size.height, weatherAlertVC.view.frame.size.width, weatherAlertVC.view.frame.size.height)
      self.view.addSubview(weatherAlertVC.view)
      
      
      UIView.animateWithDuration(0.25, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
        self.weatherAlertVC.view.frame = CGRectMake(0, 0, self.weatherAlertVC.view.frame.size.width, self.weatherAlertVC.view.frame.size.height)
      }, completion: { (finished) -> Void in
        self.weatherAlertVC.didMoveToParentViewController(self)
      })
      
    }
    
    
  }
  
  
  func dismissWeatherAlert() {
    UIView.animateWithDuration(1, animations: { () -> Void in
      self.weatherAlertVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, -self.view.frame.size.height)
      }, completion: { (finished) -> Void in
        self.weatherAlertVC.view.removeFromSuperview()
        self.weatherAlertVC.removeFromParentViewController()
        self.weatherAlertVC = nil
    })

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
      if (segue.identifier == "modalViewControllerSegue") {
        let destination = segue.destinationViewController as! MapSelectionModalViewController
        destination.delegate = self
      } else if (segue.identifier == "weatherAlertSegue") {
        print("alert title is: \(self.alertTitle)")
        let destination = segue.destinationViewController as! WeatherAlertViewController
        destination.alertTitle = alertTitle
        destination.alertExpiresAt = alertLocalExpireTime
        destination.alertDescription = alertDescription
        // destination.delegate = self
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
                northMarksImage.transform = CGAffineTransformMakeRotation(CGFloat(userLocationData.headingRadians))
                if directionLabel.text != userLocationData.dir {
                    directionLabel.text = userLocationData.dir
                }
                windDirImage.transform = CGAffineTransformMakeRotation(CGFloat(userLocationData.headingRadians - windBearingRadians))
            } else if keyPath == "location" {
                // mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 15, animated: true)
                // coordinatesLabel.text = self.coordinateString(self.userLocationData.lat, longitude: self.userLocationData.lon)
                UIView.performWithoutAnimation({ () -> Void in
                  self.coordinatesButton.setTitle(self.coordinateString(self.userLocationData.lat, longitude: self.userLocationData.lon), forState: .Normal)
                  
                  self.coordinatesButton.layoutIfNeeded()
                })
              
              
                if altitudeShowing {
                  altitudeLabel.text = userLocationData.altitude
                }
              
              if userLocationData.getInitialLocation {
                print(" lon before centering map in getInitalLocation: \(userLocationData.lon) ")
                map.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocationData.lat, longitude: userLocationData.lon), zoomLevel: 15, animated: true)
                getWeatherConditions(userLocationData.lat, longitude: userLocationData.lon)
                userLocationData.getInitialLocation = false
              }
              
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
            // XCODE BUG, fixed in xcode 7: self.map.translatesAutoresizingMaskIntoConstraints = true
            self.map.setTranslatesAutoresizingMaskIntoConstraints(true)
          
        })) { (complete) -> Void in
            
            
            
            for view in self.map.subviews {
                if view.isKindOfClass(UIButton) {
                    view.removeFromSuperview()
                }
            }
            print(self.map.subviews)
            print(self.userLocationData.lat)
            self.coordinatesButton.hidden = false
            // gps may not have updated yet
            if self.userLocationData.lat != nil {
              self.coordinatesButton.setTitle(self.coordinateString(self.userLocationData.lat, longitude: self.userLocationData.lon), forState: .Normal)
            }
            /*
            else {
              self.coordinatesButton.setTitle(self.coordinateString(self.latitude, longitude: self.longitude), forState: .Normal)
            }
            */
          
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
  
    func handleSwitch(sender: UIGestureRecognizer) {
      if sender.view == altitudeWindSwitchView {
        print("altitude wind switch view tapped")
        if altitudeShowing {
          altWindLabel.text = "WINDSOCK"
          altitudeLabel.text = "\(windSpeed)"
          altitudeUnitsLabel.text = "MPH"
          windDirLabel.hidden = false
          windDirLabel.text = "\(windDir)"
          windDirImage.hidden = false
          altitudeShowing = false
        } else {
          windDirLabel.hidden = true
          windDirImage.hidden = true
          altWindLabel.text = "ALTIMETER"
          altitudeLabel.text = userLocationData.altitude
          altitudeUnitsLabel.text = "FT"
          altitudeShowing = true
        }
        
      } else if sender.view == baroTempSwitchView {
        print("baro temp switch view tapped")
        if baroShowing {
          pressureDirectionLabel.hidden = true
          baroTempLabel.text = "THERMOMETER"
          pressureLabel.text = "\(temp)"
          pressureUnitsLabel.text = "ºF"
          weatherIcon.hidden = false
          baroShowing = false
        } else {
          weatherIcon.hidden = true
          baroTempLabel.text = "BAROMETER"
          pressureLabel.text = "\(pressure)"
          pressureUnitsLabel.text = "inHg"
          pressureDirectionLabel.hidden = false
          baroShowing = true
        }
      }
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }
  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

