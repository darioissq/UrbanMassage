//
//  Networking.swift
//  MarvelComics
//
//  Created by Dario Langella on 02/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import Foundation
import Alamofire

class Networking {
    /// Shared Alamofire `SessionManager` configured with the app-wide request and resource timeouts
    /// defined in `Constants.Request.TimeOut`.
    static let alamofireManager: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(Constants.Request.TimeOut)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(Constants.Request.TimeOut)
        return Alamofire.SessionManager(configuration: sessionConfiguration)
    }()

    /// Performs an HTTP request using the shared Alamofire session.
    ///
    /// - Parameters:
    ///   - url: The full URL string of the endpoint.
    ///   - method: HTTP method to use (default: `.post`).
    ///   - parameters: Key-value pairs to encode in the request (default: empty).
    ///   - encoding: Parameter encoding strategy (default: `URLEncoding.default`).
    ///   - contentType: Optional `Content-Type` header value.
    ///   - headers: Additional HTTP headers to include (default: empty).
    ///   - success: Called with the raw response `Data` on a successful, validated response.
    ///   - failure: Called with an `Error` if the request or validation fails.
    static func performRequest(url: String,
                               method: HTTPMethod = .post,
                               parameters: [String: Any] = [String: Any](),
                               encoding: ParameterEncoding = URLEncoding.default,
                               contentType: String? = nil,
                               headers: HTTPHeaders = [String: String](),
                               success: @escaping(Data) -> (),
                               failure: @escaping(Error) -> ()) {
        
        
            debugPrint("NetworkManager is calling endpoint: \(url)")
            
            Networking.alamofireManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().response { response in
                
                guard let data = response.data else {
                    print("Parsing Error")
                    return
                }
                success(data)
        }
    }
}
