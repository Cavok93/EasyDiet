//
//  GraphTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import UIKit
import Charts

class GraphTableViewController: UITableViewController {
    enum State {
        case isOn
        case isOff
        var image: UIImage {
            switch self {
            case .isOn:
                return UIImage(systemName: "sun.max.fill") ?? UIImage()
            case .isOff:
                return UIImage(systemName: "sun.max") ?? UIImage()
            }
        }
    }
    
    var diaries = [DiaryEntity]()
    var selectedRow = 0
    var entries = [ChartDataEntry]()
    private var token: NSObjectProtocol?
    private var dataSet: LineChartDataSet?
    private var customMarkerView: CustomMarkerView?
    private var goalLine: ChartLimitLine?
    static let goalKey = "goalKey"
    
    @IBOutlet weak var goalWeighAlphaControllButton: UIButton!
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
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self , action: #selector(afterCanceled))
        cancelButton.tintColor = UIColor.lightBlueGreen
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let centerTitleButton = UIBarButtonItem(title: "[등록된 날짜]", style: .plain, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(afterSelected))
        doneButton.tintColor = UIColor.lightBlueGreen
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
        calculatedWeightLabel.textColor = calculatedWeight <= 0 ? UIColor.black : UIColor.lightGray
    }
    
    private func configureLineChartView() {
        lineChartView.delegate = self
        lineChartView.backgroundColor = .systemBackground
        lineChartView.scaleYEnabled = false
        
        lineChartView.leftAxis.setLabelCount(10, force: false)
        lineChartView.leftAxis.labelFont = UIFont(name: "OTSBAggroL", size: 10) ?? UIFont()
        lineChartView.leftAxis.labelTextColor = .black
        lineChartView.leftAxis.axisLineColor = .lightGray
        lineChartView.leftAxis.labelPosition = .outsideChart
        lineChartView.leftAxis.drawBottomYLabelEntryEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawZeroLineEnabled = false
        
        
        
        
        
        
        
        
        
//        lineChartView.drawBordersEnabled = true
//        lineChartView.borderLineWidth = 0.5
//        lineChartView.borderColor = UIColor.lightGray
//        lineChartView.backgroundColor = UIColor.
        lineChartView.rightAxis.enabled = true
        lineChartView.rightAxis.gridColor = UIColor.clear
        lineChartView.rightAxis.labelTextColor = .clear
        lineChartView.rightAxis.axisLineColor = .lightGray
        lineChartView.setViewPortOffsets(left: 32, top: 20, right: 32, bottom: 32)

        
        lineChartView.legend.form = .none
        lineChartView.xAxis.drawGridLinesEnabled = true //MARK: 수박
        lineChartView.xAxis.setLabelCount(9, force: true) //MARK: true
        lineChartView.xAxis.labelFont = UIFont(name: "OTSBAggroM", size: 10) ?? UIFont()
        lineChartView.xAxis.labelTextColor = .black
        lineChartView.xAxis.axisLineColor = .clear
        lineChartView.xAxis.labelPosition = .bottom
        

        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1.0
        
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
        
        let sortedByMaxWeightEntries = entries.sorted {  $0.y < $1.y  }
        
        let maximumWeight = sortedByMaxWeightEntries.last?.y ?? 0.0
        let minimumWeight = 0
        
        let savedFirstDateXpoint = entries.first?.x ?? 0.0
        let savedLastDateXpoint = entries.last?.x ?? 0.0
        
        let savedFirstWeightYpoint = entries.first?.y ?? 0.0
        let savedLastWeightYpoint = entries.last?.y ?? 0.0
        
        lineChartView.leftAxis.axisMaximum = Double(maximumWeight) + Double(20.0)
        lineChartView.leftAxis.axisMinimum = Double(minimumWeight)
        
        lineChartView.xAxis.axisMinimum = savedFirstDateXpoint - marginDate
        lineChartView.xAxis.axisMaximum = savedLastDateXpoint + marginDate
        
        calculateWeight(Float32(savedFirstWeightYpoint), Float32(savedLastWeightYpoint))
        
        dateLabel.text = diaries.last?.date?.dateDotFormatter
        standardDateLabel.text = diaries.first?.date?.fullDateFormatter
        
        dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet?.mode = .linear
        
        
        dataSet?.lineWidth = 4
        dataSet?.setColor(.lightBlueGreen)
        dataSet?.circleHoleColor = UIColor.white
        dataSet?.setCircleColor(UIColor.lightBlueGreen)
        dataSet?.fill = Fill(color: UIColor.clear)
        dataSet?.fillAlpha = 0.8
        dataSet?.drawFilledEnabled = true
        dataSet?.drawHorizontalHighlightIndicatorEnabled = false
        dataSet?.drawVerticalHighlightIndicatorEnabled = false
        dataSet?.highlightLineWidth = 1.0
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        lineChartView.data = data
        
        let hightlight = Highlight(x: savedLastDateXpoint, y: 0, dataSetIndex: 0)
        lineChartView.highlightValue(hightlight)
        customMarkerView?.weightLabel.text = "\(Float32(savedLastWeightYpoint))kg"
        lineChartView.zoomAndCenterViewAnimated(scaleX: (CGFloat(lineChartView.xAxis.axisRange) / CGFloat(marginDate)), scaleY: 0, xValue:  savedLastDateXpoint, yValue: 0, axis: .left, duration: 0.4)
        
        if let goalWeightValue = UserDefaults.standard.object(forKey: GraphTableViewController.goalKey) as? Double {
            if goalWeightValue > maximumWeight {
                print("if", maximumWeight)
                lineChartView.leftAxis.axisMaximum = goalWeightValue + Double(20)
            } else if goalWeightValue <= maximumWeight {
                print("else", maximumWeight)
                lineChartView.leftAxis.axisMaximum = Double(maximumWeight) + Double(20)
            }
            
            goalLine = nil
            lineChartView.leftAxis.removeAllLimitLines()
            goalLine = ChartLimitLine(limit: goalWeightValue, label: "목표 체중: \(goalWeightValue)kg")
            goalLine?.lineColor = UIColor.lightBlueGreen
            goalLine?.valueTextColor = UIColor.lightBlueGreen
            goalLine?.valueFont = UIFont(name: "OTSBAggroL", size: 11.0) ?? UIFont()
            goalLine?.lineDashLengths = [5]
            lineChartView.leftAxis.addLimitLine(goalLine ?? ChartLimitLine())
            goalWeighAlphaControllButton.setImage(State.isOn.image, for: .normal)
        } else {
            goalLine = nil
            lineChartView.leftAxis.removeAllLimitLines()
            goalWeighAlphaControllButton.setImage(State.isOff.image, for: .normal)
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
        customMarkerView?.weightLabel.text = "\(Float32(selectedWeightYpoint))kg"
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
            nameField.font = UIFont(name: "OTSBAggroM", size: 13.0)
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
                strongSelf.goalLine?.lineColor = UIColor.lightBlueGreen
                strongSelf.goalLine?.valueTextColor = UIColor.lightBlueGreen
                strongSelf.goalLine?.valueFont = UIFont(name: "OTSBAggroL", size: 11.0) ?? UIFont()
                strongSelf.goalLine?.lineDashLengths = [5]
                strongSelf.lineChartView.leftAxis.addLimitLine(strongSelf.goalLine ?? ChartLimitLine())
                strongSelf.goalWeighAlphaControllButton.setImage(State.isOn.image, for: .normal)
                
                let maxY = strongSelf.diaries.max { $0.weight < $1.weight }
                if goalWeightValue > Double(maxY?.weight ?? Float32()) {
                    strongSelf.lineChartView.leftAxis.axisMaximum = goalWeightValue + Double(20)
                } else {
                    strongSelf.lineChartView.leftAxis.axisMaximum = Double(maxY?.weight ?? 0.0) + Double(20)
                }
                strongSelf.lineChartView.data?.notifyDataChanged()
                strongSelf.lineChartView.notifyDataSetChanged()
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.lightBlueGreen, forKey: "titleTextColor")
        okAction.setValue(UIColor.lightBlueGreen, forKey: "titleTextColor")
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
    
    
    @IBAction func showOrHideHighlightLine(_ sender: Any) {
        if goalWeighAlphaControllButton.image(for: .normal) == State.isOff.image {
            goalWeighAlphaControllButton.setImage(State.isOn.image, for: .normal)
            goalLine?.valueTextColor = UIColor.lightBlueGreen
            goalLine?.lineColor = UIColor.lightBlueGreen
        } else if goalWeighAlphaControllButton.image(for: .normal) == State.isOn.image  {
            goalWeighAlphaControllButton.setImage(State.isOff.image, for: .normal)
            goalLine?.valueTextColor = UIColor.clear
            goalLine?.lineColor  = UIColor.clear
        } else {
            return
        }
        lineChartView.notifyDataSetChanged()
        tableView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        informationView.layer.shadowColor = UIColor.black.cgColor
        informationView.layer.shadowOffset = CGSize(width: 0, height: 0)
        informationView.layer.cornerRadius = 12
        informationView.layer.shadowRadius = 12
        informationView.layer.shadowOpacity = 0.12
        informationView.layer.masksToBounds = false
        informationView.layer.shadowPath = UIBezierPath(roundedRect: informationView.bounds , cornerRadius: informationView.layer.cornerRadius).cgPath
        dateLabel.layer.cornerRadius = 10
        dateLabel.layer.borderWidth = 2.0
        dateLabel.layer.borderColor = UIColor.lightBlueGreen.cgColor
        dateLabel.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.largeTitleTextAttributes = UIFont().largeAggroNavigationFont
        self.navigationController?.navigationBar.titleTextAttributes = UIFont().generalAggroNavigationFont
        let selectedSegFont = UIFont(name: "OTSBAggroM", size: 13.0)
        let normalSegFont = UIFont(name: "OTSBAggroM", size: 13.0)
        dateSementControl.setTitleTextAttributes([NSAttributedString.Key.font: selectedSegFont ?? UIFont(),NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        dateSementControl.setTitleTextAttributes([NSAttributedString.Key.font: normalSegFont ?? UIFont(),NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        diaries = DataManager.shared.fetchDiaryEntity()
        token = NotificationCenter.default.addObserver(forName: Notification.Name.didInputData, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let strongSelf = self else { return }
            strongSelf.diaries = DataManager.shared.fetchDiaryEntity()
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
            let attrs1 = [NSAttributedString.Key.font : UIFont(name: "OTSBAggroM", size: 20), NSAttributedString.Key.foregroundColor : UIColor.black]
            let attrs2 = [NSAttributedString.Key.font : UIFont(name: "OTSBAggroL", size: 17.0), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            
            let attributedString1 = NSMutableAttributedString(string:"그래프가 필요하신가요?\n", attributes:attrs1 as [NSAttributedString.Key : Any])
            let attributedString2 = NSMutableAttributedString(string:"신체정보를 등록해보세요.", attributes:attrs2 as [NSAttributedString.Key : Any])
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
            goalWeightSettingButton.tintColor = UIColor.lightBlueGreen
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
        customMarkerView?.weightLabel.text = "\(Float32(diaries[entryIndex].weight))kg"
        let seletedWeight = diaries[entryIndex].weight
        let initialWeight = diaries.first?.weight ?? 0.0
        calculateWeight(initialWeight, seletedWeight)
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


