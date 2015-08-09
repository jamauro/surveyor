//
//  StringExtensions.swift
//  Explore
//
//  Created by John Mauro on 6/30/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import Foundation


extension String {
  func trimUpTo(word: String) -> String {
    self.lowercaseString
    let find = self.rangeOfString("for")
    let range = Range(start: self.startIndex, end: find!.startIndex)
    return self.substringWithRange(range)
  }
}