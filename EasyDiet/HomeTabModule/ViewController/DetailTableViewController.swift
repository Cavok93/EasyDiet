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
    var date: Date?
    
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var listTextView: UITextView!
    
    
    
    @IBAction func saveContents(_ sender: Any) {
        guard let date = date  else { fatalError() }
        guard let heightStr = heightField.text, heightStr.count > 0, let heightNum = Float32(heightStr) else { return }
        guard let weightStr = weightField.text, weightStr.count > 0, let weightNum = Float32(weightStr)else { return }
        guard let textViewStr = listTextView.text, textViewStr.count > 0 else { return }
        if diary == nil {
            DataManager.shared.createDiaryEntity(height: heightNum, weight: weightNum, memo: textViewStr, date: date  ,context: DataManager.shared.mainContext) {
                NotificationCenter.default.post(name: Notification.Name.didInputData, object: nil)
                self.showAlert(title: "데이터가 새로 추가됨", message: "")
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            DataManager.shared.updateDiaryEntity(context: DataManager.shared.mainContext, entity: diary ?? DiaryEntity(), height: heightNum, weight: weightNum, memo: textViewStr, date: date) {
                NotificationCenter.default.post(name: Notification.Name.didInputData, object: nil)
                self.showAlert(title: "데이터가 업데이트 됨", message: "")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelContents(_ sender: Any) {
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
    
    @objc func dismissKeyboard() {
        heightField.resignFirstResponder()
        weightField.resignFirstResponder()
        listTextView.resignFirstResponder()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let diary = diary  {
            heightField.text = "\(diary.height)"
            weightField.text = "\(diary.weight)"
            listTextView.text = diary.memo
        }
        
        self.navigationController?.navigationBar.topItem?.title = date?.sectionFormatter
        configureUI()
        heightField.becomeFirstResponder()
        self.setupHideKeyboardOnTap()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, doneButton], animated: false )
        toolBar.isUserInteractionEnabled = true
        toolBar.updateConstraintsIfNeeded()
        heightField.inputAccessoryView = toolBar
        weightField.inputAccessoryView = toolBar
        listTextView.inputAccessoryView = toolBar
        
        
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
        if let finalInt = Int16(finalText), finalInt > 300 { return false}
        if finalText.count > 5 { return false}
        return true
    }
}
