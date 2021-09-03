//
//  GraphTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import UIKit
import Charts




class GraphTableViewController: UITableViewController {
    
    var diaries = [DiaryEntity]()
    var selectedRow = 0
    var entries = [ChartDataEntry]()
    private var token: NSObjectProtocol?
    private var dataSet: LineChartDataSet?
    private var customMarkerView: CustomMarkerView?
    private var goalLine: ChartLimitLine?
    static let goalKey = "goalKey"
    
    @IBOutlet weak var goalWeightSettingButton: UIBarButtonItem!
    @IBOutlet weak var standardDateLabel: UILabel!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var dateField: CustomField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calculatedWeightLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var dateSementControl: UISegmentedControl!
    
    private func configurePicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        dateField.inputView = pickerView
        let toolBar = UIToolbar()
        toolBar.frame.size.width = tableView.frame.width
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self , action: #selector(afterCanceled))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let centerTitleButton = UIBarButtonItem(title: "[등록된 날짜]", style: .plain, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(afterSelected))
        centerTitleButton.isEnabled = false
        centerTitleButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor.black], for: .disabled)
        
        toolBar.setItems([cancelButton, flexibleSpace, centerTitleButton,  flexibleSpace, doneButton], animated: false )
        toolBar.isUserInteractionEnabled = true
        toolBar.updateConstraintsIfNeeded()
        dateField.inputAccessoryView = toolBar
    }
    
    private func calculateWeight(_ initialValue: Float32, _ selectedValue: Float32 ) {
        let initialWeight = initialValue
        let seletedWeight = selectedValue
        let calculatedWeight = (initialWeight - seletedWeight) * -1
        var op = ""
        op = calculatedWeight <= 0 ? "-" : "+"
        calculatedWeightLabel.text = "\(op) \(calculatedWeight.decimalFormatter)kg"
        calculatedWeightLabel.textColor = calculatedWeight <= 0 ? UIColor.systemBlue : UIColor.systemRed
    }
    
    private func configureLineChartView() {
        lineChartView.delegate = self
        lineChartView.backgroundColor = .systemBackground
        lineChartView.scaleYEnabled = false
        
        lineChartView.leftAxis.setLabelCount(10, force: false)
        lineChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.leftAxis.labelTextColor = .black
        lineChartView.leftAxis.axisLineColor = .systemBlue
        lineChartView.leftAxis.labelPosition = .outsideChart
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawBottomYLabelEntryEnabled = false
        
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1.0
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.setLabelCount(9, force: true)
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.xAxis.labelTextColor = .black
        lineChartView.xAxis.axisLineColor = .systemBlue
        lineChartView.xAxis.labelPosition = .bottom
        
        customMarkerView = CustomMarkerView()
        customMarkerView?.chartView = lineChartView
        lineChartView.marker = customMarkerView
    }
    
    private func setData(formatter: String, marginDate: Double) {
        var referenceTimeInterval: TimeInterval = 0
        if let minTimeInterval = (diaries.map { $0.date?.timeIntervalSince1970 ?? 0.0 }).min() {
            referenceTimeInterval = minTimeInterval
        }
        
        let xValuesFormatter = DateFormatter()
        xValuesFormatter.dateFormat = formatter
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: xValuesFormatter)
        xValuesNumberFormatter.dateFormatter = xValuesFormatter
        lineChartView.xAxis.valueFormatter = xValuesNumberFormatter
        entries =  diaries.map { (diary: DiaryEntity) -> ChartDataEntry  in
            return  ChartDataEntry(x: ((diary.date?.timeIntervalSince1970 ?? 0.0) - referenceTimeInterval) / (1.day) , y:  Double(diary.weight))
        }
        //MARK: 여기까지 시간 기준 x, y축 정렬 완료
        
        let sortedByMaxWeightEntries = entries.sorted {  $0.y < $1.y  }
        //MARK: 여기 까지 y축을 그리기 위해서 몸무게 최댓값 도출 (최대 최소 값 표현용 entries)
        
        let maximumWeight = sortedByMaxWeightEntries.last?.y ?? 0.0 //MARK: 최대 몸무게
        let minimumWeight = 0 //MARK: 최소 몸무게
        //MARK: 여기까지 y축 최대값 값 고정
        
        
        let savedFirstDateXpoint = entries.first?.x ?? 0.0//MARK: 저장된 첫번째 시간
        let savedLastDateXpoint = entries.last?.x ?? 0.0 //MARK: 저장된 마지막 시간
        
        let savedFirstWeightYpoint = entries.first?.y ?? 0.0 //MARK: 저장된 첫번째 몸무게
        let savedLastWeightYpoint = entries.last?.y ?? 0.0 //MARK: 저장된 마지막 몸무게
        
        lineChartView.leftAxis.axisMaximum = Double(maximumWeight) + Double(20.0)
        lineChartView.leftAxis.axisMinimum = Double(minimumWeight)
        
        
        lineChartView.xAxis.axisMinimum = savedFirstDateXpoint - marginDate
        lineChartView.xAxis.axisMaximum = savedLastDateXpoint + marginDate
        
        calculateWeight(Float32(savedFirstWeightYpoint), Float32(savedLastWeightYpoint))
        
        dateLabel.text = diaries.last?.date?.dateDotFormatter
        standardDateLabel.text = diaries.first?.date?.fullDateFormatter
        
        dataSet = LineChartDataSet(entries: entries, label: "몸무게")
        dataSet?.mode = .linear
        dataSet?.lineWidth = 4
        dataSet?.setColor(.systemBlue)
        dataSet?.fill = Fill(color: UIColor.lightSky)
        dataSet?.fillAlpha = 0.8
        dataSet?.drawFilledEnabled = true
        dataSet?.drawHorizontalHighlightIndicatorEnabled = false
        dataSet?.highlightColor = UIColor.systemBlue
        dataSet?.highlightLineWidth = 1.0
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        lineChartView.data = data
        
        let hightlight = Highlight(x: savedLastDateXpoint, y: 0, dataSetIndex: 0)
        lineChartView.highlightValue(hightlight)
        customMarkerView?.weightLabel.text = "\(maximumWeight)kg"
        lineChartView.zoomAndCenterViewAnimated(scaleX: (CGFloat(lineChartView.xAxis.axisRange) / CGFloat(marginDate)), scaleY: 0, xValue:  savedLastDateXpoint, yValue: 0, axis: .left, duration: 0.4)
        
        if let goalWeightValue = UserDefaults.standard.object(forKey: GraphTableViewController.goalKey) as? Double {
            if goalWeightValue > maximumWeight {
                lineChartView.leftAxis.axisMaximum = goalWeightValue + Double(20)
            } else  {
                lineChartView.leftAxis.axisMaximum = Double(maximumWeight) + Double(20)
            }
            goalLine = ChartLimitLine(limit: goalWeightValue, label: "목표 체중: \(goalWeightValue)kg")
            goalLine?.lineColor = UIColor.darkGray
            goalLine?.valueTextColor = UIColor.darkGray
            goalLine?.valueFont = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
            goalLine?.lineDashLengths = [5]
            lineChartView.leftAxis.addLimitLine(goalLine ?? ChartLimitLine())
        } else {
            print("goalLine = nil")
            goalLine = nil
            lineChartView.leftAxis.removeAllLimitLines()
            return
        }
    }
    
    private func selectedPickerViewRow(row: Int) {
        let selectedDateXpoint = entries[row].x
        let selectedWeightYpoint = entries[row].y
        let savedFirstWeightYpoint = entries.first?.y ?? 0.0
        dateLabel.text = diaries[row].date?.dateDotFormatter
        calculateWeight(Float32(savedFirstWeightYpoint), Float32(selectedWeightYpoint))
        let hightlight = Highlight(x: selectedDateXpoint, y: Double.nan, dataSetIndex: 0)
        lineChartView.highlightValue(hightlight)
        customMarkerView?.weightLabel.text = "\(selectedWeightYpoint)kg"
        lineChartView.zoomAndCenterViewAnimated(scaleX: (CGFloat(lineChartView.xAxis.axisRange) / 7), scaleY: 0, xValue:  selectedDateXpoint , yValue: 0, axis: .left, duration: 0.4)
        dateSementControl.selectedSegmentIndex = 0
    }
    
    @objc private func afterSelected() {
        selectedPickerViewRow(row: selectedRow)
        dateField.resignFirstResponder()
    }
    
    @objc private func afterCanceled() {
        dateField.resignFirstResponder()
    }
    
    @IBAction func saveGoalWeight(_ sender: Any) {
        let alert = UIAlertController(title: "목표 체중", message: "목표 체중을 등록하세요.", preferredStyle: .alert)
        alert.addTextField { nameField in
            nameField.delegate = self
            nameField.placeholder = "체중"
            nameField.keyboardType = .decimalPad
        }
        var title: String?
        if let _ = UserDefaults.standard.object(forKey: GraphTableViewController.goalKey) as? Double {
            title = "수정"
        } else {
            title = "저장"
        }
        let okAction = UIAlertAction(title: title, style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            if let goalWeightStr = alert.textFields?.first?.text, goalWeightStr.count > 0, let goalWeightValue = Double(goalWeightStr) {
                UserDefaults.standard.set(goalWeightValue ,forKey: GraphTableViewController.goalKey)
                strongSelf.lineChartView.leftAxis.removeAllLimitLines()
                strongSelf.goalLine = ChartLimitLine(limit: goalWeightValue, label: "목표 체중: \(goalWeightValue)kg")
                strongSelf.goalLine?.lineColor = UIColor.darkGray
                strongSelf.goalLine?.valueTextColor = UIColor.darkGray
                strongSelf.goalLine?.valueFont = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
                strongSelf.goalLine?.lineDashLengths = [5]
                strongSelf.lineChartView.leftAxis.addLimitLine(strongSelf.goalLine ?? ChartLimitLine())
                
                if goalWeightValue > Double(strongSelf.diaries.last?.weight ?? 0.0) {
                    strongSelf.lineChartView.leftAxis.axisMaximum = goalWeightValue + Double(20)
                } else {
                    let maxY = strongSelf.diaries.max { $0.weight < $1.weight }
                    strongSelf.lineChartView.leftAxis.axisMaximum = Double(maxY?.weight ?? 0.0) + Double(20)
                }
                strongSelf.lineChartView.data?.notifyDataChanged()
                strongSelf.lineChartView.notifyDataSetChanged()
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeDateSement(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setData(formatter: "d일" , marginDate: 7)
        case 1:
            setData(formatter: "d일", marginDate: 30)
        case 2:
            setData(formatter: "M월", marginDate: 90)
        case 3:
            setData(formatter: "M월", marginDate: 180)
        case 4:
            setData(formatter: "yy년", marginDate: 365)
        case 5:
            setData(formatter: "yy년", marginDate: 730)
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        informationView.layer.shadowColor = UIColor.black.cgColor
        informationView.layer.shadowOffset = CGSize(width: 0, height: 0)
        informationView.layer.cornerRadius = 12
        informationView.layer.shadowRadius = 12
        informationView.layer.shadowOpacity = 0.12
        informationView.layer.masksToBounds = false
        informationView.layer.shadowPath = UIBezierPath(roundedRect: self.informationView.bounds, cornerRadius: informationView.layer.cornerRadius).cgPath
        
        dateLabel.layer.cornerRadius = 10
        dateLabel.layer.borderWidth = 1.0
        dateLabel.layer.borderColor = UIColor.lightGray.cgColor
        dateLabel.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
        token = NotificationCenter.default.addObserver(forName: Notification.Name.didInputData, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let strongSelf = self else { return }
            strongSelf.diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
            strongSelf.setData(formatter: "d일", marginDate: 7)
            strongSelf.dateSementControl.selectedSegmentIndex = 0
            strongSelf.lineChartView.data?.notifyDataChanged()
            strongSelf.lineChartView.notifyDataSetChanged()
            strongSelf.tableView.reloadData()
        }
        
        
        configureTableView()
        configureLineChartView()
        configurePicker()
        setData(formatter: "d일", marginDate: 7)
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if diaries.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.numberOfLines = 0
            let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0, weight: .bold), NSAttributedString.Key.foregroundColor : UIColor.black]
            let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0, weight: .medium), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let attributedString1 = NSMutableAttributedString(string:"그래프가 필요하신가요?\n", attributes:attrs1)
            let attributedString2 = NSMutableAttributedString(string:"신체정보를 등록해보세요.", attributes:attrs2)
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.lineSpacing = 6
            style.minimumLineHeight = 3
            attributedString1.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attrs1.count))
            attributedString1.append(attributedString2)
            emptyLabel.attributedText = attributedString1
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            goalWeightSettingButton.isEnabled = false
            goalWeightSettingButton.tintColor = UIColor.clear
            return 0
        } else {
            self.tableView.separatorStyle = .singleLine
            goalWeightSettingButton.isEnabled = true
            goalWeightSettingButton.tintColor = UIColor.systemBlue
            tableView.backgroundView = nil
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

extension GraphTableViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
        let entryIndex = dataSet.entryIndex(entry: entry)
        dateLabel.text = diaries[entryIndex].date?.dateDotFormatter
        customMarkerView?.weightLabel.text = "\(diaries[entryIndex].weight)kg"
        let seletedWeight = diaries[entryIndex].weight
        let initialWeight = diaries.first?.weight ?? 0.0
        calculateWeight(initialWeight, seletedWeight)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print(#function)
    }
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        print(#function)
    }
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        //        print(#function, dX, dY)
        
    }
    func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator) {
        print(#function)
    }
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        let range = lineChartView.xAxis.axisRange
        let xAxisScale = lineChartView.scaleX
        if xAxisScale  >= (CGFloat(range) / 7) {
            dateSementControl.selectedSegmentIndex = 0
        } else if xAxisScale >= (CGFloat(range) / 30) {
            dateSementControl.selectedSegmentIndex = 1
        } else if xAxisScale >= (CGFloat(range) / 90) {
            dateSementControl.selectedSegmentIndex = 2
        } else if xAxisScale >= (CGFloat(range) / 180) {
            dateSementControl.selectedSegmentIndex = 3
        } else if xAxisScale >= (CGFloat(range) / 365) {
            dateSementControl.selectedSegmentIndex = 4
        } else if xAxisScale >= (CGFloat(range) / 730) {
            dateSementControl.selectedSegmentIndex = 5
        } else {
            return
        }
    }
    
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceTimeInterval: TimeInterval?
    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
              let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }
        let date = Date(timeIntervalSince1970: value * 1.day + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }
    
}

