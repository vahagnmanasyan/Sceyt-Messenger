//
//  UIColor+Extension.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 07.01.25.
//

import UIKit

extension UIColor {
    convenience init(_ value: UInt32) {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat((value & 0xFF)) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
