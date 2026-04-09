//
//  ViewController.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!{
        didSet{
            mapView.showsUserLocation = true
            mapView.showsTraffic = true
            mapView.showsCompass = true
            mapView.showsBuildings = true
            mapView.showsPointsOfInterest = true
            self.mapView.delegate = self
        }
    }
    @IBOutlet var logLabel: UILabel!{
        didSet{
            if let date = readDate() {
                logLabel.text = date.toString()
            } else {
                logLabel.text = ""
            }
        }
    }
    
    let locationManager = CLLocationManager()
    
    var timer: Timer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    /// Sets up location permissions, starts location updates, and registers for foreground notifications.
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMapPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// Called when the app returns to the foreground. Resets the upload scheduler so the
    /// remaining interval is recalculated from the last stored upload timestamp.
    @objc func appMovedFromForeground() {
        self.scheduler()
    }
    
    deinit {
        timer.invalidate()
        timer = nil
    }
}

//MARK: Permission Manager
extension MapViewController {
    /// Requests "Always" location authorization and, if granted, configures the location manager
    /// for high-accuracy background tracking. Shows a permission error alert if access is denied.
    private func checkMapPermission(){
        PermissionsManager.shared.requestAlways(locationManager: locationManager)
        if PermissionsManager.shared.requestLocationEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            showAlertPermissionError()
        }
    }
}

//MARK: Networking
extension MapViewController {
    /// Uploads the given coordinates to the remote API.
    /// On success, persists the current timestamp and reschedules the next upload.
    /// On failure, shows a network error alert and retries the request immediately.
    /// - Parameter coordinates: The latitude/longitude to upload.
    private func postLocation(coordinates : CLLocationCoordinate2D){
        APIRequester.postLocation(coordinates: coordinates, response: { (response) in
            if response {
                self.saveLastUpdate(lastUpdateDate: Date())
                self.logLabel.text = Date().toString()
                self.scheduler()
            }
        }) { (error) in
            self.showAlerNetworkError()
            self.postLocation(coordinates: coordinates)
        }
    }
}

//MARK: MapView
extension MapViewController : CLLocationManagerDelegate, MKMapViewDelegate {
    /// Called by CoreLocation whenever a new location fix is available.
    /// Passes the most recent coordinate to `updateLocationIfNeeded`.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateLocationIfNeeded(lastLocation: location.coordinate)
        }
    }

    /// Called when the user changes location authorization status.
    /// Shows a permission error alert if access is denied.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showAlertPermissionError()
        }
    }
}

//MARK: Util
extension MapViewController {
    /// Persists the date of the last successful location upload to `UserDefaults`.
    /// - Parameter lastUpdateDate: The timestamp to store.
    private func saveLastUpdate(lastUpdateDate : Date){
        UserDefaults.standard.set(lastUpdateDate, forKey: "lastUpdateDateUrbanMap")
    }

    /// Reads the last successful upload timestamp from `UserDefaults`.
    /// - Returns: The stored `Date`, or `nil` if no upload has occurred yet.
    private func readDate() -> Date? {
        if let date = UserDefaults.standard.object(forKey: "lastUpdateDateUrbanMap") {
            return date as? Date
        } else {
            return nil
        }
    }

    /// Uploads the given coordinate if the 15-minute interval has elapsed;
    /// otherwise starts the scheduler to wait for the remaining time.
    /// - Parameter lastLocation: The most recent coordinate received from CoreLocation.
    private func updateLocationIfNeeded(lastLocation : CLLocationCoordinate2D) {
        if needUpdates() {
            postLocation(coordinates: lastLocation)
        } else {
            self.scheduler()
        }
    }

    /// Schedules the next location upload to fire exactly when 15 minutes have elapsed
    /// since the last upload. Any previously active timer is invalidated first.
    private func scheduler() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }

        timer = Timer.scheduledTimer(timeInterval: (900 - (self.differenceTime() * 60)), target: self, selector: #selector(performSchedule), userInfo: nil, repeats: true)

        print("\((15 - self.differenceTime()))")
    }

    /// Timer callback. If 15 minutes have passed since the last upload, re-checks
    /// permissions and restarts the location update cycle; otherwise reschedules.
    @objc private func performSchedule(){
        if self.needUpdates() {
            self.checkMapPermission()
            self.scheduler() //recursion
        }
    }

    /// Returns `true` if at least 15 minutes have elapsed since the last successful upload,
    /// or if no upload timestamp is stored yet.
    private func needUpdates() -> Bool{
        if let date = readDate() {
            if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute, diff >= 15 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    /// Returns the number of minutes elapsed since the last upload, capped at 15.
    /// Used to calculate the remaining time before the next upload is due.
    /// - Returns: Minutes since last upload as a `Double` (0–15), or 15 if no upload has occurred.
    private func differenceTime() -> Double {
        if let date = readDate() {
            if needUpdates() {
                return 15
            } else {
                if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute {
                    return Double(diff)
                } else {
                    return 15
                }
            }
        } else {
            return 15
        }
    }
}

//MARK: Error Alerts
extension MapViewController {
    /// Presents an alert informing the user that "Always" location permission is required.
    private func showAlertPermissionError(){
        let alertController = UIAlertController(title: Constants.Error.AlwaysLocationErrorTitle, message: Constants.Error.AlwaysLocationErrorDescription, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }

    /// Presents an alert informing the user that the location upload request failed.
    private func showAlerNetworkError(){
        let alertController = UIAlertController(title: Constants.Error.NetworkErrorTitle, message: Constants.Error.NetworkErrorDescription, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }
}

