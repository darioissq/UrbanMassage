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
    static let alamofireManager: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(Constants.Request.TimeOut)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(Constants.Request.TimeOut)
        return Alamofire.SessionManager(configuration: sessionConfiguration)
    }()
    
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
