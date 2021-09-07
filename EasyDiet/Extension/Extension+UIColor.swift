//
//  Extension+UIColor.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/29.
//

import UIKit

extension UIColor {
    convenience init?(red: Int, green: Int, blue: Int) {
        guard (0...255).contains(red) else { return  nil }
        guard (0...255).contains(green) else { return nil }
        guard (0...255).contains(blue) else { return nil }
        self.init(red: CGFloat(red) / 255,  green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1.0)
    }
}

extension UIColor {
    static var lightBlueGreen: UIColor {
        let color = UIColor(red: 3, green: 181, blue: 148)
        return color ?? UIColor()
    }
    
    static var lightGreen: UIColor {
        let color = UIColor(red: 61, green: 237, blue: 151)
        return color ?? UIColor()
    }
}
