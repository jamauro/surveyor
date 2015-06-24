//
//  MapViewController.swift
//  Explore
//
//  Created by John Mauro on 6/12/15.
//  Copyright © 2015 John Mauro. All rights reserved.
//

import UIKit
import MapboxGL


class MapViewController: UIViewController {
    
    @IBOutlet var dirLabel: UILabel!
    @IBOutlet var minicompassButton: UIButton!
    @IBOutlet var altitudeUnitsLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    var altitudeData: String!
    var directionData: String!
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    let userLocationData = LocUtils.sharedInstance
    
    deinit {
        userLocationData.removeObserver(self, forKeyPath: "heading")
        userLocationData.removeObserver(self, forKeyPath: "location")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        latitude = userLocationData.lat
        longitude = userLocationData.lon
        
        userLocationData.addObserver(self, forKeyPath: "heading", options: NSKeyValueObservingOptions(), context: nil)
        
        userLocationData.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions(), context: nil)
        
        
        
        // set your access token
        // let mapView = MGLMapView(frame: view.bounds, accessToken: "pk.eyJ1IjoiamFtYXVybyIsImEiOiI4YTMzNGVjZjRiMDEyMzAzZTE4YTU0ODg5Y2ExOTQxYSJ9.ueI8uTYv-ldpElYWtY1G1A", styleURL: NSURL(string: "asset://styles/dark-v7.json"))
        let mapView = MGLMapView(frame: view.bounds, styleURL: NSURL(string: "asset://styles/dark-v7.json"))
        // TODO: why doesn't this work?
        // mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 15, animated: true)
        mapView.userTrackingMode = MGLUserTrackingMode.FollowWithHeading
    
        view.addSubview(mapView)
        view.addSubview(minicompassButton)
        view.addSubview(dirLabel)
        view.addSubview(altitudeLabel)
        view.addSubview(altitudeUnitsLabel)
    
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "heading" {
            if dirLabel.text != userLocationData.dir {
                dirLabel.text = userLocationData.dir
            }
        } else if keyPath == "location" {
            altitudeLabel.text = userLocationData.altitude
        }
    }

}
