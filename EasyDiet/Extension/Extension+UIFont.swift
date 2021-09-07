//
//  Extension+UIFont.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/07.
//

import UIKit

extension UIFont {
    var largeAggroNavigationFont: [NSAttributedString.Key : Any] {
        let size = UIFont.preferredFont(forTextStyle: .largeTitle)
        let attribute = [NSAttributedString.Key.font: UIFont(name: "OTSBAggroM", size: size.pointSize)]
        return attribute as [NSAttributedString.Key : Any]
    }
    var generalAggroNavigationFont: [NSAttributedString.Key : Any] {
        let size:CGFloat = UIFont.labelFontSize
        let attribute = [NSAttributedString.Key.font: UIFont(name: "OTSBAggroM", size: size)]
        return attribute as [NSAttributedString.Key: Any]
    }
}
