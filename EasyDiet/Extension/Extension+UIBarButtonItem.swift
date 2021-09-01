//
//  Extension+UIBarButtonItem.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/01.
//

import UIKit


extension UIBarButtonItem {
    func addTargetForAction(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
}
