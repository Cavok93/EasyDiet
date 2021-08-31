//
//  Expand+UIViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//
import UIKit



extension UIViewController {
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}


extension UIViewController {
    func showToast(message : String, font: UIFont = UIFont.boldSystemFont(ofSize: 15.0)) {
        
        if let tabbar =  (self.tabBarController)?.tabBar {
            let tabBarHeight = tabbar.frame.size.height
            let safeInset:CGFloat = 16.0
            let toastHight:CGFloat = 40.0
            let blurEffect = UIBlurEffect(style: .regular)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.frame = CGRect(x: 100, y: self.view.frame.size.height - (tabBarHeight + toastHight + safeInset), width: (self.view.frame.width-200), height:  toastHight)
            
            blurredEffectView.clipsToBounds = true
            blurredEffectView.layer.cornerRadius = 8
            blurredEffectView.layer.borderWidth = 0.4
            blurredEffectView.layer.borderColor = UIColor.lightGray.cgColor
          
            self.tabBarController?.view.addSubview(blurredEffectView)
            
            
            let toastLabel = UILabel()
            toastLabel.numberOfLines = 0
            toastLabel.alpha = 1.0
            toastLabel.backgroundColor = UIColor.clear
            toastLabel.textColor = UIColor.darkGray
            toastLabel.font = font
            
            toastLabel.textAlignment = .center
            toastLabel.text = message
            toastLabel.frame = blurredEffectView.contentView.bounds
            blurredEffectView.contentView.addSubview(toastLabel)
            
            
            UIView.animate(withDuration: 0.0, delay: 2.0, options: .allowUserInteraction, animations: {
                            toastLabel.alpha = 0.0 },
                           completion: { (isCompleted) in
                            blurredEffectView.removeFromSuperview() })
            
        }
    }
    
}



