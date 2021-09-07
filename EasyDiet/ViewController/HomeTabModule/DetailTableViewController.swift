//
//  DetailTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/26.
//

import UIKit

extension Notification.Name {
    static let didInputData = Notification.Name("didInputData")
}

class DetailTableViewController: UITableViewController {
    
    static let identifier = "DetailTableViewController"
    var diary: DiaryEntity?
    var dateForTopTitle: Date?
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var listTextView: UITextView!
    
    @IBAction func saveContents(_ sender: Any) {
        guard let sortedByCalendarDate = dateForTopTitle  else { return }
        guard let heightStr = heightField.text, heightStr.count > 0, let heightNum = Float32(heightStr) else { return }
        guard let weightStr = weightField.text, weightStr.count > 0, let weightNum = Float32(weightStr)else { return }
        guard let textViewStr = listTextView.text, textViewStr.count > 0 else { return }
        if diary == nil  {
            DataManager.shared.createDiaryEntity(height: heightNum, weight: weightNum, memo: textViewStr, date: sortedByCalendarDate) {
                Operation.shared.isSave = true
                NotificationCenter.default.post(name: Notification.Name.didInputData, object: nil)
            }
        } else {
            DataManager.shared.updateDiaryEntity(entity: diary ?? DiaryEntity(), height: heightNum, weight: weightNum, memo: textViewStr, date: sortedByCalendarDate) {
                Operation.shared.isSave = false
                NotificationCenter.default.post(name: Notification.Name.didInputData, object: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureUI() {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.tableFooterView = UIView(frame: .zero)
        listTextView.delegate = self
        heightField.delegate = self
        weightField.delegate = self
        heightField.keyboardType = .decimalPad
        weightField.keyboardType = .decimalPad
        
        if listTextView.text == "" {
            listTextView.text = "메모"
            listTextView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func cancelContents(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func afterCompleted() {
        if heightField.isFirstResponder {
            heightField.resignFirstResponder()
            weightField.becomeFirstResponder()
        } else if weightField.isFirstResponder {
            weightField.resignFirstResponder()
            listTextView.becomeFirstResponder()
        } else {
            listTextView.resignFirstResponder()
        }
    }
    
    @objc private func afterCanceled() {
        if heightField.isFirstResponder {
            heightField.resignFirstResponder()
        } else if weightField.isFirstResponder {
            weightField.resignFirstResponder()
        } else {
            listTextView.resignFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 200.0
        } else {
            return tableView.estimatedRowHeight
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let diary = diary  {
            heightField.text = "\(diary.height)"
            weightField.text = "\(diary.weight)"
            listTextView.text = diary.memo
        }
        self.navigationController?.navigationBar.topItem?.title = dateForTopTitle?.removeZeroDateFormatter
        self.navigationController?.navigationBar.titleTextAttributes = UIFont().generalAggroNavigationFont
        
        configureUI()
        heightField.becomeFirstResponder()
        let toolBar = UIToolbar()
        toolBar.frame.size.width = tableView.frame.width
        toolBar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self , action: #selector(afterCanceled))
        cancelButton.tintColor = UIColor.lightBlueGreen
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.afterCompleted))
        doneButton.tintColor = UIColor.lightBlueGreen
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false )
        toolBar.isUserInteractionEnabled = true
        toolBar.updateConstraintsIfNeeded()
        heightField.inputAccessoryView = toolBar
        weightField.inputAccessoryView = toolBar
        listTextView.inputAccessoryView = toolBar
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listTextView.layer.cornerRadius = 5
        listTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.6).cgColor
        listTextView.layer.borderWidth = 0.5
        listTextView.clipsToBounds = true
    }
}

extension DetailTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "메모"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let nsStr = textView.text as NSString? else { return false}
        let finalText = nsStr.replacingCharacters(in: range, with: text)
        if finalText.hasPrefix(" ") { return false}
        return true
    }
}

extension DetailTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let nsStr = textField.text as NSString? else {  return false }
        let finalText = nsStr.replacingCharacters(in: range, with: string)
        if finalText.hasPrefix(" ") { return false }
        if let finalInt = Int16(finalText), finalInt > 250 { return false}
        if finalText.count > 5 { return false}
        return true
    }
}

