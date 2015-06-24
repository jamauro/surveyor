//
//  TransitionManager.swift
//  Explore
//
//  Created by John Mauro on 6/18/15.
//  Copyright © 2015 John Mauro. All rights reserved.
//

import UIKit

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var presenting = false
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //TODO: perform the animation
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        let mapSelectionModalViewController = !self.presenting ? screens.from as! MapSelectionModalViewController : screens.to as! MapSelectionModalViewController
        let bottomViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let menuView = mapSelectionModalViewController.view
        let bottomView = bottomViewController.view
        // let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        // let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        // set up from 2D transforms that we'll use in the animation
         let offstageLeft = CGAffineTransformMakeTranslation(0, 100)
        // let offScreenRight = CGAffineTransformMakeTranslation(container!.frame.width, 0)
        // let offScreenLeft = CGAffineTransformMakeTranslation(-container!.frame.width, 0)
        
        // start the toView to the right of the screen
        // toView.transform = offScreenRight
        
        // prepare the menu
        if self.presenting {
            menuView.alpha = 0
            
            mapSelectionModalViewController.mapSegmentedControl.transform = offstageLeft
            mapSelectionModalViewController.creditsLabel.transform = offstageLeft
            mapSelectionModalViewController.selectionBackground.transform = offstageLeft
            mapSelectionModalViewController.divider.transform = offstageLeft
        }
        
        // add the both views to our view controller. NOTE: order matters
        container!.addSubview(bottomView)
        container!.addSubview(menuView)
        
        
        
        // get the duration of the animation
        // DON'T just type '0.5s' -- the reason why won't make sense until the next post
        // but for now it's important to just follow this approach
        let duration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        // for this example, just slid both fromView and toView to the left at the same time
        // meaning fromView is pushed off the screen and toView slides into view
        // we also use the block animation usingSpringWithDamping for a little bounce
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            if self.presenting {
                print("presenting true")
                menuView.alpha = 1
                mapSelectionModalViewController.mapSegmentedControl.transform = CGAffineTransformIdentity
                mapSelectionModalViewController.creditsLabel.transform = CGAffineTransformIdentity
                mapSelectionModalViewController.selectionBackground.transform = CGAffineTransformIdentity
                mapSelectionModalViewController.divider.transform = CGAffineTransformIdentity
            } else {
                print("presenting false")
                menuView.alpha = 0
                mapSelectionModalViewController.mapSegmentedControl.transform = offstageLeft
                mapSelectionModalViewController.creditsLabel.transform = offstageLeft
                mapSelectionModalViewController.selectionBackground.transform = offstageLeft
                mapSelectionModalViewController.divider.transform = offstageLeft
            }

            
            // fromView.transform = offScreenLeft
            // toView.transform = CGAffineTransformIdentity
            
            }, completion: { finished in
                transitionContext.completeTransition(true)
                
                // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                UIApplication.sharedApplication().keyWindow?.addSubview(screens.to.view)

        })
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol
    
    // return the animator when presenting a viewcontroller
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
}
