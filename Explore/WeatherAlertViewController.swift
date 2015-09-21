//
//  WeatherAlertViewController.swift
//  Explore
//
//  Created by John Mauro on 6/29/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit

class WeatherAlertViewController: UIViewController {
  
  // let transitionManager = TransitionManager()
  
  var alertTitle: String!
  var alertExpiresAt: String!
  var alertDescription: String!
  @IBOutlet var content: UIView!
  @IBOutlet var alertTitleLabel: UILabel!
  @IBOutlet var expiresAtLabel: UILabel!
  @IBOutlet var slideDownView: UIView!
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var alertDescriptionLabel: UILabel!
  @IBOutlet var bottomView: UIView!
  @IBOutlet var mainAlertView: UIView!
  @IBOutlet var contentView: UIView!
  
  var animator: UIDynamicAnimator!
  var container: UICollisionBehavior!
  var snap: UISnapBehavior!
  var dynamicItem: UIDynamicItemBehavior!
  var gravity: UIGravityBehavior!
  
  var panGestureRecognizer: UIPanGestureRecognizer!
  var swipeGestureRecognizer: UISwipeGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    
    alertDescriptionLabel.lineBreakMode = .ByWordWrapping
    alertDescriptionLabel.numberOfLines = 0
    // all UI work must be done on the main thread but alert data is coming from background thread
    
    // self.view.frame = CGRectMake(0, 0, self.view.frame.width, mainAlertView.frame.height + bottomView.frame.height)
    
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "flickUp:")
    mainAlertView.addGestureRecognizer(panGestureRecognizer)
    /*
    swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
    swipeGestureRecognizer.direction = .Up
    mainAlertView.addGestureRecognizer(swipeGestureRecognizer)
    */
    
    
    alertTitleLabel.text = alertTitle
    expiresAtLabel.text = alertExpiresAt
    alertDescriptionLabel.text = alertDescription
    // scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, 2000)
    
    /*
    var maxSize = CGSizeMake(alertDescriptionLabel.frame.size.width, CGFloat.max)
    var labelSize = alertDescriptionLabel.sizeThatFits(maxSize)
    scrollView.contentSize = labelSize
    */
    /*
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
    
      self.alertTitleLabel.text = self.alertTitle.trimUpTo("for").uppercaseString
      self.expiresAtLabel.text = "EXPIRES: \(self.alertExpiresAt)"
      
      
      self.alertDescriptionLabel.text = self.alertDescription.lowercaseString
      self.alertDescriptionLabel.sizeToFit()
      
      self.scrollView.contentSize = self.alertDescriptionLabel.frame.size

    })
    */
    


    
    // Do any additional setup after loading the view.
    
    // Control transitions with TransitionManager
    // self.transitioningDelegate = self.transitionManager
  }
  
  func flickUp(flick: UIPanGestureRecognizer) {
    let translation = flick.translationInView(mainAlertView)
    if translation.y < 0 {
      // dismissViewControllerAnimated(true, completion: nil)
      UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
        self.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
        }, completion: { (finished) -> Void in
          print("flickedUp", terminator: "")
          self.view.removeFromSuperview()
          self.removeFromParentViewController()
          UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
      })
      
    } else {
      handlePan(flick)
    }
    
    /*
    if swipe.direction == .Up {
      // swipeGestureRecognizer.requireGestureRecognizerToFail(panGestureRecognizer)
      println("swipe up")
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    */
  }
  
  func setup() {
    
    
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
    panGestureRecognizer.cancelsTouchesInView = false
    bottomView.addGestureRecognizer(panGestureRecognizer)
  
    
    
    
    
    // slideDownView.superview!.addGestureRecognizer(panGestureRecognizer)
    
    animator = UIDynamicAnimator(referenceView: slideDownView.superview!)
    dynamicItem = UIDynamicItemBehavior(items: [slideDownView])
    dynamicItem.allowsRotation = false
    dynamicItem.elasticity = 0
    
    gravity = UIGravityBehavior(items: [slideDownView])
    // Slides down
    gravity.gravityDirection = CGVectorMake(0, -1)
    
    container = UICollisionBehavior(items: [slideDownView])
    
    // Define the container for our animation
    configureContainer()
    
    animator.addBehavior(gravity)
    animator.addBehavior(dynamicItem)
    animator.addBehavior(container)
    
  }
  
  func configureContainer() {
    let boundaryWidth = UIScreen.mainScreen().bounds.size.width
    container.addBoundaryWithIdentifier("upper", fromPoint: CGPointMake(0, -self.view.frame.size.height + 134), toPoint: CGPointMake(boundaryWidth, -self.view.frame.size.height + 134))
    
    let boundaryHeight = UIScreen.mainScreen().bounds.size.height
    container.addBoundaryWithIdentifier("lower", fromPoint: CGPointMake(0, boundaryHeight), toPoint: CGPointMake(boundaryWidth, boundaryHeight))
  
  }
  
  func handlePan(pan: UIPanGestureRecognizer) {
    let velocity = pan.velocityInView(slideDownView.superview).y
    
    var movement = slideDownView.frame
    movement.origin.x = 0
    movement.origin.y = movement.origin.y + (velocity * 0.05)
    
    if pan.state == .Ended {
      panGestureEnded()
    } else if pan.state == .Began {
      print("pan began", terminator: "")
      snapToBottom()
    } else {
      print("snap is \(snap)")
      if snap != nil {
        animator.removeBehavior(snap)
      }
      snap = UISnapBehavior(item: slideDownView, snapToPoint: CGPointMake(CGRectGetMidX(movement), CGRectGetMidY(movement)))
      animator.addBehavior(snap)
    }
  }
  
  func panGestureEnded() {
    animator.removeBehavior(snap)
    
    let velocity = dynamicItem.linearVelocityForItem(slideDownView)
    if fabsf(Float(velocity.y)) > 250 {
      if velocity.y < 0 {
        snapToTop()
      } else {
        snapToBottom()
      }
    } else {
      if let superViewHeight = slideDownView.superview?.bounds.size.height {
        if slideDownView.frame.origin.y > superViewHeight / 2 {
          snapToBottom()
        } else {
          snapToTop()
        }
      }
    }
  }
  
  func snapToBottom() {
    gravity.gravityDirection = CGVectorMake(0, 2.5)
  }
  
  func snapToTop() {
    gravity.gravityDirection = CGVectorMake(0, -2.5)
  }
  
  override func viewDidLayoutSubviews() {
    slideDownView.frame = CGRectOffset(slideDownView.frame, 0, -self.view.frame.size.height) // + 58
    //alertDescriptionLabel.frame.size
    setup()
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  // Hide the status bar
  override func prefersStatusBarHidden() -> Bool {
    return true
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
