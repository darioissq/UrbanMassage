//
//  Date+Extension.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import UIKit

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        return formatter.string(from: self)
        
    }
}
