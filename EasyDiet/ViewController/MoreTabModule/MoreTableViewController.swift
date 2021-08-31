//
//  MoreTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import UIKit

class MoreTableViewController: UITableViewController {

    
    let diaries = [DiaryEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "안내", message: "모든 데이터를 삭제하시겠습니까?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "삭제", style: .default) { _ in 
                DataManager.shared.batchDelete()
                Operation.shared.isSave = nil
                NotificationCenter.default.post(name: Notification.Name.didInputData, object: nil)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
