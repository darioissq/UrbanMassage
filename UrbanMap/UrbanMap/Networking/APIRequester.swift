//
//  APIRequester.swift
//  MarvelComics
//
//  Created by Dario Langella on 02/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class APIRequester {

    /// Uploads the device's current coordinates to the remote API endpoint.
    ///
    /// - Parameters:
    ///   - coordinates: The latitude/longitude to send.
    ///   - response: Called with `true` when the server accepts the request.
    ///   - failure: Called with the underlying `Error` if the request fails.
    static func postLocation(coordinates: CLLocationCoordinate2D, response : @escaping(Bool)->(), failure: @escaping(Error)->()) {
        
        let url = "\(Constants.App.BaseURL)" + "\(Constants.APIEndPoint.SendLocation)"
        
        let parameters: Parameters = ["coordinates": coordinates]
        
        Networking.performRequest(url: url, parameters: parameters, success: { responseData in
            response(true)
        }, failure: { error in
            failure(error)
            print(error)
        })
    }
}
