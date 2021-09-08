//
//  MoreTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import UIKit
import MessageUI


class MoreTableViewController: UITableViewController {
    
    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "메일을 전송 실패", message: "아이폰 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) {
            (action) in
        }
        sendMailErrorAlert.addAction(confirmAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.largeTitleTextAttributes = UIFont().largeAggroNavigationFont
        self.navigationController?.navigationBar.titleTextAttributes = UIFont().generalAggroNavigationFont
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame.size.width = tableView.frame.size.width
        view.backgroundColor = UIColor.systemGray6
        
        return view
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
       return 30
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "안내", message: "공지사항이 없습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                okAction.setValue(UIColor.lightBlueGreen, forKey: "titleTextColor")
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            } else if indexPath.row == 3 {
                if MFMailComposeViewController.canSendMail() {
                    let compseVC = MFMailComposeViewController()
                    compseVC.mailComposeDelegate = self
                    compseVC.setToRecipients(["cavok00.info@gmail.com"])
                    self.present(compseVC, animated: true, completion: nil)
                }
                else {
                    self.showSendMailErrorAlert()
                }
            }
        case 1:
            let alert = UIAlertController(title: "안내", message: "모든 데이터를 삭제하시겠습니까?\n삭제한 데이터는 복구가 불가능합니다.", preferredStyle: .alert)
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
            cancelAction.setValue(UIColor.lightBlueGreen, forKey: "titleTextColor")
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MoreTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

