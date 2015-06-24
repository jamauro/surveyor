//
//  MapSelectionModalViewController.swift
//  Explore
//
//  Created by John Mauro on 6/17/15.
//  Copyright © 2015 John Mauro. All rights reserved.
//

import UIKit
import MapboxGL

protocol MapSelectionModalDelegate {
    func modalDidFinish(controller: MapSelectionModalViewController, mapSelection: Int)
}

class MapSelectionModalViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let transitionManager = TransitionManager()
    
    var vc = ViewController()
    var delegate: MapSelectionModalDelegate! = nil
    var selectedIndex: Int!
    var tap: UITapGestureRecognizer!
    
    @IBOutlet var selectionBackground: UIView!
    @IBOutlet var divider: UIView!
    @IBOutlet var creditsLabel: UILabel!
    @IBOutlet var mapSegmentedControl: UISegmentedControl!
    @IBAction func mapSelection(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex {
            
            case 0:
                delegate.modalDidFinish(self, mapSelection: 0)
                // vc.map.styleURL = NSURL(string: "asset://styles/dark-v7.json")
                // vc.changeMapStyle("asset://styles/dark-v7.json")
            case 1:
                delegate.modalDidFinish(self, mapSelection: 1)
                // vc.map.styleURL = NSURL(string: "asset://styles/emerald-v7.json")
                // vc.changeMapStyle("asset://styles/emerald-v7.json")
            case 2:
                delegate.modalDidFinish(self, mapSelection: 2)
                // vc.map.styleURL = NSURL(string: "asset://styles/mapbox-streets-v7.json")
                // vc.changeMapStyle("asset://styles/mapbox-streets-v7.json")
            default:
                delegate.modalDidFinish(self, mapSelection: 0)
                // vc.map.styleURL = NSURL(string: "asset://styles/dark-v7.json")
                // vc.changeMapStyle("asset://styles/dark-v7.json")
        }
        
        NSUserDefaults.standardUserDefaults().setInteger(mapSegmentedControl.selectedSegmentIndex, forKey: "mapSelection")
        
    }
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Control transitions with TransitionManager
        self.transitioningDelegate = self.transitionManager
        
        print(selectionBackground.superview)
        
        tap = UITapGestureRecognizer(target: self, action: "tapOutside:")
        // not sure this is necessary
        tap.cancelsTouchesInView = false
        tap.delegate = self
        selectionBackground.superview!.addGestureRecognizer(tap)
        
        
    }
    
    // dismiss modal when tap
    func tapOutside(gesture: UIGestureRecognizer) {
        let p: CGPoint = gesture.locationInView(self.selectionBackground)
        if (p.y < 0) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedIndex = NSUserDefaults.standardUserDefaults().integerForKey("mapSelection")
        mapSegmentedControl.selectedSegmentIndex = selectedIndex
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
