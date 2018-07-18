//
//  CLLocationCoordinate2D.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    
    /// Compare two coordinates
    /// - parameter coordinate: another coordinate to compare
    /// - return: bool value
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
    /// check the coordinate is empty or default
    /// return Bool value
    var isDefaultCoordinate: Bool {
        
        if self.latitude == 0.0 && self.longitude == 0.0 {
            return true
        }
        return false
    }
}
