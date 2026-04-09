//
//  Date+Extension.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import UIKit

extension Date {
    /// Formats the date as a human-readable string using the `dd-MMM-yyyy HH:mm:ss` pattern.
    /// Used to display the last upload timestamp in the UI.
    /// - Returns: A formatted date string, e.g. `"15-Jul-2018 14:32:00"`.
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        return formatter.string(from: self)
        
    }
}
