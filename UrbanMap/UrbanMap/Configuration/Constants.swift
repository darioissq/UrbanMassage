//
//  Constants.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import UIKit

struct Constants {
    
    
    // APPLICATION
    struct App {
        
        
        // Main
        static let isDebugJSON = true
        static let isHTTPS = true
        
        
        // Base
        static let BaseURL: String = {
            if Constants.App.isHTTPS {
                return "https://requestbin.fullcontact.com/"
            }
            else {
                return "http://requestbin.fullcontact.com/"
            }
        }()

    }
    
    // MARK: EndPoint
    struct APIEndPoint {
        static let SendLocation = "1kkjbiu1"
    }
    
    // MARK:
    struct Request {
        static let TimeOut = 10
    }
    
    //MARK: Errors
    struct Error {
        static let NetworkErrorTitle = "NetworkErrorTitle".localized()
        static let NetworkErrorDescription = "NetworkErrorDescription".localized()
        static let AlwaysLocationErrorTitle = "AlwaysAllowErrorTitle".localized()
        static let AlwaysLocationErrorDescription = "AlwaysAllowErrorDescription".localized()
        static let LocationError = "LocationError".localized()
    }
}
