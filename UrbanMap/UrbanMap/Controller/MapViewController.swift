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

    override func viewDidLoad() {
        super.viewDidLoad()
        checkMapPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateLocationIfNeeded(lastLocation: location.coordinate)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showAlertPermissionError()
        }
    }
}

//MARK: Util
extension MapViewController {
    private func saveLastUpdate(lastUpdateDate : Date){
        UserDefaults.standard.set(lastUpdateDate, forKey: "lastUpdateDateUrbanMap")
    }
    
    private func readDate() -> Date? {
        if let date = UserDefaults.standard.object(forKey: "lastUpdateDateUrbanMap") {
            return date as? Date
        } else {
            return nil
        }
    }
    
    private func updateLocationIfNeeded(lastLocation : CLLocationCoordinate2D) {
        if needUpdates() {
            postLocation(coordinates: lastLocation)
        } else {
            self.scheduler()
        }
    }
    
    private func scheduler() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
        
        timer = Timer.scheduledTimer(timeInterval: (900 - (self.differenceTime() * 60)), target: self, selector: #selector(performSchedule), userInfo: nil, repeats: true)
        
        print("\((15 - self.differenceTime()))")
    }
    
    @objc private func performSchedule(){
        if self.needUpdates() {
            self.checkMapPermission()
            self.scheduler() //recursion
        }
    }
    
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
    private func showAlertPermissionError(){
        let alertController = UIAlertController(title: Constants.Error.AlwaysLocationErrorTitle, message: Constants.Error.AlwaysLocationErrorDescription, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showAlerNetworkError(){
        let alertController = UIAlertController(title: Constants.Error.NetworkErrorTitle, message: Constants.Error.NetworkErrorDescription, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }
}

