//
//  Utils.swift
//  Metro Navigation
//
//  Created by Anastasia on 01.05.17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import Foundation
import UIKit

struct Utils {
    
    static let TableViewSegue: String = "showTableView"
    
    static func getAttributedText(inputText: String, location: Int, length: Int, color: UIColor) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: inputText, attributes: [:])
        attributedText.addAttribute(NSForegroundColorAttributeName, value: color , range: NSRange(location:location,length:length))
        return attributedText
    }
}




