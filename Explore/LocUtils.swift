//
//  LocUtils.swift
//  Explore
//
//  Created by John Mauro on 6/14/15.
//  Copyright © 2015 John Mauro. All rights reserved.
//

import UIKit
import CoreLocation

class LocUtils: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocUtils()
    
    var locationManager = CLLocationManager()
    var initialLocation: CLLocation!
    var locationAchieved: Bool = false
    var getInitialLocation: Bool = false
    var lat: CLLocationDegrees!
    var lon: CLLocationDegrees!
    var dir = ""
    var altitude = ""
    var headingRounded: Int = 0
    var headingRadians = 0.0
    
    override init() {
        
        // TODO: figure out why this is needed
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.headingOrientation = CLDeviceOrientation.Portrait
        
        print("init complete")
        
    }

    
    func startTracking() {
        
        self.locationManager.requestWhenInUseAuthorization()
        
        /*
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.headingOrientation = CLDeviceOrientation.Portrait
        locationManager.startUpdatingHeading()
        */

    }

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
      getInitialLocation = true
      self.locationManager.startUpdatingLocation()
      // self.initialLocation = self.locationManager.location
      self.locationManager.startUpdatingHeading()
    }
  }
    
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
        self.willChangeValueForKey("heading")
        self.headingRounded = Int(round(heading))
        // courseLabel.text = "\(headingRounded)º"
        
        let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        dir = "N"
        for (i, card) in cards.enumerate() {
            if heading < 45.0/2.0 + 45.0*Double(i) {
                dir = card
                break
            }
        }
        
        /*
        if directionLabel.text != dir {
            directionLabel.text = dir
        }
        */
        
        // rotate the compass
        
        self.headingRadians = (-1.0 * heading * M_PI)/180.0
        self.didChangeValueForKey("heading")

        
    }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.willChangeValueForKey("location")
    let userLocation: CLLocation = locations[0] 
    
    if userLocation.horizontalAccuracy > 0 {
      // locationAchieved = true
      self.lat = userLocation.coordinate.latitude
      self.lon = userLocation.coordinate.longitude
      /*
      if getInitialLocation == true {
      print(" initial lat is: \(lat) ")
      // rootVC.initializeMapAndWeather()
      
      getInitialLocation = false
      }
      */
    }
    
    // set altitude in FT
    if userLocation.verticalAccuracy > 0 {
      self.altitude = String(format:"%.0f", userLocation.altitude.ft)
    }
    
    self.didChangeValueForKey("location")
    // altitudeLabel.text = altitude
  }

  }
/*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {

        self.willChangeValueForKey("location")
        let userLocation: CLLocation = locations[0] as! CLLocation
      
        if userLocation.horizontalAccuracy > 0 {
          // locationAchieved = true
          self.lat = userLocation.coordinate.latitude
          self.lon = userLocation.coordinate.longitude
          /*
          if getInitialLocation == true {
            print(" initial lat is: \(lat) ")
            // rootVC.initializeMapAndWeather()
            
            getInitialLocation = false
          }
          */
      }
      
        // set altitude in FT
        if userLocation.verticalAccuracy > 0 {
          self.altitude = String(format:"%.0f", userLocation.altitude.ft)
        }
      
        self.didChangeValueForKey("location")
        // altitudeLabel.text = altitude
        
    }

}
*/
