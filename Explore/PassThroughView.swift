//
//  PassThroughView.swift
//  Explore
//
//  Created by John Mauro on 7/2/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit

class PassThroughView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
  
  override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    for subview in subviews as! [UIView] {
      if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
        return true
      }
    }
    return false
  }

}
