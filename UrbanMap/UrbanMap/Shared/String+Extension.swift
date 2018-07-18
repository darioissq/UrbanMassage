//
//  String+Extension.swift
//  UrbanMap
//
//  Created by Dario Langella on 15/07/2018.
//  Copyright © 2018 Dario Langella. All rights reserved.
//

import UIKit

extension String {
    /// This func is able to automatically find the localizedString for the string we need.
    /// If the string is not found, we show **<key>** for debugging.
    /// - Parameters:
    ///   - bundle: main
    ///   - tableName: Name of the file where we need to search the string
    /// - Returns: String in the localized language
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
