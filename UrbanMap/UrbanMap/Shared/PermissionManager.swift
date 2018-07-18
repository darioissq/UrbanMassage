//
//  PermissionManager.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * Requests permission for system features.
 */

class PermissionsManager {
    
    static let shared = PermissionsManager()
        
    func requestAlways( locationManager : CLLocationManager){
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUseLocation( locationManager : CLLocationManager) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocationEnabled() -> Bool{
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
}

