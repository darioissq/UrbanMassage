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

    /// Singleton instance.
    static let shared = PermissionsManager()

    /// Requests "Always" location authorization, allowing the app to receive location
    /// updates even when it is in the background or suspended.
    /// - Parameter locationManager: The `CLLocationManager` instance to authorize.
    func requestAlways( locationManager : CLLocationManager){
        locationManager.requestAlwaysAuthorization()
    }

    /// Requests "When In Use" location authorization, limiting updates to when
    /// the app is in the foreground.
    /// - Parameter locationManager: The `CLLocationManager` instance to authorize.
    func requestWhenInUseLocation( locationManager : CLLocationManager) {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Checks whether location services are enabled and the user has granted at least
    /// "When In Use" authorization.
    /// - Returns: `true` if location access is available, `false` otherwise.
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

