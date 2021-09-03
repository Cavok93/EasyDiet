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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.systemBackground
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch  section {
        case 0:
            return "기본정보"
        case 1:
            return "문서"
        case 2:
            return "데이터"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "안내", message: "공지사항이 없습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        case 1:
            print()
        case 2:
            let alert = UIAlertController(title: "안내", message: "모든 데이터를 삭제하시겠습니까?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "삭제", style: .default) { _ in
                DataManager.shared.batchDelete()
                Operation.shared.isSave = nil
                UserDefaults.standard.set(nil, forKey: GraphTableViewController.goalKey)
                UserDefaults.standard.set(nil, forKey: HomeTableViewController.firstWeekDayKey)
                NotificationCenter.default.post(name: Notification.Name.didInputData, object: nil)
                NotificationCenter.default.post(name: Notification.Name.didInputFirstWeekDay, object: nil)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            okAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