extension GraphTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let nsStr = textField.text as NSString? else {  return false }
        let finalText = nsStr.replacingCharacters(in: range, with: string)
        if finalText.hasPrefix(" ") { return false }
        if let finalInt = Int16(finalText), finalInt > 250 { return false}
        if finalText.count > 5 { return false}
        return true
    }
}

extension GraphTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return diaries.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return diaries[row].date?.dateDotFormatter
    }
}

extension GraphTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}



class CustomField: UITextField {
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:))
            || action == #selector(UIResponderStandardEditActions.cut(_:))
            || action ==  #selector(UIResponderStandardEditActions.copy(_:))
            || action ==  #selector(UIResponderStandardEditActions.select(_:))
            || action == #selector(UIResponderStandardEditActions.selectAll(_:))
            || action == #selector(UIResponderStandardEditActions.delete(_:))
            || action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight(_:))
            || action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft(_:))
            || action == #selector(UIResponderStandardEditActions.toggleBoldface(_:))
            || action == #selector(UIResponderStandardEditActions.toggleItalics(_:))
            || action == #selector(UIResponderStandardEditActions.toggleUnderline(_:))
            || action == #selector(UIResponderStandardEditActions.increaseSize(_:))
            || action == #selector(UIResponderStandardEditActions.decreaseSize(_:)) {
                return false
            }
            return super.canPerformAction(action, withSender: sender)
        }
}
