//
//  SplashViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/08.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func pushToTabBarVC() {
        guard let tabBarvc = self.storyboard?.instantiateViewController(identifier: "tabBarVC") else { return }
        self.navigationController?.pushViewController(tabBarvc, animated: true)
    }
    
    func fadeInSubtitleLabel() {
        subtitleLabel.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.subtitleLabel.alpha = 1
        } completion: { _ in
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {  [weak self] _ in
                self?.pushToTabBarVC()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        fadeInSubtitleLabel()
    }
}


