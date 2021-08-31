//
//  GraphTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import UIKit
import Charts




class GraphTableViewController: UITableViewController {
    
    private var lineChartViewInitialOriginY: CGFloat = 0.0
    var diaries = [DiaryEntity]()
    var entries = [ChartDataEntry]()
    private var token:  NSObjectProtocol?
    private var dataSet: LineChartDataSet?
    private var customMarkerView: CustomMarkerView?
    
    @IBOutlet weak var currentDatLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var dateSementControl: UISegmentedControl!
    
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
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.setLabelCount(8, force: true)
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.xAxis.labelTextColor = .black
        lineChartView.xAxis.axisLineColor = .systemBlue
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.granularity = 1.0
        
        customMarkerView = CustomMarkerView()
        customMarkerView?.chartView = lineChartView
        lineChartView.marker = customMarkerView
        
        currentDatLabel.text = Date().sectionFormatter
    }
    
    private func setData(_ yValues: [ChartDataEntry]) {
        var result = yValues
        var referenceTimeInterval: TimeInterval = 0
        if let minTimeInterval = (diaries.map { $0.date?.timeIntervalSince1970 ?? 0.0 }).min() {
                referenceTimeInterval = minTimeInterval
            }
        let xValuesFormatter = DateFormatter()
        xValuesFormatter.dateFormat = "d일"
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: xValuesFormatter)
        xValuesNumberFormatter.dateFormatter = xValuesFormatter
        lineChartView.xAxis.valueFormatter = xValuesNumberFormatter
        result =  diaries.map { (diary: DiaryEntity) -> ChartDataEntry  in
            return  ChartDataEntry(x: ((diary.date?.timeIntervalSince1970 ?? 0.0) - referenceTimeInterval) / (3600.0 * 24.0) , y:  Double(diary.weight))
        }
        let maxY = diaries.max { $0.weight < $1.weight }
        let yAxis = lineChartView.leftAxis
        yAxis.axisMaximum = Double(maxY?.weight ?? 0.0) + Double(20.0)
        yAxis.axisMinimum = 0.0
        
        dataSet = LineChartDataSet(entries: result, label: "몸무게")
        dataSet?.mode = .linear
        dataSet?.lineWidth = 4
        dataSet?.setColor(.systemBlue)
        dataSet?.fill = Fill(color: UIColor.lightSky)
        dataSet?.fillAlpha = 0.8
        dataSet?.drawFilledEnabled = true
        dataSet?.drawHorizontalHighlightIndicatorEnabled = false
        dataSet?.highlightColor = .systemRed
        dataSet?.highlightLineWidth = 1.0
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        let ll = ChartLimitLine(limit: 10.0, label: "타겟")
        lineChartView.leftAxis.addLimitLine(ll)
        lineChartView.data = data
    }
    
    @IBAction func changeDateSement(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("1주")
        case 1:
            print("1달")
        case 2:
            print("3개월")
        case 3:
            print("6개월")
        case 4:
            print("1년")
        case 5:
            print("2년")
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("섹션 갯수: ",tableView.numberOfSections)
        if tableView.backgroundView != nil {
            print("백그라운드 뷰 있다 ")
        } else if tableView.backgroundView == nil {
            print("백그라운드 뷰 없다 ")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
        token = NotificationCenter.default.addObserver(forName: Notification.Name.didInputData, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let strongSelf = self else { return }
            strongSelf.diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
            strongSelf.setData(strongSelf.entries)
            strongSelf.tableView.reloadData()
        }
        configureTableView()
        configureLineChartView()
        setData(entries)
     
    }
    
    private func configureTableView() {
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
            return 0
        } else {
            self.tableView.separatorStyle = .singleLine
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
        currentDatLabel.text = diaries[entryIndex].date?.sectionFormatter
        customMarkerView?.weightLabel.text = "\(diaries[entryIndex].weight)kg"
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        print(#function)
    }
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        print(#function)
    }
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        print(#function)
    }
    func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator) {
        print(#function)
    }
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
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

        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }

}
