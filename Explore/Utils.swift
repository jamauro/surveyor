//
//  Utils.swift
//  Explore
//
//  Created by John Mauro on 6/16/15.
//  Copyright © 2015 John Mauro. All rights reserved.
//

import Foundation

func roundToDecimal(value: Double, numberOfPlaces: Double) -> Double {

    let multiplier = pow(10.0, numberOfPlaces)
    return round(value * multiplier) / multiplier

}

