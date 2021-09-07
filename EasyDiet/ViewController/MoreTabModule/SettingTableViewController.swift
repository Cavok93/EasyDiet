//
//  SettingTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/02.
//

import UIKit

extension Notification.Name {
    static let didInputFirstWeekDay = Notification.Name("didInputFirstWeekDay")
}


class SettingTableViewController: UITableViewController {
    
    var date = Date()
    var selectedRow: Int = 0
    
    @IBOutlet weak var calendarStartWeakField: CustomField!
    @IBOutlet weak var calendarStartWeekLabel: UILabel!
    
    
    private func configurePicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        calendarStartWeakField.inputView = pickerView
        let toolBar = UIToolbar()
        toolBar.frame.size.width = tableView.frame.width
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self , action: #selector(afterCanceled))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let centerTitleButton = UIBarButtonItem(title: "[시작 요일 선택]", style: .plain, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(afterSelected))
        cancelButton.tintColor = UIColor.lightBlueGreen
        doneButton.tintColor = UIColor.lightBlueGreen
        centerTitleButton.isEnabled = false
        centerTitleButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor.black], for: .disabled)
  
        toolBar.setItems([cancelButton, flexibleSpace, centerTitleButton,  flexibleSpace, doneButton], animated: false )
        toolBar.isUserInteractionEnabled = true
        toolBar.updateConstraintsIfNeeded()
        calendarStartWeakField.inputAccessoryView = toolBar
    }
    
    @objc private func afterSelected() {
        calendarStartWeekLabel.text = date.returnAllWeeks[selectedRow]
        UserDefaults.standard.set(UInt(selectedRow+1), forKey: HomeTableViewController.firstWeekDayKey)
        NotificationCenter.default.post(name: Notification.Name.didInputFirstWeekDay, object: nil)
        calendarStartWeakField.resignFirstResponder()
        showToast(message: "수정되었습니다.")
    }
    
    @objc private func afterCanceled() {
        calendarStartWeakField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePicker()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20 )
        tableView.tableFooterView = UIView(frame: .zero)
        let today = Date()
        if let firstWeekDay = UserDefaults.standard.object(forKey: HomeTableViewController.firstWeekDayKey) as? UInt {
            calendarStartWeekLabel.text =  today.returnAllWeeks[Int(firstWeekDay-1)]
        } else {
            calendarStartWeekLabel.text = today.returnAllWeeks.first
            
        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
  
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let nsStr = textField.text as NSString? else {  return false }
        let finalText = nsStr.replacingCharacters(in: range, with: string)
        if finalText.hasPrefix(" ") { return false }
        if let finalInt = Int16(finalText), finalInt > 250 { return false}
        if finalText.count > 5 { return false}
        return true
    }
}

extension SettingTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return date.returnAllWeeks.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return date.returnAllWeeks[row]
    }
}

extension SettingTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}

